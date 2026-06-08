/*	
	LOBBY TIMER
	- forces people through the creation process at certain intervals
	- eventually auto-finalizes the warband if the clock runs out

	1 - START CREATION TIMER	// starts the creation phase countdown
	2 - SEND WARNING			// sends a warning to anyone in the lobby at the halfway point
	3 - STOP CREATION TIMER		// stops the timer
	4 - TRIGGER TIMEOUT			// fires when time fully expires
	5 - FORCE WARBAND SPAWN		// auto-finalizes the warband if time runs out
	6 - GET REMAINING TIME		// returns remaining creation time in deciseconds

*/
/atom/movable/screen/warband/manager
	var/cached_remaining_time = -1
	var/timer_id_warning
	var/timer_id_timeout
	var/storytellers_resolved = FALSE // we get the current storytellers when the timer starts, too

/atom/movable/screen/warband/manager/proc/start_creation_timer()
	if(creation_timer_active)
		return
	creation_start_time = world.time
	creation_timer_active = TRUE
	if(!storytellers_resolved)
		storyteller_refresh()
		storytellers_resolved = TRUE
	var/time_until_warning = creation_time_limit - creation_warning_threshold
	timer_id_warning = addtimer(CALLBACK(src, PROC_REF(send_warning)), time_until_warning, TIMER_STOPPABLE)

/atom/movable/screen/warband/manager/proc/send_warning()
	if(!creation_timer_active || finalized)
		return // bail if timer was stopped or the warband was finalized
	warned = TRUE
	var/minutes_left = round(creation_warning_threshold / 600)
	for(var/mob/living/member in lobby_members)
		to_chat(member, span_boldwarning("WARBAND CREATION TIME WARNING: [minutes_left] minute(s) remain."))
		member.playsound_local(member, 'sound/misc/notice (2).ogg', 100, FALSE)
	timer_id_timeout = addtimer(CALLBACK(src, PROC_REF(trigger_timeout)), creation_warning_threshold, TIMER_STOPPABLE)

/atom/movable/screen/warband/manager/proc/stop_creation_timer()
	if(!creation_timer_active)
		return
	creation_timer_active = FALSE
	cached_remaining_time = -1
	if(timer_id_warning)
		deltimer(timer_id_warning)
		timer_id_warning = null
	if(timer_id_timeout)
		deltimer(timer_id_timeout)
		timer_id_timeout = null
	SStgui.update_uis(src)

/atom/movable/screen/warband/manager/proc/trigger_timeout()
	if(!creation_timer_active || finalized)
		return
	stop_creation_timer()
	force_warband_spawn()

