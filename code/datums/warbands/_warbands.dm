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

////////////////////////																			////////////////////////
//////////////////////////////////////////////// NOTES ON WARBAND CREATION ////////////////////////////////////////////////
////////////////////////																			////////////////////////
*/
/datum/warbands
	abstract_type = /datum/warbands
	var/points = -1					// selection cost in the creation menu | -1 by default, so the warband is forced to pick at least 1 drawback at minimum during selection
	var/title						// name used in the creation menu
	var/name = "Warband"			// name used outside the creation menu and during desertions

	// appears in treaties. purely flavor
	var/treaty_name = "Warband"
	var/treaty_desc = "Azuria bears no shortage of enemies."
	var/icon = 'icons/roguetown/weapons/shields32.dmi'
	var/icon_state = "ironsh"

	var/desc = ""					// used for extra details
	var/summary						// first description in a warband's info tab | followed up by desc
	var/warning						// a string | when a warband spawns, we collect these strings and send someone in the city a warning letter w/details (its warband, aspects, etc)
	var/datum/map_template/warcamp	// a 45x45 map template
	var/datum/storytellerlimit		// certain warbands are only available with certain storytellers | the manager tallies each prince's contributed patron (see patron_refresh())
	var/rarity						// how many times the storytellerlimit needs to be met before a locked warband is unlocked
	var/subtyperequired = FALSE		// forces a warband to take a subtype

	var/list/faithlock = list()		// E.G: Atgervi & Warscholars
	var/list/racelock = list()		// E.G: Grudgebearers & Black Oak

	var/list/subtypes = list()
	var/list/aspects = list()

	var/list/warlordclasses = list()
	var/list/lieutenantclasses = list()
	var/list/gruntclasses = list()

	var/list/suppressed_classes = list()	// specific classes to override/hide from this selection's class/subclass panels | similar to suppress_all_other_classes, but much more targeted
	var/suppress_all_other_classes = FALSE	// when TRUE, it overrides/hides ALL other primary classes in its affected role tier | the prime example of this is (/datum/warbands/aspects/patron)

	var/universal_subclasses_enabled = FALSE	// enables universal classes for a warband | the chosen universal class is applied on top of the primary. currently used for Mercenaries	
	var/list/universal_warlordclasses = list()
	var/list/universal_lieutenantclasses = list()
	var/list/universal_gruntclasses = list()


	var/spawns // lost when an NPC is spawned | combined with the baseline spawns (400)
	var/list/combatmusic = list()
	var/datum/outskirts_wave/outskirts_wave

	var/subclass_required = FALSE	// When TRUE, a selected subclass is mandatory
	var/subclass_label = "SUBCLASS"

	var/list/input_fields = list()
	var/max_intensity = 1	// 1 = no intensity scale (just selected/not) | higher values unlock intensity ranks	
	var/max_aspects = 5		// how many aspects the warlord may select
	
/datum/warbands/New()
	input_fields = list()
	build_input_fields()

/datum/warbands/proc/build_input_fields()
	return

/datum/warbands/proc/serialize_input_fields()
	var/list/out = list()
	for(var/datum/treaty/input_field/field in input_fields)
		out += list(field.serialize())
	return out

/datum/warbands/subtypes
	abstract_type = /datum/warbands/subtypes
	points = 0
	var/quote			// flavortext sent to all members when the warlord spawns
	var/quote_followup	// as above

/datum/warbands/aspects
	abstract_type = /datum/warbands/aspects
	var/asclass			// aspects of the same class can't be selected simultaneously (i.e: two map aspects)

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////// WARBAND HOOKS
// override these in each warband's own file to customize per-warband behaviour

// returns the outfit type to equip a warband's NPCs
/datum/warbands/proc/get_grunt_outfit(mob/living/carbon/human/species/human/northern/goon/goon)
	return /datum/outfit/job/roguetown/human/species/human/northern/goon

// returns the base squad size
/datum/warbands/proc/get_base_squad_size(mob/user, datum/advclass/primary_class)
	return ALLIED_NPC_MINIMUM // 4

// called by set_race_and_faith_locks() after locks are built
// the standard restriction message fires at the end if nothing returns TRUE
/datum/warbands/proc/on_locks_applied(datum/warband_manager/manager)
	return FALSE

// called when the warband is confirmed by the warlord (stage 1 -> 2)
// intensity: the selected intensity rank for this aspect (1 if not intensity-capable)
/datum/warbands/proc/on_warband_confirmed(datum/warband_manager/manager, intensity = 1)
	return

// called from equip_character after the warlord has been fully equipped and all stats applied
/datum/warbands/proc/on_warlord_equip(mob/living/carbon/human/warlord, datum/warband_manager/manager)
	return

// called immediately after the warlord's character is spawned
/datum/warbands/proc/on_warlord_spawned(mob/living/carbon/human/warlord, datum/warband_manager/manager)
	return

// as above, but for grunts
/datum/warbands/proc/on_grunt_spawned(mob/living/carbon/human/grunt, datum/warband_manager/manager)
	return

// as above, but for lieutenants
/datum/warbands/proc/on_lieutenant_spawned(mob/living/carbon/human/lieutenant, datum/warband_manager/manager)
	return

// returns the selection point cost at a given intensity rank
// override in intensity-capable aspects to return the correct cost per rank
/datum/warbands/aspects/proc/get_points_at_intensity(intensity)
	return points

// builds a list of costs indexed by rank for serialization
/datum/warbands/aspects/proc/build_intensity_costs()
	var/list/costs = list()
	for(var/i = 1 to max_intensity)
		costs += get_points_at_intensity(i)
	return costs

// sends quote and quote_followup to all lobby members when the warlord spawns
/datum/warbands/subtypes/on_warlord_spawned(mob/living/carbon/human/warlord, datum/warband_manager/manager)
	if(quote)
		for(var/mob/living/member in manager.lobby_members)
			to_chat(member, "<span style='color:#7a2525'><i>[quote]</i></span>")
	if(quote_followup)
		for(var/mob/living/member in manager.lobby_members)
			to_chat(member, "<span style='color:#582424'><b>[quote_followup]</b></span>")
