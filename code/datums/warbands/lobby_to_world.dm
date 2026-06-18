/*	
	WARBAND SPAWNING
	- everything that happens in the transition between the lobby and gameplay
	- creates the faction, spawns the warcamp, equips & places characters, and wires up the portals leading in & out

	1 - CREATE FACTION 			// creates the faction required to interface w/treaties
	2 - SET IDS					// sets the ID of every unregistered warband object
	3 - LINK PORTALS			// called when a warband creates an outskirts map | links together all the portals that got spawned
	4 - SET DEFAULT EXIT		// decides the initial exit point for envoys
	5 - CHOOSE MAP				// choose & spawn the warcamp
	6 - CHOOSE MUSIC			// choose the combat music
	7 - SPAWN WARBAND			// spawns the warband after some final tweaks	
	8 - SEND WARNINGS 			// sends a warning letter to a single towner containing hints about the warband's type & aspects

*/

//////////////////////////////////////////////////
/////////////////////////////////// CREATE FACTION
/*
	generate a faction for dealing w/treaties
	receives the faction & initial territory's name from the selected warband & subtype datums
*/
/datum/warband_manager/proc/choose_warband_faction(owner)
	var/chosen_name
	var/chosen_desc
	var/datum/treaty_flavor/new_faction = new /datum/treaty_flavor/custom

	if(selected_subtype) // look for a subtype first
		if(selected_subtype.treaty_name != "Warband")
			chosen_name = selected_subtype.treaty_name
		if(selected_subtype.treaty_desc != "Azuria bears no shortage of enemies.")
			chosen_desc = selected_subtype.treaty_desc

	if(!chosen_name) // if there's no subtype, fall back on the warband's descriptions
		chosen_name = selected_warband.treaty_name
	if(!chosen_desc)
		chosen_desc = selected_warband.treaty_desc

	return new_faction.generate_faction(owner, chosen_name, chosen_desc, stewardhidden = TRUE)

/////////////////////////////////////////////////////////
///////////////////////////////////////////////// SET IDS
/*
	sets the ID of every unregistered warband object

	called when a warband is created
	called again when the warband spawns an outskirts & intermission map

*/
/datum/warband_manager/proc/set_IDs()
	for(var/obj/structure/fluff/warband/warband_object in SSwarbands.warband_machines)
		if(warband_object.warband_ID == 0)
			warband_object.linked_warband = src
			warband_object.warband_ID = src.warband_ID
	for(var/obj/effect/solid_invisible_barrier/warband_spawnbarrier/spawn_blocker in SSwarbands.warband_machines)
		if(spawn_blocker.warband_ID == 0)
			spawn_blocker.linked_warband = src
			spawn_blocker.warband_ID = src.warband_ID
	for(var/obj/structure/fluff/traveltile/warband/warband_tile in SSwarbands.warband_machines)
		if(warband_tile.warband_ID == 0 || (warband_tile.warband_ID == warband_ID && !warband_tile.linked_warband))
			warband_tile.linked_warband = src
			warband_tile.warband_ID = src.warband_ID
		if(warband_tile.type == /obj/structure/fluff/traveltile/warband/camp_to_outskirts && warband_tile.warband_ID == warband_ID)
			warband_tile.aportalid = "camp_[warband_ID]"
			warband_tile.aportalgoesto = "outskirts_[warband_ID]"

//////////////////////////////////////////////////////////////
///////////////////////////////////////////////// LINK PORTALS
/*
	links together all of a warband's travel tiles with a shared warband_ID
*/
/datum/warband_manager/proc/link_portals()
	for(var/obj/structure/fluff/traveltile/warband/warband_tile in SSwarbands.warband_machines)
		if(warband_tile.warband_ID == warband_ID)
			if(warband_tile.type == /obj/structure/fluff/traveltile/warband/azure_to_intermission)
				warband_tile.aportalid = "azureside_[warband_ID]"
				warband_tile.aportalgoesto = "intermission_[warband_ID]"
			if(warband_tile.type == /obj/structure/fluff/traveltile/warband/intermission_to_azure)
				warband_tile.aportalid = "intermission_[warband_ID]"
				warband_tile.aportalgoesto = "azureside_[warband_ID]"
			if(warband_tile.type == /obj/structure/fluff/traveltile/warband/intermission_to_outskirts)
				warband_tile.aportalid = "pre_outskirts_[warband_ID]"
				warband_tile.aportalgoesto = "azureside_outskirts_[warband_ID]"
			if(warband_tile.type == /obj/structure/fluff/traveltile/warband/outskirts_to_intermission)
				warband_tile.aportalid = "azureside_outskirts_[warband_ID]"
				warband_tile.aportalgoesto = "pre_outskirts_[warband_ID]"
			if(warband_tile.type == /obj/structure/fluff/traveltile/warband/outskirts_to_camp)
				warband_tile.aportalid = "outskirts_[warband_ID]"
				warband_tile.aportalgoesto = "camp_[warband_ID]"

