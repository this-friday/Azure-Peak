/datum/job/roguetown/warlord
	title = "Warlord"
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	min_pq = null
	max_pq = null
	announce_latejoin = FALSE
	show_in_credits = FALSE
	give_bank_account = FALSE
	hidden_job = TRUE

/datum/antagonist/warband/warlord
	name = "Warlord"
	roundend_category = "Warlord"
	antagpanel_category = "Warlord"
	job_rank = ROLE_WARLORD
	confess_lines = list(
		"A WAR IN MY NAME!",
		"THESE LANDS ARE MINE!",
		"I AM OWED!",
	)
	rogue_enabled = TRUE

/datum/antagonist/warband/warlord/get_replacement_name()
	return "The Warlord"

/datum/antagonist/warband/warlord/replace_mob(mob/living/carbon/human/new_warlord)
	var/mob/living/replacement_mob = ..(new_warlord)
	if(!istype(new_warlord, /mob/dead))
		SSwarbands.replaced_mobs += new_warlord
	new_warlord.real_name = "replacedmob"
	return replacement_mob

/datum/antagonist/warband/warlord/initialstage()
	var/stun_timer = 3 HOURS
	bankwipe(owner.current)
	mindwipe(owner)

	var/mob/living/newmob = replace_mob(owner.current)
	newmob.invisibility = INVISIBILITY_MAXIMUM
	newmob.set_blindness(stun_timer)
	newmob.Stun(stun_timer)
	newmob.mind = owner
	owner.current = newmob
	SSmapping.retainer.warlords |= newmob.mind
	newmob.mind.special_role = name
	if(!SSwarbands.roundstart_manager_claimed)
		newmob.mind.warband_ID = SSwarbands.roundstart_manager.warband_ID
	else
		newmob.mind.warband_ID = SSwarbands.next_warband_id
	newmob.faction |= list("warband_[newmob.mind.warband_ID]")
	newmob.mind.warbandsetup = TRUE
	addtimer(CALLBACK(src, PROC_REF(greet)), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(create_warband_manager), newmob, newmob.mind), 1 SECONDS)


// creates a warband manager for the warlord & syncs its ID with the warlord's mind
/datum/antagonist/warband/warlord/proc/create_warband_manager(mob/living/new_warlord, datum/mind/owner)
	var/atom/movable/screen/warband/manager/pregame_manager

	if(!SSwarbands.roundstart_manager_claimed && SSwarbands.roundstart_manager)
		pregame_manager = SSwarbands.roundstart_manager
		SSwarbands.roundstart_manager_claimed = TRUE
		owner.warband_ID = pregame_manager.warband_ID
	else
		pregame_manager = new /atom/movable/screen/warband/manager()
		pregame_manager.warband_ID = SSwarbands.next_warband_id++
		SSwarbands.warband_managers += pregame_manager
		owner.warband_ID = pregame_manager.warband_ID
	if(!pregame_manager.creation_timer_active)
		pregame_manager.start_creation_timer()
	pregame_manager.lobby_members += owner.current
	owner.warband_manager = pregame_manager
	pregame_manager.create_HUD_instance(new_warlord)

/datum/antagonist/warband/warlord/greet()
	..()
	to_chat(owner.current, span_danger("I bear great, terrible dreams. My legions shall make them a reality."))
	var/list/intro_sounds = list(
		'sound/misc/warband/selection_introc.ogg'
	)
	var/chosen_song = pick(intro_sounds)
	var/sound/S = sound(chosen_song, repeat = 0, wait = 0, channel = 0, volume = 60)
	SEND_SOUND(owner.current, S)
	var/atom/movable/screen/introtext/intro_text = new /atom/movable/screen/introtext
	owner.current.client.screen += intro_text
	animate(intro_text, alpha = 255, time = 50)
	forge_objectives()

/datum/antagonist/warband/warlord/on_removal()
	to_chat(owner.current, span_userdanger("I have nothing planned for the AZURE PEAK. It's over."))
	return ..()

//////// Objectives
/datum/antagonist/warband/warlord/proc/forge_objectives()
	var/datum/objective/warband/warlord/base_objective = new
	var/datum/objective/survive/warband/survive_objective = new
	objectives += base_objective
	objectives += survive_objective
	owner.announce_objectives()
