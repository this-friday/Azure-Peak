/obj/structure/fluff/warband
	var/warband_ID = 0
	var/atom/movable/screen/warband/manager/linked_warband
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
	if(user.mind.special_role == "Warlord" || user.mind.special_role == "Lieutenant" || user.mind.special_role == "Aspirant Lieutenant" || user.mind.special_role == "Grunt" || user.mind.special_role == "Warlord's Envoy")
		if(user.mind.warband_ID == warband_ID)
			var/list/campaign_options = list()		
			campaign_options += "HELP"		
			campaign_options += "View Troops"
			campaign_options += "View Allies"
			campaign_options += "View Morale"		
			if(user.mind.special_role == "Warlord" || user.mind.special_role == "Lieutenant" || user.mind.special_role == "Aspirant Lieutenant" || user.mind.special_role == "Warlord's Envoy")
				campaign_options += "Prepare Treaty"
			if(user.mind.special_role == "Warlord")
				campaign_options += "Exile Member"
				if(linked_warband.encounter_manager.outskirts_locked)
					campaign_options += "Stand Down Outskirts Defenses"
				else if(!linked_warband.encounter_manager.encounter_disabled)
					campaign_options += "Raise Outskirts Defenses"

			var/campaign_choice = input(user, "What shall I do?", "Warband Recruitment") as null|anything in campaign_options

			switch(campaign_choice)
				if("HELP")
					return
				if("Prepare Treaty")
					if(!COOLDOWN_FINISHED(user.mind, treaty_cooldown))
						var/time_left = COOLDOWN_TIMELEFT(user.mind, treaty_cooldown)
						to_chat(user, span_warning("I've recently prepared a treaty. I should wait another [round(time_left / 10, 1)] seconds."))
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
					var/mob/living/exile_choice = input(user, "Who must go?", "EXILE") as null|anything in viable_member_list
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
					if(!linked_warband.outskirts_established)
						to_chat(user, span_warning("We haven't established our outskirts yet."))
						return
					if(linked_warband.encounter_manager.encounter_active)
						to_chat(user, span_warning("There's still a battle happening in the outskirts. I cannot lower our defenses."))
						return
					if(linked_warband.encounter_manager.attacker_rout_active)
						to_chat(user, span_warning("Our foe is currently being routed from the field. I can't stand down our defenses just yet."))
						return
				
					var/confirm = alert(user, "Stand down the outskirts defenses? This will allow anyone to enter the warcamp.", "Stand Down Outskirts", "Yes", "No")
					if(confirm != "Yes")
						return
					linked_warband.encounter_manager.cancel_march()
					linked_warband.encounter_manager.outskirts_locked = FALSE
					to_chat(user, span_notice("The troops on our outskirts have stood down. Anyone may enter the warcamp."))
					return
				if("Raise Outskirts Defenses")
					if(linked_warband.encounter_manager.encounter_disabled)
						to_chat(user, span_warning("Our defensive line is shattered. We cannot reform our ranks."))
						return
					
					var/confirm = alert(user, "Raise the outskirts defenses? This will lock the warcamp from intruders.", "Raise Outskirts Defenses", "Yes", "No")
					if(confirm != "Yes")
						return
					if(!linked_warband.encounter_manager.encounter_disabled)
						linked_warband.encounter_manager.outskirts_locked = TRUE
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
	if(linked_warband.spawned_lieutenants >= LIEUTENANTS_PER_WARLORD)
		to_chat(user, span_warning("There are no more capable Lieutenants left."))
		return FALSE 
	to_chat(user, span_green("The summons are sent."))
	linked_warband.busy_summoning = TRUE
	sleep(60)	//FIXNOTE: don't leave this in
	var/turf/spawnpoint = get_turf(src)
	var/list/candidates = pollGhostCandidates("Do you want to play as one of the [user.advjob]'s Lieutenants?", ROLE_WARLORD_LIEUTENANT, null, null, 10 SECONDS, POLL_IGNORE_WARBAND_LIEUTENANT)
	if(!LAZYLEN(candidates))
		to_chat(user, span_warning("The summons go unanswered."))
		linked_warband.busy_summoning = FALSE
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
	SSjob.AssignRole(target, "Warlord's Lieutenant")
	target.mind.add_antag_datum(/datum/antagonist/warband/lieutenant)
	linked_warband.spawns--
	linked_warband.busy_summoning = FALSE
	return TRUE


