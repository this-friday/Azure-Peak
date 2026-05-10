/////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// TERM: ATTAINDER
/*
	revokes a target's nobility trait
	operates similar to the Defenestration ritual, in the sense that TRAIT_DEFILED_NOBLE is added as a replacement
	
*/
/datum/treaty/terms/attainder
	name = "Attainder"
	desc = "The target's nobility is forfeit."
	hint = "...something about spoiled blood..."
	authorities = list("target", /datum/job/roguetown/lord, /datum/job/roguetown/priest)
	minimum_signatures = 2

/datum/treaty/terms/attainder/build_input_fields()
	var/datum/treaty/input_field/text_input/target_name = new()
	target_name.key = "target"
	target_name.label = "Target Name"
	target_name.placeholder = "Enter Target Name..."
	input_fields += target_name

/datum/treaty/terms/attainder/duplicate_check(datum/treaty/terms/existing)
	if(!istype(existing, /datum/treaty/terms/attainder))
		return FALSE
	return target == existing.target

/datum/treaty/terms/attainder/apply(obj/item/treaty/treaty)
	if(!target)
		return
		
	var/mob/living/victim = treaty.text_to_mob(target)
	if(!victim)
		treaty.visible_message(span_danger("...but one of the terms yet remains in the flame. There is no '[target]'."))
		return

	if(!HAS_TRAIT(victim, TRAIT_NOBLE))
		treaty.visible_message(span_warning("...but one of the terms yet remains in the flame. '[target]''s blood is too diluted to ignite."))
		return

	victim.Stun(60)
	victim.Knockdown(60)
	victim.emote("Agony")
	to_chat(victim, span_userdanger("My veins burn!"))
	victim.visible_message(span_warning("[victim] collapses, writhing in pain!"))
	REMOVE_TRAIT(victim, TRAIT_NOBLE, TRAIT_GENERIC)
	REMOVE_TRAIT(victim, TRAIT_NOBLE, TRAIT_VIRTUE)
	ADD_TRAIT(victim, TRAIT_DEFILED_NOBLE, TRAIT_GENERIC)

	return "[target]'s noble blood has been declared forfeit."

// someone signing off on their own attainder will automatically fulfill the 2-signature requirement
/datum/treaty/terms/attainder/get_signature_weight(signer_name)
	return signer_name == target ? 2 : 1
