//////////// LOBBY & WARBAND SELECTION
/atom/movable/screen/warband/manager
	name = "BEGIN"
	icon = 'icons/roguetown/hud/warband/warband_hud.dmi'
	icon_state = "begin"
	alpha = 0
	screen_loc = "7.3,8"
	var/list/storyinfluence = list()		// storyteller influences | decides what options are available

	var/datum/warbands/selected_warband
	var/datum/warbands/subtypes/selected_subtype
	var/list/datum/warbands/aspects/selected_aspects = list()

	var/list/members = list()				// players in the warband
	var/list/lobby_members = list()			// players viewing the warband's lobby
	var/list/ready_members = list()			// list of lobby_members who are readied up | includes their class
	var/list/allies = list()				// players marked as allies
	var/list/importantfigures = list()		// important figures in town | used in the 'know thy enemy' list in the creation menu | helps in plotting an initial gimmick

	var/busy_summoning = FALSE				// active while the warband is polling for ghosts
	var/list/last_action_time = list()		// for rate limits	
	var/spawned_lieutenants = 0				// how many lieutenants have joined the lobby
	var/warband_ID = 0						// identifying number for the warband |
	var/disorder = 1						// determines how many spawns an aspirant steals during a schism (cumulative) & disables communication options (at 5+) | increased by other antagonists being marked as allies
	var/aspirant_chance = ASPIRANT_CHANCE	// chance that a lieutenant spawns as an aspirant
	var/list/combatmusic = list()			// combat track given to members + people who enter the warcamp/outskirts
	var/finalized = FALSE					// whether or not a warband is finalized
	var/creation_stage = 1  				// 1 = warband selection, 2 = casus belli selection, 3 = class selection
	var/warlord_spawned = FALSE	
	var/outskirts_established = FALSE		// whether or not the warband has spawned an outskirts map
	var/warcamp_established = FALSE
	var/turf/warband_spawn_turf				// main spawn turf for the warband's characters

	var/spawns = WARBAND_BASE_RESPAWNS		// 400 minimum | lost when an NPC is spawned | combined with spawn contributions from the warband/subtypes/aspects
											// might seem very generous, but this can be reduced in massive chunks by aspirants going rogue & outskirts fights

	var/schism_level = 0					// warbands can split/schism | this number = how many schisms away the warband is from its progenitor warband | doesn't actually influence anything atm, but for posterity's sake

	var/datum/treaty_flavor/linked_faction		// the treaty faction connected to the warband

	var/list/racelocks = list()
	var/list/faithlocks = list()
	var/static_data_set = FALSE
	var/bypass_rarity = FALSE						// if TRUE, the rarity filter is skipped entirely for the warband's creation UI | set by the GM debug panel

	// outskirts variables
	var/list/incoming_mobs = list()					// this tracks who is attempting to attack the warcamp 	(aka currently in the warband's Intermission map)
	var/list/besieging_mobs = list()				// as above, but those actively in combat				(aka currently in the warband's Outskirts map)
	var/datum/outskirts_encounter/encounter_manager
	var/outskirts_prep_timer

	// time limit for the warband creation phase
	var/creation_time_limit = 15 MINUTES			// total time allowed for creation
	var/creation_warning_threshold = 7.5 MINUTES	// send a warning at this time
	var/warned = FALSE								// if said warning has been sent
	var/creation_start_time = 0
	var/creation_timer_active = FALSE

	var/list/assigned_grunt_cache = list()					// a cache holding pre-equipped goon NPCs
	var/atom/movable/screen/warband/manager/cache_source	// if two opposing warbands have identical grunts, they share an NPC cache | this points to the manager we're sharing with
	var/list/cache_dependents = list()						// list of other managers sharing our cache

	// casus belli voting
	var/list/casus_belli_proposals = list()
	var/datum/treaty/terms/casus_belli_selection

	var/squad_size_bonus = 0			// flat bonus added to base squad size before any multipliers | set by aspects (e.g. CONSCRIPTS)
	var/marked_assassin_count = 0		// tracks how many grunts have been marked as assassins | (/datum/warbands/aspects/marked)
	var/list/aspect_intensities = list()	// assoc list: aspect type path (as string) -> selected intensity rank
	var/list/selection_inputs = list()		// assoc list: type path string -> assoc list of field key -> value, for warbands/subtypes/aspects with inputs

