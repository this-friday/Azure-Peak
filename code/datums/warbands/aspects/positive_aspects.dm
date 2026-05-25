// alternate warcamp map: a well-stocked castle
/datum/warbands/aspects/fort
	title = "FORTRESS"
	asclass = "Map"
	points = -1
	warcamp = /datum/map_template/warcamp_standard_fort
	summary = "Rather than establishing a camp close to the capital, the Warband opted to capture a small castle in the countryside."
	desc = "ALTERNATE WARCAMP MAP: A well-stocked castle."
	warning = "...of a pillaged castle in the Duchy's northern reaches."

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// prevents /atom/movable/screen/warband/manager/proc/send_warnings() from going off

/datum/warbands/aspects/surprise
	title = "SURPRISE"
	summary = "No one will be forewarned of the Warband's arrival."
	desc = "By default, a warning letter detailing the Warband's choices is discovered by a random towner. SURPRISE prevents this."
	warning = "...?"
	points = -1

////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// increase to the base squad size (aka the squad size BEFORE any multipliers)

/datum/warbands/aspects/horde
	title = "HORDE"
	summary = "Our squads become a sprawling mass of eager combatants."
	desc = "Increases squad size by 1 per intensity."
	warning = "...of a relentless tide that threatens to completely drown the battlefield."
	points = -1
	max_intensity = 3

// rank 1: -1 | rank 2: -3 | rank 3: -5
/datum/warbands/aspects/horde/get_points_at_intensity(intensity)
	return -(1 + (intensity - 1) * 2)

/datum/warbands/aspects/horde/on_warband_confirmed(atom/movable/screen/warband/manager/manager, intensity = 1)
	manager.squad_size_bonus += 1 * intensity

////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// warband starts off with negative disorder, effectively allowing them to recruit a wretch for free
// opposite of (/datum/warbands/aspects/splintered)

/datum/warbands/aspects/morale
	title = "TIGHT SHIP"
	summary = "The beatings continued until morale improved. Disorder is at an all-time low!"
	desc = "Reduces starting Disorder by 1 per intensity rank."
	warning = "...of a spirited, driven foe."
	points = -1
	max_intensity = 3

/datum/warbands/aspects/morale/get_points_at_intensity(intensity)
	return -intensity

/datum/warbands/aspects/morale/on_warband_confirmed(atom/movable/screen/warband/manager/manager, intensity = 1)
	manager.disorder -= intensity // intentionally not -4

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// massive spawn bump (500)
// skyrockets Disorder by 10, effectively instantly shutting off the warband's Communicate verb and making a single desertion catastrophic
// storyteller-limited to Ravox

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

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
