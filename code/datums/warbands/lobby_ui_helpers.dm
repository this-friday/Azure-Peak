// returns a list of names for a warband's race & faith locks
/datum/warband_manager/proc/get_lock_names(list/locks)
	var/list/names = list()
	for(var/path in locks)
		names += initial(path:name)
	return names

// close any examine panels the user has open
/datum/warband_manager/proc/close_examine_panels(mob/user)
	for(var/datum/tgui/open_ui in user.tgui_open_uis)
		if(istype(open_ui.src_object, /datum/examine_panel))
			open_ui.close()

// finds a casus belli proposal by its id
/datum/warband_manager/proc/find_casus_proposal(target_id)
	for(var/list/proposal in casus_belli_proposals)
		if(proposal["proposal_id"] == target_id)
			return proposal
	return

// serializes the fields common to all warband datums (warbands, subtypes, aspects)
/datum/warband_manager/proc/serialize_warband_datum(datum/warbands/W, list/sel_inputs)
	var/list/entry = list(
		"title" = W.title,
		"summary" = W.summary,
		"desc" = W.desc,
		"storytellerlimit" = W.storytellerlimit,
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

// returns the label of the first required-but-empty input field on a given datum
/datum/warband_manager/proc/missing_required_input(datum/warbands/W, list/sel_inputs, intensity = 1)
	if(!W || !length(W.input_fields))
		return
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
	return

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
