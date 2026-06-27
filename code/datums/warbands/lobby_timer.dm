/*
	LOBBY TIMER
	- forces people through the creation process at certain intervals
	- each stage gets its own countdown: stage 1 runs the full creation_time_limit, later stages get
	  whatever was left over from the previous stage (with creation_warning_threshold as the floor)
	- a timeout only shoves the lobby forward ONE stage (random config → auto casus belli → finalize)

	1 - START CREATION TIMER	// starts the current stage's countdown
	2 - SEND WARNING			// sends a warning to anyone in the lobby at the halfway point
	3 - STOP CREATION TIMER		// stops the timer
	4 - TRIGGER TIMEOUT			// fires when a stage's time fully expires | dispatches per stage
	5 - TIMEOUT STAGES			// stage 1: random config | stage 2: auto casus belli | stage 3: auto-finalize
	6 - GET REMAINING TIME		// returns remaining creation time in deciseconds

*/
/datum/warband_manager
	var/cached_remaining_time = -1
	var/timer_id_warning
	var/timer_id_timeout
	var/patrons_resolved = FALSE 		// we resolve the princes' patrons when the timer starts, so we can decide our rarity unlocks
	var/current_stage_limit = 0			// the CURRENT stage's timer duration | 0 means "use creation_time_limit"
	var/current_warning_threshold = 0	// the current stage's halfway warning point

/datum/warband_manager/proc/start_creation_timer()
	if(creation_timer_active)
		return
	if(current_stage_limit <= 0)
		current_stage_limit = creation_time_limit
	current_warning_threshold = current_stage_limit / 2
	creation_start_time = world.time
	creation_timer_active = TRUE
	if(!patrons_resolved)
		patron_refresh()
		patrons_resolved = TRUE
	var/time_until_warning = current_stage_limit - current_warning_threshold
	timer_id_warning = addtimer(CALLBACK(src, PROC_REF(send_warning)), time_until_warning, TIMER_STOPPABLE)

/datum/warband_manager/proc/send_warning()
	if(!creation_timer_active || finalized)
		return // bail if timer was stopped or the warband was finalized
	warned = TRUE
	var/minutes_left = round(current_warning_threshold / 600)
	for(var/mob/living/member in lobby_members)
		to_chat(member, span_boldwarning("WARBAND CREATION TIME WARNING: [minutes_left] minute(s) remain."))
		member.playsound_local(member, 'sound/misc/notice (2).ogg', 100, FALSE)
	timer_id_timeout = addtimer(CALLBACK(src, PROC_REF(trigger_timeout)), current_warning_threshold, TIMER_STOPPABLE)

/datum/warband_manager/proc/stop_creation_timer()
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

/datum/warband_manager/proc/trigger_timeout()
	if(!creation_timer_active || finalized)
		return
	stop_creation_timer()
	var/mob/living/warlord = ensure_lobby_warlord()
	if(!warlord)
		return
	switch(creation_stage)
		if(1)
			timeout_stage_one(warlord)
		if(2)
			timeout_stage_two(warlord)
		else
			timeout_stage_three(warlord)

// finds the lobby's warlord, electing a replacement if the original abandoned the lobby
/datum/warband_manager/proc/ensure_lobby_warlord()
	var/mob/living/warlord
	for(var/mob/living/member in lobby_members)
		if(member.mind && member.mind.special_role == ROLE_WARLORD)
			warlord = member
			break

	if(!warlord) // this absolutely shouldn't happen
		for(var/mob/living/member in lobby_members)
			if(member.mind && member.mind.special_role == ROLE_WARLORD_GRUNT) // but if it does, we'll prefer grunts over lieutenants for warlord replacements
				warlord = member
				member.mind.special_role = ROLE_WARLORD
				to_chat(member, span_userdanger("The Warlord has abandoned the lobby. You have been elected to serve as the warlord."))
				message_admins("Warband [warband_ID] elected grunt [member.real_name] as the new warlord during timeout.")
				break
		if(!warlord)
			for(var/mob/living/member in lobby_members)
				if(member.mind && (member.mind.special_role == ROLE_WARLORD_LIEUTENANT || member.mind.special_role == ROLE_WARLORD_ASPIRANT))
					warlord = member
					member.mind.special_role = ROLE_WARLORD
					to_chat(member, span_userdanger("The Warlord has abandoned the lobby. You have been elected to serve as the warlord."))
					message_admins("Warband [warband_ID] elected lieutenant [member.real_name] as the new warlord during timeout.")
					break
		if(!warlord)
			for(var/mob/living/member in lobby_members)
				cancel_lobby(member)
		if(lobby_members.len == 0)
			qdel(src)
			return
	return warlord

