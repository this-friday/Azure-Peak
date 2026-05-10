/////////////////////////////////////////////////////////////
///////////////////////////////////////////////// TERM: EXILE
/*
 	a mob hit with an Exile is given a subtype of Sunlight Vulnerability
	if they're inside the town (/area/rogue/outdoors/town) and exposed to sunlight, they'll catch fire like a vampire
	
*/
/datum/treaty/terms/exile
	name = "Exile"
	authorities = list("target", /datum/job/roguetown/priest, /datum/job/roguetown/lord)
	desc = "Should daelight find the Exile within the city limits, they'll be lit ablaze."
	hint = "...something regarding someone's exile..."
	minimum_signatures = 2

/datum/treaty/terms/exile/build_input_fields()
	var/datum/treaty/input_field/text_input/target_name = new()
	target_name.key = "target"
	target_name.label = "Target Name"
	target_name.placeholder = "Enter Target Name..."
	input_fields += target_name

/datum/treaty/terms/exile/duplicate_check(datum/treaty/terms/existing)
	if(!istype(existing, /datum/treaty/terms/exile))
		return FALSE
	return target == existing.target

/datum/treaty/terms/exile/apply(obj/item/treaty/treaty)
	if(!target)
		return
	var/mob/living/exile = treaty.text_to_mob(target)
	if(exile)
		exile.AddComponent(/datum/component/sunlight_vulnerability/exile)
		return "[target] has been exiled from the city."
	else
		treaty.visible_message(span_danger("...but one of the terms yet remains in the flame. It seems [target] has done you the favor of exiling themselves. Or perhaps, '[target]' never existed to begin with."))
	return

// someone signing off on their own exile will automatically fulfill the 2-signature requirement
/datum/treaty/terms/exile/get_signature_weight(signer_name)
	return signer_name == target ? 2 : 1
