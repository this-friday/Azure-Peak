/obj/structure/fluff/warband
	var/warband_ID = 0
	var/datum/warband_manager/linked_warband
	max_integrity = 0

/obj/structure/fluff/warband/Initialize()
	..()
	SSwarbands.warband_machines += src

/obj/structure/fluff/warband/Destroy()
	SSwarbands.warband_machines -= src
	linked_warband = null
	return ..()

/obj/structure/fluff/warband/campaign_planner
	name = "campaign planner"
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "scrollwrite"

/obj/structure/fluff/warband/campaign_planner/attack_hand(mob/user)
	. = ..()
	if(!user.mind || !linked_warband)
		return
	if(IS_WARBAND_MEMBER_ROLE(user.mind))
		if(user.mind.warband_ID == warband_ID)
			var/datum/outskirts_encounter/encounter = linked_warband.encounter_manager // schism warbands don't have one until they scout a path
			var/list/campaign_options = list()
			campaign_options += "HELP"
			campaign_options += "View Troops"
			campaign_options += "View Allies"
			campaign_options += "View Morale"
			if(IS_WARBAND_OFFICER(user.mind) || user.mind.special_role == ROLE_WARLORD_ENVOY)
				campaign_options += "Prepare Treaty"
			if(IS_WARBAND_WARLORD(user.mind))
				campaign_options += "Exile Member"
				if(encounter)
					if(encounter.outskirts_locked)
						campaign_options += "Stand Down Outskirts Defenses"
					else if(!encounter.encounter_disabled)
						campaign_options += "Raise Outskirts Defenses"

			var/campaign_choice = tgui_input_list(user, "What shall I do?", "Warband Recruitment", campaign_options)

			switch(campaign_choice)
				if("HELP")
					return
				if("Prepare Treaty")
					if(!COOLDOWN_FINISHED(user.mind, treaty_cooldown))
						var/time_left = COOLDOWN_TIMELEFT(user.mind, treaty_cooldown)
						to_chat(user, span_warning("I've recently prepared a treaty. I should wait another [round(time_left / 10, 1)] seconds."))
						return
					if(!linked_warband.linked_faction)
						to_chat(user, span_warning("Our warband bears no recognized name yet. There's no one to draft a treaty for."))
						return
					var/obj/item/treaty/spawned_treaty = new /obj/item/treaty(loc)
					new /obj/item/natural/feather(loc)
					spawned_treaty.firstparty = linked_warband.linked_faction.name
					spawned_treaty.secondparty = "The Crown"
					spawned_treaty.add_unique_terms(linked_warband)
					linked_warband.apply_casus_belli_to_treaty(spawned_treaty)
					COOLDOWN_START(user.mind, treaty_cooldown, 15 MINUTES)
					return
				if("View Troops")
					to_chat(user, span_warning("[linked_warband.spawns] soldiers remain at our disposal. Our finest are..."))
					for(var/mob/living/member in linked_warband.members)
						to_chat(user, span_warning("- [member.real_name], the [member.job]."))
					return
				if("Exile Member")
					var/list/viable_member_list = list()
					for(var/mob/living/member in linked_warband.members)
						if(member.real_name != user.real_name)
							viable_member_list += member.real_name
					if(!viable_member_list.len)
						to_chat(user, span_warning("There are no other members to exile."))
						return
					var/mob/living/exile_choice = tgui_input_list(user, "Who must go?", "EXILE", viable_member_list)
					if(exile_choice)
						linked_warband.exile(null, user, exile_choice)
						return
					else
						to_chat(user, span_warning("I've changed my mind."))
						return
				if("View Morale")
					if(linked_warband.disorder <= 1)
						to_chat(user, span_green("Spirits are high!"))
						return
					if(linked_warband.disorder <= 2)
						to_chat(user, span_warning("There's some strain weighing upon our legion's spirit, but we're holding out well enough."))
						return
					if(linked_warband.disorder <= 3)
						to_chat(user, span_warning("More than a few instances of insubordination have been reported."))
						return
					if(linked_warband.disorder <= 4)
						to_chat(user, span_warning("If order isn't restored, we shall be found in dire straits."))
						return
					if(linked_warband.disorder <= 8)
						to_chat(user, span_warning("Unrest is rampant in our ranks. We won't hold together for much longer."))
						return
					if(linked_warband.disorder <= 10)
						to_chat(user, span_warning("Order has completely broken down. We are akin to bandits."))

				if("View Allies")
					if(!linked_warband.allies.len)
						to_chat(user, span_warning("We are without allies."))
						return
					for(var/mob/living/ally in linked_warband.allies)
						to_chat(user, span_warning("There is [ally.real_name], the [ally.job]. They were joined with us by decree of [ally.mind.warband_recruiter_name]"))

					return
				if("Stand Down Outskirts Defenses")
					if(!encounter)
						return
					if(!linked_warband.outskirts_established)
						to_chat(user, span_warning("We haven't established our outskirts yet."))
						return
					if(encounter.encounter_active)
						to_chat(user, span_warning("There's still a battle happening in the outskirts. I cannot lower our defenses."))
						return
					if(encounter.attacker_rout_active)
						to_chat(user, span_warning("Our foe is currently being routed from the field. I can't stand down our defenses just yet."))
						return

					var/confirm = tgui_alert(user, "Stand down the outskirts defenses? This will allow anyone to enter the warcamp.", "Stand Down Outskirts", list("Yes", "No"))
					if(confirm != "Yes")
						return
					encounter.cancel_march()
					encounter.outskirts_locked = FALSE
					to_chat(user, span_notice("The troops on our outskirts have stood down. Anyone may enter the warcamp."))
					return
				if("Raise Outskirts Defenses")
					if(!encounter)
						return
					if(encounter.encounter_disabled)
						to_chat(user, span_warning("Our defensive line is shattered. We cannot reform our ranks."))
						return

					var/confirm = tgui_alert(user, "Raise the outskirts defenses? This will lock the warcamp from intruders.", "Raise Outskirts Defenses", list("Yes", "No"))
					if(confirm != "Yes")
						return
					if(!encounter.encounter_disabled)
						encounter.outskirts_locked = TRUE
						to_chat(user, span_notice("The outskirts defenses have been raised. The warcamp is now secured."))
						return
			return
	return


