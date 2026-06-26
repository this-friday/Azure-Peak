/datum/warband_manager/proc/create_HUD_instance(mob/user)
	if(!user?.client || !button)
		return
	user.client.screen |= button
	animate(button, alpha = 255, time = 800)

/datum/warband_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WarbandCreation")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/warband_manager/ui_data(mob/user)
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

/datum/warband_manager/ui_static_data(mob/user)
	var/list/data = ..()
	data["creation_stage"] = creation_stage
	data["warlord_spawned"] = warlord_spawned
	data["is_warlord"] = (user.mind.special_role == ROLE_WARLORD)
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
	data["class_slot_counts"] = build_class_slot_counts()
	data["bypass_rarity"] = bypass_rarity
	static_data_set = TRUE
	return data


/datum/warband_manager/proc/populate_noble_and_ally_data(mob/user, list/data)
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
			"in_lobby" = FALSE,
			"ref" = REF(buddy)
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
			"is_ready" = (lobby_member.ckey in ready_members),
			"ready_class" = ready_class_title(lobby_member.ckey, "class"),
			"ready_subclass" = ready_class_title(lobby_member.ckey, "subclass"),
			"ref" = REF(lobby_member)
		))
	data["allies"] = allies_list

// occupied-slot counts per class type (spawned members + readied picks), keyed by type path string for the UI
/datum/warband_manager/proc/build_class_slot_counts()
	var/list/counts = list()
	for(var/class_path in taken_class_counts)
		counts["[class_path]"] = taken_class_counts[class_path]
	for(var/ckey in ready_members)
		var/list/stored = ready_members[ckey]
		if(!islist(stored))
			continue
		for(var/slot_key in list("class", "subclass"))
			if(!stored[slot_key])
				continue
			counts["[stored[slot_key]]"] += 1
	return counts

// resolves a readied member's stored class/subclass pick into its display title, or null
/datum/warband_manager/proc/ready_class_title(ckey, slot_key)
	var/list/stored = ready_members[ckey]
	if(!islist(stored) || !stored[slot_key])
		return null
	var/stored_path = text2path(stored[slot_key])
	if(!ispath(stored_path, /datum/advclass))
		return null
	return initial(stored_path:title) || initial(stored_path:name)

/datum/warband_manager/proc/populate_user_data(mob/user, list/data)
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

/datum/warband_manager/proc/populate_casus_belli_data(mob/user, list/data)
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

// closes any examine panel the user has open
// close_user_uis() matches on src_object instances, so a typepath never closes anything — walk the open uis ourselves
/datum/warband_manager/proc/close_examine_panels(mob/user)
	for(var/datum/tgui/open_ui in user.tgui_open_uis)
		if(istype(open_ui.src_object, /datum/examine_panel))
			open_ui.close()

// finds a casus belli proposal by its id
/datum/warband_manager/proc/find_casus_proposal(target_id)
	for(var/list/proposal in casus_belli_proposals)
		if(proposal["proposal_id"] == target_id)
			return proposal
	return null

// tells everyone who voted on the given proposal that their vote was reset
/datum/warband_manager/proc/notify_proposal_voters(list/proposal, message)
	var/list/voter_ckeys = list()
	voter_ckeys |= proposal["confirmed_votes"]
	voter_ckeys |= proposal["pending_votes"]
	if(!voter_ckeys.len)
		return
	for(var/mob/living/member in lobby_members)
		if(member.ckey in voter_ckeys)
			to_chat(member, span_warning(message))
			member.playsound_local(member, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)

// wipes the warlord's locked-in casus belli selection and every proposal's selection flag
/datum/warband_manager/proc/clear_casus_selection()
	if(casus_belli_selection)
		qdel(casus_belli_selection)
		casus_belli_selection = null
	for(var/list/proposal in casus_belli_proposals)
		proposal["is_selected"] = FALSE

// fills a term datum's vars from a ui_act payload and returns the extracted details list
/datum/warband_manager/proc/build_term_details(datum/treaty/terms/term, list/params)
	var/list/term_details = list()
	for(var/datum/treaty/input_field/field in term.input_fields)
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
		term.vars[field.key] = val
	return term_details