// stage-1 timeout: pick a random warband configuration and advance to the casus belli stage
/datum/warband_manager/proc/timeout_stage_one(mob/living/warlord)
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

	if(!linked_faction)
		var/datum/treaty_flavor/custom/seed_faction = new /datum/treaty_flavor/custom()
		SSwarbands.treaty_flavor_factions += seed_faction
		seed_faction.name = seed_faction.verify_faction_name("The Warband")
		linked_faction = seed_faction

	creation_stage = 2
	set_race_and_faith_locks()
	selected_subtype?.on_warband_confirmed(src)
	selected_warband?.on_warband_confirmed(src)
	for(var/datum/warbands/aspects/aspect in selected_aspects)
		aspect.on_warband_confirmed(src)
	send_warnings()
	for(var/mob/living/carbon/human/member in lobby_members)
		to_chat(member, span_boldwarning("TIME EXPIRED! The warband has been randomly configured and auto-advanced to casus belli selection."))
		SStgui.update_uis(member)
		update_static_data(member)
	advance_stage_timer(0)

// stage-2 timeout: settle the casus belli (warlord's pick > most-voted proposal > random term) and advance to class selection
/datum/warband_manager/proc/timeout_stage_two(mob/living/warlord)
	to_chat(warlord, span_boldwarning("TIME EXPIRED! Settling the casus belli..."))
	auto_select_leading_casus_belli() // the old force-spawn path proceeded without one entirely, so a failed pick isn't fatal
	creation_stage = 3
	for(var/mob/living/carbon/human/member in lobby_members)
		to_chat(member, span_boldwarning("The casus belli stage has closed. You may now choose your class."))
		member.playsound_local(member, 'sound/misc/warband/menusound3.ogg', 100, FALSE)
	advance_stage_timer(0)
	update_static_data_for_all_viewers()

// stage-3 timeout: auto-pick the warlord's class and finalize the warband
/datum/warband_manager/proc/timeout_stage_three(mob/living/warlord)
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
	if(!class_path) // no spawnable class exists for this configuration, so the lobby can't proceed
		message_admins("Warband [warband_ID] timed out with no valid warlord class. Cancelling the lobby.")
		for(var/mob/living/member in lobby_members.Copy())
			cancel_lobby(member)
		qdel(src)
		return
	finalize_warband(warlord, class_path, subclass_path)
	for(var/mob/living/carbon/human/member in lobby_members)
		if(member.mind.special_role == ROLE_WARLORD_LIEUTENANT || member.mind.special_role == ROLE_WARLORD_ASPIRANT || member.mind.special_role == ROLE_WARLORD_GRUNT)
			to_chat(member, span_boldwarning("TIME EXPIRED! The warband has been auto-finalized. You may now create your character."))
			member.playsound_local(member, 'sound/misc/warband/menusound3.ogg', 100, FALSE)

