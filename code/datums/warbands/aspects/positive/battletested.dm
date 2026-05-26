////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// gives all grunts the Combat Aware trait

/datum/warbands/aspects/battletested
	title = "BATTLE-TESTED"
	summary = "The Warband's veterans are a step above their peers."
	desc = "All Grunts are given the Combat Aware trait."
	warning = "...of a trained, lethal foe."
	points = -1

/datum/warbands/aspects/battletested/on_grunt_spawned(mob/living/carbon/human/grunt, atom/movable/screen/warband/manager/manager)
	ADD_TRAIT(grunt, TRAIT_COMBAT_AWARE, TRAIT_GENERIC)
