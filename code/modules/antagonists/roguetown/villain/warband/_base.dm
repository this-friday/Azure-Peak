/datum/antagonist/warband
	var/is_lieutenant = FALSE

/datum/antagonist/warband/proc/mindwipe(var/datum/mind/owner)
	for(var/datum/mind/found_mind in get_minds())
		owner.become_unknown_to(found_mind)

/datum/antagonist/warband/proc/bankwipe(var/mob/owner)
	if(owner in SStreasury.bank_accounts)
		SStreasury.bank_accounts.Remove(owner)


//////////////////////////////////////////////////////
/////////////////////////////////// CANCEL CLASS MENUS
/datum/antagonist/warband/proc/cancel_class_menus(mob/living/carbon/human/owner)
	if(!istype(owner, /mob/dead))
		owner.advsetup = FALSE
	SStgui.close_user_uis(owner)
	if(owner.client)
		SSrole_class_handler.special_session_queue -= owner.ckey
		owner.client << browse(null, "window=latechoices")
		owner.client << browse(null, "window=class_handler_main")
		owner.client << browse(null, "window=class_select_yea")
		owner.client << browse(null, "window=input")
	var/datum/class_select_handler/related_handler = SSrole_class_handler.class_select_handlers[owner.ckey]
	if(related_handler)
		related_handler.ForceCloseMenus()
		SSrole_class_handler.class_select_handlers.Remove(owner.ckey)
		qdel(related_handler)

	for(var/atom/movable/screen/advsetup/subclass_hud in owner.hud_used.static_inventory)
		qdel(subclass_hud)


///////////////////////////////////////////////
/////////////////////////////////// REPLACE MOB

/datum/antagonist/warband/proc/replace_mob(mob/new_character)
	var/mob/living/replacement_mob = SSwarbands.get_lobby_mob()
	for(var/obj/effect/landmark/start/warlord/warlord_spawn in GLOB.landmarks_list)
		replacement_mob.forceMove(warlord_spawn.loc)
		break
	replacement_mob.key = new_character.key
	replacement_mob.sync_mind()
	GLOB.chosen_names -= new_character.real_name
	replacement_mob.real_name = get_replacement_name()
	GLOB.mob_living_list -= new_character
	new_character.alpha = 0
	new_character.moveToNullspace()
	return replacement_mob

/datum/antagonist/warband/proc/get_replacement_name()
	return "Warband Member"

/datum/antagonist/warband/on_gain()
	cancel_class_menus(owner.current)
	addtimer(CALLBACK(src, PROC_REF(initialstage)), 1 SECONDS)
	return ..()

/datum/antagonist/warband/proc/initialstage()
	var/stun_timer = 3 HOURS
	bankwipe(owner.current)
	mindwipe(owner)
	if(!owner.warband_latespawn)
		if(isliving(owner.current))
			owner.current.unequip_everything()
		var/mob/living/newmob = replace_mob(owner.current)
		newmob.invisibility = INVISIBILITY_MAXIMUM
		newmob.set_blindness(stun_timer)
		newmob.Stun(stun_timer)
		newmob.mind = owner
		owner.current = newmob
	else
		owner.current.set_blindness(stun_timer)
		owner.current.Stun(stun_timer)
	owner.current.mind.warbandsetup = TRUE
	post_spawn_setup()
	addtimer(CALLBACK(src, PROC_REF(setup_warband_manager)), 1 SECONDS)
	greet()

/datum/antagonist/warband/proc/post_spawn_setup()
	return

//////////////////////////////////////////////////////////
/////////////////////////////////// SETUP WARBAND MANAGER
/datum/antagonist/warband/proc/setup_warband_manager()
	if(!owner || !owner.current)
		return

	if(!owner.warband_ID)
		for(var/datum/mind/potential_warlord in get_minds())
			if(potential_warlord.special_role == "Warlord" && potential_warlord.warband_ID)
				if(potential_warlord.warband_manager)
					owner.warband_ID = potential_warlord.warband_ID
					break

	if(!owner.warband_ID)
		to_chat(owner.current, span_warning("Failed to find a Warlord. Setup cancelled."))
		qdel(owner.current) // It's over. Go Home.
		return

	for(var/atom/movable/screen/warband/manager/listed_manager in SSwarbands.warband_managers)
		if(listed_manager.warband_ID == owner.warband_ID)
			owner.warband_manager = listed_manager
			listed_manager.lobby_members += owner.current
			if(is_lieutenant)
				listed_manager.spawned_lieutenants++
			listed_manager.create_HUD_instance(owner.current)
			return

