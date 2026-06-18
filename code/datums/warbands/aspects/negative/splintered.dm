////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// the warband's disorder is increased by 4
// opposite of (/datum/warbands/aspects/morale)

/datum/warbands/aspects/splintered
	title = "SPLINTERED"
	summary = "Old grievances have already fractured the warband's chain of command."
	desc = "Begin with +4 Disorder."
	warning = "...of a warband in open disarray. It's a miracle they got here at all."
	points = 1
 
/datum/warbands/aspects/splintered/on_warband_confirmed(datum/warband_manager/manager, intensity = 1)
	manager.disorder += 4
