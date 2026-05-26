////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// a bump to the warband's NPC spawns

/datum/warbands/aspects/extraspawns
	title = "GRAND HOST"
	summary = "Many have flocked to the Warlord's banner."
	desc = "Allied NPC spawn pool is increased by 150."
	warning = "...of a notably large size."
	points = -1

/datum/warbands/aspects/extraspawns/on_warband_confirmed(atom/movable/screen/warband/manager/manager, intensity = 1)
	manager.spawns += 150