//////SPAWNER
/obj/structure/fluff/warband/warband_recruit
	name = "rally point"
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "travel"
	color = "#b61111"
	var/disabled = FALSE
	var/destruction_doafter = "prepares to clear out the rally point."
	var/destruction_msg = "The rally point is no more. The Warband's tide of reinforcements is stemmed."

/obj/structure/fluff/warband/foreguard

/obj/structure/fluff/warband/rearguard

/obj/structure/fluff/warband/shortcut
	name = "shortcut"
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "travel"
	var/disabled = FALSE


/obj/structure/fluff/warband/shortcut/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(user.mind.warband_ID == warband_ID)
		if(disabled)
			if(do_after(user, 90, target = src))
				disabled = FALSE
				alpha = 255
				to_chat(user, span_userdanger("I've restored the Shortcut!"))
				return
		else
			to_chat(user, span_bold("This is a one-way path. If I want to leave, I'll need to leave through the front."))


	else if(!disabled)
		user.visible_message(span_info("[user] prepares to clear out [src]."))
		if(do_after(user, 90, target = src))
			disabled = TRUE
			alpha = 50
			to_chat(user, span_userdanger("The coast is clear. We won't be flanked from this Shortcut."))
			return

/obj/structure/fluff/warband/warband_recruit/proc/summon_lieutenant(mob/user)
	var/given_warband_ID = user.mind.warband_ID
	if(linked_warband.spawns <= 0)
		to_chat(user, span_warning("We've been completely decimated. No one remains to heed my call."))
		return FALSE
	if(linked_warband.busy_summoning == TRUE)
		to_chat(user, span_warning("There's already been a call for our men to rally. I'll need to wait for a moment."))
		return FALSE
	if(linked_warband.lobby_members.len)
		to_chat(user, span_warning("I need to be patient. My men are still preparing themselves."))
		return FALSE
	if(linked_warband.spawned_lieutenants >= LIEUTENANTS_PER_WARLORD)
		to_chat(user, span_warning("There are no more capable Lieutenants left."))
		return FALSE
	// the flag is taken here and released in exactly one place, no matter how the attempt ends inside
	linked_warband.busy_summoning = TRUE
	. = do_summon_lieutenant(user, given_warband_ID)
	linked_warband.busy_summoning = FALSE

