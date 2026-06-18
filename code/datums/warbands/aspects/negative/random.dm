////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// selects a random negative aspect

/datum/warbands/aspects/fated_suffering
	title = "FATED SUFFERING"
	summary = "There's nothing we can do."
	desc = "A negative aspect is chosen at random."
	warning = "...of an ill-omen hanging over a wretched, pathetic lot."
	points = 2 // larger point yield, to make this an Actual Choice

/datum/warbands/aspects/fated_suffering/on_warband_confirmed(datum/warband_manager/manager, intensity = 1)
	var/list/selected_types = list()
	var/list/selected_asclasses = list()
	for(var/datum/warbands/aspects/picked in manager.selected_aspects)
		selected_types += picked.type
		if(picked.asclass)
			selected_asclasses += picked.asclass

	// only draw from the aspects the current warband/subtype actually offers, same as commit_warband_selection()'s validation
	var/list/offered = list()
	if(manager.selected_warband)
		offered |= manager.selected_warband.aspects
	if(manager.selected_subtype)
		offered |= manager.selected_subtype.aspects

	var/list/available = list()
	for(var/datum/warbands/aspects/candidate in SSwarbands.all_aspects)
		if(istype(candidate, /datum/warbands/aspects/fated_suffering))
			continue
		if(!(candidate.type in offered))
			continue // not offered by this warband or its subtype
		if(candidate.points <= 0)
			continue // skip positive/bonus aspects
		if(candidate.type in selected_types)
			continue // already selected
		if(candidate.asclass && (candidate.asclass in selected_asclasses))
			continue // would conflict with an existing aspect's class slot
		available += candidate

	if(!available.len)
		for(var/mob/living/member in manager.lobby_members)
			to_chat(member, span_warning("Fated Suffering was chosen, but you're already at rock bottom."))
		return

	var/datum/warbands/aspects/chosen = pick(available)
	manager.selected_aspects += chosen

	chosen.on_warband_confirmed(manager) // fire the chosen aspect's own confirmation hook

	for(var/mob/living/member in manager.lobby_members)
		to_chat(member, span_redteamradio("Fated Suffering has selected [chosen.title]."))