////////////////////////////////////////////////////////////
///////////////////////////////////////////////// BASE PROCS
/*
	// INITIALIZING
	0 - GET MANAGER				// gets the warband manager of a provided mob
	1 - FIGURE REFRESH			// populates the importantfigures list from current player_list
	2 - STORYTELLER REFRESH		// populates the manager's storyinfluence list

	// LORE LOCKS
	1 - LOCK CHECK 				// compares a mob against the warband's faith & racelocks
	2 - SET LOCKS				// collects all race & faith locks from the selected warband/subtype/aspects

	// OUTSKIRTS
	1 - INITIALIZE OUTSKIRTS ENCOUNTER		// sets up the outskirts encounter manager
	2 - FINALIZE OUTSKIRTS ENCOUNTER		// populates entry points & spawns the encounter objective
	3 - CHOOSE OUTSKIRTS WAVE				// picks an appropriate wave type from aspects/subtype/warband

	// MISC
	1 - EXILE			// kicks a character from the warband
	2 - CLEANUP			// combs through the member & ally list for null entries
	3 - RETURN ENVOY	// sends an envoy's client back to their stored character
	4 - CANCEL LOBBY	// if the lobby is absolutely bricked, Cancel Lobby gets called and sends all the warband members into observer
	5 - END INTRO		// clears the intro text from a mob's screen

*/

/atom/movable/screen/warband/manager/Initialize()
	..()
	if(!finalized)
		storyteller_refresh()
		figure_refresh()

///////////////////////////////////////////////
/////////////////////////////////// GET MANAGER
/proc/get_lobby_manager_for(mob/talker)
	if(!talker?.mind)
		return
	if(talker.mind.warband_manager)
		return talker.mind.warband_manager
	for(var/atom/movable/screen/warband/manager/candidate in SSwarbands.warband_managers)
		if(candidate.warband_ID == talker.mind.warband_ID)
			return candidate
		if(talker in candidate.lobby_members)
			return candidate
	return

/atom/movable/screen/warband/manager/proc/figure_refresh()
	var/list/important_jobs = list(
		/datum/job/roguetown/lord,
		/datum/job/roguetown/priest,
		/datum/job/roguetown/exlady,
		/datum/job/roguetown/lady,
		/datum/job/roguetown/hand,
		/datum/job/roguetown/prince,
		/datum/job/roguetown/marshal,
		/datum/job/roguetown/steward,
		/datum/job/roguetown/suitor,
		/datum/job/roguetown/martyr,
		/datum/job/roguetown/guildmaster,
		/datum/job/roguetown/magician,
		/datum/job/roguetown/councillor
	)
	for(var/mob/living/carbon/human/important_figure in GLOB.player_list)
		if(important_jobs.Find(important_figure.job_path))
			importantfigures |= important_figure

///////////////////////////////////////////////////////
/////////////////////////////////// STORYTELLER REFRESH
/*
	builds the storyinfluences for warband creation
	takes into account:
		the roundstart storyteller
		the currently active storyteller (only really matters for latespawns)
		each prince has a 50% chance to contribute their patron to the storyteller list
	
	ran when a manager's timer first starts during start_creation_timer()
*/
/atom/movable/screen/warband/manager/proc/storyteller_refresh()
	storyinfluence.Cut()
	var/active_storyteller = SSgamemode.current_storyteller
	var/roundstart_storyteller_string = SSgamemode.selected_storyteller
	if(active_storyteller)
		storyinfluence += active_storyteller

	if(roundstart_storyteller_string)
		storyinfluence += new roundstart_storyteller_string()

	for(var/mob/living/carbon/human/deadbeat in importantfigures)
		if(deadbeat.job_path == /datum/job/roguetown/prince && deadbeat.patron)
			if(prob(50))
				var/datum/patron/prince_patron_datum = deadbeat.patron
				storyinfluence += new prince_patron_datum.storyteller()

