// lets an admin/gamemaster manually assemble a warband w/the ckeys they provide
/client/proc/warband_gm_panel()
	set name = "Warband - Spawner"
	set category = "-GameMaster-"
	if(!holder)
		return
	var/datum/warband_spawner_ui/D = new()
	D.ui_interact(mob)

/datum/warband_spawner_ui
	var/list/members = list()
	var/bypass_rarity = FALSE

/datum/warband_spawner_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui(user, src, "WarbandDebug", "Create Warband")
		ui.open()

/datum/warband_spawner_ui/ui_status(mob/user)
	if(user)
		return UI_INTERACTIVE
	return ..()

/datum/warband_spawner_ui/ui_close()
	qdel(src)

/datum/warband_spawner_ui/ui_data(mob/user)
	return list(
		"members" = members,
		"bypass_rarity" = bypass_rarity,
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

		if("toggle_bypass_rarity")
			bypass_rarity = !bypass_rarity

		if("create_warband")
			if(create_warband(ui.user, bypass_rarity))
				ui.close()

	return TRUE

/datum/warband_spawner_ui/proc/create_warband(mob/admin_mob, bypass = FALSE)
	if(SSwarbands.warband_managers_busy)
		to_chat(admin_mob, span_warning("The Warband subsystem is occupied."))
		return FALSE // we don't want two being created at once
	SSwarbands.warband_managers_busy = TRUE

	var/turf/spawn_loc
	for(var/obj/effect/landmark/start/warlord/the_box in GLOB.landmarks_list)
		spawn_loc = get_turf(the_box)
		break

	if(!spawn_loc)
		return FALSE

	var/datum/mind/warlord_mind
	var/list/lieutenant_minds = list()
	var/list/grunt_minds = list()

	for(var/list/member in members)
		var/client/found_client = GLOB.directory[member["ckey"]]
		if(!found_client?.mob?.mind)
			continue

		switch(member["role"])
			if("Warlord")
				warlord_mind = found_client.mob.mind
			if("Lieutenant")
				lieutenant_minds += found_client.mob.mind
			if("Grunt")
				grunt_minds += found_client.mob.mind
		SStgui.close_all_uis(found_client)
		if(istype(found_client.mob, /mob/dead/new_player))
			var/mob/dead/new_player/member_in_joinscreen = found_client.mob
			member_in_joinscreen.close_spawn_windows()

	if(!warlord_mind)
		return FALSE

	var/datum/round_event/antagonist/solo/warlord/event = new()
	event.bypass_rarity = bypass

	event.process_candidate(warlord_mind, "Warlord", /datum/antagonist/warband/warlord, spawn_loc)

	var/expected_warband_id
	var/atom/movable/screen/warband/manager/target_manager
	if(!SSwarbands.roundstart_manager_claimed && SSwarbands.roundstart_manager)
		target_manager = SSwarbands.roundstart_manager
		expected_warband_id = target_manager.warband_ID
	else
		expected_warband_id = SSwarbands.next_warband_id
		for(var/atom/movable/screen/warband/manager/chosen_manager in SSwarbands.warband_managers)
			if(chosen_manager.warband_ID == expected_warband_id)
				target_manager = chosen_manager
				break

	if(bypass && target_manager)
		target_manager.bypass_rarity = TRUE

	var/lt_num = 1
	for(var/datum/mind/lt_mind in lieutenant_minds)
		if(lt_mind.current)
			lt_mind.warband_ID = expected_warband_id
			event.process_candidate(lt_mind, "Lieutenant", /datum/antagonist/warband/lieutenant, spawn_loc, lt_num++)

	var/grunt_num = 1
	for(var/datum/mind/grunt_mind in grunt_minds)
		if(grunt_mind.current)
			grunt_mind.warband_ID = expected_warband_id
			event.process_candidate(grunt_mind, "Grunt", /datum/antagonist/warband/grunt, spawn_loc, grunt_num++)

	SSwarbands.warband_managers_busy = FALSE
	message_admins("[key_name(admin_mob)] created a warband via the Gamemaster panel.")
	return TRUE
