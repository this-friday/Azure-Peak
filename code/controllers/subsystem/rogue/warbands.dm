SUBSYSTEM_DEF(warbands)
	name = "warbands"
	wait = 20
	flags = SS_KEEP_TIMING
	priority = 15
	init_order = INIT_ORDER_MAPPING + 1
	var/list/warband_managers = list()
	var/list/warband_machines = list()
	var/warband_managers_busy = FALSE	// prevents multiple warbands from being loaded in at once | necessary, as warband_ID assignments for objects will expect this to be the case
	var/atom/movable/screen/warband/manager/roundstart_manager
	var/roundstart_manager_claimed = FALSE
	var/next_warband_id = 1

	var/list/treaties = list()
	var/list/submitted_treaties = list()
	var/territory_factions = list()

	// list of associated faction names & jobs
	var/list/name_to_faction_cache = list() 	 
	var/list/job_to_faction_cache = list()

	var/classes_initialized = FALSE

	var/list/currentrun_encounters = list()

	// npc cache
	// we're spawning large groups of complex mobs at once (especially during outskirts fights), so this is softens the lag spikes
	var/list/unassigned_mob_cache = list()	
	var/max_unassigned_cache = 100			// max size for the unassigned goon cache
	var/ticks_between_equip = 6
	var/grunt_equip_timer = 0
	var/current_warband_index = 1			// when equipping goons in the cache, we determine which warband receives a cache refill in a Round Robin style
	var/grunts_to_create = 0
	var/grunt_processing_phase = 0			// 0 = equip phase, 1 = create phase, 2 = lobby phase
	var/cache_mode = 0						// 0 = initial burst, 1 = slowmode

	// player cache
	var/list/lobby_mob_cache = list()		// for a reduced impact when the round starts, since we're getting mobs from scratch | also used for Envoys & latespawns, because why not. they're already here
	var/list/replaced_mobs = list()

	//
	var/list/cached_warbands = list()
	var/list/cached_subtypes = list()
	var/list/cached_aspects = list()
	var/list/cached_classes = list()

	var/list/datum/warbands/warband_lookup = list()
	var/list/datum/warbands/subtype_lookup = list()
	var/list/datum/warbands/aspect_lookup = list()	

/datum/controller/subsystem/warbands/New()
	..()

/datum/controller/subsystem/warbands/Initialize()
	for(var/territory_faction_path in DEFAULT_TERRITORY_FACTIONS)
		territory_factions += new territory_faction_path
	create_name_cache()
	initialize_class_cache()
	initialize_grunt_mob_cache()
	initialize_lobby_mob_cache()	
	roundstart_manager = new /atom/movable/screen/warband/manager()
	roundstart_manager.warband_ID = next_warband_id++
	warband_managers += roundstart_manager
	return ..()

/datum/controller/subsystem/warbands/proc/create_name_cache()
	for(var/datum/territory_faction/faction in territory_factions)
		if(faction.owner)
			name_to_faction_cache[faction.owner] = faction
		if(faction.job_owner)
			job_to_faction_cache[faction.job_owner] = faction

/datum/controller/subsystem/warbands/proc/initialize_class_cache()
	for(var/warband_type in WARBANDS)
		var/datum/warbands/added_warband = new warband_type() 
		cached_warbands += added_warband
		warband_lookup[warband_type] = added_warband

	var/list/all_subtypes = WARBAND_UNTAGGED_SUBTYPES + WARBAND_MERCENARIES + WARBAND_SECTS
	for(var/sub_type in all_subtypes)
		var/datum/warbands/subtypes/added_subtype = new sub_type() 
		cached_subtypes += added_subtype
		subtype_lookup[sub_type] = added_subtype

	for(var/aspect_type in ASPECTS)
		var/datum/warbands/added_aspect = new aspect_type() 
		cached_aspects += added_aspect
		aspect_lookup[aspect_type] = added_aspect

	for(var/datum/warbands/warband in cached_warbands)
		cache_classes_from_datum(warband)
	for(var/datum/warbands/subtypes/subtype in cached_subtypes)
		cache_classes_from_datum(subtype)
	for(var/datum/warbands/aspects/aspect in cached_aspects)
		cache_classes_from_datum(aspect)

	classes_initialized = TRUE

