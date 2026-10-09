// the big clump of UI acts
/datum/warband_manager/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = usr

	if(action == "interaction_sound")
		user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
		return TRUE

	var/user_key = user.ckey
	if(last_action_time[user_key] && world.time < last_action_time[user_key] + 10)
		return TRUE
	last_action_time[user_key] = world.time

	switch(action)
		if("swap_character_slot")
			select_pref_slot(user)
		if("refresh")
			update_static_data(user, ui)
		if("edit_character")
			user.client.prefs.ShowChoices(user, PREFERENCE_TAB_CHARACTER_CREATOR)
		if("create_character")
			if(user.mind.special_role == ROLE_WARLORD)
				to_chat(user, span_warning("Use the finalize button to complete your warband."))
				return
			if(!warlord_spawned)
				to_chat(user, span_warning("Wait for the Warlord to be finalized, first."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			var/class_path = text2path(params["class"])
			var/subclass_path = text2path(params["subclass"])
			if(!subclass_requirement_met(class_path, subclass_path))
				to_chat(user, span_warning("This class requires a subclass selection."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			if(!validate_class_selection(user, class_path, subclass_path))
				to_chat(user, span_warning("That class isn't available to this warband."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			SStgui.close_user_uis(user)
			user.mind.warband_manager = src
			if(user in lobby_members)
				lobby_members -= user
			load_appearance(user, user)
			lock_check(user, class_path)
			spawn_character(class_path, user, subclass_path, is_leader = 0, is_latespawn = user.mind.warband_latespawn)
			end_intro(user)
			update_static_data_for_all_viewers()
			return
		if("advance_stage")
			if(user.mind.special_role != ROLE_WARLORD)
				to_chat(user, span_warning("Only the Warlord can advance stages."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			if(creation_stage == 1)
				commit_warband_selection(user, params)
				return
			if(creation_stage == 2)
				if(!casus_belli_selection)
					to_chat(user, span_warning("A casus belli must be chosen before advancing."))
					user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
					return
				creation_stage = 3
				advance_stage_timer()
				INVOKE_ASYNC(src, PROC_REF(spawn_warcamp))
				for(var/mob/living/carbon/human/member in lobby_members)
					to_chat(member, span_greentext("The Warlord has advanced to class selection. You may now choose your class."))
				update_static_data_for_all_viewers()
				return
		if("create_warband")
			if(user.mind.special_role != ROLE_WARLORD)
				to_chat(user, span_warning("Only the Warlord may finalize the warband."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			if(creation_stage != 3)
				to_chat(user, span_warning("Select a Warband first."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			if(SSwarbands.warband_managers_busy == TRUE)
				to_chat(user, span_bold("Warband Generation is occupied. Please wait."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			var/class_path = text2path(params["class"])
			var/subclass_path = text2path(params["subclass"])
			if(!subclass_requirement_met(class_path, subclass_path))
				to_chat(user, span_warning("Your class requires a subclass selection before finalizing."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			if(!validate_class_selection(user, class_path, subclass_path))
				to_chat(user, span_warning("That class isn't available to this warband."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			finalize_warband(user, class_path, subclass_path)
			return
		if("toggle_ready")
			if(user.mind.special_role == ROLE_WARLORD)
				return
			if(creation_stage < 3)
				return
			if(user.ckey in ready_members)
				ready_members -= user.ckey
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
			else
				var/class_path_str = params["class"]
				var/ready_class_path = text2path(class_path_str)
				var/ready_subclass_path = text2path(params["subclass"])
				if(!class_path_str || !ready_class_path)
					to_chat(user, span_warning("Select a valid class before readying up."))
					user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
					return
				if(!subclass_requirement_met(ready_class_path, ready_subclass_path))
					to_chat(user, span_warning("Select a subclass before readying up."))
					user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
					return
				if(!validate_class_selection(user, ready_class_path, ready_subclass_path))
					to_chat(user, span_warning("That class isn't available to this warband."))
					user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
					return
				ready_members[user.ckey] = list(
					"class" = class_path_str,
					"subclass" = params["subclass"]
				)
				user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
			update_static_data_for_all_viewers()
			return
		if("propose_casus_belli")
			var/term_type_str = params["term_type"]
			var/term_name = params["term_name"]
			if(!term_type_str || !term_name)
				return
			var/found_type = text2path(term_type_str)
			if(!found_type)
				return
			var/list/old_proposal
			for(var/list/existing in casus_belli_proposals)
				if(existing["author"] == user.ckey)
					old_proposal = existing
					break
			var/datum/treaty/terms/new_term = new found_type()
			var/list/term_details = build_term_details(new_term, params)
			if(casus_proposal_duplicates(new_term, old_proposal))
				qdel(new_term)
				to_chat(user, span_warning("An identical proposition already exists. Your proposal was cancelled."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			var/term_desc = new_term.desc
			qdel(new_term)
			if(old_proposal)
				if(old_proposal["is_selected"])
					clear_casus_selection()
					announce_to_lobby(span_warning("The Warlord's chosen casus belli was withdrawn, as the proposal has been replaced."))
				notify_proposal_voters(old_proposal, "The proposal you voted for was replaced by its author. Your vote has been reset.")
				casus_belli_proposals -= list(old_proposal)
			user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
			var/list/new_proposal = list(
				"proposal_id" = "[user.ckey]_[world.time]",
				"term_type" = term_type_str,
				"term_name" = term_name,
				"term_desc" = term_desc,
				"term_details" = term_details,
				"author" = user.ckey,
				"confirmed_votes" = list(),
				"pending_votes" = list(),
				"is_selected" = FALSE
			)
			casus_belli_proposals += list(new_proposal)
			update_static_data_for_all_viewers()
			return
		if("vote_casus_belli")
			if(user.mind.special_role == ROLE_WARLORD)
				return
			if(creation_stage != 2)
				return
			var/target_id = params["proposal_id"]
			if(!target_id)
				return
			var/list/target_proposal = find_casus_proposal(target_id)
			if(!target_proposal)
				return
			var/was_mine = (user.ckey in target_proposal["pending_votes"]) || (user.ckey in target_proposal["confirmed_votes"])
			for(var/list/proposal in casus_belli_proposals)
				proposal["pending_votes"] -= user.ckey
				proposal["confirmed_votes"] -= user.ckey
			if(!was_mine)
				target_proposal["pending_votes"] += user.ckey
			update_static_data_for_all_viewers()
			return
		if("confirm_casus_belli")
			if(user.mind.special_role == ROLE_WARLORD)
				return
			var/target_id = params["proposal_id"]
			if(!target_id)
				return
			for(var/list/proposal in casus_belli_proposals)
				if(proposal["proposal_id"] == target_id && (user.ckey in proposal["pending_votes"]))
					proposal["pending_votes"] -= user.ckey
					proposal["confirmed_votes"] += user.ckey
					user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
					update_static_data_for_all_viewers()
					return
			return
		if("select_casus_belli")
			if(user.mind.special_role != ROLE_WARLORD)
				return
			var/target_id = params["proposal_id"]
			if(!target_id)
				return
			var/list/target_proposal = find_casus_proposal(target_id)
			if(!target_proposal)
				return
			var/found_type = text2path(target_proposal["term_type"])
			if(!found_type)
				return
			var/was_selected = target_proposal["is_selected"]
			clear_casus_selection()
			if(!was_selected)
				target_proposal["is_selected"] = TRUE
				casus_belli_selection = new found_type()
				var/list/details = target_proposal["term_details"] || list()
				for(var/datum/treaty/input_field/field in casus_belli_selection.input_fields)
					if(field.client_only || isnull(details[field.key]))
						continue
					casus_belli_selection.vars[field.key] = details[field.key]
			update_static_data_for_all_viewers()
			return
		if("edit_casus_belli")
			if(user.mind.special_role != ROLE_WARLORD)
				return
			if(creation_stage != 2)
				return
			var/target_id = params["proposal_id"]
			if(!target_id)
				return
			var/list/target_proposal = find_casus_proposal(target_id)
			if(!target_proposal)
				to_chat(user, span_warning("That proposal no longer exists."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			var/found_type = text2path(target_proposal["term_type"])
			if(!found_type)
				return
			var/datum/treaty/terms/edited_term = new found_type()
			var/list/term_details = build_term_details(edited_term, params)
			if(casus_proposal_duplicates(edited_term, target_proposal))
				qdel(edited_term)
				to_chat(user, span_warning("An identical proposition already exists. Your edit was cancelled."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			qdel(edited_term)
			notify_proposal_voters(target_proposal, "The proposal you voted for was edited by the Warlord. Your vote has been reset.")
			target_proposal["term_details"] = term_details
			if(params["term_name"])
				target_proposal["term_name"] = params["term_name"]
			target_proposal["confirmed_votes"] = list()
			target_proposal["pending_votes"] = list()
			if(target_proposal["is_selected"])
				clear_casus_selection()
				announce_to_lobby(span_warning("The Warlord's chosen casus belli was withdrawn, as the proposal was edited."))
			for(var/mob/living/member in lobby_members)
				if(member.ckey == target_proposal["author"])
					to_chat(member, span_warning("The Warlord has edited your casus belli proposal."))
					break
			user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
			update_static_data_for_all_viewers()
			return
		if("mute_lobby_chat")
			toggle_lobby_chat_mute(user)
			return
		if("request_role_swap")
			if(creation_stage != 1)
				to_chat(user, span_warning("Role swaps are only possible during warband selection."))
				user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
				return
			if(!(user in lobby_members))
				return
			if(user.ckey in pending_swap_ckeys)
				to_chat(user, span_warning("A role swap involving me is already pending."))
				return
			if(last_swap_request[user.ckey] && world.time < last_swap_request[user.ckey] + 30 SECONDS)
				to_chat(user, span_warning("I should wait for a moment."))
				return
			INVOKE_ASYNC(src, PROC_REF(handle_role_swap_request), user)
			return
		if("view_laws")
			to_chat(user, span_greentext("AZURIA'S LAWS ARE AS FOLLOWS:"))
			user.playsound_local(user, 'sound/misc/notice (2).ogg', 100, FALSE)
			for(var/law in GLOB.laws_of_the_land)
				to_chat(user, span_info(law))
			return
		if("view_vip")
			var/returned_vip = params["enemy"]
			var/mob/living/carbon/human/matched_vip
			for(var/mob/living/carbon/human/vip in importantfigures)
				if(vip.real_name == returned_vip)
					matched_vip = vip
					break
			if(matched_vip)
				if(!ismob(usr))
					return
				close_examine_panels(usr)
				var/datum/examine_panel/mob_examine_panel = new(matched_vip)
				mob_examine_panel.viewing = usr
				mob_examine_panel.ui_interact(usr)
				return
		if("view_member")
			var/mob/living/carbon/human/member = locate(params["ref"])
			if(!istype(member))
				return
			var/in_field = (member in members)
			var/in_lobby = (member in lobby_members)
			if(!in_field && !in_lobby)
				return
			if(!ismob(usr))
				return
			close_examine_panels(usr)
			var/datum/examine_panel/member_panel = new(member)
			if(in_lobby)
				if(!member.client?.prefs)
					to_chat(usr, span_warning("They have nothing to show."))
					return
				member_panel.pref = member.client.prefs
			member_panel.viewing = usr
			member_panel.ui_interact(usr)
			return
