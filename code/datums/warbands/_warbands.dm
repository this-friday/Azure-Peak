/*
////////////////////////																			////////////////////////
//////////////////////////////////////////////// NOTES ON WARBAND CREATION ////////////////////////////////////////////////
////////////////////////																			////////////////////////
	MAP SIZES
		warcamp: 45x45
		outskirts: 30x45
		intermission: 13x13

	in each WARCAMP map
		required objects:
			'/obj/effect/landmark/start/warlordlate'					| a spawn point
			'/obj/structure/fluff/warband/warband_recruit'				| a recruitment point
			'/obj/effect/solid_invisible_barrier/warband_spawnbarrier'	| this thing blocking the spawn room's exit
			'/obj/structure/fluff/warband/campaign_planner'				| this thing
			'/obj/structure/fluff/traveltile/warband/camp_to_outskirts' | an exit
			'/obj/structure/fluff/warband/shortcut' 					| an emergency entrance

		!VERY IMPORTANT!
			each area in a warcamp or outskirts template requires a baseturf helper
			otherwise, destroyed walls will cause errors
			it must be placed once in EACH AREA!!
			EACH!
			AREA!!

	in each OUTSKIRTS map
		'/obj/structure/fluff/traveltile/warband/outskirts_to_intermission' | an entrance
		'/obj/structure/fluff/traveltile/warband/outskirts_to_camp' | an exit
		in strongdmm they'll appear teal & purple


	in each INTERMISSION map
		'/obj/structure/fluff/traveltile/warband/intermission_to_azure' | an entrance
		'/obj/structure/fluff/traveltile/warband/intermission_to_outskirts' | an exit
		in strongdmm they'll appear red & orange

	add any warbands & aspects you make to the #define lists, otherwise they'll never pop up in the warband creation menu

////////////////////////																			////////////////////////
//////////////////////////////////////////////// NOTES ON WARBAND CREATION ////////////////////////////////////////////////
////////////////////////																			////////////////////////
*/
/datum/warbands
	var/title						// name used in the creation menu
	var/name = "Warband"			// name used outside the creation menu and during desertions

	// appears in treaties
	var/treaty_name = "Warband"
	var/treaty_desc = "Azuria bears no shortage of enemies."
	var/icon = 'icons/roguetown/weapons/shields32.dmi'
	var/icon_state = "ironsh"

	var/desc						// used for extra details
	var/summary						// first description in a warband's info tab | followed up by desc
	var/warning						// when a warband spawns, someone in the city is sent a warning letter w/details (its warband, aspects, etc)
	var/datum/map_template/warcamp	// a 45x45 map template
	var/datum/storytellerlimit		// certain warbands are only available with certain storytellers | when storytellers are accounted, the manager will look at the current storyteller, the storyteller chosen at roundstart, and each prince's patron
	var/rarity						// how many times the storytellerlimit needs to be met before a locked warband is unlocked
	var/subtyperequired = FALSE		// forces a warband to take a subtype

	var/list/faithlock = list()		// E.G: Atgervi & Warscholars
	var/list/racelock = list()		// E.G: Grudgebearers & Black Oak

	var/list/subtypes = list()
	var/list/aspects = list()

	var/points = 0					// selection cost in the creation menu
	var/list/warlordclasses = list()
	var/list/lieutenantclasses = list()
	var/list/gruntclasses = list()
	var/spawns						// lost when an NPC is spawned | combined with the baseline spawns (400)
	var/list/combatmusic = list()
	var/datum/outskirts_wave/outskirts_wave
	var/multiclass_enabled = FALSE	// when TRUE, the creation menu shows a second class picker | multiclassing results in both classes getting applied. currently used for Mercenaries
	var/subclass_required = FALSE	// when TRUE, a subclass/multiclass is required
	var/subclass_label = "SUBCLASS"	// note: if you want something to properly function as a multiclass option, add multiclass_capable = TRUE to the respective advclass

/datum/warbands/subtypes
	points = 0
	var/quote				// small flavortext for the creation menu
	var/quote_followup		// as above

/datum/warbands/aspects
	var/asclass				// aspects of the same class can't be selected simultaneously (i.e: two map aspects)

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////// WARBAND HOOKS
// override these in each warband's own file to customize per-warband behaviour

// returns the outfit type to equip a warband's NPCs
/datum/warbands/proc/get_grunt_outfit(mob/living/carbon/human/species/human/northern/goon/goon)
	return /datum/outfit/job/roguetown/human/species/human/northern/goon

// returns the base squad size
/datum/warbands/proc/get_base_squad_size(mob/user)
	return 4

// called when the final warband/subtype/aspects selections are confirmed by the warlord (stage 1 -> 2)
/datum/warbands/proc/on_warband_confirmed(atom/movable/screen/warband/manager/manager)
	return

// called from equip_character after the warlord has been fully equipped and all stats applied
/datum/warbands/proc/on_warlord_equip(mob/living/carbon/human/warlord, atom/movable/screen/warband/manager/manager)
	return

// called immediately after the warlord's character is spawned
/datum/warbands/proc/on_warlord_spawned(mob/living/carbon/human/warlord, atom/movable/screen/warband/manager/manager)
	return

// as above, but for grunts
/datum/warbands/proc/on_grunt_spawned(mob/living/carbon/human/grunt, atom/movable/screen/warband/manager/manager)
	return

// as above, but for lieutenants
/datum/warbands/proc/on_lieutenant_spawned(mob/living/carbon/human/lieutenant, atom/movable/screen/warband/manager/manager)
	return
