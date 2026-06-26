#define WARBAND_GM_POLL_TIME (30 SECONDS)

// lets an admin/gamemaster manually assemble a warband w/the ckeys they provide
/client/proc/warband_gm_panel()
	set name = "Warband - Spawner"
	set category = "Game Master"
	if(!holder)
		return
	var/datum/warband_spawner_ui/D = new()
	D.ui_interact(mob)

/datum/warband_spawner_ui
	var/list/members = list()
	var/bypass_rarity = FALSE
	var/poll_active = FALSE
	var/poll_ends_at = 0

/datum/warband_spawner_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui(user, src, "WarbandDebug", "Create Warband")
		ui.open()

/datum/warband_spawner_ui/ui_status(mob/user)
	if(user?.client?.holder)
		return UI_INTERACTIVE
	return UI_CLOSE

/datum/warband_spawner_ui/ui_close()
	qdel(src)

/datum/warband_spawner_ui/ui_data(mob/user)
	return list(
		"members" = members,
		"bypass_rarity" = bypass_rarity,
		"poll_active" = poll_active,
		"poll_seconds_left" = poll_active ? max(0, round((poll_ends_at - world.time) / 10)) : 0,
	)

/datum/warband_spawner_ui/ui_static_data(mob/user)
	var/list/active_ckeys = list()
	for(var/ckey_entry in GLOB.directory)
		active_ckeys += ckey_entry
	return list("active_ckeys" = active_ckeys)

/datum/warband_spawner_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!ui.user?.client?.holder)
		return TRUE

	switch(action)
		if("add_member")
			var/input_ckey = ckey(params["ckey"])
			if(!input_ckey)
				return TRUE
			if(params["role"] == "Warlord")
				for(var/list/member in members)
					if(member["role"] == "Warlord")
						return TRUE
			members += list(list("ckey" = input_ckey, "role" = params["role"]))

		if("remove_member")
			var/chosen_index = text2num(params["index"])
			if(chosen_index < 1 || chosen_index > members.len)
				return TRUE
			members.Cut(chosen_index, chosen_index + 1)

		if("set_member_role")
			var/target_index = text2num(params["index"])
			if(target_index < 1 || target_index > members.len)
				return TRUE
			var/new_role = params["role"]
			if(!(new_role in list("Warlord", "Lieutenant", "Grunt")))
				return TRUE
			if(new_role == "Warlord")
				for(var/i in 1 to members.len)
					if(i == target_index)
						continue
					var/list/other_member = members[i]
					if(other_member["role"] == "Warlord")
						return TRUE
			var/list/target_member = members[target_index]
			target_member["role"] = new_role

		if("toggle_bypass_rarity")
			bypass_rarity = !bypass_rarity

		if("poll_candidates")
			if(poll_active)
				to_chat(ui.user, span_warning("A candidate poll is already running."))
				return TRUE
			var/poll_size = clamp(round(text2num(params["poll_size"])), 1, 50)
			INVOKE_ASYNC(src, PROC_REF(try_start_candidate_poll), poll_size, ui.user.client)

		if("create_warband")
			if(poll_active)
				to_chat(ui.user, span_warning("A candidate poll is still running."))
				return TRUE

			if(create_warband(ui.user, bypass_rarity))
				ui.close()

	return TRUE