// returns FALSE if a turf sits in an area we never want to spawn a warband into
// currently just the wretch lair/cave, as we shouldn't really have anything to worry about beyond that
/datum/warband_manager/proc/is_valid_wretch_turf(turf/T)
	if(!T)
		return FALSE
	var/area/A = get_area(T)
	if(istype(A, /area/rogue/under/cave/inhumen))
		return FALSE
	if(istype(A, /area/rogue/outdoors/woods/wretch_lair))
		return FALSE
	return TRUE

// picks a random valid wretch spawn landmark
/datum/warband_manager/proc/get_random_wretch_landmark()
	var/list/candidates = list()
	for(var/obj/effect/landmark/start/wretchlate/wretch in GLOB.start_landmarks_list)
		if(is_valid_wretch_turf(get_turf(wretch)))
			candidates += wretch
	if(candidates.len)
		return pick(candidates)
	return

//////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// SET DEFAULT EXIT
/*
	before the warcamp's z-level is connected to the main z-level, they need envoys to establish travel tiles
	before those travel tiles are established, the envoys spawn on a Default Exit

	the Default Exit is one of the wretch spawn landmarks
	if there's no valid wretch landmark, we fall back on the Adventurer Spawn

*/
/datum/warband_manager/proc/set_default_exit()
	var/obj/effect/landmark/random_landmark = get_random_wretch_landmark()

	if(!random_landmark)
		for(var/obj/effect/landmark/start/adventurerlate/fallback_spawn_landmark in GLOB.start_landmarks_list)
			random_landmark = fallback_spawn_landmark
			break

	for(var/obj/structure/fluff/traveltile/warband/camp_to_outskirts/exit_tile in SSwarbands.warband_machines)
		if(exit_tile.warband_ID == warband_ID)
			exit_tile.chosen_landmark = random_landmark

//////////////////////////////////////////////
/////////////////////////////////// CHOOSE MAP
/*
	selects & spawns a map
	prioritizes a choice from an aspect or subtype before falling back on the warband map

	if there's no room to spawn a fresh warcamp (e.g. prior warbands consumed all the warcamp landmarks), we flag the warband to spawn directly in the field at a wretch landmark
*/
/datum/warband_manager/proc/choose_map(latespawn = FALSE)
	var/warcamp_template_type

	if(selected_aspects)
		for(var/datum/warbands/aspects/aspect in selected_aspects)
			if(aspect.warcamp)
				warcamp_template_type = aspect.warcamp
				break
	if(!warcamp_template_type && selected_subtype && selected_subtype.warcamp)
		warcamp_template_type = selected_subtype.warcamp
	if(!warcamp_template_type && selected_warband && selected_warband.warcamp)
		warcamp_template_type = selected_warband.warcamp

	if(!warcamp_template_type)
		return FALSE

	var/datum/map_template/chosenmap = new warcamp_template_type()

	if(!chosenmap)
		return FALSE

	for(var/obj/effect/landmark/warcamp/warcamp_landmark in GLOB.landmarks_list)
		var/list/bounds = chosenmap.load(warcamp_landmark.loc, centered = TRUE)
		qdel(warcamp_landmark)
		if(!bounds)
			continue
		warcamp_established = TRUE
		break

	// no warcamp could be placed, so we just drop the warband straight onto the field at a wretch spawn landmark and continue
	if(!warcamp_established)
		var/obj/effect/landmark/field_landmark = get_random_wretch_landmark()
		if(!field_landmark)
			return FALSE
		warband_spawn_turf = get_turf(field_landmark)
		return TRUE

	if(latespawn == TRUE)
		for(var/obj/effect/landmark/start/warlordlate/warlord_spawn in GLOB.landmarks_list)
			qdel(warlord_spawn)
			break
	return TRUE

////////////////////////////////////////////////
/////////////////////////////////// CHOOSE MUSIC
/*
	same process as map selection, but for music

*/
/datum/warband_manager/proc/choose_combat_music()
	var/chosen_combatmusic
	if(selected_aspects)
		for(var/datum/warbands/aspects/aspect in selected_aspects)
			if(aspect.combatmusic.len)
				chosen_combatmusic = aspect.combatmusic
				break

	if(!chosen_combatmusic)
		if(selected_subtype && selected_subtype.combatmusic)
			chosen_combatmusic = selected_subtype.combatmusic

	if(!chosen_combatmusic)
		if(selected_warband && selected_warband.combatmusic)
			chosen_combatmusic = selected_warband.combatmusic

	if(!chosen_combatmusic)
		return

	if(chosen_combatmusic)
		combatmusic = chosen_combatmusic
		return

