SUBSYSTEM_DEF(warbands)
	name = "warbands"
	wait = 20
	flags = SS_KEEP_TIMING
	priority = 15
	init_order = INIT_ORDER_MAPPING + 1
	var/list/warband_managers = list()
	var/list/warband_machines = list()
	var/warband_managers_busy = FALSE	// prevents multiple warbands from being loaded in at once | necessary, as warband_ID assignments for objects will expect this to be the case
	var/datum/warband_manager/roundstart_manager
	var/roundstart_manager_claimed = FALSE
	var/next_warband_id = 1

	var/list/treaties = list()
	var/list/submitted_treaties = list()
	var/treaty_flavor_factions = list()

	// list of associated faction names & jobs
	var/list/name_to_faction_cache = list() 	 
	var/list/job_to_faction_cache = list()

	var/classes_initialized = FALSE

	var/list/currentrun_encounters = list() // currently running Defense encounters for warcamps

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

	// warbands (stored as datums)
	var/list/datum/warbands/all_warbands = list()
	var/list/datum/warbands/subtypes/all_subtypes = list()
	var/list/datum/warbands/aspects/all_aspects = list()
	// classes (stored as types)
	var/list/all_warband_class_types = list()

	// data for the lobby's tgui, built once the first time the UI opens and is identical for every viewer all round
	// only the per-manager selection states (the actual decisions they made, like which warband/subtype they chose) are rebuilt per refresh
	var/list/warband_ui_data
	var/list/subtypes_ui_data
	var/list/aspects_ui_data
	var/list/cached_ui_classes

	// terms
	var/list/all_terms					// a list of universal terms from WARBAND_TERMS, available to every treaty
	var/list/unique_terms_by_warband	// an associated list of: warband type path + a list of unique terms

/datum/controller/subsystem/warbands/New()
	..()

/datum/controller/subsystem/warbands/Initialize()
	for(var/territory_faction_path in DEFAULT_TREATY_FLAVOR_FACTIONS)
		treaty_flavor_factions += new territory_faction_path
	create_name_cache()
	initialize_class_cache()
	initialize_lobby_mob_cache()
	grunts_to_create = max_unassigned_cache
	roundstart_manager = new /datum/warband_manager()
	register_manager(roundstart_manager)
	return ..()

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////// TERM REGISTRY

/datum/controller/subsystem/warbands/proc/build_term_registry()
	if(all_terms)
		return
	all_terms = list()
	unique_terms_by_warband = list()
	// universal terms: explicitly declared in WARBAND_TERMS
	for(var/datum/treaty/terms/term_type as anything in WARBAND_TERMS)
		if(initial(term_type.warbandlock))
			continue // a warband-locked term doesn't belong in the universal pool
		all_terms += new term_type
	// unique terms: auto-discovered via the warbandlock each one declares
	for(var/datum/treaty/terms/term_type as anything in subtypesof(/datum/treaty/terms))
		var/lock = initial(term_type.warbandlock)
		if(!lock)
			continue
		if(!unique_terms_by_warband[lock])
			unique_terms_by_warband[lock] = list()
		unique_terms_by_warband[lock] += new term_type

// returns the terms available for the given warband
/datum/controller/subsystem/warbands/proc/get_all_terms(warband_type)
	build_term_registry()
	var/list/result = all_terms.Copy()
	if(warband_type)
		var/list/uniques = unique_terms_by_warband[warband_type]
		if(uniques)
			result += uniques
	return result

/datum/controller/subsystem/warbands/proc/allocate_warband_id()
	return next_warband_id++

// registers a freshly created manager with the subsystem & stamps its ID
/datum/controller/subsystem/warbands/proc/register_manager(datum/warband_manager/manager)
	if(!manager.warband_ID)
		manager.warband_ID = allocate_warband_id()
	warband_managers |= manager
	return manager

// shared player-count scaling for grunt allotments
// currently: a minimum of 2 grunts per lieutenant, +1 for every 15 active players past 40
/proc/warband_grunts_per_lieutenant()
	var/scaled = GRUNTS_PER_LIEUTENANT + max(0, round((get_active_player_count() - 40) / 15))
	return min(scaled, GRUNTS_PER_LIEUTENANT_MAX)

/datum/controller/subsystem/warbands/proc/create_name_cache()
	for(var/datum/treaty_flavor/faction in treaty_flavor_factions)
		if(faction.owner)
			name_to_faction_cache[faction.owner] = faction
		if(faction.job_owner)
			job_to_faction_cache[faction.job_owner] = faction


