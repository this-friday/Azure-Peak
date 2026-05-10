// component used to facilitate a treaty-enforced Peace (initiated with /datum/treaty/terms/peace)
// meant to function in tandem with another Peace component on the bound partner
// when one bound mob dies, this component kills the other
/datum/component/peace
	var/mob/living/carbon/partner
	var/parent_name		// preserved in case of Gibbing
	var/partner_name	// ^
	var/days_remaining
	var/death_imminent = FALSE

/datum/component/peace/Initialize(bound_partner, num_days)
	if(!isliving(parent) || !isliving(bound_partner))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/holder = parent
	partner = bound_partner
	parent_name = holder.name
	partner_name = partner.name
	days_remaining = num_days

	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(parent, COMSIG_LIVING_TOD_CHANGE_DAWN, PROC_REF(on_tod_change))

/datum/component/peace/proc/on_tod_change()
	var/mob/living/holder = parent
	if(GLOB.tod != "dawn")
		return
	days_remaining--
	if(days_remaining > 0)
		to_chat(holder, span_notice("My pact with [partner_name] will conclude in [days_remaining] daes."))
	if(days_remaining <= 0)
		expire()

/datum/component/peace/proc/on_death()
	if(!partner || partner.stat == DEAD)
		cleanup()
		return
	var/datum/component/peace/partner_component = partner.GetComponent(/datum/component/peace)		
	if(partner_component)
		addtimer(CALLBACK(partner_component, PROC_REF(break_followup)), 10 SECONDS)
		partner_component.death_imminent = TRUE
	to_chat(partner, span_userdanger("My pact with [parent_name] has been broken! My lyfe comes undone!"))
	partner.visible_message(span_warning("[partner] goes pale, before suddenly doubling over!"))
	partner.vomit(blood = TRUE)
	partner.Knockdown(60)

/datum/component/peace/proc/break_followup()
	var/mob/living/holder = parent
	if(!holder || QDELETED(holder) || holder.stat == DEAD)
		return
	holder.adjustOxyLoss(200)
	cleanup()

/datum/component/peace/proc/expire()
	if(!QDELETED(parent))
		to_chat(parent, span_notice("My pact with [partner_name] has expired. Henceforth, either of us are more than welcome to die."))
	if(partner && !QDELETED(partner))
		to_chat(partner, span_notice("My pact with [parent_name] has expired. Henceforth, either of us are more than welcome to die."))
	if(partner)
		var/datum/component/peace/other_component = partner.GetComponent(/datum/component/peace)
		if(other_component)
			other_component.partner = null
			qdel(other_component)
	qdel(src)

/datum/component/peace/proc/cleanup()
	if(partner)
		var/datum/component/peace/other_component = partner.GetComponent(/datum/component/peace)
		if(other_component)
			other_component.partner = null
			if(!other_component.death_imminent)
				qdel(other_component)
	qdel(src)

/datum/component/peace/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_TOD_CHANGE_DAWN))
	. = ..()

/datum/component/peace/Destroy()
	partner = null
	return ..()