/obj/structure/fluff/warband/warband_recruit/proc/do_summon_lieutenant(mob/user, given_warband_ID)
	to_chat(user, span_green("The summons are sent."))
	var/turf/spawnpoint = get_turf(src)
	var/list/candidates = pollGhostCandidates("Do you want to play as one of the [user.advjob]'s Lieutenants?", ROLE_WARLORD_LIEUTENANT, null, null, 10 SECONDS, POLL_IGNORE_WARBAND_LIEUTENANT)
	if(!LAZYLEN(candidates))
		to_chat(user, span_warning("The summons go unanswered."))
		return TRUE

	var/mob/candidate = pick(candidates)
	if(!candidate || !istype(candidate, /mob/dead))
		return FALSE

	if(istype(candidate, /mob/dead/new_player))
		var/mob/dead/new_player/N = candidate
		N.close_spawn_windows()

	to_chat(user, span_green("My summons are answered. I must simply spare them a moment to arm themselves."))
	var/mob/living/carbon/human/target = SSwarbands.get_lobby_mob()
	target.forceMove(spawnpoint)
	target.invisibility = INVISIBILITY_MAXIMUM
	target.set_blindness(3 HOURS)
	target.sync_mind()
	target.mind.warband_ID = given_warband_ID
	target.mind.warband_latespawn = TRUE
	target.mind.warband_manager = linked_warband
	target.mind.warbandsetup = TRUE
	target.key = candidate.key
	SSjob.AssignRole(target, ROLE_WARLORD_LIEUTENANT)
	target.mind.add_antag_datum(/datum/antagonist/warband/lieutenant)
	linked_warband.spawns--
	return TRUE

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////// EQUIP VETERAN
/*
	spawns & equips a veteran
*/
/obj/structure/fluff/warband/warband_recruit/proc/summon_veteran(mob/user)
	var/given_warband_ID = user.mind.warband_ID
	if(linked_warband.spawns <= 0)
		to_chat(user, span_warning("We've been completely decimated. No one remains to heed my call."))
		return FALSE
	if(linked_warband.lobby_members.len)
		to_chat(user, span_warning("I need to be patient. My men are still preparing themselves."))
		return FALSE
	if(length(user.mind.subordinates) >= warband_grunts_per_lieutenant())
		to_chat(user, span_warning("I have no Veterans left to call."))
		return FALSE
	if(linked_warband.busy_summoning == TRUE)
		to_chat(user, span_warning("There's already been a call for our men to rally. I'll need to wait for a moment."))
		return FALSE
	// the flag is taken here and released in exactly one place, no matter how the attempt ends inside
	linked_warband.busy_summoning = TRUE
	. = do_summon_veteran(user, given_warband_ID)
	linked_warband.busy_summoning = FALSE