//////////////////////////////////////////////
/////////////////////////////////// LOCK CHECK
/*
	checks for any patron & or faith locks
	if the given mob doesn't match them, fixes the discrepancy
*/
/atom/movable/screen/warband/manager/proc/lock_check(mob/living/carbon/human/user, spawning_class_path)
	var/class_path = warband_class_for(spawning_class_path)
	if(class_path && initial(class_path:ignore_locks))
		if(user.patron)
			user.set_patron(user.patron.type)
		return
	if(racelocks && racelocks.len)
		var/user_species_type = user.dna?.species?.type
		var/species_allowed = FALSE
		
		for(var/allowed_species in racelocks)
			if(ispath(user_species_type, allowed_species))
				species_allowed = TRUE
				break
		
		if(!species_allowed)
			var/new_species = pick(racelocks)
			user.set_species(new_species)
			to_chat(user, span_warning("Your character's species has been adjusted to match the warband's requirements."))

	if(faithlocks && faithlocks.len)
		var/patron_allowed = FALSE
		if(user.patron)
			for(var/allowed_patron in faithlocks)
				if(ispath(user.patron.type, allowed_patron))
					patron_allowed = TRUE
					break
		if(!patron_allowed)
			var/new_patron = pick(faithlocks)
			user.set_patron(new_patron)
			to_chat(user, span_warning("Your character's patron has been adjusted to match the warband's requirements."))
		else
			user.set_patron(user.patron.type)
	else
		user.set_patron(user.patron.type) // no faithlocks, but we'll still want to reapply the current patron to restore any patron-relevant traits after the statwipe
	return

/////////////////////////////////////////////
/////////////////////////////////// SET LOCKS
/*
	collects all race and faith locks from the selected warband, subtype, and aspects
	stores them in the manager's racelocks and faithlocks lists

*/
/atom/movable/screen/warband/manager/proc/set_race_and_faith_locks()
	racelocks = list()
	faithlocks = list()
	
	if(selected_warband)
		if(selected_warband.racelock && selected_warband.racelock.len)
			for(var/race in selected_warband.racelock)
				racelocks |= race
		
		if(selected_warband.faithlock && selected_warband.faithlock.len)
			for(var/faith in selected_warband.faithlock)
				faithlocks |= faith
	
	if(selected_subtype)
		if(selected_subtype.racelock && selected_subtype.racelock.len)
			for(var/race in selected_subtype.racelock)
				racelocks |= race
		
		if(selected_subtype.faithlock && selected_subtype.faithlock.len)
			for(var/faith in selected_subtype.faithlock)
				faithlocks |= faith
	
	if(selected_aspects.len)
		for(var/datum/warbands/aspects/aspect in selected_aspects)
			if(aspect.racelock && aspect.racelock.len)
				for(var/race in aspect.racelock)
					racelocks |= race
			
			if(aspect.faithlock && aspect.faithlock.len)
				for(var/faith in aspect.faithlock)
					faithlocks |= faith
	
	// aspects take priority, then the subtype, then the warband
	// something returning TRUE prevents the default message from being sent
	for(var/datum/warbands/aspects/aspect in selected_aspects)
		if(aspect.on_locks_applied(src))
			return
	if(selected_subtype?.on_locks_applied(src))
		return
	if(selected_warband?.on_locks_applied(src))
		return
		
	if(!racelocks.len && !faithlocks.len)
		return

	var/lock_message = span_bold("<span style='color:#e8bf67'>WARBAND RESTRICTIONS:</span> ")

	if(racelocks.len)
		var/list/race_names = list()
		for(var/race_type in racelocks)
			var/datum/species/temp_species = new race_type()
			race_names += temp_species.name
			qdel(temp_species)
		lock_message += "Species limited to: [race_names.Join(", ")]"

	if(faithlocks.len)
		if(racelocks.len)
			lock_message += " | "
		var/list/faith_names = list()
		for(var/faith_type in faithlocks)
			var/datum/patron/temp_patron = new faith_type()
			faith_names += temp_patron.name
			qdel(temp_patron)
		lock_message += "Faith limited to: [faith_names.Join(", ")]"

	lock_message += ". Your character will be adjusted if necessary."
	for(var/mob/living/member in lobby_members)
		to_chat(member, lock_message)
		member.playsound_local(member, 'sound/misc/notice (2).ogg', 100, FALSE)

	return