/datum/warband_spawner_ui/proc/create_warband(mob/admin_mob, bypass = FALSE)
	if(SSwarbands.warband_managers_busy)
		to_chat(admin_mob, span_warning("The Warband subsystem is occupied."))
		return FALSE

	var/turf/spawn_loc
	for(var/obj/effect/landmark/start/warlord/the_box in GLOB.landmarks_list)
		spawn_loc = get_turf(the_box)
		break

	if(!spawn_loc)
		to_chat(admin_mob, span_warning("No warlord spawn landmark exists on this map. Put a /obj/effect/landmark/start/warlord/ somewhere."))
		return FALSE

	var/datum/mind/warlord_mind
	var/list/lieutenant_minds = list()
	var/list/grunt_minds = list()

	for(var/list/member in members)
		var/client/found_client = GLOB.directory[member["ckey"]]
		if(!found_client?.mob)
			continue

		var/mob/candidate_mob = found_client.mob

		if(!candidate_mob.mind)
			candidate_mob.mind = new /datum/mind(found_client.key)
			candidate_mob.mind.set_current(candidate_mob)

		switch(member["role"])
			if("Warlord")
				warlord_mind = candidate_mob.mind
			if("Lieutenant")
				lieutenant_minds += candidate_mob.mind
			if("Grunt")
				grunt_minds += candidate_mob.mind
		SStgui.close_all_uis(found_client)
		if(istype(candidate_mob, /mob/dead/new_player))
			var/mob/dead/new_player/member_in_joinscreen = candidate_mob
			member_in_joinscreen.close_spawn_windows()

	if(!warlord_mind)
		to_chat(admin_mob, span_warning("A warband needs a Warlord."))
		return FALSE

	var/datum/round_event/antagonist/solo/warlord/event = new()
	event.bypass_rarity = bypass

	event.process_candidate(warlord_mind, "Warlord", /datum/antagonist/warband/warlord, spawn_loc)

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(warband_gm_process_subordinates), event, warlord_mind, lieutenant_minds, grunt_minds, spawn_loc), 2 SECONDS)

	message_admins("[key_name(admin_mob)] created a warband via the Gamemaster panel.")
	return TRUE

/proc/warband_gm_process_subordinates(datum/round_event/antagonist/solo/warlord/event, datum/mind/warlord_mind, list/lieutenant_minds, list/grunt_minds, turf/spawn_loc)
	if(!event || !warlord_mind)
		return
	var/warband_id = warlord_mind.warband_ID

	var/lt_num = 1
	for(var/datum/mind/lt_mind in lieutenant_minds)
		if(lt_mind.current)
			lt_mind.warband_ID = warband_id
			event.process_candidate(lt_mind, "Lieutenant", /datum/antagonist/warband/lieutenant, spawn_loc, lt_num++)

	var/grunt_num = 1
	for(var/datum/mind/grunt_mind in grunt_minds)
		if(grunt_mind.current)
			grunt_mind.warband_ID = warband_id
			event.process_candidate(grunt_mind, "Grunt", /datum/antagonist/warband/grunt, spawn_loc, grunt_num++)

///////////////////////////////////////////////////////
///////////////////////////////////// CANDIDATE POLLING

/datum/warband_spawner_ui/proc/has_member(member_ckey)
	for(var/list/member in members)
		if(member["ckey"] == member_ckey)
			return TRUE
	return FALSE

// dishes out roles to candidates & tries to stick to the defined playercount limits
/datum/warband_spawner_ui/proc/next_auto_role()
	var/has_warlord = FALSE
	var/lt_count = 0
	for(var/list/member in members)
		switch(member["role"])
			if("Warlord")
				has_warlord = TRUE
			if("Lieutenant")
				lt_count++
	if(!has_warlord)
		return "Warlord"
	if(lt_count < LIEUTENANTS_PER_WARLORD)
		return "Lieutenant"
	return "Grunt"

/datum/warband_spawner_ui/proc/get_poll_candidates(admin_ckey)
	var/list/candidate_mobs = list()
	for(var/found_ckey in GLOB.directory)
		if(found_ckey == admin_ckey)
			continue // the creator isn't eligible
		if(has_member(found_ckey))
			continue // existing members aren't eligible
		var/client/found_client = GLOB.directory[found_ckey]
		if(!found_client || !found_client.mob)
			continue // nulls aren't eligible
		if(!istype(found_client.mob, /mob/dead))
			continue // the living aren't eligible
		if(!found_client.prefs || !(ROLE_WARLORD in found_client.prefs.be_special))
			continue // players without Warband enabled aren't eligible
		candidate_mobs += found_client.mob
	return candidate_mobs

