////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// massive spawn bump (500)
// skyrockets Disorder by 10, effectively instantly shutting off the warband's Communicate verb and making a single desertion catastrophic
// storyteller-limited to Ravox & currently only given to Feud

/datum/warbands/aspects/war
	title = "TOTAL WAR"
	storytellerlimit = /datum/storyteller/ravox
	rarity = 2
	summary = "We arrive with one of the largest armies yet assembled. Proper cohesion, however, is nearly impossible."
	desc = "You are given a massive NPC spawn pool (+500). As a drawback, however, the Warband permanently suffers from 10 Disorder. This shuts off the Communicate verb."
	warning = "...of what could in fact be the largest army they've ever seen."
	points = -2

/datum/warbands/aspects/war/on_warband_confirmed(atom/movable/screen/warband/manager/manager, intensity = 1)
	manager.disorder += 10
	manager.spawns += 500
	manager.squad_size_bonus += 2