///////////////////////////////////////////////////////////
////////////////////////////////////// CLASS INITIALIZATION
/*
	collects each warband, subtype & aspect as new datums
	then we comb through each of THOSE and cache the .types of each class associated with them

*/
/datum/controller/subsystem/warbands/proc/initialize_class_cache()
	for(var/datum/warbands/band_type as anything in subtypesof(/datum/warbands))
		if(initial(band_type.abstract_type) == band_type)
			continue
		if(ispath(band_type, /datum/warbands/subtypes))
			all_subtypes += new band_type()
		else if(ispath(band_type, /datum/warbands/aspects))
			all_aspects += new band_type()
		else
			all_warbands += new band_type()

	for(var/datum/warbands/warband in all_warbands)
		cache_classes_from_datum(warband)
	for(var/datum/warbands/subtypes/subtype in all_subtypes)
		cache_classes_from_datum(subtype)
	for(var/datum/warbands/aspects/aspect in all_aspects)
		cache_classes_from_datum(aspect)

	classes_initialized = TRUE

/datum/controller/subsystem/warbands/proc/cache_classes_from_datum(datum/warbands/source)
	if(source.warlordclasses)
		for(var/class_type in source.warlordclasses)
			register_class(class_type)
	if(source.lieutenantclasses)
		for(var/class_type in source.lieutenantclasses)
			register_class(class_type)
	if(source.gruntclasses)
		for(var/class_type in source.gruntclasses)
			register_class(class_type)
	if(source.universal_warlordclasses)
		for(var/class_type in source.universal_warlordclasses)
			register_class(class_type)
	if(source.universal_lieutenantclasses)
		for(var/class_type in source.universal_lieutenantclasses)
			register_class(class_type)
	if(source.universal_gruntclasses)
		for(var/class_type in source.universal_gruntclasses)
			register_class(class_type)

/datum/controller/subsystem/warbands/proc/register_class(class_type)
	all_warband_class_types[class_type] = TRUE
	if(initial(class_type:use_subclasses))
		for(var/sub_type in subtypesof(class_type))
			all_warband_class_types[sub_type] = TRUE
	for(var/sub_type in initial(class_type:classes))
		all_warband_class_types[sub_type] = TRUE

/datum/controller/subsystem/warbands/proc/warband_datum_for(warband_path)
	for(var/datum/warbands/warband in all_warbands)
		if(warband.type == warband_path)
			return warband

/datum/controller/subsystem/warbands/proc/subtype_datum_for(subtype_path)
	for(var/datum/warbands/subtypes/subtype in all_subtypes)
		if(subtype.type == subtype_path)
			return subtype

/datum/controller/subsystem/warbands/proc/aspect_datum_for(aspect_path)
	for(var/datum/warbands/aspects/aspect in all_aspects)
		if(aspect.type == aspect_path)
			return aspect

// cycles through phases each time it fires
// phases: 0 (equip a mob) -> 1 (create a fresh, unassigned mob) -> 2 (create a fresh lobby mob) -> repeat until the caches are full
/datum/controller/subsystem/warbands/fire(resumed = FALSE)
	if(!resumed)
		currentrun_encounters = list()
		for(var/datum/warband_manager/warband in warband_managers)
			if(warband.encounter_manager)
				currentrun_encounters += warband.encounter_manager
	
	process_encounters()

	// push timer updates for any lobby currently counting down
	for(var/datum/warband_manager/manager in warband_managers)
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
	for(var/datum/outskirts_encounter/encounter as anything in currentrun_encounters)
		if(QDELETED(encounter))
			continue
		encounter.check_wave_integrity()
		encounter.process_cleanup_queue()

////////////////
////// MOB CACHE

// warbands considered viable to receive a fresh cached mob
/datum/controller/subsystem/warbands/proc/get_viable_warbands()
	var/list/viable = list()
	for(var/datum/warband_manager/warband in warband_managers)
		if(warband.creation_stage < 2 || !warband.selected_warband)
			continue // skip incomplete warbands
		if(warband.cache_source)
			continue // skip warbands that are sharing a cache with another
		if(warband.assigned_grunt_cache.len >= 100)
			continue // skip warbands with 100 mobs in their assigned cache
					 // note: grunt caches can still exceed 100 mobs if, for example: a bunch are summoned, the cache naturally refills, and the already-existing summoned mobs get recycled
					 // this should be fine. in that scenario, the cache is likely in High Demand at that point
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
	
	var/datum/warband_manager/target_warband = viable_warbands[current_warband_index]
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
	refills the unassigned grunt cache based on the grunts_to_create queue

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
