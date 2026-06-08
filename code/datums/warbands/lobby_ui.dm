/atom/movable/screen/warband/manager/proc/create_HUD_instance(mob/user)
	for(var/atom/movable/screen/warband/manager/listed_manager in SSwarbands.warband_managers)
		if(listed_manager.warband_ID == user.mind.warband_ID)
			user.client.screen += listed_manager
			animate(listed_manager, alpha = 255, time = 800)
			break

/atom/movable/screen/warband/manager/Click()
	ui_interact(usr)

/atom/movable/screen/warband/manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WarbandCreation")
		ui.open()

/atom/movable/screen/warband/manager/ui_data(mob/user)
	var/list/data = ..()
	if(cached_remaining_time >= 0)
		data["time_remaining"] = cached_remaining_time
		data["timer_active"] = TRUE
	else
		data["time_remaining"] = 0
		data["timer_active"] = FALSE
	data["lobby_chat_muted"] = (lobby_chat_muted_until > world.time)
	data["lobby_mute_remaining"] = max(0, lobby_chat_muted_until - world.time)
	return data

/atom/movable/screen/warband/manager/ui_static_data(mob/user)
	var/list/data = ..()
	data["creation_stage"] = creation_stage
	data["warlord_spawned"] = warlord_spawned
	data["is_warlord"] = (user.mind.special_role == "Warlord")
	data["user_role"] = user.mind.special_role
	data["finalized_status"] = finalized
	populate_noble_and_ally_data(user, data)
	populate_user_data(user, data)
	populate_casus_belli_data(user, data)
	populate_faction_data(data)
	populate_storyteller_data(data)
	populate_warband_lists(data)
	populate_class_data(data)
	populate_terms_data(data)
	data["bypass_rarity"] = bypass_rarity
	static_data_set = TRUE
	return data


/atom/movable/screen/warband/manager/proc/populate_noble_and_ally_data(mob/user, list/data)
	var/list/noble_list = list()
	for(var/mob/living/carbon/human/vip in importantfigures)
		UNTYPED_LIST_ADD(noble_list, list(
			"name" = vip.real_name,
			"job" = vip.job
		))
	data["nobles"] = noble_list

	var/list/allies_list = list()
	for(var/mob/living/carbon/human/buddy in members)
		var/member_role = buddy.mind?.special_role || "Unknown"
		UNTYPED_LIST_ADD(allies_list, list(
			"name" = buddy.real_name,
			"job" = buddy.job,
			"special_role" = member_role,
			"in_lobby" = FALSE
		))
	for(var/mob/living/lobby_member in lobby_members)
		if(!lobby_member.client || !lobby_member.client.prefs)
			continue
		var/char_name = lobby_member.client.prefs.real_name
		var/member_role = lobby_member.mind?.special_role || "Unknown"
		UNTYPED_LIST_ADD(allies_list, list(
			"name" = char_name,
			"job" = member_role,
			"in_lobby" = TRUE,
			"is_ready" = (lobby_member.ckey in ready_members)
		))
	data["allies"] = allies_list

/atom/movable/screen/warband/manager/proc/populate_user_data(mob/user, list/data)
	data["user_ready"] = (user.ckey in ready_members)
	if(user.client?.prefs)
		var/datum/species/user_species = user.client.prefs.pref_species
		var/datum/patron/user_patron_datum = user.client.prefs.selected_patron
		data["user_race"] = user_species ? "[user_species.type]" : ""
		data["user_race_name"] = user_species ? user_species.name : ""
		data["user_patron"] = user_patron_datum ? "[user_patron_datum.type]" : ""
		data["user_patron_name"] = user_patron_datum ? user_patron_datum.name : ""
	else
		data["user_race"] = ""
		data["user_race_name"] = ""
		data["user_patron"] = ""
		data["user_patron_name"] = ""

