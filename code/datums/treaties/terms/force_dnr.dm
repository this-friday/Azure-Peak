//////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// TERM: SEAL GRAVE
/*
	when the target dies, they are considered "sealed". if they're resurrected afterwards, they get a variant of sunlight vulnerability
	state is tracked by /datum/component/grave_seal

	can potentially be cleansed by a Hag, via /datum/hag_boon/misc/cleanse_grave_seal
*/
/datum/treaty/terms/seal_grave
	name = "Seal Grave"
	desc = "Their death shall be final. Should they resurrect, they'll burn beneath sunlight."
	hint = "...something about seals...?"
	authorities = list("target", /datum/job/roguetown/lord, /datum/job/roguetown/priest)
	minimum_signatures = 2

/datum/treaty/terms/seal_grave/build_input_fields()
	var/datum/treaty/input_field/text_input/target_name = new()
	target_name.key = "target"
	target_name.label = "Target Name"
	target_name.placeholder = "Enter Target Name..."
	input_fields += target_name

/datum/treaty/terms/seal_grave/duplicate_check(datum/treaty/terms/existing)
	if(!istype(existing, /datum/treaty/terms/seal_grave))
		return FALSE
	return target == existing.target

/datum/treaty/terms/seal_grave/apply(obj/item/treaty/treaty)
	if(!target)
		return

	var/mob/living/seal_target = treaty.text_to_mob(target)

	if(seal_target)
		seal_target.AddComponent(/datum/component/grave_seal)
		return "The grave of [target] is considered sealed. Should they die, any resurrection shall result in a damned lyfe."
	else
		treaty.visible_message(span_danger("...but one of the terms yet remains in the flame. '[target]''s grave couldn't be sealed."))
	return

// someone signing off to seal their own grave will automatically fulfill the 2-signature requirement
/datum/treaty/terms/seal_grave/get_signature_weight(signer_name)
	return signer_name == target ? 2 : 1