/obj/structure/fluff/warband/warband_recruit/proc/do_summon_veteran(mob/user, given_warband_ID)
	to_chat(user, span_green("The summons are sent."))
	var/turf/spawnpoint = get_turf(src)
	var/list/candidates = pollGhostCandidates("Do you want to play as one of the [user.advjob]'s Veteran Soldiers?", ROLE_WARLORD_GRUNT, null, null, 10 SECONDS, POLL_IGNORE_WARBAND_VETERAN)
	if(!LAZYLEN(candidates))
		to_chat(user, span_warning("The summons go unanswered."))
		return FALSE

	var/mob/candidate = pick(candidates)
	if(!candidate || !istype(candidate, /mob/dead))
		return FALSE

	if(istype(candidate, /mob/dead/new_player))
		var/mob/dead/new_player/N = candidate
		N.close_spawn_windows()

	to_chat(user, span_green("My summons are answered. I must simply spare them a moment to arm themselves."))
	var/mob/living/carbon/human/target = SSwarbands.get_lobby_mob()
	target.forceMove(spawnpoint)
	target.invisibility = INVISIBILITY_MAXIMUM
	target.set_blindness(3 HOURS)
	target.sync_mind()
	target.mind.warband_ID = given_warband_ID
	target.mind.warband_latespawn = TRUE
	target.mind.warband_manager = linked_warband
	target.mind.warbandsetup = TRUE
	target.key = candidate.key

	SSjob.AssignRole(target, "Grunt")
	target.mind.add_antag_datum(/datum/antagonist/warband/grunt)
	if(user && user.mind)
		user.mind.subordinates += target
		target.mind.warband_recruiter_name = user.real_name
		target.faction |= "[user.real_name]_faction" // included in their lieutenant's personal faction
	linked_warband.spawns--
	return TRUE


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// RECRUITMENT POINT INTERACTION
/*
	ALLIED WARLORDS & LIEUTENANTS: recruitment prompts, unless the rally point is disabled
	ENEMY WARLORDS: convert the rally point
	ANYONE ELSE: disable the rally point
*/
/obj/structure/fluff/warband/warband_recruit/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(!user.mind || !linked_warband)
		return
	if(disabled && user.mind.warband_ID == warband_ID)
		if(do_after(user, 90, target = src))
			disabled = FALSE
			alpha = 255
			to_chat(user, span_nicegreen("I've restored the rally point!"))
			return
	if(IS_WARBAND_MEMBER_ROLE(user.mind))
		if(user.mind.warband_ID == warband_ID)
			var/list/summon_options = list()
			if(IS_WARBAND_WARLORD(user.mind))
				summon_options += "Summon LIEUTENANT (Player)"
			if(IS_WARBAND_LIEUTENANT(user.mind))
				summon_options += "Summon VETERAN (Player)"
			if(IS_WARBAND_OFFICER(user.mind))
				summon_options += "Summon GOONS (NPCs)"
			if(user.mind.special_role == ROLE_WARLORD_ENVOY)
				summon_options += "Stow Envoy"
			if(IS_WARBAND_OFFICER(user.mind))
				summon_options += "Summon ENVOY"
			var/summon_choice = tgui_input_list(user, "Who should be summoned?", "Warband Recruitment", summon_options)

			switch(summon_choice)
				if("Summon LIEUTENANT (Player)")
					summon_lieutenant(user)
				if("Summon VETERAN (Player)")
					summon_veteran(user)
					return
				if("Summon ENVOY")
					if(linked_warband.spawns > 0)
						var/list/depth_options = list("Simple Envoy","Use a Character Slot")
						var/depth_choice = tgui_input_list(user, "How should they look?", "Warband Recruitment", depth_options)
						switch(depth_choice)
							if("Use a Character Slot")
								linked_warband.select_pref_slot(user)
								var/mob/living/envoy = linked_warband.summon_envoy(user, loc, src, null, depth_choice)
								linked_warband.load_appearance(user, envoy)
							if("Simple Envoy")
								var/list/races = list("Humen","Half-Elf","Dwarf","Elf","Aasimar")
								var/race_choice = tgui_input_list(user, "What species should they be?", "Warband Recruitment", races)
								if(race_choice)
									linked_warband.summon_envoy(user, loc, src, race_choice, depth_choice)
					else
						to_chat(user, span_userdanger("No reinforcements remain."))					
				if("Summon GOONS (NPCs)")
					if(!user.mind.warband_manager.outskirts_established)
						to_chat(user, span_warning("It's far too soon to prepare the soldiery. We should allow time for our envoys to scout a path, first."))
						return

					var/datum/component/trail_follow/squad = linked_warband.get_squad_component(user)

					if(!COOLDOWN_FINISHED(user.mind, squad_spawn_cooldown))
						var/time_left = COOLDOWN_TIMELEFT(user.mind, squad_spawn_cooldown)
						to_chat(user, span_warning("I've recently summoned a squad. I should wait another [round(time_left / 10, 1)] seconds."))
						return

					if(linked_warband.squad_has_goons(squad))
						var/list/choices = list("ABANDON OLD SQUAD","CANCEL")
						var/abandon_choice = tgui_input_list(user, "You've already deployed a squad. Abandon them?", "Warband Recruitment", choices)
						if(abandon_choice == "ABANDON OLD SQUAD")
							linked_warband.abandon_npc_squad(squad)
						return
					else if(linked_warband.spawns > 0)
						linked_warband.deploy_npc_squad(user, loc, squad, 1)
						to_chat(user, span_userdanger("There are [linked_warband.spawns] soldiers remaining."))
						COOLDOWN_START(user.mind, squad_spawn_cooldown, 2 MINUTES)
					else
						to_chat(user, span_userdanger("No reinforcements remain."))
				if("Stow Envoy")
					for(var/obj/item/treaty/carried_treaty in user.contents)
						to_chat(user, span_userdanger("I'm carrying a Treaty. I should set it down somewhere before I return."))
						return
					for(var/obj/item/storage/bag in user.contents)
						for(var/obj/item/treaty/bag_treaty in bag.contents)
							to_chat(user, span_userdanger("I'm carrying a Treaty. I should set it down somewhere before I return."))
							return
					linked_warband.return_envoy(user)						
					return
				else
					return
			return

		if(user.mind.warband_ID)
			if(do_after(user, 90, target = src))
				warband_ID = user.mind.warband_ID
				linked_warband = user.mind.warband_manager
				to_chat(user, span_userdanger("You have claimed this recruitment point for your Warband."))
				return
	else if(disabled)
		return
	// if we're not a part of the warband, we disable the rally point
	// when a rally point is disabled we also attempt to pull out any characters stored inside w/return_envoy
	user.visible_message(span_info("[user] [destruction_doafter]"))
	if(do_after(user, 90, target = src))
		if(contents.len)
			for(var/mob/living/stored_character in contents.Copy())
				linked_warband.return_envoy(null, stored_character, src)
				to_chat(user, span_nicegreen("[stored_character] is pulled out!"))
		disabled = TRUE
		alpha = 50
		to_chat(user, span_nicegreen("[destruction_msg]"))

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////// SPAWN BARRIER
/*
	a spawn barrier
	prevents warlords and lieutenants from leaving until they've sent an envoy
	can easily be bypassed if they absolutely need to go somewhere in their camp first

	it's essentially a guard rail for noobs, whom we don't want immediately running off & getting confused
*/

