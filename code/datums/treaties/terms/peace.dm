/////////////////////////////////////////////////////////////
///////////////////////////////////////////////// TERM: PEACE
/*
	connects two mobs via a pair of components
	when one dies, so does the other
	thus, they're responsible for each other's safety

*/
/datum/treaty/terms/peace
	name = "Grith"
	desc = "Peace between two souls enforced by a threat of mutual death. If one dies, so shall the other."
	hint = "...something about peace..."
	authorities = list("target", "receiver")
	minimum_signatures = 2

/datum/treaty/terms/peace/build_input_fields()
	var/datum/treaty/input_field/number/days = new()
	days.key = "number"
	days.label = "Duration (Daes)"
	days.min_value = 1
	days.max_value = 7
	days.step = 1
	input_fields += days

	var/datum/treaty/input_field/text_input/first = new()
	first.key = "target"
	first.label = "First Bound Name"
	first.placeholder = "Enter First Bound Name..."
	input_fields += first

	var/datum/treaty/input_field/text_input/second = new()
	second.key = "receiver"
	second.label = "Second Bound Name"
	second.placeholder = "Enter Second Bound Name..."
	input_fields += second

/datum/treaty/terms/peace/duplicate_check(datum/treaty/terms/existing)
	if(!istype(existing, /datum/treaty/terms/peace))
		return FALSE
	// can't be in multiple Peace Pacts at once
	return (target == existing.target || target == existing.receiver || receiver == existing.target || receiver == existing.receiver)

/datum/treaty/terms/peace/apply(obj/item/treaty/treaty)
	if(!target || !receiver)
		return

	if(target == receiver)
		treaty.visible_message(span_danger("...but one of the terms yet remains in the flame. [target] and [receiver] could NEVER be at peace."))
		return
		
	var/mob/living/first_mob = treaty.text_to_mob(target)
	var/mob/living/second_mob = treaty.text_to_mob(receiver)

	if(!first_mob || !second_mob)
		treaty.visible_message(span_danger("...but one of the terms yet remains in the flame. Either '[target]' or '[receiver]' don't exist among the living."))
		return

	if(first_mob.GetComponent(/datum/component/peace) || second_mob.GetComponent(/datum/component/peace))
		treaty.visible_message(span_danger("...but one of the terms yet remains in the flame. One or both of the Amān's named souls - '[target]' or '[receiver]' - are already bound by an existing pact."))
		return

	first_mob.AddComponent(/datum/component/peace, second_mob, number)
	second_mob.AddComponent(/datum/component/peace, first_mob, number)
	to_chat(first_mob, span_userdanger("I have sworn to peace with [second_mob.real_name] for [number] daes. I am responsible for their lyfe, and vice-versa. Should one of us perish, so too shall the other."))
	to_chat(second_mob, span_userdanger("I have sworn to peace with [first_mob.real_name] for [number] daes. I am responsible for their lyfe, and vice-versa. Should one of us perish, so too shall the other."))
	return "Peace has been sworn between the [first_mob.job], [first_mob.real_name] and the [second_mob.job], [second_mob.real_name] under threat of mutual death. This peace will remain for [number] daes."
