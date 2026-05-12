///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// TERM: ABOLISH CHARTER
/*
	deactivates a chosen charter (/datum/decree) & permanently bars it from being reactivated

*/
/datum/treaty/terms/abolish_charter
	name = "Seal Charter"
	desc = "The chosen charter is permanently suspended. It may only be restored after the Duke's usurpation."
	hint = "...something about one of the realm's charters..."
	authorities = list(/datum/job/roguetown/lord)
	minimum_signatures = 1

/datum/treaty/terms/abolish_charter/build_input_fields()
	var/datum/treaty/input_field/option_dropdown/charter_picker = new()
	charter_picker.key = "target"
	charter_picker.label = "Charter to Abolish"
	charter_picker.placeholder = "Select a charter..."
	for(var/id in SStreasury.decrees)
		var/datum/decree/D = SStreasury.decrees[id]
		charter_picker.options += D.name
	input_fields += charter_picker
 
	var/datum/treaty/input_field/display/info = new()
	info.key = "charter_info"
	info.display_key = "target"
	info.placeholder = "Select a charter to see its effects."
	for(var/id in SStreasury.decrees)
		var/datum/decree/D = SStreasury.decrees[id]
		if(!D.mechanical_text)
			continue
		var/list/blocks = list()
		UNTYPED_LIST_ADD(blocks, list("label" = "Charter Effects", "text" = D.mechanical_text))
		info.content_map[D.name] = blocks
	input_fields += info

/datum/treaty/terms/abolish_charter/get_info_blocks()
	if(!target)
		return list()
	for(var/id in SStreasury.decrees)
		var/datum/decree/D = SStreasury.decrees[id]
		if(D.name != target)
			continue
		if(!D.mechanical_text)
			return list()
		var/list/blocks = list()
		UNTYPED_LIST_ADD(blocks, list("label" = "Charter Effects", "text" = D.mechanical_text))
		return blocks
	return list()

/datum/treaty/terms/abolish_charter/duplicate_check(datum/treaty/terms/existing)
	return istype(existing, /datum/treaty/terms/abolish_charter) // limited to 1 Perma Abolition per treaty, to give it more narrative weight & prevent mass perma-abolitions

/datum/treaty/terms/abolish_charter/apply(obj/item/treaty/treaty)
	if(!target)
		return

	var/datum/decree/found_decree
	for(var/id in SStreasury.decrees)
		var/datum/decree/D = SStreasury.decrees[id]
		if(D.name == target)
			found_decree = D
			break

	if(!found_decree)
		treaty.visible_message(span_danger("...but one of the terms yet remains in the flame. There is no charter known as '[target]'."))
		return

	if(found_decree.id in SStreasury.abolished_decree_ids)
		treaty.visible_message(span_warning("...but one of the terms yet remains in the flame. [target] has already been sealed."))
		return

	// deactivate and (semi)permanently lock out reactivation
	SStreasury.set_decree_active(found_decree.id, FALSE, TRUE)
	SStreasury.abolished_decree_ids |= found_decree.id

	return "[target] has been permanently suspended. So long as the [SSticker.rulertype] reigns, it cannot be reinstated."