/atom/movable/screen/warband/manager/proc/populate_casus_belli_data(mob/user, list/data)
	var/user_ckey = user.ckey
	var/user_proposal_id_out
	var/user_vote_id_out
	var/user_vote_confirmed_flag = FALSE
	var/warlord_selected_id
	var/list/proposals_out = list()

	for(var/list/proposal in casus_belli_proposals)
		var/list/confirmed_votes = proposal["confirmed_votes"]
		var/list/pending_votes = proposal["pending_votes"]
		var/is_user_proposal = (proposal["author"] == user_ckey)
		var/user_is_pending = (user_ckey in pending_votes)
		var/user_vote_confirmed = (user_ckey in confirmed_votes)
		var/is_user_vote = user_is_pending || user_vote_confirmed
		if(is_user_proposal)
			user_proposal_id_out = proposal["proposal_id"]
		if(is_user_vote)
			user_vote_id_out = proposal["proposal_id"]
			user_vote_confirmed_flag = user_vote_confirmed
		if(proposal["is_selected"])
			warlord_selected_id = proposal["proposal_id"]
		var/list/details = proposal["term_details"] || list()
		var/list/proposal_entry = list(
			"proposal_id" = proposal["proposal_id"],
			"term_type" = proposal["term_type"],
			"term_name" = proposal["term_name"],
			"term_desc" = proposal["term_desc"],
			"vote_count" = confirmed_votes.len,
			"pending_count" = pending_votes.len,
			"is_user_proposal" = is_user_proposal,
			"is_user_vote_confirmed" = user_vote_confirmed,
			"is_warlord_selected" = proposal["is_selected"]
		)
		var/found_term_type = text2path(proposal["term_type"])
		if(found_term_type)
			var/datum/treaty/terms/proto = new found_term_type()
			var/list/display_fields_out = list()
			for(var/datum/treaty/input_field/field in proto.input_fields)
				if(!field.client_only)
					proposal_entry["term_[field.key]"] = details[field.key]
					UNTYPED_LIST_ADD(display_fields_out, list("key" = field.key, "label" = field.label))
			proposal_entry["display_fields"] = display_fields_out
			qdel(proto)
		UNTYPED_LIST_ADD(proposals_out, proposal_entry)

	data["casus_belli_proposals"] = proposals_out
	data["user_proposal"] = user_proposal_id_out
	data["user_vote"] = user_vote_id_out
	data["user_vote_confirmed"] = user_vote_confirmed_flag
	data["warlord_selected_proposal"] = warlord_selected_id

	if(casus_belli_selection)
		var/list/casus_belli_out = list(
			"name" = casus_belli_selection.name,
			"desc" = casus_belli_selection.desc,
			"type" = "[casus_belli_selection.type]",
			"inputs" = casus_belli_selection.serialize_input_fields(),
			"display_fields" = casus_belli_selection.get_display_fields(),
			"open_signatures" = casus_belli_selection.open_signatures,
		)
		for(var/datum/treaty/input_field/field in casus_belli_selection.input_fields)
			if(!field.client_only)
				casus_belli_out[field.key] = casus_belli_selection.vars[field.key]
		data["warlord_casus_belli"] = casus_belli_out
	else
		data["warlord_casus_belli"] = null

/atom/movable/screen/warband/manager/proc/populate_faction_data(list/data)
	var/list/cb_faction_list = list()
	for(var/datum/treaty_flavor/faction in SSwarbands.treaty_flavor_factions)
		if(faction.type in DEFAULT_TREATY_FLAVOR_FACTIONS)
			UNTYPED_LIST_ADD(cb_faction_list, list(
				"name" = faction.name,
				"desc" = faction.desc,
				"vault" = faction.vault,
				"owner" = faction.owner,
				"type" = "[faction.type]",
				"icon" = ""
			))
	if(linked_faction)
		UNTYPED_LIST_ADD(cb_faction_list, list(
			"name" = linked_faction.name,
			"desc" = linked_faction.desc,
			"vault" = linked_faction.vault,
			"owner" = linked_faction.owner,
			"type" = "[linked_faction.type]",
			"icon" = ""
		))
	data["backend_factions"] = cb_faction_list