// TRUE if the populated term duplicates an existing proposal | skip_proposal exempts one proposal (the author's own, or the one being edited)
/datum/warband_manager/proc/casus_proposal_duplicates(datum/treaty/terms/new_term, list/skip_proposal)
	for(var/list/existing_proposal in casus_belli_proposals)
		if(existing_proposal == skip_proposal)
			continue
		var/existing_type = text2path(existing_proposal["term_type"])
		if(!existing_type)
			continue
		var/datum/treaty/terms/existing_term = new existing_type()
		var/list/existing_details = existing_proposal["term_details"] || list()
		for(var/datum/treaty/input_field/field in existing_term.input_fields)
			if(field.client_only || isnull(existing_details[field.key]))
				continue
			existing_term.vars[field.key] = existing_details[field.key]
		var/is_dup = new_term.duplicate_check(existing_term)
		qdel(existing_term)
		if(is_dup)
			return TRUE
	return FALSE

/datum/warband_manager/proc/populate_faction_data(list/data)
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

/datum/warband_manager/proc/populate_storyteller_data(list/data)
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

/datum/warband_manager/proc/populate_class_data(list/data)
	if(!SSwarbands.cached_ui_classes)
		var/list/class_list = list()
		for(var/class_type in SSwarbands.all_warband_class_types)
			var/class_ignore_locks = FALSE
			var/class_ignores_subclass_requirement = FALSE
			var/list/class_subclass_paths = list()
			var/class_slots = -1
			if(ispath(class_type, /datum/advclass/warband))
				class_slots = initial(class_type:maximum_possible_slots)
				class_ignore_locks = initial(class_type:ignore_locks)
				class_ignores_subclass_requirement = initial(class_type:ignores_uni_class_requirement)
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
				"slots" = class_slots,
				"type" = class_type,
				"ignore_locks" = class_ignore_locks,
				"ignores_uni_class_requirement" = class_ignores_subclass_requirement,
				"classes" = class_subclass_paths
			))
		SSwarbands.cached_ui_classes = class_list
	data["classes"] = SSwarbands.cached_ui_classes

/datum/warband_manager/proc/populate_terms_data(list/data)
	var/warband_type = (creation_stage >= 2 && selected_warband) ? selected_warband.type : null
	var/list/all_terms_list = list()
	for(var/datum/treaty/terms/term in SSwarbands.get_all_terms(warband_type))
		UNTYPED_LIST_ADD(all_terms_list, list(
			"name" = term.name,
			"desc" = term.desc,
			"hint" = term.hint,
			"open_signatures" = term.open_signatures,
			"inputs" = term.serialize_input_fields(),
			"type" = "[term.type]",
			"warbandlock" = (term.warbandlock ? "[term.warbandlock]" : null)
		))
	data["all_terms"] = all_terms_list

/datum/warband_manager/proc/populate_warband_lists(list/data)
	if(!SSwarbands.warband_ui_data) // everything here is only built once, cached in the subsystem, and referenced
		var/list/warbands_list = list()
		var/list/subtypes_list = list()
		var/list/aspects_list = list()
		for(var/datum/warbands/warband in SSwarbands.all_warbands)
			var/list/entry = serialize_warband_datum(warband)
			entry["subtyperequired"] = warband.subtyperequired
			entry["subtypes"] = warband.subtypes
			entry["aspects"] = warband.aspects
			entry["universal_subclasses_enabled"] = warband.universal_subclasses_enabled
			entry["subclass_required"] = warband.subclass_required
			entry["subclass_label"] = warband.subclass_label
			entry["max_aspects"] = warband.max_aspects
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
		entry["universal_subclasses_enabled"] = selected_warband.universal_subclasses_enabled
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
/datum/warband_manager/proc/get_lock_names(list/locks)
	var/list/names = list()
	for(var/path in locks)
		names += initial(path:name)
	return names

// serializes the fields common to all warband datums (warbands, subtypes, aspects)
/datum/warband_manager/proc/serialize_warband_datum(datum/warbands/W, list/sel_inputs)
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
		"suppress_all_other_classes" = W.suppress_all_other_classes,
		"universal_warlordclasses" = W.universal_warlordclasses,
		"universal_lieuclasses" = W.universal_lieutenantclasses,
		"universal_gruntclasses" = W.universal_gruntclasses
	)
	if(sel_inputs)
		entry["selection_inputs"] = sel_inputs
	return entry

/datum/warband_manager/proc/subclass_requirement_met(class_path, subclass_path)
	if(!selected_warband?.universal_subclasses_enabled || !selected_warband?.subclass_required)
		return TRUE
	if(warband_class_for(class_path) && initial(class_path:ignores_uni_class_requirement))
		return TRUE
	return subclass_path ? TRUE : FALSE