/atom/movable/screen/warband/manager/proc/force_warband_spawn()
	var/mob/living/warlord
	for(var/mob/living/member in lobby_members)
		if(member.mind && member.mind.special_role == "Warlord")
			warlord = member
			break
	
	if(!warlord) // this absolutely shouldn't happen
		for(var/mob/living/member in lobby_members)
			if(member.mind && member.mind.special_role == "Grunt") // but if it does, we'll prefer grunts over lieutenants for warlord replacements
				warlord = member
				member.mind.special_role = "Warlord"
				to_chat(member, span_userdanger("The Warlord has abandoned the lobby. You have been elected to serve as the warlord."))
				message_admins("Warband [warband_ID] elected grunt [member.real_name] as the new warlord during timeout.")
				break
		if(!warlord)
			for(var/mob/living/member in lobby_members)
				if(member.mind && (member.mind.special_role == "Lieutenant" || member.mind.special_role == "Aspirant Lieutenant"))
					warlord = member
					member.mind.special_role = "Warlord"
					to_chat(member, span_userdanger("The Warlord has abandoned the lobby. You have been elected to serve as the warlord."))
					message_admins("Warband [warband_ID] elected lieutenant [member.real_name] as the new warlord during timeout.")
					break
		if(!warlord)
			for(var/mob/living/member in lobby_members)
				cancel_lobby(member)
		if(lobby_members.len == 0)
			qdel(src)
			return
	
	if(creation_stage == 1)
		to_chat(warlord, span_warning("Selecting random warband configuration..."))
		
		if(!SSwarbands.all_warbands.len)
			for(var/mob/living/member in lobby_members)
				cancel_lobby(member)
			return
		
		var/datum/warbands/random_warband = pick(SSwarbands.all_warbands)
		selected_warband = random_warband
		to_chat(warlord, span_notice("Warband: [random_warband.title]"))

		if(random_warband.subtypes && random_warband.subtypes.len > 0)
			var/list/available_subtypes = list()
			var/list/compatible_types = random_warband.subtypes[1]
			for(var/datum/warbands/subtypes/potential_subtype in SSwarbands.all_subtypes)
				if(potential_subtype.type in compatible_types)
					available_subtypes += potential_subtype

			if(available_subtypes.len > 0)
				if(random_warband.subtyperequired || prob(50))
					var/datum/warbands/subtypes/random_subtype = pick(available_subtypes)
					selected_subtype = random_subtype
					to_chat(warlord, span_notice("Subtype: [random_subtype.title]"))
		
		// build compatible aspect pools
		var/list/negative_aspects = list()
		var/list/positive_aspects = list()

		for(var/datum/warbands/aspects/potential_aspect in SSwarbands.all_aspects)
			var/is_compatible = random_warband.aspects.Find(potential_aspect.type)
			if(selected_subtype?.aspects)
				if(selected_subtype.aspects.Find(potential_aspect.type))
					is_compatible = TRUE
			if(!is_compatible)
				continue
			if(potential_aspect.points > 0)
				negative_aspects += potential_aspect
			else if(potential_aspect.points < 0)
				positive_aspects += potential_aspect

		selected_aspects = list()

		if(negative_aspects.len)
			var/datum/warbands/aspects/picked_negative = pick(negative_aspects)
			selected_aspects += picked_negative
			to_chat(warlord, span_notice("Negative Aspect: [picked_negative.title]"))

		if(positive_aspects.len)
			var/list/valid_positives = list()
			for(var/datum/warbands/aspects/candidate in positive_aspects)
				var/conflict = FALSE
				for(var/datum/warbands/aspects/existing in selected_aspects)
					if(existing.asclass && candidate.asclass && existing.asclass == candidate.asclass)
						conflict = TRUE
						break
				if(!conflict)
					valid_positives += candidate

			if(valid_positives.len)
				var/datum/warbands/aspects/picked_positive = pick(valid_positives)
				selected_aspects += picked_positive
				to_chat(warlord, span_notice("Positive Aspect: [picked_positive.title]"))

		creation_stage = 2
		set_race_and_faith_locks()
		selected_subtype?.on_warband_confirmed(src)
		selected_warband?.on_warband_confirmed(src)
		for(var/datum/warbands/aspects/aspect in selected_aspects)
			aspect.on_warband_confirmed(src)
		send_warnings()
		for(var/mob/living/carbon/human/member in lobby_members)
			to_chat(member, span_boldwarning("TIME EXPIRED! The warband has been randomly configured and auto-advanced to class selection."))
			SStgui.update_uis(member)
			update_static_data(member)

	
	if(creation_stage >= 2)
		if(!selected_warband)
			if(SSwarbands.all_warbands.len > 0)
				selected_warband = pick(SSwarbands.all_warbands)
			else
				for(var/mob/living/carbon/human/member in lobby_members)
					cancel_lobby(member)
				return

		to_chat(warlord, span_boldwarning("Spawning with current selections..."))
		var/list/auto_selection = auto_pick_class_and_subclass(warlord)
		var/class_path = auto_selection[1]
		var/subclass_path = auto_selection[2]
		SSwarbands.warband_managers_busy = TRUE
		SStgui.close_user_uis(warlord)
		if(warlord in lobby_members)
			lobby_members -= warlord
		load_appearance(warlord, warlord)
		lock_check(warlord)
		spawn_warband(warlord)
		set_IDs()
		spawn_character(class_path, warlord, subclass_path, is_leader = 1)
		set_default_exit()
		selected_warband?.on_warlord_spawned(warlord, src)
		for(var/datum/warbands/aspects/aspect in selected_aspects)
			aspect.on_warlord_spawned(warlord, src)
		warlord_spawned = TRUE
		SSwarbands.warband_managers_busy = FALSE
		finalized = TRUE
		warlord.mind.warband_manager = src
		end_intro(warlord)
		addtimer(CALLBACK(src, PROC_REF(spawn_ready_members)), 30)
		for(var/mob/living/carbon/human/member in lobby_members)
			if(member.mind.special_role == "Lieutenant" || member.mind.special_role == "Aspirant Lieutenant" || member.mind.special_role == "Grunt")
				to_chat(member, span_boldwarning("TIME EXPIRED! The warband has been auto-finalized. You may now create your character."))
				member.playsound_local(member, 'sound/misc/warband/menusound3.ogg', 100, FALSE)

