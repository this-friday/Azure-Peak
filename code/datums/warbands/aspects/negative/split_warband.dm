////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// half the lobby splits into a second, independent warband

/datum/warbands/aspects/split_warband
	title = "DIVORCE"
	summary = "We were never meant to be."
	desc = "Half of the lobby automatically schisms and create a second, independent warband with its own warlord. \
	You will share a lobby chat. \
	(NOTE: Only one Warband will receive a warcamp, and the other will be spawned directly into the world.)"
	warning = "...of an open schism in their ranks."
	points = 1
	random_blacklisted = TRUE // a timeout selecting this (when assumedly the warlord's afk) would be too weird

/datum/warbands/aspects/split_warband/on_warband_confirmed(datum/warband_manager/manager, intensity = 1)
	manager.split_lobby()

/datum/warband_manager
	var/datum/warband_manager/linked_lobby // a two-way link between the split lobbies

/datum/warband_manager/proc/split_lobby()
	var/list/candidates = list()
	for(var/mob/living/member in lobby_members)
		if(!member.mind || member.mind.special_role == ROLE_WARLORD)
			continue
		candidates += member

	if(candidates.len < 2)
		return

	candidates = shuffle(candidates)
	var/departing_count = -round(-candidates.len / 2)
	var/list/departing = candidates.Copy(1, departing_count + 1)

	// the second warband
	var/datum/warband_manager/new_manager = new /datum/warband_manager()
	SSwarbands.register_manager(new_manager)
	new_manager.linked_lobby = src
	new_manager.lobby_chat_number = 2
	lobby_chat_number = 1
	linked_lobby = new_manager
	new_manager.lobby_chat_muted_until = lobby_chat_muted_until
	cancel_all_swap_offers("Role swap cancelled. The lobby was split.")

	for(var/mob/living/member in departing)
		lobby_members -= member
		new_manager.lobby_members += member
		member.mind.warband_ID = new_manager.warband_ID
		member.mind.warband_manager = new_manager
		if(member.mind.special_role == ROLE_WARLORD_LIEUTENANT || member.mind.special_role == ROLE_WARLORD_ASPIRANT)
			spawned_lieutenants--
			new_manager.spawned_lieutenants++
		SStgui.close_user_uis(member)
		if(member.client)
			member.client.screen -= button
		new_manager.create_HUD_instance(member)
		to_chat(member, span_boldwarning("You've been pushed into another warband. You are now in WARBAND 2."))
		
	var/list/officer_candidates = list()
	for(var/mob/living/member in departing)
		if(member.mind.special_role == ROLE_WARLORD_LIEUTENANT || member.mind.special_role == ROLE_WARLORD_ASPIRANT)
			officer_candidates += member // we prefer officers as candidates, but beyond that we'll take anyone
	var/mob/living/new_warlord = officer_candidates.len ? pick(officer_candidates) : pick(departing)

	new_manager.promote_new_warlord(new_warlord)
	new_manager.start_creation_timer()
	var/old_warlord_name = "the original Warlord"
	for(var/mob/living/member in lobby_members)
		if(member.mind?.special_role == ROLE_WARLORD)
			old_warlord_name = member.real_name
			break
	var/announcement = span_redteamradio("The lobby has been split. WARBAND 1 is led by [old_warlord_name]. WARBAND 2 is led by [new_warlord.real_name]. For planning's sake, both lobbies still share this chat.")
	announce_to_lobby(announcement)
	new_manager.announce_to_lobby(announcement)
	for(var/mob/living/member in lobby_members + new_manager.lobby_members)
		member.playsound_local(member, 'sound/misc/warband/warband_warhorn3.ogg', 100, FALSE)

/datum/warband_manager/proc/promote_new_warlord(mob/living/new_warlord)
	new_warlord.mind.special_role = ROLE_WARLORD
	SSmapping.retainer.warlords |= new_warlord.mind
	var/datum/antagonist/warband/antag_datum = new_warlord.mind.has_antag_datum(/datum/antagonist/warband)
	if(antag_datum)
		antag_datum.objectives.Cut() // clear their prior objectives
		var/datum/objective/warband/warlord/base_objective = new
		base_objective.owner = new_warlord.mind
		antag_datum.objectives += base_objective
		var/datum/objective/survive/warband/survive_objective = new
		survive_objective.owner = new_warlord.mind
		antag_datum.objectives += survive_objective
		new_warlord.mind.announce_objectives()
	to_chat(new_warlord, span_userdanger("I am a Warlord!"))
