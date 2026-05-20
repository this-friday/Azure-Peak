// alternate warcamp map: a well-stocked castle
/datum/warbands/aspects/fort
	title = "FORTRESS"
	asclass = "Map"
	points = -1
	warcamp = /datum/map_template/warcamp_standard_fort
	summary = "Rather than establishing a camp close to the capital, the Warband opted to capture a small castle in the countryside."
	warning = "...of a pillaged castle in the Duchy's northern reaches."

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// prevents /atom/movable/screen/warband/manager/proc/send_warnings() from going off

/datum/warbands/aspects/surprise
	title = "SURPRISE"
	summary = "No one will be forewarned of the Warband's arrival."
	warning = "...?"
	points = -1

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// a bump to the warband's NPC spawns

/datum/warbands/aspects/extraspawns
	title = "GRAND HOST"
	summary = "Many have flocked to the Warlord's banner."
	warning = "...of a notably large size."
	points = -1

/datum/warbands/aspects/extraspawns/on_warband_confirmed(atom/movable/screen/warband/manager/manager)
	manager.spawns += 150

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// increase to the base squad size (aka the squad size BEFORE any multipliers)

/datum/warbands/aspects/horde
	title = "HORDE"
	summary = "Our squads become a sprawling mass of eager combatants."
	warning = "...of a relentless tide that threatens to completely drown the battlefield."
	points = -1

/datum/warbands/aspects/horde/on_warband_confirmed(atom/movable/screen/warband/manager/manager)
	manager.squad_size_bonus += 2

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// gives all grunts the Combat Aware trait

/datum/warbands/aspects/battletested
	title = "BATTLE-TESTED"
	summary = "The Warband's veterans are a step above their peers."
	warning = "...of a trained, lethal foe."
	points = -1

/datum/warbands/aspects/battletested/on_grunt_spawned(mob/living/carbon/human/grunt, atom/movable/screen/warband/manager/manager)
	ADD_TRAIT(grunt, TRAIT_COMBAT_AWARE, TRAIT_GENERIC)

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// warband starts off with negative disorder, effectively allowing them to recruit 2 wretches for free
// opposite of (/datum/warbands/aspects/splintered)

/datum/warbands/aspects/morale
	title = "TIGHT SHIP"
	summary = "The beatings continued until morale improved. Disorder is at an all-time low!"
	warning = "...of a spirited, driven foe."
	points = -1

/datum/warbands/aspects/morale/on_warband_confirmed(atom/movable/screen/warband/manager/manager)
	manager.disorder -= 2 // intentionally not -4

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
	warning = "...of what could in fact be the largest army they've ever seen."
	points = -2

/datum/warbands/aspects/war/on_warband_confirmed(atom/movable/screen/warband/manager/manager)
	manager.disorder += 10
	manager.spawns += 500
	manager.squad_size_bonus += 2

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