//////////////////////////////////////////////////////////////
///////////////////////////////////////////////// RETURN ENVOY
/*
	returns an envoy's client to their original character

	done via two potential routes
	1. USING A STORED CHARACTER
		we'll do this if:
		a recruitment point holding a stored character is captured

	2. USING A LINKED MOB
		we'll do this if:
		an Envoy uses their ABANDON ENVOY verb
		an Envoy interacts with a recruitment point
		an Envoy re-enters their corpse

	search all rally points for the envoy's stored character
	puts the envoy back in their stored character, and then delete the envoy
*/
/atom/movable/screen/warband/manager/proc/return_envoy(mob/living/carbon/human/envoy, mob/returning_character, obj/return_recruitmentpoint, abandoned = FALSE)
	// USING A STORED CHARACTER
	// aka: home <- envoy
	// requires the recruitment point & the stored/returning character
	if(returning_character && return_recruitmentpoint)
		for(var/mob/living/carbon/human/stored_character in return_recruitmentpoint.contents)
			for(var/mob/living/potential_envoy in members)
				if(potential_envoy.canon_client.key == returning_character.canon_client.key && potential_envoy.mind.special_role == "Warlord's Envoy")
					potential_envoy.visible_message(span_boldred("[potential_envoy] suddenly collapses. They won't be getting up."))
					stored_character.forceMove(return_recruitmentpoint.loc)
					returning_character.key = potential_envoy.key
					returning_character.forceMove(return_recruitmentpoint.loc)
			for(var/mob/living/carbon/spirit/ghost in GLOB.player_list) // if the envoy isn't found, we check the ghosts
				if(ghost.canon_client.key == returning_character.canon_client.key && ghost.mind.special_role == "Warlord's Envoy")
					stored_character.forceMove(return_recruitmentpoint.loc)
					returning_character.forceMove(return_recruitmentpoint.loc)					
					returning_character.key = ghost.key

	// USING A LINKED MOB
	// aka: envoy -> home
	else
		var/mob/living/carbon/human/target_character = envoy?.mind.original_char
		target_character.key = envoy.key
		target_character.forceMove(target_character.loc.loc)
		members -= envoy
		if(abandoned)
			return
		spawns++ // if they made it back alive refund the spawn spent on them
		envoy.unequip_everything()
		qdel(envoy)
	return

