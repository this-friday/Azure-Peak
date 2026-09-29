/*	
	LOBBY CHAT
	in-lobby warband characters are given a TRAIT_FORCED_LOBBY_CHAT trait
	this intercepts their say() chat, and instead sends their messages into their warband's Lobby Chat
	-

*/
/datum/warband_manager
	var/lobby_chat_muted_until = 0
	var/list/pending_swap_offers = list()	// an associated list of: target ckey + offer details | used to track Role Swap requests between warband members

// returns a style based on the provided special_role
/datum/warband_manager/proc/get_warband_lobby_style(role)
	var/list/style = list("color" = "#bdbdbd", "size" = "100%", "weight" = "normal")
	if(role == ROLE_WARLORD)
		style["color"] = "#e8bf67"
		style["size"] = "126%"
		style["weight"] = "bold"
	else if(role == ROLE_WARLORD_LIEUTENANT || role == ROLE_WARLORD_ASPIRANT)
		style["color"] = "#d8a657"
		style["size"] = "108%"
		style["weight"] = "bold"
	return style

// say/chat proc
/client/proc/do_lobby_say(message as text)
	if(!mob || !prefs)
		return

	var/datum/warband_manager/manager = get_lobby_manager_for(mob)
	if(!manager)
		to_chat(src, span_warning("Your warband lobby channel isn't available right now."))
		return

	if(GLOB.say_disabled)
		to_chat(src, span_danger("Speech is currently admin-disabled."))
		return
	if(!(prefs.chat_toggles & CHAT_OOC))
		to_chat(src, span_danger("You have OOC muted."))
		return

	var/speaker_is_warlord = (mob.mind?.special_role == ROLE_WARLORD)

	// warlord silence: blocks everyone except the Warlord themselves
	if(!speaker_is_warlord && manager.lobby_chat_muted_until > world.time)
		var/secs_left = round((manager.lobby_chat_muted_until - world.time) / 10)
		to_chat(src, span_danger("The Warlord has silenced the lobby. ([secs_left]s remaining.)"))
		return

	message = copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)
	if(!message)
		return
	if(handle_spam_prevention(message, MUTE_LOOC)) 
		return
	if(findtext(message, "byond://")) // ctrl c'd from looc.dm & deadsay.dm
		to_chat(src, "<B>Advertising other servers is not allowed.</B>")
		log_admin("[key_name(src)] attempted to advertise in a warband lobby: [message]")
		return

	mob.log_talk(message, LOG_LOOC)

	var/role = mob.mind?.special_role || ROLE_WARLORD_GRUNT
	var/list/style = manager.get_warband_lobby_style(role)
	var/col = style["color"]
	var/size = style["size"]
	var/speaker_name = mob.real_name
	var/speaker_ckey = mob.ckey
	var/lobby_line = "<font color='[col]'><span style='font-size:[size];font-weight:[style["weight"]]'><b>[speaker_name]</b>: <span class='message'>[message]</span></span></font>"

	var/list/recipients = list()
	var/list/hearing_members = manager.lobby_members.Copy()
	if(manager.linked_lobby) // sundered lobbies share their chat, so the two hosts can conspire
		hearing_members |= manager.linked_lobby.lobby_members
	for(var/mob/living/lobby_member in hearing_members)
		var/client/lobby_client = lobby_member.client
		if(!lobby_client)
			continue
		if(!(lobby_client.prefs.chat_toggles & CHAT_OOC))
			continue
		recipients |= lobby_client
	recipients |= src

	for(var/client/receiving_client in recipients)
		to_chat(receiving_client, lobby_line)

	// deadchat mirror
	// shows the message + real_name (admins also see the ckey in parens)
	for(var/mob/dead/dead_watcher in GLOB.player_list)
		var/client/deadchat_client = dead_watcher.client
		if(!deadchat_client || deadchat_client == src)
			continue
		if(!(isobserver(dead_watcher) || (deadchat_client in GLOB.admins)))
			continue
		if(!(deadchat_client.prefs.chat_toggles & CHAT_DSAY))
			continue
		var/admin_suffix = ""
		if(deadchat_client in GLOB.admins)
			admin_suffix = " ([speaker_ckey]) <a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(mob)]'>\[PP\]</a>"
		var/dead_line = span_gamedeadsay("<span class='prefix'>WARBAND:</span> <font color='[col]'><b>[speaker_name]</b>[admin_suffix]</font>: <span class='dsayspeech'>\"[message]\"</span>")
		to_chat(deadchat_client, dead_line)