/atom/movable/screen/warband/manager/proc/populate_storyteller_data(list/data)
	if(static_data_set)
		data["backendstorytellers"] = list()
		return
	var/list/storyteller_list = list()
	for(var/datum/storyteller/storyteller in storyinfluence)
		UNTYPED_LIST_ADD(storyteller_list, list(
			"title" = storyteller.name,
			"summary" = storyteller.desc,
			"type" = storyteller.type
		))
	data["backendstorytellers"] = storyteller_list

/atom/movable/screen/warband/manager/proc/populate_class_data(list/data)
	if(!SSwarbands.cached_ui_classes)
		var/list/class_list = list()
		for(var/class_type in SSwarbands.all_warband_class_types)
			var/class_ignore_locks = FALSE
			var/class_ignores_subclass_requirement = FALSE
			var/list/class_subclass_paths = list()
			if(ispath(class_type, /datum/advclass/warband))
				class_ignore_locks = initial(class_type:ignore_locks)
				class_ignores_subclass_requirement = initial(class_type:ignores_multiclass_requirement)
				// a primary may source its subclasses from its own filepath subtypes, or from an explicit list
				if(initial(class_type:use_subclasses))
					for(var/sub_type in subtypesof(class_type))
						if(SSwarbands.all_warband_class_types[sub_type])
							class_subclass_paths += "[sub_type]"
				else
					for(var/sub_path in initial(class_type:classes))
						class_subclass_paths += "[sub_path]"
			UNTYPED_LIST_ADD(class_list, list(
				"name" = initial(class_type:title),
				"desc" = initial(class_type:tutorial),
				"alt_name" = initial(class_type:name),
				"storyinfluence" = initial(class_type:storytellerlimit),
				"rarity" = initial(class_type:rarity),
				"slots" = initial(class_type:maximum_possible_slots),
				"type" = class_type,
				"multiclass_capable" = initial(class_type:multiclass_capable),
				"ignore_locks" = class_ignore_locks,
				"ignores_multiclass_requirement" = class_ignores_subclass_requirement,
				"classes" = class_subclass_paths
			))
		SSwarbands.cached_ui_classes = class_list
	data["classes"] = SSwarbands.cached_ui_classes

/atom/movable/screen/warband/manager/proc/populate_terms_data(list/data)
	var/obj/item/treaty/temp_treaty = new /obj/item/treaty()
	if(creation_stage >= 2 && selected_warband)
		temp_treaty.add_unique_terms(src)
	var/list/all_terms_list = list()
	for(var/datum/treaty/terms/term in temp_treaty.terms)
		UNTYPED_LIST_ADD(all_terms_list, list(
			"name" = term.name,
			"desc" = term.desc,
			"hint" = term.hint,
			"open_signatures" = term.open_signatures,
			"inputs" = term.serialize_input_fields(),
			"type" = "[term.type]",
			"warbandlock" = (term.warbandlock ? "[term.warbandlock]" : null)
		))
	qdel(temp_treaty)
	data["all_terms"] = all_terms_list