///////////////////////////////////////////////////////
///////////////////////////////////////////////// EXILE
/*
	kicks someone out of the warband
	varies depending on whether or not they were just an ally or an Actual Member of the warband

*/
/atom/movable/screen/warband/manager/proc/exile(mob/initial_target, mob/living/carbon/human/user, menu_name, personal = FALSE)
	var/faction_tag = "warband_[warband_ID]"
	var/personal_faction_tag
	var/mob/exiled_creecher = initial_target
	var/datum/component/trail_follow/manager = user.GetComponent(/datum/component/trail_follow)
	if(!manager)
		manager = user.AddComponent(/datum/component/trail_follow)

	if(menu_name) // get the mob w/the name given from the exile menu
		for(var/mob/living/member in members)
			if(member.real_name == menu_name)
				exiled_creecher = member
				break
	if(user)
		personal_faction_tag = "[user.real_name]_faction"

	if(exiled_creecher == user) // against yourself
		to_chat(user, span_warning("I shouldn't exile myself."))
		return FALSE

	if(exiled_creecher.stat == DEAD) // against a corpse
		to_chat(user, span_warning("They're dead. That's exile enough."))
		return
		
	if(exiled_creecher.mind && exiled_creecher.mind.special_role == "Warlord's Envoy")
		to_chat(user, span_warning("No point in killing the messenger."))
		return

	if(exiled_creecher in manager.members) // against one of your own NPCs
		to_chat(user, span_warning("[exiled_creecher.name] is one of my finest soldiers! I could never consider such a thing..."))
		return FALSE

	// for warlords exiling a re-associated exiled lieutenant or grunt
	if(user.mind && user.mind.special_role == "Warlord" && exiled_creecher.mind && (user.mind.warband_ID in exiled_creecher.mind.warband_exile_IDs))
		if(exiled_creecher in user.mind.warband_manager.allies)
			to_chat(user, span_red("[exiled_creecher.real_name] is branded as an exile yet again."))
			if(faction_tag in exiled_creecher.faction)
				exiled_creecher.faction -= faction_tag		
			if(personal_faction_tag in exiled_creecher.faction)
				exiled_creecher.faction -= personal_faction_tag
			if(personal)
				user.say("HOSTIS DECLARATUS ES!")
				user.linepoint(exiled_creecher)
			user.mind.warband_manager.allies -= exiled_creecher
			user.mind.warband_manager.disorder ++ 	// adds a permanent stack of disorder. Something has to be going horribly wrong
		return TRUE									// The Boss Has Lost His Fucking Mind

	// if they're a lieutenant's exiled subordinate, this confirms they want them gone
	if(exiled_creecher.real_name in user.mind.unresolved_exile_names)
		user.mind.unresolved_exile_names -= exiled_creecher.real_name
		user.mind.subordinates -= exiled_creecher

	if(istype(exiled_creecher, /mob/living/simple_animal))
		if(personal_faction_tag in exiled_creecher.faction)
			exiled_creecher.faction -= personal_faction_tag
			to_chat(user, span_warning("I have released the [exiled_creecher.name] from my protection."))
			return TRUE
		return

	else if(istype(exiled_creecher, /mob/living/carbon/human))
		var/mob/living/carbon/human/target = exiled_creecher

		// against allies
		if(target.mind && (target in allies))
			if((faction_tag in target.faction))
				if(personal) // if the exile's being done manually via the spell
					user.say("Hostis declaratus es.")
					user.linepoint(target)
				target.mind.current.faction -= faction_tag
				if(personal_faction_tag && (personal_faction_tag in target.faction))
					target.mind.current.faction -= personal_faction_tag

				allies -= target
				target.mind.warband_recruiter_name = null

				// if they were an antagonist (and not a warband member), reduce disorder
				if(target.mind.special_role && target.mind.warband_ID != user.mind.warband_ID)
					to_chat(user, span_warning("I have exiled [target.name] from our ranks. Some measure of order has been restored."))
					disorder --
					return
				else
					to_chat(user, span_warning("I have exiled [target.name] from our ranks."))
					return

		// against other warband members
		if(target.mind && (target in members))
			if(user.mind.special_role == "Warlord" || (target in user.mind.subordinates))
				var/readycheck = input(user, "Am I sure I want to exile [target.real_name]? This will be final.") in list("EXILE", "Cancel")
				if(readycheck == "EXILE")
					if(target.mind.special_role == "Grunt")
						if(target in user.mind.subordinates) // if they're exiled by their own boss, ignore the deliberation phase
							target.abandon_warband(grunt_kick = TRUE, autoresolve = TRUE)
							target.faction -= personal_faction_tag
							if(target.real_name in user.mind.unresolved_exile_names) // if they were an unresolved exile we consider them resolved
								user.mind.unresolved_exile_names -= target.real_name
							return
						else
							target.abandon_warband(grunt_kick = TRUE)
							to_chat(user, span_warning("I've branded [target.real_name] as an exile. But unless their Lieutenant, [target.mind.warband_recruiter_name], approves of this, [target.real_name] will remain associated with them."))
							return
					else
						target.abandon_warband(kicked = TRUE)
						return
			else
				to_chat(user, span_warning("I don't bear the authority to exile the [target.job]."))

		if((personal_faction_tag in target.faction)) // you should always be able to remove your personal faction tag from someone
			target.faction -= personal_faction_tag
			if(target.mind.warband_recruiter_name == user.real_name)
				target.mind.warband_recruiter_name = null
			if(personal)
				user.say("Hostis declaratus es.")
				user.linepoint(exiled_creecher)

		if(!(faction_tag in target.faction)) // if you're completely unrelated to them
			to_chat(user, span_warning("They're not with us. Exile would be pointless."))
			return FALSE
		return
	return

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////// CLEAN MEMBERS
/*
	cleans nulls out of the members & ally list

*/
/atom/movable/screen/warband/manager/proc/clean_members()
	for(var/member in members)
		if(!member)
			members -= member
	for(var/ally in allies)
		if(!ally)
			allies -= ally

