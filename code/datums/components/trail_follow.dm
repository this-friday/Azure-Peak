// a component that allows squads of Warband NPCs to follow their leader conga line style
// drags them up & down z-levels as required
// no real pathfinding (outside of getting directions), so massive groups of NPCs on the move shouldn't be TIDI intensive
/datum/component/trail_follow
	var/list/mob/living/carbon/human/species/human/northern/goon/members = list()	// all goons spawned & associated with the squad leader
	var/list/mob/living/carbon/human/species/human/northern/goon/followers = list()	// goons currently following via the waypoint system
	var/list/turf/waypoints = list()	// 	as the leader moves, they mark the turfs they pass over as 'waypoints'
	var/max_waypoints = 40				//	followers move along said waypoints
	var/list/turf/portals = list()		//	when the leader changes z-levels, we mark the tile they left as a "portal" to wherever they landed

/datum/component/trail_follow/Initialize()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_leader_moved))
	var/mob/living/leader = parent
	leader.AddElement(/datum/element/relay_attackers)
	RegisterSignal(parent, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_leader_attacked))
	RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_leader_death))

/datum/component/trail_follow/Destroy()
	clear_followers()
	members = null
	followers = null
	waypoints = null
	portals = null
	return ..()

/datum/component/trail_follow/proc/on_leader_moved(atom/movable/mover, atom/old_loc, direction, forced)
	var/turf/current_pos = get_turf(parent)
	if(!current_pos)
		return
		
	// when the leader changes z-levels, we mark the tile they left as a "portal" to wherever they landed
	var/turf/old_turf = get_turf(old_loc)
	if(old_turf && old_turf.z != current_pos.z)
		portals -= current_pos // to prevent accidentally creating loops (for example: going up stairs and going down again), we clear portal doorways we happen to land on post-z-transition
		portals[old_turf] = current_pos

	if(!waypoints.len || waypoints[1] != current_pos)
		waypoints.Insert(1, current_pos)
		if(waypoints.len > max_waypoints)
			waypoints.Cut(max_waypoints + 1)
			clear_portals()

	move_squad_waypoint()

/datum/component/trail_follow/proc/track_member(mob/living/carbon/human/species/human/northern/goon/new_member)
	members |= new_member
	RegisterSignal(new_member, COMSIG_PARENT_QDELETING, PROC_REF(on_member_deleted), override = TRUE)

/datum/component/trail_follow/proc/on_member_deleted(datum/source)
	SIGNAL_HANDLER
	members -= source
	followers -= source

/datum/component/trail_follow/proc/add_follower(mob/living/carbon/human/species/human/northern/goon/new_member)
	track_member(new_member)
	new_member.squad_leader = parent
	
	var/mob/living/leader = parent
	leader.AddElement(/datum/element/relay_attackers) // re-assert the attack relay on the leader

	if(!(new_member in followers))
		followers |= new_member // mark them as an active waypoint follower
		RegisterSignal(new_member, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_follower_attacked))

	new_member.ai_controller?.CancelActions()
	new_member.ai_controller?.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	new_member.ai_controller?.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)
	if(new_member.ai_controller?.blackboard[BB_MOB_AGGRO_TABLE])
		new_member.ai_controller.blackboard[BB_MOB_AGGRO_TABLE] = list()
	new_member.ai_controller?.set_ai_status(AI_STATUS_OFF) 	// we want the AI fully asleep during the march
	return													// the goon's set_ai_status() override keeps it off until they leave the squad

// the mob stops following the leader
// beyond that, they stay in the Members list of the squad
/datum/component/trail_follow/proc/remove_follower(mob/living/carbon/human/species/human/northern/goon/member, wake = TRUE)
	if(!(member in followers))
		return
	followers -= member
	member.squad_leader = null
	UnregisterSignal(member, COMSIG_ATOM_WAS_ATTACKED)
	member.ai_controller?.clear_blackboard_key(BB_TRAVEL_DESTINATION)
	if(wake) // wake = FALSE skips turning the AI back on, if we're shelving the goon (recycle/deletion)
		member.ai_controller?.set_ai_status(AI_STATUS_ON)

// being attacked knocks a goon out of the follow so they can defend themselves
/datum/component/trail_follow/proc/on_follower_attacked(mob/living/carbon/human/species/human/northern/goon/member, atom/attacker, damage)
	SIGNAL_HANDLER
	if(!(member in followers))
		return
	var/mob/living/carbon/human/leader = parent
	if(leader)
		to_chat(leader, span_warning("[member] breaks from my formation to fight!"))
	remove_follower(member)

// an attack on the leader scatters the whole follow, so the squad defends them instead of marching on
/datum/component/trail_follow/proc/on_leader_attacked(datum/source, atom/attacker, damage)
	SIGNAL_HANDLER
	if(attacker == parent) // self-inflicted hits shouldn't scatter the squad
		return
	if(!followers.len)
		return
	var/mob/living/carbon/human/leader = parent
	to_chat(leader, span_warning("My goons break formation to defend me!"))
	clear_followers()

/datum/component/trail_follow/proc/on_leader_death(datum/source)
	SIGNAL_HANDLER
	clear_followers()

/datum/component/trail_follow/proc/lose_follower(mob/living/carbon/human/species/human/northern/goon/goon)
	var/mob/living/carbon/human/leader = parent
	if(leader)
		to_chat(leader, span_warning("A goon couldn't follow me."))
	remove_follower(goon)

