// component used to facilitate treaty-enforced death battles (initiated with /datum/treaty/terms/blood_pact)
// meant to function in tandem with another blood_pact component on their opponent
// listens for its parent's death or concession, and declares a victory or defeat
/datum/component/blood_pact
	var/mob/living/opponent
	var/parent_name		// preserved in case of Gibbing
	var/opponent_name	// ^

/datum/component/blood_pact/Initialize(enemy)
	if(!isliving(parent) || !isliving(enemy))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/holder = parent
	opponent = enemy
	parent_name = holder.name
	opponent_name = opponent.name

	// each component only watches its own parent
	// when a mob dies or yields, their own component announces and cleans up both sides
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(parent, COMSIG_LIVING_SURRENDER, PROC_REF(on_yield))
	RegisterSignal(opponent, COMSIG_PARENT_QDELETING, PROC_REF(on_opponent_deleted))

/datum/component/blood_pact/proc/on_opponent_deleted(datum/source)
	SIGNAL_HANDLER
	opponent = null

/datum/component/blood_pact/proc/on_death(mob/living/source)
	announce_winner(opponent_name, parent_name, "death")
	cleanup()

/datum/component/blood_pact/proc/on_yield(mob/living/source)
	announce_winner(opponent_name, parent_name, "concession")
	cleanup()

/datum/component/blood_pact/proc/announce_winner(winner_name, loser_name, method)
	priority_announce("[winner_name] has prevailed over [loser_name] in a sanctioned Blood Pact by way of [method]. With all Ten as witness, [winner_name]'s cause is declared Just.", "Pact Concluded")

/datum/component/blood_pact/proc/cleanup()
	if(opponent)
		var/datum/component/blood_pact/other_component = opponent.GetComponent(/datum/component/blood_pact)
		if(other_component)
			other_component.opponent = null
			qdel(other_component)
	qdel(src)

/datum/component/blood_pact/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_SURRENDER))
	. = ..()

/datum/component/blood_pact/Destroy()
	opponent = null
	return ..()