/obj/effect/solid_invisible_barrier/warband_spawnbarrier
	var/warband_ID = 0
	var/datum/warband_manager/linked_warband

/obj/effect/solid_invisible_barrier/warband_spawnbarrier/Initialize()
	. = ..()
	SSwarbands.warband_machines += src

/obj/effect/solid_invisible_barrier/warband_spawnbarrier/Destroy()
	SSwarbands.warband_machines -= src
	linked_warband = null
	return ..()

/obj/effect/solid_invisible_barrier/warband_spawnbarrier/CanPass(atom/movable/mover, turf/target)
	if(!linked_warband || linked_warband.outskirts_established)
		return TRUE // once the outskirts are established (or before the barrier is linked), anyone can pass through

	if(!isliving(mover))
		return TRUE

	var/mob/living/carbon/human/user = mover

	if(!istype(user))
		return TRUE

	if(user.fixedeye)
		return TRUE

	if(!user.mind || !user.mind.special_role)
		return TRUE

	if(user.mind.warband_ID != src.warband_ID)
		return TRUE // if they don't match warband IDs, we let them through (as they likely deserted)

	var/user_role = user.mind.special_role

	// envoys and grunts can pass freely
	if(user_role == ROLE_WARLORD_ENVOY || user_role == ROLE_WARLORD_GRUNT)
		return TRUE

	return FALSE

