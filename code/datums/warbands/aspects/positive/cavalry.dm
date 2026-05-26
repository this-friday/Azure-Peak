////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// gives every grunt the Saddleborn virtue
// they're also exempt from the potential mood loss of losing their mount

/datum/warbands/aspects/cavalry
	title = "CAVALRY"
	summary = "Our warband's veterans are as adept in a saddle as they are beyond it."
	desc = "All Grunts are given the Saddleborn virtue."
	warning = "...of an approaching cavalry force."
	points = -1

/datum/warbands/aspects/cavalry/on_grunt_spawned(mob/living/carbon/human/grunt, atom/movable/screen/warband/manager/manager)
	apply_virtue(grunt, new /datum/virtue/utility/riding())
	grunt.adjust_skillrank_up_to(/datum/skill/misc/riding = 3, TRUE)