// if the lobby is absolutely Deep Fried, we'll send everyone back as a ghost
/atom/movable/screen/warband/manager/proc/cancel_lobby(mob/lobby_member)
	to_chat(lobby_member, span_userdanger("The lobby system failed catastrophically. Go home."))
	GLOB.chosen_names -= lobby_member.real_name
	lobby_members -= lobby_member
	lobby_member.ghostize(FALSE)

/atom/movable/screen/warband/manager/proc/initialize_outskirts_encounter()
	encounter_manager = new /datum/outskirts_encounter()
	encounter_manager.linked_warband = src
	encounter_manager.custom_wave = choose_outskirts_wave()
	encounter_manager.outskirts_locked = TRUE
	return encounter_manager

/atom/movable/screen/warband/manager/proc/finalize_outskirts_encounter()
	if(!encounter_manager)
		initialize_outskirts_encounter()
	encounter_manager.find_defender_entry()
	encounter_manager.find_attacker_entry()
	encounter_manager.spawn_objective()
	return TRUE

/atom/movable/screen/warband/manager/proc/choose_outskirts_wave()
	var/datum/outskirts_wave/chosen_wave
	if(selected_aspects)
		for(var/datum/warbands/aspects/aspect in selected_aspects)
			if(aspect.outskirts_wave)
				chosen_wave = aspect.outskirts_wave
				return new chosen_wave()
	if(!chosen_wave)
		if(selected_subtype && selected_subtype.outskirts_wave)
			chosen_wave = selected_subtype.outskirts_wave
			return new chosen_wave()
	if(!chosen_wave)
		if(selected_warband && selected_warband.outskirts_wave)
			chosen_wave = selected_warband.outskirts_wave
			return new chosen_wave()
	if(!chosen_wave)
		chosen_wave = /datum/outskirts_wave/feud
		return new chosen_wave()
	return

/////////////////////////////////////////////
/////////////////////////////////// END INTRO
/*
	fades the intro text from the client's screen
	removes the "BEGIN" text from the client's screen
	heals the loaded character to clear the stun & blindness
	makes them visible
*/
/atom/movable/screen/warband/manager/proc/end_intro(mob/living/user)
	if(!user || !user.client)
		return
	for(var/atom/movable/screen/warband/manager/loaded_manager in user.client.screen)
		user.client.screen -= loaded_manager
	user.mind.warbandsetup = FALSE
	user.invisibility = INVISIBILITY_NONE
	user.fully_heal()
	SEND_SOUND(user, sound(null)) // cuts the selection music
	user.playsound_local(user, 'sound/misc/warband/warband_warhorn3.ogg', 100, FALSE, pressure_affected = FALSE)
	for(var/atom/movable/screen/introtext/text in user.client.screen)
		animate(text, alpha = 0, time = 50)
		addtimer(CALLBACK(src, PROC_REF(remove_intro), user.client, text), 5 SECONDS)