/datum/controller/subsystem/warbands/proc/cache_classes_from_datum(datum/warbands/source)
	if(source.warlordclasses)
		for(var/class_type in source.warlordclasses)
			if(!cached_classes[class_type])
				cached_classes[class_type] = new class_type()
	if(source.lieutenantclasses)
		for(var/class_type in source.lieutenantclasses)
			if(!cached_classes[class_type])
				cached_classes[class_type] = new class_type()
	if(source.gruntclasses)
		for(var/class_type in source.gruntclasses)
			if(!cached_classes[class_type])
				cached_classes[class_type] = new class_type()

// cycles through phases each time it fires
// 	phases: 0 (equip a mob) -> 1 (create a fresh, unassigned mob) -> 2 (create a fresh lobby mob) -> repeat until the caches are full
/datum/controller/subsystem/warbands/fire(resumed = FALSE)
	if(!resumed)
		currentrun_encounters = list()
		for(var/atom/movable/screen/warband/manager/warband in warband_managers)
			if(warband.encounter_manager)
				currentrun_encounters += warband.encounter_manager
	
	process_encounters()

	// push timer updates for any lobby currently counting down
	for(var/atom/movable/screen/warband/manager/manager in warband_managers)
		if(manager.creation_timer_active)
			manager.cached_remaining_time = manager.get_remaining_time()
			SStgui.update_uis(manager)

	// when the unassigned mob cache hits 10, we swap to slowmode
	if(cache_mode == 0 && unassigned_mob_cache.len <= 10)
		cache_mode = 1
		grunt_processing_phase = 0

	grunt_equip_timer++
	if(grunt_equip_timer >= ticks_between_equip)
		grunt_equip_timer = 0
		
		if(cache_mode == 0)
			process_burst_mode()
		else
			process_slowmode()

/datum/controller/subsystem/warbands/proc/get_template(template_type, key)
	switch(template_type)
		if(TEMPLATE_OUTSKIRTS)
			var/list/options = OUTSKIRTS_TEMPLATE_TYPES[key]
			if(!options)
				return
			var/chosen_type = options[rand(1, length(options))]
			return new chosen_type()
		if(TEMPLATE_INTERMISSION)
			var/list/options = INTERMISSION_TEMPLATE_TYPES[key]
			if(!options)
				return
			var/chosen_type = options[rand(1, length(options))]
			return new chosen_type()

/datum/controller/subsystem/warbands/proc/process_encounters()
	var/list/current = currentrun_encounters
	while(current.len)
		var/datum/outskirts_encounter/encounter = current[current.len]
		current.len--

		if(!encounter || QDELETED(encounter))
			if(MC_TICK_CHECK)
				return
			continue
		encounter.check_wave_integrity()
		encounter.process_cleanup_queue()


////////////////
////// MOB CACHE

/datum/controller/subsystem/warbands/proc/get_viable_warbands()
	var/list/viable = list()
	for(var/atom/movable/screen/warband/manager/warband in warband_managers)
		if(warband.creation_stage < 2 || !warband.selected_warband)
			continue // skip incomplete warbands
		if(warband.cache_source)
			continue // skip warbands that are sharing a cache with another
		if(warband.assigned_grunt_cache.len >= 100)
			continue // skip warbands with 100 mobs in their assigned cache
		viable += warband
	return viable

//////////////////////////////////////////////////////////
////////////////////////////////// EQUIP GRUNT FOR WARBAND
/*
	equips a single grunt from the global cache for a warband
	grunts are distributed between unique warbands in a round-robin rotation

*/
/datum/controller/subsystem/warbands/proc/equip_grunt_for_warband(list/viable_warbands)
	if(!viable_warbands.len || !unassigned_mob_cache.len)
		return FALSE
	
	if(current_warband_index > viable_warbands.len)
		current_warband_index = 1
	
	var/atom/movable/screen/warband/manager/target_warband = viable_warbands[current_warband_index]
	var/mob/living/carbon/human/species/human/northern/goon/cached_grunt = unassigned_mob_cache[1]
	unassigned_mob_cache -= cached_grunt
	
	cached_grunt.warband = target_warband.selected_warband
	if(target_warband.selected_subtype)
		cached_grunt.subtype = target_warband.selected_subtype
	cached_grunt.warband_ID = target_warband.warband_ID
	cached_grunt.equip_for_warband()
	target_warband.assigned_grunt_cache += cached_grunt
	current_warband_index = (current_warband_index % viable_warbands.len) + 1

	if(cache_mode == 1)
		grunts_to_create++
	
	return TRUE

