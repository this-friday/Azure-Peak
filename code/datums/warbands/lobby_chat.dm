/*	
	LOBBY CHAT
	in-lobby warband characters are given a TRAIT_FORCED_LOBBY_CHAT trait
	this intercepts their say() chat, and instead sends their messages into their warband's Lobby Chat
	-

*/
/atom/movable/screen/warband/manager
	var/lobby_chat_muted_until = 0

// returns a style based on the provided special_role
/atom/movable/screen/warband/manager/proc/get_warband_lobby_style(role)
	var/list/style = list("color" = "#bdbdbd", "size" = "100%", "weight" = "normal")
	if(role == "Warlord")
		style["color"] = "#e8bf67"
		style["size"] = "126%"
		style["weight"] = "bold"
	else if(role == "Lieutenant" || role == "Aspirant Lieutenant")
		style["color"] = "#d8a657"
		style["size"] = "108%"
		style["weight"] = "bold"
	return style

// say/chat proc
/client/proc/do_lobby_say(message as text)
	if(!mob || !prefs)
		return

	var/atom/movable/screen/warband/manager/manager = get_lobby_manager_for(mob)
	if(!manager)
		to_chat(src, span_warning("Your warband lobby channel isn't available right now."))
		return

	if(GLOB.say_disabled)
		to_chat(src, span_danger("Speech is currently admin-disabled."))
		return
	if(!(prefs.chat_toggles & CHAT_OOC))
		to_chat(src, span_danger("You have OOC muted."))
		return

	var/speaker_is_warlord = (mob.mind?.special_role == "Warlord")

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

	var/role = mob.mind?.special_role || "Grunt"
	var/list/style = manager.get_warband_lobby_style(role)
	var/col = style["color"]
	var/size = style["size"]
	var/speaker_name = mob.real_name
	var/speaker_ckey = mob.ckey
	var/lobby_line = "<font color='[col]'><span style='font-size:[size];font-weight:[style["weight"]]'><b>[speaker_name]</b>: <span class='message'>[message]</span></span></font>"

	var/list/recipients = list()
	for(var/mob/living/lobby_member in manager.lobby_members)
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
/atom/movable/screen/warband/manager/proc/toggle_lobby_chat_mute(mob/user)
	if(!user?.mind || user.mind.special_role != "Warlord")
		to_chat(user, span_warning("Only the Warlord may silence the lobby."))
		user.playsound_local(user, 'sound/misc/warband/menusound_fail.ogg', 100, FALSE)
		return
	if(lobby_chat_muted_until > world.time)
		lobby_chat_muted_until = 0
		announce_to_lobby(span_greenteamradio("The Warlord lifts the silence. The lobby may speak freely."))
		user.playsound_local(user, 'sound/misc/warband/menusound1.ogg', 100, FALSE)
	else
		lobby_chat_muted_until = world.time + 2 MINUTES
		announce_to_lobby(span_redteamradio("The Warlord silences the lobby. Only the Warlord may speak for the next 2 minutes."))
		user.playsound_local(user, 'sound/misc/warband/menusound3.ogg', 100, FALSE)

	SStgui.update_uis(src)

/atom/movable/screen/warband/manager/proc/announce_to_lobby(text)
	for(var/mob/living/lobby_member in lobby_members)
		if(!lobby_member.client)
			continue
		to_chat(lobby_member, text)