// a warlord-only toggle for a 2-minute lobby silence
// could technically be bypassed by looc, but that should be fine
/datum/warband_manager/proc/toggle_lobby_chat_mute(mob/user)
	if(!user?.mind || user.mind.special_role != ROLE_WARLORD)
		to_chat(user, span_warning("Only the Warlord may silence the lobby."))
		user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
		return
	var/announcement
	if(lobby_chat_muted_until > world.time)
		lobby_chat_muted_until = 0
		announcement = span_greenteamradio("The Warlord lifts the silence. The lobby may speak freely.")
		user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
	else
		lobby_chat_muted_until = world.time + 2 MINUTES
		announcement = span_redteamradio("The Warlord silences the lobby. Only the Warlord may speak for the next 2 minutes.")
		user.playsound_local(user, 'sound/misc/warband/menusound3.ogg', 100, FALSE)
	announce_to_lobby(announcement)
	if(linked_lobby) // mutes are shared between linked lobbies
		linked_lobby.lobby_chat_muted_until = lobby_chat_muted_until
		linked_lobby.announce_to_lobby(announcement)
		SStgui.update_uis(linked_lobby)

	SStgui.update_uis(src)

/datum/warband_manager/proc/announce_to_lobby(text)
	for(var/mob/living/lobby_member in lobby_members)
		if(!lobby_member.client)
			continue
		to_chat(lobby_member, text)

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////// ROLE SWAP
/*
	any two lobby members may trade their special_roles during stage 1 (warband selection)
	the requester picks a target, the target gets a clickable ACCEPT/REFUSE chat message
	an unanswered offer expires after 30 seconds

*/

/datum/warband_manager/proc/display_role(role)
	if(role == ROLE_WARLORD_ASPIRANT)
		return ROLE_WARLORD_LIEUTENANT
	return role

// asks the requester to pick a target, then sends the target a clickable chat offer
/datum/warband_manager/proc/handle_role_swap_request(mob/living/requester)
	if(!requester?.mind || !(requester in lobby_members))
		return
	var/list/choices = list()
	for(var/mob/living/candidate in lobby_members)
		if(candidate == requester || !candidate.client || !candidate.mind)
			continue
		var/label = "[candidate.client.prefs?.real_name || candidate.ckey] ([display_role(candidate.mind.special_role)])"
		choices[label] = candidate
	if(!choices.len)
		to_chat(requester, span_warning("There's nobody to swap roles with."))
		return
	var/picked_label = tgui_input_list(requester, "Whose role do I covet?", "ROLE SWAP", choices)
	if(!picked_label)
		return
	var/mob/living/target = choices[picked_label]
	if(creation_stage != 1 || !(requester in lobby_members) || !istype(target) || !(target in lobby_members) || !target.client || !target.mind || !requester.mind)
		to_chat(requester, span_warning("The moment has passed. Swaps may only be performed in phase 1."))
		return
	var/requester_role = requester.mind.special_role
	var/target_role = target.mind.special_role
	if(requester_role == target_role)
		to_chat(requester, span_warning("We already serve the same station."))
		return
	if((requester.ckey in pending_swap_ckeys) || (target.ckey in pending_swap_ckeys))
		to_chat(requester, span_warning("A role swap involving one of us is already pending."))
		return
	var/requester_name = requester.client?.prefs?.real_name || requester.ckey
	var/target_name = target.client?.prefs?.real_name || target.ckey
	pending_swap_ckeys += requester.ckey
	pending_swap_ckeys += target.ckey
	last_swap_request[requester.ckey] = world.time
	pending_swap_offers[target.ckey] = list(
		"requester_ckey" = requester.ckey,
		"requester_name" = requester_name,
		"target_name" = target_name,
		"requester_role" = requester_role,
		"target_role" = target_role,
		"timer_id" = addtimer(CALLBACK(src, PROC_REF(expire_swap_offer), target.ckey), 30 SECONDS, TIMER_STOPPABLE)
	)
	to_chat(requester, span_notice("The offer is sent. Awaiting their answer..."))
	var/offer_line = "<b>ROLE SWAP:</b> [requester_name] ([display_role(requester_role)]) offers to swap roles with me. I would become a [display_role(requester_role)], and they would become a [display_role(target_role)]. <a href='?src=[REF(src)];swap_answer=accept'>\[ACCEPT\]</a> <a href='?src=[REF(src)];swap_answer=refuse'>\[REFUSE\]</a>"
	to_chat(target, span_notice(offer_line))
	target.playsound_local(target, 'sound/misc/warband/menusound1.ogg', 100, FALSE)