/datum/antagonist/warband/greet()
	ADD_TRAIT(owner.current, TRAIT_FORCED_LOBBY_CHAT, TRAIT_GENERIC)
	SEND_SOUND(owner.current, sound(null))
	return ..()

/datum/objective/warband/aspirant/greatergood
	name = "Greater Good"
	explanation_text = "The Warlord must prevail in his main objective."

/datum/objective/warband/aspirant/standard
	name = "Term"
	explanation_text = "A single treaty term of my design must be fulfilled."

/datum/objective/warband/aspirant/disorder
	name = "Pragmatism"
	explanation_text = "We must prevail by any means necessary. My Warband must recruit 4 or more allies."

/datum/objective/warband/aspirant/order
	name = "Order"
	explanation_text = "If we are to succeed, order must be maintained. My Warband cannot have more than 3 strangers in its ranks."

/datum/objective/warband/aspirant/wormtongue
	name = "Dead Weight"
	explanation_text = "The other Lieutenants cannot be trusted. By the end of the week, I must be the last remaining Lieutenant in the Warband."

/datum/objective/warband/aspirant/coin
	name = "Mammon"
	explanation_text = "I'm in desperate need of coin, and I've been long denied it. By the week's end, I need a total of 2000 mammon on my person."

/datum/objective/warband/warlord
	name = "Find Common Ground"
	explanation_text = "Sign a Treaty that benefits the Warband."

/datum/objective/survive/warband
	name = "Survive"
	explanation_text = "Live to reap the rewards."


// base objective for both aspirants & regular lieutenants
// succeed if the warlord's "find common ground" objective is complete
// the warlord's actual survival is irrelevant
/datum/objective/warband/aspirant/greatergood/check_completion()
	if(!owner || !owner.warband_manager)
		return FALSE
	var/atom/movable/screen/warband/manager/warband = owner.warband_manager
	for(var/mob/living/carbon/human/member in warband.members)
		if(!member.mind)
			continue
		if(member.mind.special_role == "Warlord")
			for(var/datum/objective/obj in member.mind.get_all_objectives())
				if(istype(obj, /datum/objective/warband/warlord))
					return obj.check_completion()
	return FALSE

// disorder
// succeed if the warband stays above 4 or more disorder
/datum/objective/warband/aspirant/disorder/check_completion()
	if(!owner || !owner.warband_manager)
		return FALSE
	var/atom/movable/screen/warband/manager/warband = owner.warband_manager
	return warband.disorder >= 4

// order
// succeed if disorder stays below 3
/datum/objective/warband/aspirant/order/check_completion()
	if(!owner || !owner.warband_manager)
		return FALSE
	var/atom/movable/screen/warband/manager/warband = owner.warband_manager
	return warband.disorder < 3

// wormtongue
// succeed if we're the only living lieutenant
/datum/objective/warband/aspirant/wormtongue/check_completion()
	if(!owner || !owner.warband_manager)
		return FALSE
	var/atom/movable/screen/warband/manager/warband = owner.warband_manager
	var/living_lieutenants = 0
	for(var/mob/living/carbon/human/member in warband.members)
		if(!member.mind)
			continue
		if(member.mind == owner)
			continue
		if(member.mind.special_role == "Lieutenant" || member.mind.special_role == "Aspirant Lieutenant")
			if(member.stat != DEAD)
				living_lieutenants++
	return living_lieutenants == 0

// coin
// succeed if they're carrying 2000 or more mammons
/datum/objective/warband/aspirant/coin/check_completion()
	if(!owner || !owner.current)
		return FALSE
	var/mammons = get_mammons_in_atom(owner.current)
	return mammons >= 2000

// standard
// succeed when a term you wrote is in a submitted treaty
// handled in treaty.dm
/datum/objective/warband/aspirant/standard/check_completion()
	return completed

// grunt only, given via (/datum/warbands/aspects/marked)
// succeed if the Warlord is dead
/datum/objective/warband/assassin
	name = "Death Mark"
	explanation_text = "The Warlord must die."

/datum/objective/warband/assassin/check_completion()
	return !target || target.current.stat == DEAD