// warlord's pick > most-voted proposal > random term
/datum/warband_manager/proc/auto_select_leading_casus_belli()
	if(casus_belli_selection) // the warlord picked one but never advanced
		return TRUE
	if(casus_belli_proposals.len)
		var/best_count = -1
		var/list/leaders = list()
		for(var/list/proposal in casus_belli_proposals)
			var/list/confirmed = proposal["confirmed_votes"]
			if(confirmed.len > best_count)
				best_count = confirmed.len
				leaders = list()
			if(confirmed.len == best_count)
				leaders += list(proposal)
		var/list/winner = pick(leaders)
		var/found_type = text2path(winner["term_type"])
		if(found_type)
			winner["is_selected"] = TRUE
			casus_belli_selection = new found_type()
			var/list/details = winner["term_details"] || list()
			for(var/datum/treaty/input_field/field in casus_belli_selection.input_fields)
				if(field.client_only || isnull(details[field.key]))
					continue
				casus_belli_selection.vars[field.key] = details[field.key]
			announce_to_lobby(span_redteamradio("The most-supported casus belli proposal ([winner["term_name"]]) carries the day."))
			return TRUE

	var/list/no_input_terms = list()
	var/list/fillable_terms = list()
	for(var/datum/treaty/terms/term in SSwarbands.get_all_terms(selected_warband?.type))
		var/fillable = TRUE
		var/has_required = FALSE
		for(var/datum/treaty/input_field/field in term.input_fields)
			if(field.client_only || !field.required)
				continue
			has_required = TRUE
			if(istype(field, /datum/treaty/input_field/textarea) || istype(field, /datum/treaty/input_field/text_input))
				fillable = FALSE
				break
		if(!has_required)
			no_input_terms += term.type
		else if(fillable)
			fillable_terms += term.type
	var/list/candidate_pool = no_input_terms.len ? no_input_terms : fillable_terms
	if(!candidate_pool.len)
		return FALSE
	var/picked_type = pick(candidate_pool)
	casus_belli_selection = new picked_type()
	auto_fill_term_fields(casus_belli_selection)
	announce_to_lobby(span_redteamradio("With no proposals made, a random casus belli was selected: [casus_belli_selection.name]."))
	return TRUE

/datum/warband_manager/proc/auto_fill_term_fields(datum/treaty/terms/term)
	for(var/datum/treaty/input_field/field in term.input_fields)
		if(field.client_only || !field.required)
			continue
		if(!isnull(term.vars[field.key]) && term.vars[field.key] != "")
			continue
		if(istype(field, /datum/treaty/input_field/number))
			var/datum/treaty/input_field/number/num_field = field
			term.vars[field.key] = num_field.min_value
		else if(istype(field, /datum/treaty/input_field/option_dropdown))
			var/datum/treaty/input_field/option_dropdown/opt_field = field
			if(opt_field.options.len)
				term.vars[field.key] = pick(opt_field.options)
		else if(istype(field, /datum/treaty/input_field/faction_dropdown))
			var/list/faction_names = list()
			for(var/datum/treaty_flavor/faction in SSwarbands.treaty_flavor_factions)
				if(faction.type in DEFAULT_TREATY_FLAVOR_FACTIONS)
					faction_names += faction.name
			if(faction_names.len)
				term.vars[field.key] = pick(faction_names)

// auto-selects a primary class + subclass
/datum/warband_manager/proc/auto_pick_class_and_subclass(mob/member)
	var/role = member.mind?.special_role
	var/list/primaries = allowed_primaries(role)
	if(!primaries.len) // suppression/exclusivity filtered everything out, so fall back on the warband's own tier list
		primaries = tier_classes_for(selected_warband, role)
	primaries = filter_full_classes(primaries, member)
	if(!primaries.len)
		return list(null, null)
	var/class_path = pick(primaries)

	var/subclass_path
	if(selected_warband.universal_subclasses_enabled) // for universal-class warbands (mercenaries)
		var/list/subclass_pool = filter_full_classes(allowed_subclasses(role, class_path), member)
		if(subclass_pool.len)
			subclass_path = pick(subclass_pool)
	return list(class_path, subclass_path)

// called between stages | restarts the countdown for the next stage
// a manual advance carries the previous stage's leftover time
/datum/warband_manager/proc/advance_stage_timer(leftover = -1)
	if(leftover < 0)
		leftover = max(0, get_remaining_time())
	stop_creation_timer()
	warned = FALSE
	current_stage_limit = max(creation_warning_threshold, leftover)
	start_creation_timer()

// get remaining time in deciseconds
/datum/warband_manager/proc/get_remaining_time()
	if(!creation_timer_active)
		return -1
	var/elapsed = world.time - creation_start_time
	var/remaining = current_stage_limit - elapsed
	return max(0, remaining)
