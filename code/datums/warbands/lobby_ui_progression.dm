
// stage 1 (warband selection) to stage 2 (casus belli selection)
/datum/warband_manager/proc/commit_warband_selection(mob/user, list/params)
	var/warband_path = text2path(params["warband"])
	var/datum/warbands/incoming_warband = warband_path ? SSwarbands.warband_datum_for(warband_path) : null
	if(!incoming_warband)
		to_chat(user, span_warning("Select a valid warband before advancing."))
		user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
		return

	var/datum/warbands/subtypes/incoming_subtype
	var/subtype_path = text2path(params["subtype"])
	if(subtype_path)
		var/list/compatible_subtypes = incoming_warband.subtypes.len ? incoming_warband.subtypes[1] : list()
		if(subtype_path in compatible_subtypes)
			incoming_subtype = SSwarbands.subtype_datum_for(subtype_path)
	if(incoming_warband.subtyperequired && !incoming_subtype)
		to_chat(user, span_warning("This warband requires a subtype selection."))
		user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
		return

	var/list/aspect_paths = params["aspects"]
	var/list/incoming_intensities = params["aspect_intensities"] || list()
	var/list/incoming_selection_inputs = params["selection_inputs"] || list()

	var/list/datum/warbands/aspects/incoming_aspects = list()
	var/aspect_cap = incoming_warband.max_aspects
	for(var/aspect_path in aspect_paths)
		var/aspect_type = text2path(aspect_path)
		var/datum/warbands/aspects/aspect = SSwarbands.aspect_datum_for(aspect_type)
		if(!aspect)
			continue
		if(aspect in incoming_aspects)
			continue // duplicate payload entry
		if(!(aspect_type in incoming_warband.aspects) && !(incoming_subtype && (aspect_type in incoming_subtype.aspects)))
			continue // not offered by this warband or its subtype
		var/slot_conflict = FALSE
		for(var/datum/warbands/aspects/existing in incoming_aspects)
			if(existing.asclass && aspect.asclass && existing.asclass == aspect.asclass)
				slot_conflict = TRUE
				break
		if(slot_conflict)
			continue
		if(incoming_aspects.len >= aspect_cap)
			to_chat(user, span_warning("This warband can field [aspect_cap] aspects at most."))
			break
		incoming_aspects += aspect

	var/total_points = incoming_warband.points + (incoming_subtype ? incoming_subtype.points : 0)
	for(var/datum/warbands/aspects/aspect in incoming_aspects)
		var/rank = clamp(text2num(incoming_intensities["[aspect.type]"]) || 1, 1, aspect.max_intensity)
		total_points += aspect.get_points_at_intensity(rank)
	if(total_points < 0)
		to_chat(user, span_warning("The selection's points must balance before advancing."))
		user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
		return
		
	for(var/datum/warbands/aspects/aspect in incoming_aspects)
		if(!istype(aspect, ASPECT_SPLIT))
			continue
		var/other_members = 0
		for(var/mob/living/member in lobby_members)
			if(member.mind && member.mind.special_role != ROLE_WARLORD)
				other_members++
		if(other_members < 4)
			to_chat(user, span_warning("The lobby is too small for the Divorce aspect to be taken."))
			user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
			return
		break

	for(var/datum/warbands/source in list(incoming_warband, incoming_subtype) + incoming_aspects)
		var/source_intensity = clamp(text2num(incoming_intensities["[source.type]"]) || 1, 1, source.max_intensity)
		var/missing_label = missing_required_input(source, incoming_selection_inputs["[source.type]"], source_intensity)
		if(missing_label)
			to_chat(user, span_warning("[source.title] requires '[missing_label]' to be filled in before advancing."))
			user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
			return

	// after everything's confirmed, commit the selections
	selected_warband = incoming_warband
	selected_subtype = incoming_subtype
	selected_aspects = incoming_aspects
	selection_inputs["[selected_warband.type]"] = incoming_selection_inputs["[selected_warband.type]"] || list()
	if(selected_subtype)
		selection_inputs["[selected_subtype.type]"] = incoming_selection_inputs["[selected_subtype.type]"] || list()
	for(var/datum/warbands/aspects/aspect in selected_aspects)
		var/incoming_intensity = text2num(incoming_intensities["[aspect.type]"])
		aspect_intensities["[aspect.type]"] = clamp(incoming_intensity || 1, 1, aspect.max_intensity)
		selection_inputs["[aspect.type]"] = incoming_selection_inputs["[aspect.type]"] || list()

	if(!linked_faction)
		var/datum/treaty_flavor/custom/seed_faction = new /datum/treaty_flavor/custom()
		SSwarbands.treaty_flavor_factions += seed_faction
		seed_faction.name = seed_faction.verify_faction_name("The Warband")
		linked_faction = seed_faction

	creation_stage = 2
	set_race_and_faith_locks()
	selected_subtype?.on_warband_confirmed(src)
	selected_warband?.on_warband_confirmed(src)
	for(var/datum/warbands/aspects/aspect in selected_aspects)
		aspect.on_warband_confirmed(src, aspect_intensities["[aspect.type]"] || 1)

	for(var/mob/living/carbon/human/member in lobby_members)
		var/warband_info = "<span style='color:#e8bf67'>WARBAND CHOSEN:</span> [selected_warband.title]"
		if(selected_subtype)
			warband_info += " ([selected_subtype.title])"
		if(selected_aspects.len)
			warband_info += "<br><span style='color:#e8bf67'>ASPECTS:</span>"
			for(var/datum/warbands/aspects/aspect in selected_aspects)
				warband_info += "<br>- <span style='color:#c9a347'><b>[aspect.title]</b></span>: [aspect.summary]"
		else
			warband_info += "."
		to_chat(member, span_greenteamradio(warband_info))
		to_chat(member, span_redteamradio("A Warband is chosen. But what are you fighting for? Propose a Casus Belli."))

	update_static_data_for_all_viewers()
	send_warnings()
	advance_stage_timer()