/atom/movable/screen/warband/manager/proc/populate_warband_lists(list/data)
	if(!SSwarbands.warband_ui_data) // everything here is only built once, cached in the subsystem, and referenced
		var/list/warbands_list = list()
		var/list/subtypes_list = list()
		var/list/aspects_list = list()
		for(var/datum/warbands/warband in SSwarbands.all_warbands)
			var/list/entry = serialize_warband_datum(warband)
			entry["subtyperequired"] = warband.subtyperequired
			entry["subtypes"] = warband.subtypes
			entry["aspects"] = warband.aspects
			entry["multiclass_enabled"] = warband.multiclass_enabled
			entry["subclass_required"] = warband.subclass_required
			entry["subclass_label"] = warband.subclass_label
			UNTYPED_LIST_ADD(warbands_list, entry)
		for(var/datum/warbands/subtypes/subtype in SSwarbands.all_subtypes)
			var/list/entry = serialize_warband_datum(subtype)
			entry["aspects"] = subtype.aspects
			entry["quote"] = subtype.quote
			entry["quote_followup"] = subtype.quote_followup
			UNTYPED_LIST_ADD(subtypes_list, entry)
		for(var/datum/warbands/aspects/aspect in SSwarbands.all_aspects)
			var/list/entry = serialize_warband_datum(aspect)
			entry["class"] = aspect.asclass
			entry["max_intensity"] = aspect.max_intensity
			entry["intensity_costs"] = aspect.build_intensity_costs()
			UNTYPED_LIST_ADD(aspects_list, entry)
		SSwarbands.warband_ui_data = warbands_list
		SSwarbands.subtypes_ui_data = subtypes_list
		SSwarbands.aspects_ui_data = aspects_list

	data["warbands"] = SSwarbands.warband_ui_data
	data["subtypes"] = SSwarbands.subtypes_ui_data
	data["aspects"] = SSwarbands.aspects_ui_data

	// we rebuild our Actual Selected Choices (selected_warband, selected_subtype, aspects, etc) per action
	var/list/backend_warband_list = list()
	var/list/backend_subtype_list = list()
	var/list/backend_aspects_list = list()
	if(selected_warband)
		var/list/entry = serialize_warband_datum(selected_warband, selection_inputs["[selected_warband.type]"])
		entry["subtyperequired"] = selected_warband.subtyperequired
		entry["subtypes"] = selected_warband.subtypes
		entry["aspects"] = selected_warband.aspects
		entry["multiclass_enabled"] = selected_warband.multiclass_enabled
		entry["subclass_required"] = selected_warband.subclass_required
		entry["subclass_label"] = selected_warband.subclass_label
		UNTYPED_LIST_ADD(backend_warband_list, entry)

	if(selected_subtype)
		var/list/entry = serialize_warband_datum(selected_subtype, selection_inputs["[selected_subtype.type]"])
		entry["aspects"] = selected_subtype.aspects
		entry["quote"] = selected_subtype.quote
		entry["quote_followup"] = selected_subtype.quote_followup
		UNTYPED_LIST_ADD(backend_subtype_list, entry)

	for(var/datum/warbands/aspects/selected_aspect in selected_aspects)
		var/list/entry = serialize_warband_datum(selected_aspect, selection_inputs["[selected_aspect.type]"])
		entry["class"] = selected_aspect.asclass
		entry["max_intensity"] = selected_aspect.max_intensity
		entry["intensity_costs"] = selected_aspect.build_intensity_costs()
		entry["intensity"] = (aspect_intensities["[selected_aspect.type]"] || 1)
		UNTYPED_LIST_ADD(backend_aspects_list, entry)

	data["backend_warband"] = backend_warband_list
	data["backend_subtype"] = backend_subtype_list
	data["backend_aspects"] = backend_aspects_list
	data["manager_faithlocks"] = faithlocks.Copy()
	data["manager_faithlock_names"] = get_lock_names(faithlocks)
	data["manager_racelocks"] = racelocks.Copy()
	data["manager_racelock_names"] = get_lock_names(racelocks)


// returns a list of readable names for a list of type paths
/atom/movable/screen/warband/manager/proc/get_lock_names(list/locks)
	var/list/names = list()
	for(var/path in locks)
		names += initial(path:name)
	return names