/datum/component/trail_follow/proc/clear_followers()
	for(var/mob/living/carbon/human/M in followers) // remove_follower mutates the list
		remove_follower(M)

// drop any portal whose entry tile is no longer part of the live waypoint trail
/datum/component/trail_follow/proc/clear_portals()
	for(var/turf/entry in portals)
		if(!(entry in waypoints))
			portals -= entry

/datum/component/trail_follow/proc/move_squad_waypoint()
	var/list/sorted_followers = list()
	var/mob/living/carbon/human/leader = parent

	for(var/mob/living/carbon/human/species/human/northern/goon/goon in followers)
		if(goon.stat == CONSCIOUS)
			sorted_followers += goon
	
	if(!sorted_followers.len)
		return

	sorted_followers = sortTim(sorted_followers, GLOBAL_PROC_REF(cmp_dist_to_atom_dsc), leader)

	for(var/mob/living/carbon/human/species/human/northern/goon/goon in sorted_followers)
		var/turf/goon_turf = get_turf(goon)

		var/turf/portal_exit = goon_turf ? portals[goon_turf] : null
		if(portal_exit)
			goon.forceMove(portal_exit)
			goon.recent_travel = world.time
			if(goon.m_intent != MOVE_INTENT_SNEAK)
				playsound(goon, 'sound/foley/climb.ogg', 100, TRUE)
			continue

		var/turf/target_waypoint = next_best_waypoint(goon)
		
		if(!target_waypoint)
			continue
		
		var/step_dir = get_dir(goon, target_waypoint)
		if(!step_dir)
			continue

		try_move_grunt(goon, step_dir)

/datum/component/trail_follow/proc/try_move_grunt(mob/living/carbon/human/species/human/northern/goon/goon, move_dir)
	if(!move_dir)
		return
	
	var/turf/current_turf = get_turf(goon)
	var/turf/target_turf = get_step(current_turf, move_dir)
	
	if(!target_turf)
		return
	
	if(!target_turf.can_traverse_safely(goon))
		return FALSE
	
	for(var/mob/M in target_turf)
		if(M.density)
			if(istype(M, /mob/living/carbon/human/species/human/northern/goon))
				var/mob/living/carbon/human/species/human/northern/goon/other = M
				if(goon.warband_ID == other.warband_ID)
					if(goon.squad_leader != other.squad_leader)
						continue  // if another goon is in the same warband but inside a different squad, they can pass through one another during a Follow Command
			
			return FALSE
	
	return step(goon, move_dir)

/datum/component/trail_follow/proc/next_best_waypoint(mob/living/carbon/human/species/human/northern/goon/goon)
	var/turf/goon_turf = get_turf(goon)
	if(!goon_turf)
		return

	var/turf/best_waypoint
	var/closest_dist = INFINITY
	
	for(var/turf/waypoint in waypoints)
		if(waypoint == goon_turf || waypoint.z != goon_turf.z) // skip the waypoint we're already standing on
			continue // and skip waypoints on other z-levels

		var/dist = get_dist(goon, waypoint)

		// prefer waypoints that are 1-3 tiles away
		if(dist > 0 && dist <= 3 && dist < closest_dist)
			closest_dist = dist
			best_waypoint = waypoint

	// if there's no nearby waypoint, just take the closest one
	if(!best_waypoint)
		for(var/turf/waypoint in waypoints)
			if(waypoint == goon_turf || waypoint.z != goon_turf.z)
				continue
			
			var/dist = get_dist(goon, waypoint)
			if(dist < closest_dist)
				closest_dist = dist
				best_waypoint = waypoint

	// fall back to the leader's tile, but only if they're on this goon's floor
	if(!best_waypoint)
		var/turf/leader_turf = get_turf(parent)
		if(leader_turf && leader_turf.z == goon_turf.z)
			best_waypoint = leader_turf

	return best_waypoint

// whenever the squad leader goes through a travel tile, we bring along any squadmates within 5 tiles of them
// we also bring along the squadmates nearby THOSE squadmates
// so we get a long chain of teleports
/datum/component/trail_follow/proc/teleport_squad(turf/destination, max_range = 5)
	var/list/qualified = get_qualified_members(max_range)
	
	// teleport qualified followers
	for(var/mob/living/carbon/human/species/human/northern/goon/goon in qualified)
		goon.forceMove(destination)
		goon.recent_travel = world.time
	
	// if a follower didn't qualify for the TP, drop them as a follower
	for(var/mob/living/carbon/human/species/human/northern/goon/goon in followers)
		if(!(goon in qualified))
			remove_follower(goon)

/datum/component/trail_follow/proc/get_qualified_members(max_range = 5)
	var/mob/living/carbon/human/leader = parent
	var/list/to_check = list(leader)
	var/list/qualified = list()
	var/list/checked = list()
	
	while(to_check.len)
		var/atom/current = to_check[1]
		to_check -= current
		checked += current
		
		for(var/mob/living/carbon/human/species/human/northern/goon/goon in followers)
			if(goon in qualified)
				continue  // skip anyone already marked for the teleport
			
			if(goon.stat != CONSCIOUS)
				continue  // skip anyone unconscious
			
			var/distance = get_dist(current, goon)
			if(distance <= max_range)
				qualified += goon
				if(!(goon in to_check) && !(goon in checked))
					to_check += goon
	
	return qualified