//////////////////////////////////////////////////////////////
///////////////////////////////////////////////// SUMMON ENVOY
/*
	alternates depending on if we're spawning a simple envoy or using a character slot

	simple envoys choose a race from a tiny selection, then get an option to choose a name after they're equipped later on
	custom envoys just spawn as a human, which is then modified via the user's active preferences

	then it assigns the following to the envoy:
		warband & personal faction
		warband ID
		warband manager
		envoy job & special role

	the envoy and the person who summoned it are rotated out
		summoner's ckey is put into the spawned envoy
		summoner's body is stored in the recruitment point
*/

/obj/structure/fluff/warband/warband_recruit/proc/summon_envoy(mob/living/carbon/human/user, race_choice, depth_choice)
	var/mob/living/carbon/human/envoy
	switch(depth_choice)
		if("Simple Envoy")
			switch(race_choice)
				if("Humen")
					envoy = new /mob/living/carbon/human/species/human/northern(loc)	
				if("Half-Elf")
					envoy = new /mob/living/carbon/human/species/human/halfelf(loc)
				if("Dwarf")
					envoy = new /mob/living/carbon/human/species/dwarf/mountain(loc)
				if("Elf")
					envoy = new /mob/living/carbon/human/species/elf/wood(loc)
				if("Aasimar")
					envoy = new /mob/living/carbon/human/species/aasimar(loc)
			envoy.real_name = pick(world.file2list("strings/rt/names/human/humsoulast.txt"))
			simpleappearance(envoy)
		if("Use a Character Slot")
			envoy = new /mob/living/carbon/human/species/human/northern(loc)
	envoy.sync_mind()
	envoy.faction |= list("warband_[warband_ID]", "[user.real_name]_faction")			
	envoy.key = user.key
	envoy.mind.warband_ID = warband_ID
	envoy.mind.warband_manager = linked_warband
	envoy.mind.original_char = user
	envoy.mind.warband_manager.spawns--
	transfer_treaties(user, envoy)
	equip_envoy(envoy)
	SSjob.AssignRole(envoy, "Warlord's Envoy")
	envoy.mind.special_role = "Warlord's Envoy"
	contents += user
	return envoy

/obj/structure/fluff/warband/warband_recruit/proc/transfer_treaties(mob/living/carbon/human/from_mob, mob/living/carbon/human/to_mob)
	for(var/obj/item/treaty/carried_treaty in from_mob.contents)
		if(from_mob.transferItemToLoc(carried_treaty, to_mob.loc))
			to_mob.put_in_hands(carried_treaty)
	
	for(var/obj/item/storage/bag in from_mob.contents)
		for(var/obj/item/treaty/bag_treaty in bag.contents)
			bag_treaty.remove_item_from_storage(from_mob)
			bag_treaty.forceMove(to_mob.loc)
			to_mob.put_in_hands(bag_treaty)


////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////

/obj/structure/fluff/warband/warband_recruit/proc/simpleappearance(mob/living/carbon/human/envoy)
	var/obj/item/bodypart/head/head = envoy.get_bodypart(BODY_ZONE_HEAD)
	var/hair_choice = /datum/sprite_accessory/hair/head/troubadour

	var/datum/bodypart_feature/hair/head/new_hair = new()

	new_hair.set_accessory_type(hair_choice, null, envoy)

	if(prob(50))
		new_hair.accessory_colors = "#96403d"
		new_hair.hair_color = "#96403d"
	else
		new_hair.accessory_colors = "#160d02"
		new_hair.hair_color = "#160d02"

	head.add_bodypart_feature(new_hair)

	envoy.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
	envoy.dna.species.handle_body(envoy)


	var/obj/item/organ/eyes/organ_eyes = envoy.getorgan(/obj/item/organ/eyes)
	if(organ_eyes)
		var/picked_eye_color = pick("#365334", "#395c70", "#30261e")
		organ_eyes.eye_color = picked_eye_color
		organ_eyes.accessory_colors = picked_eye_color + picked_eye_color