// serializes the fields common to all warband datums (warbands, subtypes, aspects)
/atom/movable/screen/warband/manager/proc/serialize_warband_datum(datum/warbands/W, list/sel_inputs)
	var/list/entry = list(
		"title" = W.title,
		"summary" = W.summary,
		"desc" = W.desc,
		"storyinfluence" = W.storytellerlimit,
		"rarity" = W.rarity,
		"points" = W.points,
		"type" = W.type,
		"warlordclasses" = W.warlordclasses,
		"lieuclasses" = W.lieutenantclasses,
		"gruntclasses" = W.gruntclasses,
		"racelock" = W.racelock.Copy(),
		"racelock_names" = get_lock_names(W.racelock),
		"faithlock" = W.faithlock.Copy(),
		"faithlock_names" = get_lock_names(W.faithlock),
		"inputs" = W.serialize_input_fields(),
		"suppressed_classes" = W.suppressed_classes ? W.suppressed_classes.Copy() : list(),
		"replaces_primaries" = W.replaces_primaries
	)
	if(sel_inputs)
		entry["selection_inputs"] = sel_inputs
	return entry

/atom/movable/screen/warband/manager/proc/subclass_requirement_met(class_path, subclass_path)
	if(!selected_warband?.multiclass_enabled || !selected_warband?.subclass_required)
		return TRUE
	if(warband_class_for(class_path) && initial(class_path:ignores_multiclass_requirement))
		return TRUE
	return subclass_path ? TRUE : FALSE