/////////////////////////////////////////////////
/////////////////////////////////// SPAWN WARBAND
/*
	chooses variables with priority & spawns the final result
	for example, a map provided from an aspect is prioritized over one from a subtype, and a subtype map's prioritized over the base warband's map
*/
/datum/warband_manager/proc/spawn_warband(mob/user, rebellion = FALSE)
	stop_creation_timer() // before choose_map: the template load sleeps, and the timeout must not fire mid-finalization
	if(rebellion == FALSE) // if a warband is spawning via a lieutenant's desertion,
		choose_map()
	choose_combat_music()
	// apply the band's & subtype's spawn pool contributions on top of the 400 baseline
	if(selected_warband?.spawns)
		spawns += selected_warband.spawns
	if(selected_subtype?.spawns)
		spawns += selected_subtype.spawns
	for(var/datum/warband_manager/other_manager in SSwarbands.warband_managers)
		if(other_manager == src)
			continue
		if(other_manager.finalized && has_compatible_cache(other_manager))
			share_cache_with(other_manager)
			break
	initialize_outskirts_encounter()
	linked_faction = choose_warband_faction(user)
	linked_faction.member_names += user.real_name
	finalized = TRUE
	announce_spawn_to_deadchat(user)

/datum/warband_manager/proc/announce_spawn_to_deadchat(mob/warlord)
	if(!selected_warband)
		return
	var/announcement = "[selected_warband.title]"
	if(selected_subtype)
		announcement += " ([selected_subtype.title])"
	if(length(selected_aspects))
		var/list/aspect_names = list()
		for(var/datum/warbands/aspects/aspect in selected_aspects)
			aspect_names += aspect.title
		announcement += " | ASPECTS: [aspect_names.Join(", ")]"
	if(casus_belli_selection)
		announcement += " | CASUS BELLI: [casus_belli_selection.custom_name || casus_belli_selection.name]"
	deadchat_broadcast(" has spawned: [announcement]", "<b>A WARBAND</b>", follow_target = warlord)

/////////////////////////////////////////////////
/////////////////////////////////// SEND WARNINGS
/*
	creates a list of people from GLOB.player_list
		a warning letter is created and sent out
		the chance of reception varies depending on each person's job

	1 is chosen to receive a warning letter containing information on:
		the main warband type 
		any subtype
		any selected aspects

	cancels immediately if the spawning Warband has taken the "Surprise" aspect

*/
/datum/warband_manager/proc/send_warnings()
	for(var/datum/warbands/aspects/chosen_aspect in selected_aspects)
		if(istype(chosen_aspect, /datum/warbands/aspects/surprise))
			return // if the incoming warband has the Surprise aspect, no one's getting warned

	// most likely roles to be chosen to receive the warning
	var/list/most_likely = list(
		"Hand",
		"Councillor",
		"Inquisitor",
		"Marshal",
		"Towner",
		"Soilson",
	) 

	var/mob/living/carbon/human/recipient
	var/list/priority_candidates = list()
	var/list/general_candidates = list()

	// roles in this list are blacklisted from being warned
	var/list/warband_roles = list(ROLE_WARLORD, ROLE_WARLORD_ASPIRANT, ROLE_WARLORD_LIEUTENANT, ROLE_WARLORD_GRUNT, ROLE_WARLORD_ENVOY)
	for(var/mob/living/carbon/human/candidate in GLOB.player_list)
		if(candidate.stat == DEAD || !candidate.client)
			continue
		if(candidate.mind && (candidate.mind.special_role in warband_roles))
			continue
		var/turf/T = get_turf(candidate)
		if(!T || !istype(T.loc, /area/rogue/outdoors))
			continue // skip candidates who aren't outside
		if(candidate.job in most_likely)
			priority_candidates += candidate
		else
			general_candidates += candidate

	if(!priority_candidates.len && !general_candidates.len)
		return // if no one's outside, no warning is getting sent
	
	// 75% chance to choose a likely candidate, 25% chance for someone completely random
	if(prob(75) && priority_candidates.len)
		recipient = pick(priority_candidates)
	else if(general_candidates.len)
		recipient = pick(general_candidates)
	else if(priority_candidates.len)
		recipient = pick(priority_candidates)

	if(!recipient)
		return

	var/final_readout = "Terrible news has been hastily scrawled upon old, torn parchment. It warns...<BR>\n"
	if(selected_warband && selected_warband.warning)
		final_readout += "<BR>\n[selected_warband.warning]"
	if(selected_subtype && selected_subtype.warning)
		final_readout += "<BR>\n[selected_subtype.warning]"
	for(var/datum/warbands/aspects/chosenaspect in selected_aspects)
		if(chosenaspect && chosenaspect.warning)
			final_readout += "<BR>\n[chosenaspect.warning]"

	var/obj/item/paper/warband_warning/newparchment = new /obj/item/paper/warband_warning(recipient.loc)
	newparchment.info = final_readout
	to_chat(recipient, span_warning("Something crunches underfoot. I've stepped on a crumpled, blood-stained heap of parchment.")) 

	recipient.playsound_local(recipient, 'sound/villain/littlescary.ogg', 100, FALSE)

/obj/item/paper/warband_warning
	name = "hastily-written warning"