/////////////////////////////////////////////////////////
///////////////////////////////// CREATE UNASSIGNED GRUNT
/*
	refills the unassigned grunt cache based on grunts_to_create queue

*/
/datum/controller/subsystem/warbands/proc/create_unassigned_grunt()
	if(grunts_to_create <= 0 || unassigned_mob_cache.len >= max_unassigned_cache)
		return FALSE
	
	var/mob/living/carbon/human/species/human/northern/goon/cached_grunt = new()
	unassigned_mob_cache += cached_grunt
	cached_grunt.ai_controller?.set_ai_status(AI_STATUS_OFF)
	grunts_to_create--
	return TRUE

//////////////////////////////////////////////////////////
///////////////////////////////////////// CREATE LOBBY MOB
/*
	creates a single fresh lobby mob for the lobby cache
	used for player spawns, envoys, and latejoins

*/
/datum/controller/subsystem/warbands/proc/create_lobby_mob()
	var/lobby_cache_cap = 32
	if(lobby_mob_cache.len >= lobby_cache_cap)
		return FALSE
	
	var/mob/living/carbon/human/species/human/northern/cached_mob = new()
	lobby_mob_cache += cached_mob
	cached_mob.ai_controller?.set_ai_status(AI_STATUS_OFF)
	return TRUE


/////////////////////////////////////////////////////////
////////////////////////////////////// PROCESS BURST MODE
/*
	handles cache processing during initial burst mode
	during burst mode, we only want to equip grunts and (if necessary) refill the lobby cache

	since we're not using an initial unequipped cache anymore this is hardly gonna be used, but it's nice to have
*/
/datum/controller/subsystem/warbands/proc/process_burst_mode()
	if(grunt_processing_phase == 0)
		var/list/viable_warbands = get_viable_warbands()
		if(equip_grunt_for_warband(viable_warbands))
			if(MC_TICK_CHECK)
				return
		else
			grunt_processing_phase = 2
	
	else if(grunt_processing_phase == 2)
		if(create_lobby_mob())
			if(MC_TICK_CHECK)
				return
		else
			grunt_processing_phase = 0

/////////////////////////////////////////////////////////
//////////////////////////////////////// PROCESS SLOWMODE
/*
	handles cache processing during slowmode
	in comparison to burst mode where we ONLY equip grunts, we now start creating fresh mobs
	activates when global cache drops to 10 or below

	phases: 0 (equip mob) -> 1 (create unassigned mob) -> 2 (create lobby mob) -> repeat

*/
/datum/controller/subsystem/warbands/proc/process_slowmode()
	if(grunt_processing_phase == 0)
		var/list/viable_warbands = get_viable_warbands()
		if(equip_grunt_for_warband(viable_warbands))
			if(MC_TICK_CHECK)
				return
		grunt_processing_phase = 1
	
	else if(grunt_processing_phase == 1)
		if(create_unassigned_grunt())
			if(MC_TICK_CHECK)
				return
		grunt_processing_phase = 2
	
	else if(grunt_processing_phase == 2)
		if(create_lobby_mob())
			if(MC_TICK_CHECK)
				return
		grunt_processing_phase = 0

/datum/controller/subsystem/warbands/proc/initialize_lobby_mob_cache()
	var/cache_size = 32
	for(var/i = 1 to cache_size)
		var/mob/living/carbon/human/species/human/northern/cached_mob = new()
		lobby_mob_cache += cached_mob
		
/datum/controller/subsystem/warbands/proc/get_lobby_mob()
	if(lobby_mob_cache.len)
		var/mob/living/carbon/human/cached_mob = lobby_mob_cache[1]
		lobby_mob_cache -= cached_mob
		cached_mob.ai_controller?.set_ai_status(AI_STATUS_OFF)
		return cached_mob
	else // if the cache is empty fall back to creating a fresh mob
		var/mob/living/carbon/human/species/human/northern/new_mob = new() 
		return new_mob

/datum/controller/subsystem/warbands/proc/initialize_grunt_mob_cache()
	for(var/i = 1 to max_unassigned_cache)
		var/mob/living/carbon/human/species/human/northern/goon/cached_grunt = new()
		unassigned_mob_cache += cached_grunt
		cached_grunt?.ai_controller?.set_ai_status(AI_STATUS_OFF)