// the target clicked ACCEPT or REFUSE on their offer
/datum/warband_manager/proc/resolve_swap_offer(mob/living/target, accepted)
	var/list/offer = pending_swap_offers[target.ckey]
	if(!offer)
		return
	clear_swap_offer(target.ckey)
	var/mob/living/requester
	for(var/mob/living/candidate in lobby_members)
		if(candidate.ckey == offer["requester_ckey"])
			requester = candidate
			break
	if(!accepted)
		if(requester)
			to_chat(requester, span_warning("The offer was refused."))
		return
	if(!requester)
		to_chat(target, span_warning("They're no longer in the lobby. The swap is off."))
		return
	complete_role_swap(requester, target, offer["requester_role"], offer["target_role"])

// re-validates everything (everything could've changed since the moment the offer was made), then trades special_roles
/datum/warband_manager/proc/complete_role_swap(mob/living/requester, mob/living/target, requester_role, target_role)
	if(creation_stage != 1 || !(requester in lobby_members) || !(target in lobby_members) || !requester.client || !target.client || !requester.mind || !target.mind)
		to_chat(target, span_warning("The moment has passed. Swaps may only be performed in phase 1."))
		return
	if(requester.mind.special_role != requester_role || target.mind.special_role != target_role)
		to_chat(requester, span_warning("Our stations have shifted. The swap is off."))
		to_chat(target, span_warning("Our stations have shifted. The swap is off."))
		return
	var/requester_name = requester.client?.prefs?.real_name || requester.ckey
	var/target_name = target.client?.prefs?.real_name || target.ckey
	requester.mind.special_role = target_role
	target.mind.special_role = requester_role
	to_chat(requester, span_greenteamradio("The swap is made. I now serve as [display_role(target_role)]."))
	to_chat(target, span_greenteamradio("The swap is made. I now serve as [display_role(requester_role)]."))
	announce_to_lobby(span_redteamradio("[requester_name] and [target_name] have swapped roles."))
	requester.playsound_local(requester, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
	target.playsound_local(target, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
	update_static_data_for_all_viewers()

// removes a pending offer
/datum/warband_manager/proc/clear_swap_offer(target_ckey)
	var/list/offer = pending_swap_offers[target_ckey]
	if(!offer)
		return
	if(offer["timer_id"])
		deltimer(offer["timer_id"])
	pending_swap_ckeys -= offer["requester_ckey"]
	pending_swap_ckeys -= target_ckey
	pending_swap_offers -= target_ckey

// the offer went unanswered for 30 seconds
/datum/warband_manager/proc/expire_swap_offer(target_ckey)
	var/list/offer = pending_swap_offers[target_ckey]
	if(!offer)
		return
	clear_swap_offer(target_ckey)
	for(var/mob/living/member in lobby_members)
		if(member.ckey == offer["requester_ckey"])
			to_chat(member, span_warning("The offer went unanswered."))
		else if(member.ckey == target_ckey)
			to_chat(member, span_warning("The role swap offer has lapsed."))

// voids every pending offer (lobby death, schisms) | reason_text (if any) is sent to everyone involved
/datum/warband_manager/proc/cancel_all_swap_offers(reason_text)
	for(var/target_ckey in pending_swap_offers.Copy())
		var/list/offer = pending_swap_offers[target_ckey]
		clear_swap_offer(target_ckey)
		if(!reason_text)
			continue
		for(var/mob/living/member in lobby_members)
			if(member.ckey == offer["requester_ckey"] || member.ckey == target_ckey)
				to_chat(member, span_warning(reason_text))