/////////////////////////////////////////////////////////////
///////////////////////////////////////////////// EQUIP ENVOY
/*
	equips an envoy
*/
/obj/structure/fluff/warband/warband_recruit/proc/equip_envoy(mob/envoy, used_slot)
	var/datum/advclass/warband/envoy/envoy_class = new /datum/advclass/warband/envoy
	if(linked_warband)
		envoy.cmode_music = linked_warband.combatmusic
	envoy.job = envoy_class.name
	envoy_class.equipme(envoy, null, used_slot)


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
	var/grunts_per_lt = GRUNTS_PER_LIEUTENANT + max(0, (get_active_player_count() - 40) / 15) // minimum of 2, with +1 for every 15 active players beyond 40
	if(length(user.mind.subordinates) >= grunts_per_lt)
		to_chat(user, span_warning("I have no Veterans left to call."))
		return FALSE
	if(linked_warband.busy_summoning == TRUE)
		to_chat(user, span_warning("There's already been a call for our men to rally. I'll need to wait for a moment."))
		return FALSE
	linked_warband.busy_summoning = TRUE
	to_chat(user, span_green("The summons are sent."))	
	sleep(60)	//FIXNOTE: don't leave this in
	var/turf/spawnpoint = get_turf(src)
	var/list/candidates = pollGhostCandidates("Do you want to play as one of the [user.advjob]'s Veteran Soldiers?", ROLE_WARLORD_GRUNT, null, null, 10 SECONDS, POLL_IGNORE_WARBAND_VETERAN)
	if(!LAZYLEN(candidates))
		to_chat(user, span_warning("The summons go unanswered."))
		linked_warband.busy_summoning = FALSE
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
	linked_warband.busy_summoning = FALSE
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
	if(disabled && user.mind.warband_ID == warband_ID)
		if(do_after(user, 90, target = src))
			disabled = FALSE
			alpha = 255
			to_chat(user, span_nicegreen("I've restored the rally point!"))
			return
	if(user.mind.special_role == "Warlord" || user.mind.special_role == "Lieutenant" || user.mind.special_role == "Aspirant Lieutenant" || user.mind.special_role == "Grunt" || user.mind.special_role == "Warlord's Envoy")
		if(user.mind.warband_ID == warband_ID)
			var/list/summon_options = list()
			if(user.mind.special_role == "Warlord")
				summon_options += "Summon LIEUTENANT"
			if(user.mind.special_role == "Lieutenant" || user.mind.special_role == "Aspirant Lieutenant")
				summon_options += "Summon VETERAN SOLDIER"
			if(user.mind.special_role == "Warlord" || user.mind.special_role == "Lieutenant" || user.mind.special_role == "Aspirant Lieutenant")
				summon_options += "Summon GOONS (NPCs)"
			if(user.mind.special_role == "Warlord's Envoy")
				summon_options += "Stow Envoy"
			if(user.mind.special_role == "Warlord" || user.mind.special_role == "Lieutenant" || user.mind.special_role == "Aspirant Lieutenant")
				summon_options += "Summon ENVOY"
			var/summon_choice = input(user, "Who should be summoned?", "Warband Recruitment") as null|anything in summon_options

			switch(summon_choice)
				if("Summon LIEUTENANT")
					summon_lieutenant(user)
				if("Summon VETERAN SOLDIER")
					summon_veteran(user)
					return
				if("Summon ENVOY")
					if(linked_warband.spawns > 0)
						var/list/depth_options = list("Simple Envoy","Use a Character Slot")
						var/depth_choice = input(user, "How should they look?", "Warband Recruitment") as anything in depth_options
						switch(depth_choice)
							if("Use a Character Slot")
								linked_warband.select_pref_slot(user)
								var/mob/living/envoy = summon_envoy(user, null, depth_choice)
								linked_warband.load_appearance(user, envoy)
								linked_warband.spawns--
							if("Simple Envoy")
								var/list/races = list("Humen","Half-Elf","Dwarf","Elf","Aasimar")
								var/race_choice = input(user, "What species should they be?", "Warband Recruitment") as anything in races
								summon_envoy(user, race_choice, depth_choice)
								linked_warband.spawns--
					else
						to_chat(user, span_userdanger("No reinforcements remain."))					
				if("Summon GOONS (NPCs)")
					if(!user.mind.warband_manager.outskirts_established)
						to_chat(user, span_warning("It's far too soon to prepare the soldiery. We should allow time for our envoys to scout a path, first."))
						return
					
					var/squad_deployed
					var/datum/component/squad_controller/manager = user.GetComponent(/datum/component/squad_controller)
					if(!manager)
						manager = user.AddComponent(/datum/component/squad_controller)
					for(var/mob/friend in manager.members)
						if(istype(friend, /mob/living/carbon/human/species/human/northern/goon))
							squad_deployed = TRUE
							break
					
					if(!COOLDOWN_FINISHED(user.mind, squad_spawn_cooldown))
						var/time_left = COOLDOWN_TIMELEFT(user.mind, squad_spawn_cooldown)
						to_chat(user, span_warning("I've recently summoned a squad. I should wait another [round(time_left / 10, 1)] seconds."))
						return
					
					if(squad_deployed)
						var/list/choices = list("ABANDON OLD SQUAD","CANCEL")
						var/abandon_choice = input(user, "You've already deployed a squad. Abandon them?", "Warband Recruitment") as anything in choices
						switch(abandon_choice)
							if("ABANDON OLD SQUAD")
								for(var/mob/living/carbon/human/species/human/northern/goon/abandoned_grunt in manager.members)
									if(!abandoned_grunt)
										manager.members -= abandoned_grunt
										continue
									abandoned_grunt.abandonevent()
									manager.members -= abandoned_grunt
							if("CANCEL")
								return
						return
					else if(linked_warband.spawns > 0)
						for(var/grunts_spawned = 1, grunts_spawned <= user.mind.squad_size && linked_warband.spawns > 0, grunts_spawned++)
							var/mob/living/carbon/human/species/human/northern/goon/new_grunt = linked_warband.get_cached_grunt(loc, user)
							new_grunt.patron = user.patron
							new_grunt.faction |= list("warband_[warband_ID]", "[user.real_name]_faction")
							new_grunt.warband_ID = user.mind.warband_ID
							manager.members |= new_grunt
							linked_warband.spawns--
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
			for(var/mob/living/stored_character in contents)
				linked_warband.return_envoy(null, TRUE, stored_character, src)
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
	var/atom/movable/screen/warband/manager/linked_warband

/obj/effect/solid_invisible_barrier/warband_spawnbarrier/Initialize()
	. = ..()
	SSwarbands.warband_machines += src

/obj/effect/solid_invisible_barrier/warband_spawnbarrier/CanPass(atom/movable/mover, turf/target)
	if(linked_warband.outskirts_established)
		return TRUE // once the outskirts are established, anyone can pass through

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
	if(user_role == "Warlord's Envoy" || user_role == "Grunt")
		return TRUE

	return FALSE

/obj/effect/solid_invisible_barrier/warband_spawnbarrier/Bumped(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/carbon/human/user = AM
		if(istype(user) && user.mind)
			var/user_role = user.mind.special_role
			if((user_role == "Warlord" || user_role == "Lieutenant" || user_role == "Aspirant Lieutenant") && user.mind.warband_ID == warband_ID)
				if(!user.fixedeye)
					to_chat(user, span_notice("I shouldn't leave so soon. I should allow our veterans and envoys to scout a path, first. \n \
											<span style='color:#4f4733'>(Directly control an Envoy by interacting with a Rally Point)</span> \n \
											<span style='color:#4f4733'>(You may temporarily bypass this barrier by approaching it in Fixed Eye Mode)</span>"))