// confirms the count & fires the poll
/datum/warband_spawner_ui/proc/try_start_candidate_poll(poll_size, client/admin_client)
	if(poll_active || !admin_client)
		return
	var/list/candidate_mobs = get_poll_candidates(admin_client.ckey)
	if(!length(candidate_mobs))
		to_chat(admin_client, span_warning("No eligible players to poll."))
		return
	var/eligible = length(candidate_mobs)
	var/confirm = tgui_alert(admin_client.mob, "This polls [eligible] ghosts who have Warband enabled in their antagonist preferences. Each gets [WARBAND_GM_POLL_TIME / 10] seconds to accept. Send the poll?", "Poll Candidates", list("Yes", "No"))
	if(confirm != "Yes" || poll_active)
		return
	// re-gather in case the lobby shifted while the confirmation dialog was open
	candidate_mobs = get_poll_candidates(admin_client.ckey)
	if(!length(candidate_mobs))
		to_chat(admin_client, span_warning("No eligible players remain."))
		return
	poll_active = TRUE
	poll_ends_at = world.time + WARBAND_GM_POLL_TIME
	SStgui.update_uis(src)
	var/list/willing_ckeys = list()
	for(var/mob/candidate_mob in candidate_mobs)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(warband_gm_ask_candidate), candidate_mob, willing_ckeys)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(warband_gm_finish_poll), willing_ckeys, poll_size, WEAKREF(src), WEAKREF(admin_client)), WARBAND_GM_POLL_TIME)
	to_chat(admin_client, span_notice("Polling [eligible] eligible players..."))

// asks a single candidate & appends their ckey to the Willing Candidate list on a Yes
/proc/warband_gm_ask_candidate(mob/candidate_mob, list/willing_ckeys)
	if(!candidate_mob?.client)
		return
	var/choice = tgui_alert(candidate_mob, "A Warband is being assembled. Join the fray?", "Warband Recruitment", list("Yes", "No"), WARBAND_GM_POLL_TIME)
	if(choice == "Yes" && candidate_mob?.client)
		willing_ckeys |= candidate_mob.client.ckey

// deposits a shuffled, size-capped slice of candidates into the spawner
// auto-assigns roles
/proc/warband_gm_finish_poll(list/willing_ckeys, poll_size, datum/weakref/ui_ref, datum/weakref/admin_ref)
	var/datum/warband_spawner_ui/spawner = ui_ref?.resolve()
	var/client/admin_client = admin_ref?.resolve()
	if(!spawner)
		if(admin_client && length(willing_ckeys))
			to_chat(admin_client, span_warning("Your poll finished, but you closed the spawner window. [length(willing_ckeys)] players who accepted were discarded."))
		return
	spawner.poll_active = FALSE
	spawner.poll_ends_at = 0
	var/list/valid_ckeys = list()
	for(var/found_ckey in willing_ckeys)
		var/client/found_client = GLOB.directory[found_ckey]
		if(!found_client || !found_client.mob || !istype(found_client.mob, /mob/dead))
			continue
		if(spawner.has_member(found_ckey))
			continue
		valid_ckeys += found_ckey
	if(!length(valid_ckeys))
		SStgui.update_uis(spawner)
		if(admin_client)
			to_chat(admin_client, span_warning("No eligible players accepted."))
		return
	valid_ckeys = shuffle(valid_ckeys)
	var/added = 0
	var/added_warlord = 0
	var/added_lt = 0
	var/added_grunt = 0
	for(var/picked_ckey in valid_ckeys)
		if(added >= poll_size)
			break
		var/role = spawner.next_auto_role()
		spawner.members += list(list("ckey" = picked_ckey, "role" = role))
		added++
		switch(role)
			if("Warlord")
				added_warlord++
			if("Lieutenant")
				added_lt++
			if("Grunt")
				added_grunt++
	SStgui.update_uis(spawner)
	if(admin_client)
		to_chat(admin_client, span_notice("Poll finished. Added [added] members ([added_warlord] Warlord, [added_lt] Lieutenants, [added_grunt] Grunts). [length(valid_ckeys)] accepted."))

#undef WARBAND_GM_POLL_TIME
