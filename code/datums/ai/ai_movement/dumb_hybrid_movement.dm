// adds a third tier of reduction to hybrid movement
// so now it goes: Dumb Movement -> Basic Avoidance -> A*
/datum/ai_movement/hybrid_pathing/dumb_hybrid_movement
	max_path_distance = 200
	repath_distance_tolerance = 5

	var/list/dumb_stuck_deadline = list()	// an associative list of: the controller + the world.time at which a continuously-blocked controller graduates to basic avoidance & A*
											// the threshold is randomized, so a swarm of goons doesn't all swap to A* on the same tick
	var/list/dumb_promoted = list()	// controllers "promoted" to use full pathfinding/a*

// We're Sending Every Goon to Jupiter To Get More Stupider
/datum/ai_movement/hybrid_pathing/dumb_hybrid_movement/goon
	max_basic_failures = 3
	max_pathing_attempts = 10 // 3 basic failures + 7 a* attempts
	// a hard limit on A* attempts. reduces the impact of a mob endlessly trying to reach something it can't (the most tragic example being: a viable target behind something transparent)
	repath_cooldown_duration = 8 SECONDS
	repath_anticipation_cooldown_duration = 2 SECONDS

/datum/ai_movement/hybrid_pathing/dumb_hybrid_movement/proc/dumb_step(datum/ai_controller/controller, atom/movable/movable_pawn, turf/target_turf)
	var/turf/next_step = get_step_towards(movable_pawn, target_turf) // we still want to check if the turf's safe
	if(!next_step || !next_step.can_traverse_safely(movable_pawn))
		return FALSE
	return step_towards(movable_pawn, target_turf, controller.movement_delay)

/datum/ai_movement/hybrid_pathing/dumb_hybrid_movement/pre_movement_hook(datum/ai_controller/controller, atom/movable/movable_pawn, turf/target_turf)
	if(controller in dumb_promoted)
		return FALSE

	if(dumb_step(controller, movable_pawn, target_turf))
		controller.pathing_attempts = 0
		dumb_stuck_deadline -= controller
		return TRUE

	if(isnull(dumb_stuck_deadline[controller]))
		dumb_stuck_deadline[controller] = world.time + rand(1, 4) SECONDS
	else if(world.time >= dumb_stuck_deadline[controller]) // stuck for too long
		dumb_stuck_deadline -= controller
		dumb_promoted |= controller
		return FALSE // graduate to basic avoidance & A*

	return TRUE

// resets back to being dumb whenever a new movement target gets assigned
/datum/ai_movement/hybrid_pathing/dumb_hybrid_movement/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	controller.pathing_attempts = 0
	dumb_promoted -= controller
	dumb_stuck_deadline -= controller
	return ..()

/datum/ai_movement/hybrid_pathing/dumb_hybrid_movement/stop_moving_towards(datum/ai_controller/controller)
	dumb_promoted -= controller
	dumb_stuck_deadline -= controller
	controller.pathing_attempts = 0
	return ..()

/datum/ai_movement/hybrid_pathing/dumb_hybrid_movement/process(delta_time)
	if(world.time >= next_resolve)
		for(var/datum/ai_controller/controller in dumb_promoted.Copy())
			if(QDELETED(controller))
				dumb_promoted -= controller
		for(var/datum/ai_controller/controller in dumb_stuck_deadline.Copy())
			if(QDELETED(controller))
				dumb_stuck_deadline -= controller
	return ..()

// goon-specific pre_movement_hook
/datum/ai_movement/hybrid_pathing/dumb_hybrid_movement/goon/pre_movement_hook(datum/ai_controller/controller, atom/movable/movable_pawn, turf/target_turf)
	if(!(controller in dumb_promoted))
		return ..()
	if(!COOLDOWN_FINISHED(controller, repath_cooldown))
		if(length(controller.movement_path))
			return FALSE
		// whenever a* is on cooldown, we revert back to Dumb Moves
		dumb_step(controller, movable_pawn, target_turf)
		return TRUE
	if(controller.blackboard[BB_MOVEMENT_PATH_PROTECTED] && controller.movement_path)
		COOLDOWN_START(controller, repath_cooldown, repath_cooldown_duration)
		return FALSE
	controller.movement_path = null
	controller.clear_blackboard_key(future_path_blackboard_key)
	return FALSE