/atom/movable/screen/warband/manager/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = usr

	var/user_key = user.ckey
	if(last_action_time[user_key] && world.time < last_action_time[user_key] + 10)
		return TRUE
	last_action_time[user_key] = world.time

	switch(action)
		if("swap_character_slot")
			select_pref_slot(user)
		if("refresh")
			update_static_data(user, ui)
		if("edit_character")
			user.client.prefs.current_tab = 1
			user.client.prefs.ShowChoices(usr, 4)
		if("create_character")
			if(user.mind.special_role == "Warlord")
				to_chat(user, span_warning("Use the finalize button to complete your warband."))
				return
			if(!warlord_spawned)
				to_chat(user, span_warning("Wait for the Warlord to be finalized, first."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			var/class_path = text2path(params["class"])
			var/subclass_path = text2path(params["subclass"])
			if(!subclass_requirement_met(class_path, subclass_path))
				to_chat(user, span_warning("This class requires a subclass selection."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			SStgui.close_user_uis(user)
			user.mind.warband_manager = src
			if(user in lobby_members)
				lobby_members -= user
			load_appearance(user, user)
			lock_check(user, class_path)
			spawn_character(class_path, user, subclass_path, is_leader = 0, is_latespawn = user.mind.warband_latespawn)
			end_intro(user)
			return
		if("advance_stage")
			if(user.mind.special_role != "Warlord")
				to_chat(user, span_warning("Only the Warlord can advance stages."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			if(creation_stage == 1)
				commit_warband_selection(user, params)
				return
			if(creation_stage == 2)
				if(!casus_belli_selection)
					to_chat(user, span_warning("A casus belli must be chosen before advancing."))
					user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
					return
				creation_stage = 3
				reset_creation_timer()
				for(var/mob/living/carbon/human/member in lobby_members)
					to_chat(member, span_greenteamradio("The Warlord has advanced to class selection. You may now choose your class."))
				update_static_data_for_all_viewers()
				return
		if("create_warband")
			if(user.mind.special_role != "Warlord")
				to_chat(user, span_warning("Only the Warlord may finalize the warband."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			if(creation_stage != 3)
				to_chat(user, span_warning("Select a Warband first."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			if(SSwarbands.warband_managers_busy == TRUE)
				to_chat(src, span_bold("Warband Generation is occupied. Please wait."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			var/class_path = text2path(params["class"])
			var/subclass_path = text2path(params["subclass"])
			if(!subclass_requirement_met(class_path, subclass_path))
				to_chat(user, span_warning("Your class requires a subclass selection before finalizing."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			SSwarbands.warband_managers_busy = TRUE
			SStgui.close_user_uis(user)
			if(user in lobby_members)
				lobby_members -= user
			load_appearance(user, user)
			lock_check(user, class_path)
			spawn_warband(user)
			set_IDs()
			if(linked_faction && !linked_faction.owner)
				linked_faction.owner = user.real_name
				linked_faction.name = linked_faction.verify_faction_name("[user.real_name]'s Warband", user)
			// we use "The Warband" as a placeholder faction for the UI. once we're actually in-game, we need to update it
			if(casus_belli_selection && linked_faction)
				var/real_name = linked_faction.name
				if(casus_belli_selection.target == "The Warband")
					casus_belli_selection.target = real_name
				if(casus_belli_selection.receiver == "The Warband")
					casus_belli_selection.receiver = real_name
			spawn_character(class_path, user, subclass_path, is_leader = 1)
			set_default_exit()
			warlord_spawned = TRUE
			SSwarbands.warband_managers_busy = FALSE
			user.mind.warband_manager = src
			end_intro(user)
			for(var/mob/living/carbon/human/member in lobby_members)
				if(member.mind.special_role == "Lieutenant" || member.mind.special_role == "Aspirant Lieutenant" || member.mind.special_role == "Grunt")
					to_chat(member, span_greenteamradio("The Warlord has established the warband. You may now finalize your character."))
					member.playsound_local(member, 'sound/misc/warband/menusound3.ogg', 100, FALSE)
			update_static_data_for_all_viewers()
			addtimer(CALLBACK(src, PROC_REF(spawn_ready_members)), 30)
			return
		if("interaction_sound")
			user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
			return
		if("toggle_ready")
			if(user.mind.special_role == "Warlord")
				return
			if(creation_stage < 3)
				return
			if(user.ckey in ready_members)
				ready_members -= user.ckey
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
			else
				var/class_path_str = params["class"]
				if(!class_path_str || !text2path(class_path_str))
					to_chat(user, span_warning("Select a valid class before readying up."))
					user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
					return
				if(!subclass_requirement_met(text2path(class_path_str), text2path(params["subclass"])))
					to_chat(user, span_warning("Select a subclass before readying up."))
					user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
					return
				ready_members[user.ckey] = list(
					"class" = class_path_str,
					"subclass" = params["subclass"]
				)
				user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
			update_static_data_for_all_viewers()
			return
		if("propose_casus_belli")
			var/term_type_str = params["term_type"]
			var/term_name = params["term_name"]
			if(!term_type_str || !term_name)
				return
			var/found_type = text2path(term_type_str)
			if(!found_type)
				return
			var/datum/treaty/terms/new_term = new found_type()
			var/list/term_details = list()
			for(var/datum/treaty/input_field/field in new_term.input_fields)
				if(field.client_only)
					continue
				var/raw = params[field.key]
				if(!raw)
					continue
				var/val
				if(istype(field, /datum/treaty/input_field/number))
					val = text2num(raw)
				else if(istype(field, /datum/treaty/input_field/textarea) || istype(field, /datum/treaty/input_field/text_input))
					val = sanitize(copytext(raw, 1, MAX_MESSAGE_LEN))
				else
					val = copytext(raw, 1, MAX_MESSAGE_LEN)
				term_details[field.key] = val
				new_term.vars[field.key] = val
			for(var/list/existing in casus_belli_proposals)
				if(existing["author"] == user.ckey)
					existing["author"] = null
					var/list/existing_confirmed = existing["confirmed_votes"]
					var/list/existing_pending = existing["pending_votes"]
					if(!existing_confirmed.len && !existing_pending.len)
						casus_belli_proposals -= list(existing)
					break
			for(var/list/existing_proposal in casus_belli_proposals)
				var/existing_type = text2path(existing_proposal["term_type"])
				if(!existing_type)
					continue
				var/datum/treaty/terms/existing_term = new existing_type()
				var/list/ed = existing_proposal["term_details"] || list()
				for(var/datum/treaty/input_field/field in existing_term.input_fields)
					if(field.client_only || isnull(ed[field.key]))
						continue
					existing_term.vars[field.key] = ed[field.key]
				var/is_dup = new_term.duplicate_check(existing_term)
				qdel(existing_term)
				if(is_dup)
					qdel(new_term)
					to_chat(user, span_warning("An identical proposition already exists. Your proposal was cancelled."))
					user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
					return
			qdel(new_term)
			user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
			var/term_desc = ""
			var/datum/treaty/terms/proto = new found_type()
			term_desc = proto.desc
			qdel(proto)
			var/list/new_proposal = list(
				"proposal_id" = "[user.ckey]_[world.time]",
				"term_type" = term_type_str,
				"term_name" = term_name,
				"term_desc" = term_desc,
				"term_details" = term_details,
				"author" = user.ckey,
				"confirmed_votes" = list(),
				"pending_votes" = list(),
				"is_selected" = FALSE
			)
			casus_belli_proposals += list(new_proposal)
			update_static_data_for_all_viewers()
			return
		if("vote_casus_belli")
			if(user.mind.special_role == "Warlord")
				return
			var/target_id = params["proposal_id"]
			if(!target_id)
				return
			for(var/list/proposal in casus_belli_proposals)
				if(user.ckey in proposal["confirmed_votes"])
					return
			var/already_pending = FALSE
			for(var/list/proposal in casus_belli_proposals)
				if(proposal["proposal_id"] == target_id)
					if(user.ckey in proposal["pending_votes"])
						already_pending = TRUE
					break
			for(var/list/proposal in casus_belli_proposals)
				proposal["pending_votes"] -= user.ckey
			if(!already_pending)
				for(var/list/proposal in casus_belli_proposals)
					if(proposal["proposal_id"] == target_id)
						proposal["pending_votes"] += user.ckey
						break
			update_static_data_for_all_viewers()
			return
		if("confirm_casus_belli")
			if(user.mind.special_role == "Warlord")
				return
			var/target_id = params["proposal_id"]
			if(!target_id)
				return
			for(var/list/proposal in casus_belli_proposals)
				if(proposal["proposal_id"] == target_id && (user.ckey in proposal["pending_votes"]))
					proposal["pending_votes"] -= user.ckey
					proposal["confirmed_votes"] += user.ckey
					user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
					update_static_data_for_all_viewers()
					return
			return
		if("select_casus_belli")
			if(user.mind.special_role != "Warlord")
				return
			var/target_id = params["proposal_id"]
			if(!target_id)
				return
			var/list/target_proposal
			for(var/list/proposal in casus_belli_proposals)
				if(proposal["proposal_id"] == target_id)
					target_proposal = proposal
					break
			if(!target_proposal)
				return
			var/found_type = text2path(target_proposal["term_type"])
			if(!found_type)
				return
			var/was_selected = target_proposal["is_selected"]
			for(var/list/proposal in casus_belli_proposals)
				proposal["is_selected"] = FALSE
			if(casus_belli_selection && was_selected)
				qdel(casus_belli_selection)
				casus_belli_selection = null
			else
				target_proposal["is_selected"] = TRUE
				if(casus_belli_selection)
					qdel(casus_belli_selection)
				casus_belli_selection = new found_type()
				var/list/details = target_proposal["term_details"] || list()
				for(var/datum/treaty/input_field/field in casus_belli_selection.input_fields)
					if(field.client_only || isnull(details[field.key]))
						continue
					casus_belli_selection.vars[field.key] = details[field.key]
			update_static_data_for_all_viewers()
			return
		if("mute_lobby_chat")
			toggle_lobby_chat_mute(user)
			return
		if("view_laws")
			to_chat(user, span_greenteamradio("AZURIA'S LAWS ARE AS FOLLOWS:"))
			user.playsound_local(user, 'sound/misc/notice (2).ogg', 100, FALSE)
			for(var/law in GLOB.laws_of_the_land)
				to_chat(user, span_memo(law))
			return
		if("view_decrees")
			user.playsound_local(user, 'sound/misc/notice (2).ogg', 100, FALSE)
			for(var/decree in GLOB.lord_decrees)
				to_chat(user, span_memo(decree))
			return
		if("view_vip")
			var/returned_vip = params["enemy"]
			var/returned_ally = params["ally"]
			var/mob/living/carbon/human/matched_vip
			for(var/mob/living/carbon/human/vip in importantfigures)
				if(vip.real_name == returned_vip)
					matched_vip = vip
					break
			for(var/mob/living/carbon/human/pal in members)
				if(pal.real_name == returned_ally)
					matched_vip = pal
					break
			if(matched_vip)
				if(!ismob(usr))
					return
				SStgui.close_user_uis(usr, /datum/examine_panel)
				var/datum/examine_panel/mob_examine_panel = new(matched_vip)
				mob_examine_panel.holder = matched_vip
				mob_examine_panel.viewing = usr
				mob_examine_panel.ui_interact(usr)
				return

// commits warband/subtype/aspect selections and advances to stage 2
/atom/movable/screen/warband/manager/proc/commit_warband_selection(mob/user, list/params)
	var/warband_path = text2path(params["warband"])
	if(!warband_path || !SSwarbands.warband_datum_for(warband_path))
		to_chat(user, span_warning("Select a valid warband before advancing."))
		user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
		return

	selected_warband = SSwarbands.warband_datum_for(warband_path)

	var/subtype_path = text2path(params["subtype"])
	if(subtype_path && SSwarbands.subtype_datum_for(subtype_path))
		selected_subtype = SSwarbands.subtype_datum_for(subtype_path)

	var/list/aspect_paths = params["aspects"]
	var/list/incoming_intensities = params["aspect_intensities"] || list()
	var/list/incoming_selection_inputs = params["selection_inputs"] || list()

	if(selected_warband)
		selection_inputs["[selected_warband.type]"] = incoming_selection_inputs["[selected_warband.type]"] || list()
	if(selected_subtype)
		selection_inputs["[selected_subtype.type]"] = incoming_selection_inputs["[selected_subtype.type]"] || list()

	for(var/aspect_path in aspect_paths)
		var/aspect_type = text2path(aspect_path)
		var/datum/warbands/aspects/aspect = SSwarbands.aspect_datum_for(aspect_type)
		if(aspect)
			selected_aspects += aspect
			var/incoming_intensity = text2num(incoming_intensities[aspect_path])
			aspect_intensities["[aspect_type]"] = clamp(incoming_intensity || 1, 1, aspect.max_intensity)
			selection_inputs[aspect_path] = incoming_selection_inputs[aspect_path] || list()

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
	reset_creation_timer()


// spawns every member who readied up during finalization
/atom/movable/screen/warband/manager/proc/spawn_ready_members()
	for(var/ckey in ready_members)
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
		if(member in lobby_members)
			lobby_members -= member
		load_appearance(member, member)
		lock_check(member, class_path)
		spawn_character(class_path, member, subclass_path)
		end_intro(member)
	addtimer(CALLBACK(src, PROC_REF(finalize)), 30) // separated from the main proc, in case someone unreadies mid-finalization
	ready_members = list()

/atom/movable/screen/warband/manager/proc/finalize()
	finalized = TRUE

/atom/movable/screen/warband/manager/ui_close(mob/user, datum/tgui/ui)
	. = ..()

/atom/movable/screen/warband/manager/ui_status(mob/user)
	if(user)
		return UI_INTERACTIVE
	return ..()

/////////////////////////////////////////////

/atom/movable/screen/introtext
	name = "intro text"
	icon = 'icons/roguetown/hud/warband/placeholder_intro.dmi'
	icon_state = "warlordintro_placeholder"
	screen_loc = "4.3,9"
	alpha = 0

/atom/movable/screen/introtext/lieutenant
	icon_state = "lieutenantintro_placeholder"
	screen_loc = "4.5,9"

/atom/movable/screen/introtext/veteran
	icon_state = "veteranintro_placeholder"

/atom/movable/screen/introtext/aspirant
	icon_state = "aspirantintro_placeholder"
