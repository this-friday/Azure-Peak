//////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// TERM: BLOOD PACT
/*
	locks two characters into a 'duel'
	gives them a component to track the duel's status (/datum/component/blood_pact)
	whomever Yields or Dies while the component is listening, is declared to be the loser

	besides this, there's no real effect aside from an announcement declaring the loser a Punk Bitch (and them most likely being dead)

*/
/datum/treaty/terms/blood_pact
	name = "Blood Pact"
	desc = "A recognized blood dispute between two parties. Whom is Just is determined after death - whether this be achieved in combat or another, equally lethal challenge."
	hint = "...something about blood being spilled to settle a score..."
	authorities = list("target", "receiver", /datum/job/roguetown/marshal)
	minimum_signatures = 2

/datum/treaty/terms/blood_pact/build_input_fields()
	var/datum/treaty/input_field/text_input/challenger = new()
	challenger.key = "target"
	challenger.label = "Challenger Name"
	challenger.placeholder = "Enter Challenger Name..."
	input_fields += challenger

	var/datum/treaty/input_field/text_input/defender = new()
	defender.key = "receiver"
	defender.label = "Defender Name"
	defender.placeholder = "Enter Defender Name..."
	input_fields += defender

/datum/treaty/terms/blood_pact/duplicate_check(datum/treaty/terms/existing)
	if(!istype(existing, /datum/treaty/terms/blood_pact))
		return FALSE
	// a combatant can't be in multiple blood pacts
	return (target == existing.target || target == existing.receiver || receiver == existing.target || receiver == existing.receiver)

/datum/treaty/terms/blood_pact/apply(obj/item/treaty/treaty)
	if(!target || !receiver)
		return

	if(target == receiver)
		treaty.visible_message(span_danger("...but one of the terms yet remains in the flame, for a man cannot wage a blood dispute against himself. Perhaps he *could*. But it seems Astrata has neither the mind nor tyme to mediate it."))
		return

	var/mob/living/challenger_mob = treaty.text_to_mob(target)
	var/mob/living/defender_mob = treaty.text_to_mob(receiver)

	if(!challenger_mob || !defender_mob)
		treaty.visible_message(span_danger("...but one of the terms yet remains in the flame. Either '[target]' or '[receiver]' don't exist among the living."))
		return

	if(challenger_mob.GetComponent(/datum/component/blood_pact) || defender_mob.GetComponent(/datum/component/blood_pact))
		treaty.visible_message(span_danger("...but one of the terms yet remains in the flame. One or both of the Blood Pact's named combatants - '[target]' or '[receiver]' - are already entangled in an existing pact."))
		return
		
	challenger_mob.AddComponent(/datum/component/blood_pact, defender_mob)
	defender_mob.AddComponent(/datum/component/blood_pact, challenger_mob)
	to_chat(challenger_mob, span_userdanger("I've been sealed into a Blood Pact with [receiver]. The last one standing shall be declared the victor."))
	to_chat(defender_mob, span_userdanger("I've been sealed into a Blood Pact with [target]. The last one standing shall be declared the victor."))
	return "A Blood Pact has been sealed between the [challenger_mob.job] known as [target], and the [defender_mob.job], [receiver]."