/atom/movable/screen/warband/manager/proc/remove_intro(client/user, atom/movable/screen/introtext/text)
	if(user)
		user.screen -= text
	qdel(text)

/atom/movable/screen/warband/manager/proc/apply_casus_belli_to_treaty(obj/item/treaty/T)
	if(!casus_belli_selection || !T)
		return
	var/datum/treaty/terms/cb_copy = new casus_belli_selection.type()
	if(casus_belli_selection.custom_name)
		cb_copy.custom_name = casus_belli_selection.custom_name
	if(casus_belli_selection.text)
		cb_copy.text = casus_belli_selection.text
	if(casus_belli_selection.number)
		cb_copy.number = casus_belli_selection.number
	if(casus_belli_selection.target)
		cb_copy.target = casus_belli_selection.target
		if(casus_belli_selection.target != linked_faction.name)
			T.secondparty = casus_belli_selection.target
	if(casus_belli_selection.receiver)
		cb_copy.receiver = casus_belli_selection.receiver
	if(casus_belli_selection.obj_target)
		cb_copy.obj_target = casus_belli_selection.obj_target
	T.active_terms += cb_copy

// returns the type path if it's a registered warband class, else null | callers read metadata via initial(path:var)
/atom/movable/screen/warband/manager/proc/warband_class_for(class_path)
	if(SSwarbands.all_warband_class_types[class_path] && ispath(class_path, /datum/advclass/warband))
		return class_path
	return

////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// NPC SPAWN COST
/*
	returns how many spawns a single allied NPC (goon) costs to summon
*/
/atom/movable/screen/warband/manager/proc/get_npc_spawn_cost(base_cost = 1)
	for(var/datum/warbands/aspects/aspect in selected_aspects)
		if(istype(aspect, ASPECT_BADSPAWN))
			return base_cost * 2
	return base_cost

/////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// ENVOY SUMMONING

/atom/movable/screen/warband/manager/proc/summon_envoy(mob/living/carbon/human/user, turf/spawn_loc, atom/storage_point, race_choice, depth_choice)
	var/mob/living/carbon/human/envoy
	switch(depth_choice)
		if("Simple Envoy")
			switch(race_choice)
				if("Humen")
					envoy = new /mob/living/carbon/human/species/human/northern(spawn_loc)
				if("Half-Elf")
					envoy = new /mob/living/carbon/human/species/human/halfelf(spawn_loc)
				if("Dwarf")
					envoy = new /mob/living/carbon/human/species/dwarf/mountain(spawn_loc)
				if("Elf")
					envoy = new /mob/living/carbon/human/species/elf/wood(spawn_loc)
				if("Aasimar")
					envoy = new /mob/living/carbon/human/species/aasimar(spawn_loc)
			envoy.real_name = pick(world.file2list("strings/rt/names/human/humsoulast.txt"))
			apply_simple_envoy_appearance(envoy)
		if("Use a Character Slot")
			envoy = new /mob/living/carbon/human/species/human/northern(spawn_loc)
	if(!envoy)
		return
	envoy.sync_mind()
	envoy.faction |= list("warband_[warband_ID]", "[user.real_name]_faction")
	envoy.key = user.key
	envoy.mind.warband_ID = warband_ID
	envoy.mind.warband_manager = src
	envoy.mind.original_char = user
	transfer_treaties(user, envoy)
	equip_envoy(envoy)
	SSjob.AssignRole(envoy, "Warlord's Envoy")
	envoy.mind.special_role = "Warlord's Envoy"
	spawns-- // an envoy costs a single spawn
	if(storage_point)
		storage_point.contents += user
	return envoy