/datum/warband_manager/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = usr

	// cosmetic clicks must bypass the throttle below, or firing one alongside a real action silently eats that action
	if(action == "interaction_sound")
		user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
		return TRUE

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
			if(user.mind.special_role == ROLE_WARLORD)
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
			if(!validate_class_selection(user, class_path, subclass_path))
				to_chat(user, span_warning("That class isn't available to this warband."))
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
			update_static_data_for_all_viewers() // keeps class slot counts fresh for everyone still in the lobby
			return
		if("advance_stage")
			if(user.mind.special_role != ROLE_WARLORD)
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
				advance_stage_timer()
				for(var/mob/living/carbon/human/member in lobby_members)
					to_chat(member, span_greenteamradio("The Warlord has advanced to class selection. You may now choose your class."))
				update_static_data_for_all_viewers()
				return
		if("create_warband")
			if(user.mind.special_role != ROLE_WARLORD)
				to_chat(user, span_warning("Only the Warlord may finalize the warband."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			if(creation_stage != 3)
				to_chat(user, span_warning("Select a Warband first."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			if(SSwarbands.warband_managers_busy == TRUE)
				to_chat(user, span_bold("Warband Generation is occupied. Please wait."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			var/class_path = text2path(params["class"])
			var/subclass_path = text2path(params["subclass"])
			if(!subclass_requirement_met(class_path, subclass_path))
				to_chat(user, span_warning("Your class requires a subclass selection before finalizing."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			if(!validate_class_selection(user, class_path, subclass_path))
				to_chat(user, span_warning("That class isn't available to this warband."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			finalize_warband(user, class_path, subclass_path)
			for(var/mob/living/carbon/human/member in lobby_members)
				if(member.mind.special_role == ROLE_WARLORD_LIEUTENANT || member.mind.special_role == ROLE_WARLORD_ASPIRANT || member.mind.special_role == ROLE_WARLORD_GRUNT)
					to_chat(member, span_greenteamradio("The Warlord has established the warband. You may now finalize your character."))
					member.playsound_local(member, 'sound/misc/warband/menusound3.ogg', 100, FALSE)
			return
		if("toggle_ready")
			if(user.mind.special_role == ROLE_WARLORD)
				return
			if(creation_stage < 3)
				return
			if(user.ckey in ready_members)
				ready_members -= user.ckey
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
			else
				var/class_path_str = params["class"]
				var/ready_class_path = text2path(class_path_str)
				var/ready_subclass_path = text2path(params["subclass"])
				if(!class_path_str || !ready_class_path)
					to_chat(user, span_warning("Select a valid class before readying up."))
					user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
					return
				if(!subclass_requirement_met(ready_class_path, ready_subclass_path))
					to_chat(user, span_warning("Select a subclass before readying up."))
					user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
					return
				if(!validate_class_selection(user, ready_class_path, ready_subclass_path))
					to_chat(user, span_warning("That class isn't available to this warband."))
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
			// each player holds at most one live proposal — re-proposing replaces it outright once the new one is accepted
			var/list/old_proposal
			for(var/list/existing in casus_belli_proposals)
				if(existing["author"] == user.ckey)
					old_proposal = existing
					break
			var/datum/treaty/terms/new_term = new found_type()
			var/list/term_details = build_term_details(new_term, params)
			if(casus_proposal_duplicates(new_term, old_proposal)) // a failed re-propose keeps the old proposal intact
				qdel(new_term)
				to_chat(user, span_warning("An identical proposition already exists. Your proposal was cancelled."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			var/term_desc = new_term.desc
			qdel(new_term)
			if(old_proposal)
				if(old_proposal["is_selected"])
					clear_casus_selection()
					announce_to_lobby(span_warning("The Warlord's chosen casus belli was withdrawn, as the proposal has been replaced."))
				notify_proposal_voters(old_proposal, "The proposal you voted for was replaced by its author. Your vote has been reset.")
				casus_belli_proposals -= list(old_proposal)
			user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
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
			if(user.mind.special_role == ROLE_WARLORD)
				return
			if(creation_stage != 2)
				return
			var/target_id = params["proposal_id"]
			if(!target_id)
				return
			var/list/target_proposal = find_casus_proposal(target_id)
			if(!target_proposal)
				return
			// votes are freely movable until the casus belli stage ends: clicking a new proposal moves my vote there
			// (a confirmed vote demotes back to pending), clicking my current one withdraws it
			var/was_mine = (user.ckey in target_proposal["pending_votes"]) || (user.ckey in target_proposal["confirmed_votes"])
			for(var/list/proposal in casus_belli_proposals)
				proposal["pending_votes"] -= user.ckey
				proposal["confirmed_votes"] -= user.ckey
			if(!was_mine)
				target_proposal["pending_votes"] += user.ckey
			update_static_data_for_all_viewers()
			return
		if("confirm_casus_belli")
			if(user.mind.special_role == ROLE_WARLORD)
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
			if(user.mind.special_role != ROLE_WARLORD)
				return
			var/target_id = params["proposal_id"]
			if(!target_id)
				return
			var/list/target_proposal = find_casus_proposal(target_id)
			if(!target_proposal)
				return
			var/found_type = text2path(target_proposal["term_type"])
			if(!found_type)
				return
			var/was_selected = target_proposal["is_selected"]
			clear_casus_selection()
			if(!was_selected) // re-clicking the selected proposal just deselects it
				target_proposal["is_selected"] = TRUE
				casus_belli_selection = new found_type()
				var/list/details = target_proposal["term_details"] || list()
				for(var/datum/treaty/input_field/field in casus_belli_selection.input_fields)
					if(field.client_only || isnull(details[field.key]))
						continue
					casus_belli_selection.vars[field.key] = details[field.key]
			update_static_data_for_all_viewers()
			return
		if("edit_casus_belli")
			if(user.mind.special_role != ROLE_WARLORD)
				return
			if(creation_stage != 2)
				return
			var/target_id = params["proposal_id"]
			if(!target_id)
				return
			var/list/target_proposal = find_casus_proposal(target_id)
			if(!target_proposal)
				to_chat(user, span_warning("That proposal no longer exists."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			var/found_type = text2path(target_proposal["term_type"]) // the term type is fixed — only the details can be edited
			if(!found_type)
				return
			var/datum/treaty/terms/edited_term = new found_type()
			var/list/term_details = build_term_details(edited_term, params)
			if(casus_proposal_duplicates(edited_term, target_proposal))
				qdel(edited_term)
				to_chat(user, span_warning("An identical proposition already exists. Your edit was cancelled."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			qdel(edited_term)
			// the edit lands in place: author keeps the credit, but every vote resets and any lock-in is withdrawn
			notify_proposal_voters(target_proposal, "The proposal you voted for was edited by the Warlord. Your vote has been reset.")
			target_proposal["term_details"] = term_details
			if(params["term_name"])
				target_proposal["term_name"] = params["term_name"]
			target_proposal["confirmed_votes"] = list()
			target_proposal["pending_votes"] = list()
			if(target_proposal["is_selected"])
				clear_casus_selection()
				announce_to_lobby(span_warning("The Warlord's chosen casus belli was withdrawn, as the proposal was edited."))
			for(var/mob/living/member in lobby_members)
				if(member.ckey == target_proposal["author"])
					to_chat(member, span_warning("The Warlord has edited your casus belli proposal."))
					break
			user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
			update_static_data_for_all_viewers()
			return
		if("mute_lobby_chat")
			toggle_lobby_chat_mute(user)
			return
		if("request_role_swap")
			if(creation_stage != 1)
				to_chat(user, span_warning("Role swaps are only possible during warband selection."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			if(!(user in lobby_members))
				return
			if(user.ckey in pending_swap_ckeys)
				to_chat(user, span_warning("A role swap involving me is already pending."))
				return
			if(last_swap_request[user.ckey] && world.time < last_swap_request[user.ckey] + 30 SECONDS)
				to_chat(user, span_warning("I should give it a moment before asking again."))
				return
			INVOKE_ASYNC(src, PROC_REF(handle_role_swap_request), user) // the prompts sleep — ui_act must not
			return
		if("view_laws")
			to_chat(user, span_greenteamradio("AZURIA'S LAWS ARE AS FOLLOWS:"))
			user.playsound_local(user, 'sound/misc/notice (2).ogg', 100, FALSE)
			for(var/law in GLOB.laws_of_the_land)
				to_chat(user, span_memo(law))
			return
		if("view_vip")
			var/returned_vip = params["enemy"]
			var/mob/living/carbon/human/matched_vip
			for(var/mob/living/carbon/human/vip in importantfigures)
				if(vip.real_name == returned_vip)
					matched_vip = vip
					break
			if(matched_vip)
				if(!ismob(usr))
					return
				close_examine_panels(usr)
				var/datum/examine_panel/mob_examine_panel = new(matched_vip)
				mob_examine_panel.viewing = usr
				mob_examine_panel.ui_interact(usr)
				return
		if("view_member")
			var/mob/living/carbon/human/member = locate(params["ref"])
			if(!istype(member))
				return
			var/in_field = (member in members)
			var/in_lobby = (member in lobby_members)
			if(!in_field && !in_lobby) // only this warband's own people can be viewed
				return
			if(!ismob(usr))
				return
			close_examine_panels(usr)
			var/datum/examine_panel/member_panel = new(member)
			if(in_lobby)
				// lobby members haven't had their character applied to their mob yet — show their active slot's prefs instead
				if(!member.client?.prefs)
					to_chat(usr, span_warning("They have nothing to show."))
					return
				member_panel.pref = member.client.prefs
			member_panel.viewing = usr
			member_panel.ui_interact(usr)
			return

// returns the label of the first required-but-empty input field on the given datum, or null if everything's filled
// mirrors the creation menu's progressive-reveal rule: when a datum has exactly one input per intensity rank,
// only the fields up to the chosen rank are shown, so only those can be required
/datum/warband_manager/proc/missing_required_input(datum/warbands/W, list/sel_inputs, intensity = 1)
	if(!W || !length(W.input_fields))
		return null
	var/field_index = 0
	for(var/datum/treaty/input_field/field in W.input_fields)
		field_index++
		if(length(W.input_fields) == W.max_intensity && field_index > intensity)
			break
		if(field.client_only || !field.required)
			continue
		var/val = sel_inputs ? sel_inputs[field.key] : null
		if(isnull(val) || val == "")
			return field.label
	return null

// commits warband/subtype/aspect selections and advances to stage 2
// everything from the client payload is re-validated here: compatibility, duplicates, slot conflicts, the aspect cap, the point budget, and required inputs
// the TSX enforces the same rules for UX, but the server is the authority
/datum/warband_manager/proc/commit_warband_selection(mob/user, list/params)
	var/warband_path = text2path(params["warband"])
	var/datum/warbands/incoming_warband = warband_path ? SSwarbands.warband_datum_for(warband_path) : null
	if(!incoming_warband)
		to_chat(user, span_warning("Select a valid warband before advancing."))
		user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
		return

	// the subtype must be one the chosen warband actually offers
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

	// aspects must be offered by the warband or its subtype, unique, free of class-slot conflicts, and within the cap
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
			to_chat(user, span_warning("This warband can field at most [aspect_cap] aspects."))
			break
		incoming_aspects += aspect

	// the point budget must balance: drawbacks yield points, boons & the warband baseline spend them
	var/total_points = incoming_warband.points + (incoming_subtype ? incoming_subtype.points : 0)
	for(var/datum/warbands/aspects/aspect in incoming_aspects)
		var/rank = clamp(text2num(incoming_intensities["[aspect.type]"]) || 1, 1, aspect.max_intensity)
		total_points += aspect.get_points_at_intensity(rank)
	if(total_points < 0)
		to_chat(user, span_warning("The selection's points must balance before advancing."))
		user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
		return

	// required inputs (e.g. a Sect subtype's patron) must be filled on every selection — otherwise the confirm hooks fall back to random picks
	for(var/datum/warbands/source in list(incoming_warband, incoming_subtype) + incoming_aspects)
		var/source_intensity = clamp(text2num(incoming_intensities["[source.type]"]) || 1, 1, source.max_intensity)
		var/missing_label = missing_required_input(source, incoming_selection_inputs["[source.type]"], source_intensity)
		if(missing_label)
			to_chat(user, span_warning("[source.title] requires '[missing_label]' to be filled in before advancing."))
			user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
			return

	// everything checks out: commit the selections
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


// the one true warlord-finalization pipeline
/datum/warband_manager/proc/finalize_warband(mob/living/carbon/human/warlord, class_path, subclass_path)
	if(SSwarbands.warband_managers_busy || finalized) // another finalization is already in flight
		return FALSE
	SSwarbands.warband_managers_busy = TRUE
	SStgui.close_user_uis(warlord)
	if(warlord in lobby_members)
		lobby_members -= warlord
	load_appearance(warlord, warlord)
	lock_check(warlord, class_path)
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
	SSwarbands.warband_managers_busy = FALSE
	warlord.mind.warband_manager = src
	end_intro(warlord)
	update_static_data_for_all_viewers()
	addtimer(CALLBACK(src, PROC_REF(spawn_ready_members)), 30)

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
	addtimer(CALLBACK(src, PROC_REF(finalize)), 30) // separated from the main proc, in case someone unreadies mid-finalization
	ready_members = list()

/datum/warband_manager/proc/finalize()
	finalized = TRUE

/datum/warband_manager/ui_close(mob/user, datum/tgui/ui)
	. = ..()

// only lobby members, spawned members, and admins may interact
// possession of the screen button isn't an access check on its own
/datum/warband_manager/ui_status(mob/user)
	if(!user)
		return ..()
	if((user in lobby_members) || (user in members))
		return UI_INTERACTIVE
	if(user.client?.holder)
		return UI_INTERACTIVE
	return UI_CLOSE

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