/obj/effect/solid_invisible_barrier/warband_spawnbarrier/Bumped(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/carbon/human/user = AM
		if(istype(user) && user.mind)
			if(IS_WARBAND_OFFICER(user.mind) && user.mind.warband_ID == warband_ID)
				if(!user.fixedeye)
					to_chat(user, span_notice("I shouldn't leave so soon. I should allow our veterans and envoys to scout a path, first. \n \
											<span style='color:#4f4733'>(Directly control an Envoy by interacting with a Rally Point)</span> \n \
											<span style='color:#4f4733'>(You may temporarily bypass this barrier by approaching it in Fixed Eye Mode)</span>"))

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
/////////////////////////////////// WARBAND TRAVEL TILES
/obj/structure/fluff/traveltile/warband
	name = "travel"
	var/warband_ID = 0
	var/datum/warband_manager/linked_warband

/obj/structure/fluff/traveltile/warband/Destroy()
	linked_warband = null
	SSwarbands.warband_machines -= src
	return ..()

/obj/structure/fluff/traveltile/warband/azure_to_intermission


/obj/structure/fluff/traveltile/warband/intermission_to_azure
	color = "#a32121"

/obj/structure/fluff/traveltile/warband/azure_to_intermission/perform_travel(obj/structure/fluff/traveltile/T, mob/living/carbon/human/L)
	..()
	if(!linked_warband)
		return
	var/is_friendly = (L.mind && (L.mind.warband_ID == warband_ID)) || (L in linked_warband.allies)

	if(is_friendly)
		return // members and allies don't get tracked

	if(!(L in linked_warband.incoming_mobs))
		linked_warband.incoming_mobs += L
		to_chat(L, span_warning("I feel eyes upon me. I've entered hostile territory."))
		for(var/mob/officer in src.linked_warband.members)
			if(!officer || !officer.mind)
				continue
			if(IS_WARBAND_OFFICER(officer.mind))
				to_chat(officer, span_warning("Our scouts report lurkers in our camp's outskirts. They've spotted [linked_warband.incoming_mobs.len] potential foe(s)."))
		if(linked_warband.combatmusic && linked_warband.combatmusic.len)
			if(L.cmode_music_override != linked_warband.combatmusic)
				if(!L.cmode_music_override || L.cmode_music_override.len <= 0)
					L.originalcmode = L.cmode_music
				else
					L.originalcmode = L.cmode_music_override
				L.cmode_music_override = linked_warband.combatmusic


/obj/structure/fluff/traveltile/warband/intermission_to_azure/perform_travel(obj/structure/fluff/traveltile/T, mob/living/carbon/human/L)
	..()
	if(linked_warband)
		linked_warband.incoming_mobs -= L
		linked_warband.besieging_mobs -= L
	if(L.originalcmode)
		L.restore_original_cmode_music()

/obj/structure/fluff/traveltile/warband/Initialize()
	..()
	SSwarbands.warband_machines += src
	src.color = null	// different colors in the editor for visual clarity, but they should appear normal in game

/obj/structure/fluff/traveltile/warband/intermission_to_outskirts
	color = "#ff8b2c"

/obj/structure/fluff/traveltile/warband/intermission_to_outskirts/perform_travel(obj/structure/fluff/traveltile/T, mob/living/carbon/human/L)
	..()
	if(!linked_warband)
		return
	var/is_friendly = (L.mind && (L.mind.warband_ID == warband_ID)) || (L in linked_warband.allies)
	if(is_friendly)
		return

	linked_warband.besieging_mobs |= L

/obj/structure/fluff/traveltile/warband/intermission_to_outskirts/try_living_travel(obj/structure/fluff/traveltile/T, mob/living/L)
	if(!L.mind)
		return FALSE

	var/is_friendly = (L.mind && (L.mind.warband_ID == warband_ID)) || (linked_warband && (L in linked_warband.allies))
	if(is_friendly)
		return ..()

	var/datum/outskirts_encounter/encounter = linked_warband?.encounter_manager
	if(!encounter) // an unfinished warband has no defensive line to speak of
		return ..()

	if(encounter.attacker_rout_active)
		to_chat(L, span_warning("It's too soon for another assault."))
		return FALSE

	// there's a 90 second window for attackers to enter an outskirts encounter
	if(encounter.encounter_active && encounter.encounter_start_time > 0)
		var/time_elapsed = world.time - encounter.encounter_start_time
		if(time_elapsed >= 90 SECONDS)
			to_chat(L, span_warning("It's too late to enter the fray."))
			return FALSE

	if(!encounter.outskirts_locked)
		return ..()

	if(encounter.prep_started)
		var/time_left = max(0, (linked_warband.outskirts_prep_timer - world.time) / 10)
		to_chat(L, span_warning("The march has already begun. We are [round(time_left)] seconds away."))
		return FALSE

	if(encounter.encounter_disabled)
		to_chat(L, span_warning("It's too soon for another assault."))
		return FALSE

	if(encounter.encounter_active)
		to_chat(L, span_warning("Battle rages ahead!"))
		return ..()

	if(HAS_TRAIT(L, TRAIT_ZOMBIE_SPEECH))
		return FALSE

	var/march_minutes = round(encounter.prep_time / (1 MINUTES))
	var/confirm = tgui_alert(L, "Begin the march to the enemy warcamp? We would arrive in around [march_minutes] minute(s).", "Initiate Battle", list("Yes", "No"))
	if(confirm != "Yes")
		return FALSE
	if(encounter.prep_started)
		var/time_left = max(0, (linked_warband.outskirts_prep_timer - world.time) / 10)
		to_chat(L, span_warning("The march has already begun. We are [round(time_left)] seconds away."))
		return FALSE // in case someone hit yes while someone else was mid-prompt
	if(!encounter.outskirts_locked)
		to_chat(L, span_warning("Surprisingly enough, the path seems clear."))
		return FALSE // in case the defenses are lowered mid-prompt
	visible_message(span_boldwarning("[L] begins the long march to the enemy's line. We will arrive in [march_minutes] minute(s)."))
	linked_warband.outskirts_prep_timer = world.time + encounter.prep_time
	encounter.begin_march()
	return FALSE

/obj/structure/fluff/traveltile/warband/intermission_to_outskirts/attack_hand(mob/user)
	if(!istype(user, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/H = user
	var/datum/outskirts_encounter/encounter = linked_warband?.encounter_manager

	// check if there's an active prep phase that can be cancelled
	if(encounter?.prep_started && !encounter.encounter_active)
		var/choice = tgui_alert(H, "Call off the march to the outskirts?", "Cancel March", list("Yes", "No"))
		if(choice == "Yes")
			if(encounter.cancel_march())
				visible_message(span_notice("[H] calls off the march to the outskirts."))
				return
		else
			return

	. = ..()


/obj/structure/fluff/traveltile/warband/outskirts_to_intermission
	color = "#28d2d8"

/obj/structure/fluff/traveltile/warband/outskirts_to_intermission/perform_travel(obj/structure/fluff/traveltile/T, mob/living/carbon/human/L)
	..()
	if(linked_warband)
		linked_warband.besieging_mobs -= L

/obj/structure/fluff/traveltile/warband/outskirts_to_intermission/try_living_travel(obj/structure/fluff/traveltile/T, mob/living/L)
	var/is_friendly = (L.mind && (L.mind.warband_ID == warband_ID)) || (linked_warband && (L in linked_warband.allies))
	if(is_friendly)
		return ..()

	if(HAS_TRAIT(L, TRAIT_ZOMBIE_SPEECH))
		return ..() // always let zombies leave

	var/datum/outskirts_encounter/encounter = linked_warband?.encounter_manager
	if(!encounter)
		return ..()

	if(encounter.attacker_rout_active && (L in linked_warband.besieging_mobs) && encounter.rout_start_time > 0)
		var/time_since_rout = world.time - encounter.rout_start_time
		if(time_since_rout >= 80 SECONDS)
			if(!L || !L.mind)
				return FALSE
			to_chat(L, span_userdanger("They've cut off my escape route! I must bide my time for an opportunity!"))
			if(do_after(L, 20 SECONDS, needhand = FALSE, target = src))
				to_chat(L, span_warning("I've found a gap in the encirclement!"))
				perform_travel(T, L)
				return TRUE
			else
				to_chat(L, span_warning("I halt my escape attempt."))
				return FALSE

	return ..()

/obj/structure/fluff/traveltile/warband/outskirts_to_camp
	color = "#6135ff"


/obj/structure/fluff/traveltile/warband/outskirts_to_camp/try_living_travel(obj/structure/fluff/traveltile/T, mob/living/L)
	var/is_friendly = (L.mind && (L.mind.warband_ID == warband_ID)) || (linked_warband && (L in linked_warband.allies))
	if(is_friendly)
		return ..()

	var/datum/outskirts_encounter/encounter = linked_warband?.encounter_manager
	if(!encounter) // an unfinished warband has no camp defenses to speak of
		return ..()

	if(encounter.outskirts_locked || encounter.encounter_active)
		if(!L || !L.mind)
			return FALSE
		to_chat(L, span_warning("The camp's defenses hold strong. I can't slip by."))
		return FALSE

	if(!encounter.encounter_active || encounter.encounter_disabled)
		linked_warband.besieging_mobs -= L
		return ..()
	
/obj/structure/fluff/traveltile/warband/camp_to_outskirts
	color = "#ff35f5"
	var/obj/effect/landmark/chosen_landmark

/obj/structure/fluff/traveltile/warband/camp_to_outskirts/Destroy()
	chosen_landmark = null
	return ..()


// a mirror of the envoy spawning logic for rally points, in case someone decides to leave the spawn room early
/obj/structure/fluff/traveltile/warband/camp_to_outskirts/attack_hand(mob/user)
	if(!linked_warband)
		return ..()
	if(linked_warband.outskirts_established)
		if(user.mind && user.mind.warband_ID != warband_ID)
			linked_warband.besieging_mobs |= user
		return ..()

	if(!user.mind)
		return

	if(user.mind.special_role == ROLE_WARLORD_ENVOY)
		var/readycheck = tgui_alert(user, "The road ahead could be dangerous. I won't be able to return immediately.", "VENTURE FORTH?", list("I AM READY", "WAIT"))
		if(readycheck == "I AM READY")
			if(chosen_landmark)
				to_chat(user, span_warning("The Rot prevented a simple walk down Azuria's main road. This is the safest route from my Warcamp."))
				to_chat(user, span_warning("Before I return, I'll need to SCOUT A PATH (Warband Verb Tab)."))
				user.forceMove(chosen_landmark.loc)
				user.visible_message(span_bold("[user] emerges from a hidden path!"))
				return
		return

	// if they don't match the warband ID, we assume they rebelled VERY early into the round (for whatever reason) and just let them leave
	if(user.mind.warband_ID != warband_ID || user.mind.special_role == ROLE_WARLORD_GRUNT) // we'll let grunts leave too	
		if(chosen_landmark)
			user.forceMove(chosen_landmark.loc)
			return

	if(IS_WARBAND_OFFICER(user.mind))
		if(user.mind.warband_ID == warband_ID)
			var/create_envoy = tgui_alert(user, "I can't leave yet. I need to send out an Envoy.", "BECOME ENVOY", list("BECOME ENVOY", "No"))

			if(create_envoy == "BECOME ENVOY")
				if(linked_warband.spawns <= 0)
					to_chat(user, span_warning("No reinforcements remain to serve as an Envoy. We haven't even left the camp. How the fuck did this happen?"))
					return
	
				var/list/depth_options = list("Simple Envoy", "Use a Character Slot")
				var/depth_choice = tgui_input_list(user, "How should the Envoy look?", "Envoy Creation", depth_options)
				switch(depth_choice)
					if("Use a Character Slot")
						linked_warband.select_pref_slot(user)
						var/mob/living/envoy = linked_warband.summon_envoy(user, get_turf(user), linked_warband.get_random_recruit_point(), null, depth_choice)
						linked_warband.load_appearance(user, envoy)
					if("Simple Envoy")
						var/list/races = list("Humen","Half-Elf","Dwarf","Elf","Aasimar")
						var/race_choice = tgui_input_list(user, "What species should they be?", "Envoy Creation", races)
						if(race_choice)
							linked_warband.summon_envoy(user, get_turf(user), linked_warband.get_random_recruit_point(), race_choice, depth_choice)
				return
	to_chat(user, span_warning("I can't leave yet. I need to send out an ENVOY first."))
	return

/obj/structure/fluff/traveltile/warband/proc/summon_grunt_squad_at_tile(mob/living/carbon/human/user)
	var/datum/warband_manager/user_warband = user.mind.warband_manager
	var/datum/component/trail_follow/squad = user_warband.get_squad_component(user)

	if(!COOLDOWN_FINISHED(user.mind, squad_spawn_cooldown))
		var/time_left = COOLDOWN_TIMELEFT(user.mind, squad_spawn_cooldown)
		to_chat(user, span_warning("I've recently summoned a squad. I should wait another [round(time_left / 10, 1)] seconds."))
		return FALSE

	if(user_warband.spawns <= 0)
		to_chat(user, span_userdanger("No reinforcements remain."))
		return FALSE

	if(user_warband.squad_has_goons(squad))
		user_warband.abandon_npc_squad(squad)
		to_chat(user, span_warning("My previous squad has been abandoned."))

	user_warband.deploy_npc_squad(user, loc, squad, 2) // base 2 for summoning so far from camp, potentially doubled again by /datum/warbands/aspects/badexit
	to_chat(user, span_warning("There are [user_warband.spawns] soldiers remaining. Summoning my men so far from the Camp has incurred additional attrition."))
	COOLDOWN_START(user.mind, squad_spawn_cooldown, 4 MINUTES) // cooldown for summoning via travel tile is a little longer
	return TRUE

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