// moves any treaties the summoner is carrying into the envoy's hands
/atom/movable/screen/warband/manager/proc/transfer_treaties(mob/living/carbon/human/from_mob, mob/living/carbon/human/to_mob)
	for(var/obj/item/treaty/carried_treaty in from_mob.contents)
		if(from_mob.transferItemToLoc(carried_treaty, to_mob.loc))
			to_mob.put_in_hands(carried_treaty)

	for(var/obj/item/storage/bag in from_mob.contents)
		for(var/obj/item/treaty/bag_treaty in bag.contents)
			bag_treaty.remove_item_from_storage(from_mob)
			bag_treaty.forceMove(to_mob.loc)
			to_mob.put_in_hands(bag_treaty)

/atom/movable/screen/warband/manager/proc/apply_simple_envoy_appearance(mob/living/carbon/human/envoy)
	var/obj/item/bodypart/head/head = envoy.get_bodypart(BODY_ZONE_HEAD)
	var/hair_choice = /datum/sprite_accessory/hair/head/troubadour

	var/datum/bodypart_feature/hair/head/new_hair = new()

	new_hair.set_accessory_type(hair_choice, owner = envoy)

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

// equips an envoy with the envoy advclass kit
/atom/movable/screen/warband/manager/proc/equip_envoy(mob/envoy, used_slot)
	var/datum/advclass/warband/envoy/envoy_class = new /datum/advclass/warband/envoy
	envoy.cmode_music = combatmusic
	envoy.job = envoy_class.name
	envoy_class.equipme(envoy, FALSE)

// returns a random rally point belonging to this warband, or null
/atom/movable/screen/warband/manager/proc/get_random_recruit_point()
	var/list/recruit_points = list()
	for(var/obj/structure/fluff/warband/warband_recruit/point in SSwarbands.warband_machines)
		if(point.warband_ID == warband_ID)
			recruit_points += point
	if(recruit_points.len)
		return pick(recruit_points)
	return

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

// returns (creating if needed) the trail_follow component that herds a player's NPC squad
/atom/movable/screen/warband/manager/proc/get_squad_component(mob/user)
	var/datum/component/trail_follow/squad = user.GetComponent(/datum/component/trail_follow)
	if(!squad)
		squad = user.AddComponent(/datum/component/trail_follow)
	return squad

// TRUE if the given squad component is currently herding any goons
/atom/movable/screen/warband/manager/proc/squad_has_goons(datum/component/trail_follow/squad)
	for(var/mob/friend in squad.members)
		if(istype(friend, /mob/living/carbon/human/species/human/northern/goon))
			return TRUE
	return FALSE

// abandons every goon currently herded by the given squad component
/atom/movable/screen/warband/manager/proc/abandon_npc_squad(datum/component/trail_follow/squad)
	for(var/mob/living/carbon/human/species/human/northern/goon/abandoned_grunt in squad.members)
		if(!abandoned_grunt)
			squad.members -= abandoned_grunt
			continue
		abandoned_grunt.abandonevent()
		squad.members -= abandoned_grunt

// spawns a fresh squad of goons at spawn_loc
/atom/movable/screen/warband/manager/proc/deploy_npc_squad(mob/living/carbon/human/user, turf/spawn_loc, datum/component/trail_follow/squad, base_cost = 1)
	var/grunt_cost = get_npc_spawn_cost(base_cost)
	var/deployed = 0
	for(var/grunts_spawned = 1, grunts_spawned <= user.mind.squad_size && spawns >= grunt_cost, grunts_spawned++)
		var/mob/living/carbon/human/species/human/northern/goon/new_grunt = get_cached_grunt(spawn_loc, user)
		new_grunt.patron = user.patron
		new_grunt.faction |= list("warband_[warband_ID]", "[user.real_name]_faction")
		new_grunt.warband_ID = warband_ID
		squad.members |= new_grunt
		spawns -= grunt_cost
		deployed++
	return deployed