// returns a warband source's class list for a given role tier
/atom/movable/screen/warband/manager/proc/tier_classes_for(datum/warbands/source, role)
	if(!source)
		return list()
	if(role == "Warlord")
		return source.warlordclasses || list()
	if(role == "Lieutenant" || role == "Aspirant Lieutenant")
		return source.lieutenantclasses || list()
	return source.gruntclasses || list()

// auto-selects a primary class + subclass for timeout spawns
/atom/movable/screen/warband/manager/proc/auto_pick_class_and_subclass(mob/member)
	var/role = member.mind?.special_role
	var/list/sources = list(selected_warband)
	if(selected_subtype)
		sources += selected_subtype
	for(var/datum/warbands/aspects/aspect in selected_aspects)
		sources += aspect

	var/list/granted = list()
	var/list/exclusive = list()
	var/list/suppressed = list()
	for(var/datum/warbands/source in sources)
		var/list/tier_list = tier_classes_for(source, role)
		if(tier_list.len)
			granted |= tier_list
			if(source.replaces_primaries)
				exclusive |= tier_list
		if(source.suppressed_classes)
			suppressed |= source.suppressed_classes

	var/list/primaries = list()
	for(var/class_type in granted)
		if(class_type in suppressed)
			continue
		if(selected_warband.multiclass_enabled && initial(class_type:multiclass_capable))
			continue
		primaries += class_type
	if(exclusive.len)
		var/list/restricted = list()
		for(var/class_type in primaries)
			if(class_type in exclusive)
				restricted += class_type
		primaries = restricted

	var/class_path = pick(primaries)

	var/subclass_path
	if(selected_warband.multiclass_enabled) // for multiclass warbands (mercenaries)
		var/list/subclass_pool = list()
		var/registered = SSwarbands.all_warband_class_types[class_path]
		if(registered && initial(class_path:use_subclasses))
			for(var/sub_type in subtypesof(class_path))
				if(SSwarbands.all_warband_class_types[sub_type] && !(sub_type in suppressed))
					subclass_pool += sub_type
		else if(registered && length(initial(class_path:classes)))
			for(var/sub_type in initial(class_path:classes))
				if(!(sub_type in suppressed))
					subclass_pool += sub_type
		else
			var/list/tier_types = tier_classes_for(selected_warband, role) + tier_classes_for(selected_subtype, role)
			for(var/class_type in tier_types)
				if((class_type in suppressed) || !initial(class_type:multiclass_capable))
					continue
				subclass_pool += class_type
			if(!subclass_pool.len)
				var/list/grunt_types = (selected_warband.gruntclasses || list()) + (selected_subtype ? (selected_subtype.gruntclasses || list()) : list())
				for(var/class_type in grunt_types)
					if((class_type in suppressed) || !initial(class_type:multiclass_capable))
						continue
					subclass_pool += class_type
		if(subclass_pool.len)
			subclass_path = pick(subclass_pool)
	return list(class_path, subclass_path)

// called between stages
// refreshes the creation timer
/atom/movable/screen/warband/manager/proc/reset_creation_timer()
	stop_creation_timer()
	warned = FALSE
	start_creation_timer()

// get remaining time in deciseconds
/atom/movable/screen/warband/manager/proc/get_remaining_time()
	if(!creation_timer_active)
		return -1
	var/elapsed = world.time - creation_start_time
	var/remaining = creation_time_limit - elapsed
	return max(0, remaining)
