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
	populate_patron_data(data)
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

// TRUE if the populated term duplicates an existing proposal | skip_proposal exempts one proposal (either the author's own, or the one being edited)
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

/datum/warband_manager/proc/populate_patron_data(list/data)
	if(static_data_set)
		data["backendpatrons"] = list()
		return
	var/list/patron_list = list()
	for(var/datum/patron/influence_patron in storyinfluence)
		UNTYPED_LIST_ADD(patron_list, list(
			"title" = influence_patron.name,
			"summary" = influence_patron.desc,
			"type" = influence_patron.type
		))
	data["backendpatrons"] = patron_list

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
				"storytellerlimit" = initial(class_type:storytellerlimit),
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