// starts finalizing a warband
/datum/warband_manager/proc/finalize_warband(mob/living/carbon/human/warlord, class_path, subclass_path, timed_out = FALSE)
	if(SSwarbands.warband_managers_busy || finalized)
		return FALSE
	SSwarbands.warband_managers_busy = TRUE
	finalization_in_progress = TRUE
	SStgui.close_user_uis(warlord)
	if(warlord in lobby_members)
		lobby_members -= warlord
	load_appearance(warlord, warlord)
	lock_check(warlord, class_path)
	stop_creation_timer()
	INVOKE_ASYNC(src, PROC_REF(finalize_warcamp), warlord, class_path, subclass_path, timed_out)
	return TRUE

/datum/warband_manager/proc/finalize_warcamp(mob/living/carbon/human/warlord, class_path, subclass_path, timed_out = FALSE)
	if(QDELETED(src))
		end_finalization()
		return
	spawn_warcamp()
	if(QDELETED(src))
		end_finalization()
		return
	complete_finalization(warlord, class_path, subclass_path, timed_out)

/datum/warband_manager/proc/complete_finalization(mob/living/carbon/human/warlord, class_path, subclass_path, timed_out = FALSE)
	if(QDELETED(src))
		end_finalization()
		return
	spawn_warband(warlord)
	set_IDs()
	if(linked_faction && !linked_faction.owner)
		linked_faction.owner = warlord.real_name
		linked_faction.name = linked_faction.verify_faction_name("[warlord.real_name]'s Warband", warlord)
	// we use "The Warband" as a placeholder flavortext faction for the UI. once we're actually in-game, we need to update it
	if(casus_belli_selection && linked_faction)
		var/real_name = linked_faction.name
		if(casus_belli_selection.target == "The Warband")
			casus_belli_selection.target = real_name
		if(casus_belli_selection.receiver == "The Warband")
			casus_belli_selection.receiver = real_name
	spawn_character(class_path, warlord, subclass_path, is_leader = 1)
	set_default_exit()
	warlord_spawned = TRUE
	finalization_in_progress = FALSE
	SSwarbands.warband_managers_busy = FALSE
	warlord.mind.warband_manager = src
	end_intro(warlord)
	update_static_data_for_all_viewers()
	addtimer(CALLBACK(src, PROC_REF(spawn_ready_members)), 30)
	finalization_announcement(timed_out)

// clears the finalization lock(s)
/datum/warband_manager/proc/end_finalization()
	if(!finalization_in_progress)
		return
	finalization_in_progress = FALSE
	SSwarbands.warband_managers_busy = FALSE

/datum/warband_manager/proc/finalization_announcement(timed_out = FALSE)
	for(var/mob/living/carbon/human/member in lobby_members)
		if(member.mind.special_role == ROLE_WARLORD_LIEUTENANT || member.mind.special_role == ROLE_WARLORD_ASPIRANT || member.mind.special_role == ROLE_WARLORD_GRUNT)
			if(timed_out)
				to_chat(member, span_boldwarning("TIME EXPIRED! The warband has been auto-finalized. You may now create your character."))
			else
				to_chat(member, span_greenteamradio("The Warlord has established the warband. You may now finalize your character."))
			member.playsound_local(member, 'sound/misc/warband/menusound3.ogg', 100, FALSE)

// spawns every member who readied up during finalization
/datum/warband_manager/proc/spawn_ready_members()
	for(var/ckey in ready_members.Copy())
		var/list/stored = ready_members[ckey]
		var/mob/living/carbon/human/member
		for(var/mob/living/lobby_mob in lobby_members)
			if(lobby_mob.ckey == ckey)
				member = lobby_mob
				break
		if(!member || !member.client)
			continue
		SStgui.close_user_uis(member)
		member.mind.warband_manager = src
		var/class_path = text2path(stored["class"])
		var/subclass_path = stored["subclass"] ? text2path(stored["subclass"]) : null
		if(!validate_class_selection(member, class_path, subclass_path)) // falls back to an auto-pick if their stored choice went stale
			var/list/auto_selection = auto_pick_class_and_subclass(member)
			class_path = auto_selection[1]
			subclass_path = auto_selection[2]
			if(!class_path)
				continue
		if(member in lobby_members)
			lobby_members -= member
		ready_members -= ckey
		load_appearance(member, member)
		lock_check(member, class_path)
		spawn_character(class_path, member, subclass_path)
		end_intro(member)
	addtimer(CALLBACK(src, PROC_REF(finalize)), 30)
	ready_members = list()
