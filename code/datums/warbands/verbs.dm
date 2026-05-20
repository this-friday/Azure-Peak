///////////////////////////////////////////////////////////////
///////////////////////////////////////////////// ABANDON ENVOY
/*
	a verb to manually perform the return_envoy proc in emergencies
	abandons a character's envoy & sends them back to their stored character w/return_envoy
*/
/mob/living/carbon/human/proc/abandon_envoy()
	set name = "ABANDON ENVOY"
	set category = "Warband"


	var/list/style_options = list()
	
	if(mind.warband_manager.selected_warband?.title == "SORCERER-KING")
		style_options += "BLOW UP HEAD"
	if(mind.warband_manager.selected_subtype?.title == "ASCENDANT")
		style_options += "DEADITE"

	style_options += "POISON TOOTH"

	var/style_choice = input(src, "How should they go out?", "ABANDON SHIP") as null|anything in style_options

	switch(style_choice)
		if("POISON TOOTH")
			ADD_TRAIT(src, TRAIT_NOSSDINDICATOR, TRAIT_GENERIC) // for immersion's sake
			ADD_TRAIT(src, TRAIT_DNR, TRAIT_GENERIC) // they get dnr'd either way, so this should be fine ^
			visible_message(span_boldred("[src] suddenly seizes up, blood-laced foam bubbling from the corners of their mouth!"))
			mind.warband_manager.return_envoy(src, abandoned = TRUE)
			adjustOxyLoss(200)
			adjustToxLoss(200)
			return TRUE
		if("DEADITE")
			if(prob(90))
				ADD_TRAIT(src, TRAIT_NOSSDINDICATOR, TRAIT_GENERIC)
				emote("agony", forced = TRUE)
				visible_message(span_boldred("[src] digs their nails into their flesh. Once they have a solid grip, they yank themselves free!"))
				mind.warband_manager.return_envoy(src, abandoned = TRUE)
				addtimer(CALLBACK(src, PROC_REF(abandon_followup), 1), 3 SECONDS)
				return TRUE
			else
				ADD_TRAIT(src, TRAIT_NOSSDINDICATOR, TRAIT_GENERIC)
				emote("agony", forced = TRUE)
				visible_message(span_boldred("[src] contorts in agony as wisps of a dark, terrible energy rise from their screaming lips and bleeding ears. Something wicked is coming..."))
				mind.warband_manager.return_envoy(src, abandoned = TRUE)
				addtimer(CALLBACK(src, PROC_REF(abandon_followup), 2), 3 SECONDS)
				return TRUE

		if("BLOW UP HEAD")
			ADD_TRAIT(src, TRAIT_NOSSDINDICATOR, TRAIT_GENERIC)
			visible_message(span_boldred("[src]'s skull hums with a swelling, arcane force! Holy shit! They're gonna blow!"))
			flash_fullscreen("redflash3")
			emote("agony", forced = TRUE)			
			mind.warband_manager.return_envoy(src, abandoned = TRUE)
			addtimer(CALLBACK(src, PROC_REF(abandon_followup), 3), 3 SECONDS)
			return TRUE
	return TRUE


/mob/living/carbon/human/proc/abandon_followup(event)
	ADD_TRAIT(src, TRAIT_DNR, TRAIT_GENERIC)
	if(event == 1)
		var/deathloc = loc
		var/mob/living/carbon/human/species/skeleton/npc/no_equipment/skeleton = new /mob/living/carbon/human/species/skeleton/npc/no_equipment(deathloc)
		skeleton.emote("laugh", forced = TRUE)
		gib()
		return TRUE

	if(event == 2)
		var/deathloc = loc
		gib()
		new /mob/living/simple_animal/hostile/rogue/haunt/omen(deathloc)
		return TRUE

	if(event == 3)
		mind = null
		var/obj/item/bodypart/head = get_bodypart(BODY_ZONE_HEAD)
		if(head)
			explosion(src, light_impact_range = 4,  smoke = TRUE)
			head.drop_limb()
			qdel(head)
		return TRUE

/////////////////////////////////////////////////////////////
///////////////////////////////////////////////// COMMUNICATE
/*
	cross-map communication between warband characters
*/
/mob/living/carbon/human/proc/communicate()
	set name = "COMMUNICATE"
	set category = "Warband"
	var/list/random_flavortone = list("caw", "weep", "croak", "scream", "gurgle", "sing", "murmur", "wail", "chirp", "babble")

	if(!mind.warband_manager)
		to_chat(src, span_bold("I call, but no Carrier Zad heeds me."))
		return

	if(mind.warband_manager.disorder >= 8 && !mind.special_role == "Warlord") // warlord can always use Communicate
		to_chat(src, span_bold("I call, but no Carrier Zad heeds me. It's likely disturbed by the disorder in our Warband."))
		return

	if(mind.warband_manager.disorder >= 8 && mind.special_role == "Warlord")
		to_chat(src, span_warning("My Carrier Zad arrives, but my Warband's morale is too low for my men to utilize their own. I can still send out a message, but I shouldn't expect a direct response."))

	if(istype(loc.loc, /area/rogue/outdoors))
		var/input_text = input(src, "Enter your message", "Message")
		if(input_text)
			var/sanitized_text = html_encode(input_text)
			visible_message(span_boldred("[src] begins binding a sealed letter to a zad's leg..."))
			if(do_after(src, 100, FALSE, src))
				if(istype(loc.loc, /area/rogue/outdoors)) // another area check, in case someone starts the prompt outside and moves back inside for the doafter
					var/random_tone = pick(random_flavortone)
					visible_message(span_boldred("[src] releases a carrier zad!"))
					playsound(src, 'sound/vo/mobs/bird/birdfly.ogg', 100, TRUE, -1)
					for(var/mob/warband_member in mind.warband_manager.members)
						if(!warband_member)	// if there's a null in here, we remove them from the member list, call a cleanup, and skip them
							mind.warband_manager.members -= warband_member
							mind.warband_manager.clean_members() // Who Up Cleaning They Members
							continue
						if(!warband_member.loc)
							continue
						if(isliving(warband_member))
							if(istype(warband_member.loc.loc, /area/rogue/outdoors))
								if(mind.special_role == "Warlord")
									to_chat(warband_member, span_highlight("A carrier zad flutters down and perches nearby. In mimicry of our Warlord, it recites a missive clutched in its talons: <span style='color:#[src.voice_color]'>''[sanitized_text]''</span>"))								
								else
									to_chat(warband_member, span_red("A zad-bound message arrives with the seal of the [src.job]: <span style='color:#[src.voice_color]'>''[sanitized_text]''</span> - [src.real_name]"))
							else
								to_chat(warband_member, span_warning("Beyond the walls, I faintly hear a carrier zad [random_tone] in mimicry: <span style='color:#[src.voice_color]'>''[sanitized_text]''</span>"))
	else
		to_chat(src, span_bold("I'll need to be outside."))

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////// TAKE SHORTCUT
/*
	teleports someone to their camp's Shortcut Tile
	FAILS IF:
		they aren't near an existing travel tile. any will do
		the shortcut tile is disabled/captured
		the camp hasn't been connected to the main z-level via an Envoy using a "SCOUT A PATH" verb
*/ 
/mob/living/carbon/human/proc/shortcut()
	set name = "TAKE SHORTCUT"
	set desc = "Attempt to take a shortcut to your warcamp."
	set category = "Warband"

	var/can_shortcut = FALSE
	if(!mind.warband_manager)
		to_chat(src, span_warning("There's nowhere for me to go. I am alone."))
		return


	if(!mind.warband_manager.outskirts_established)
		to_chat(src, span_bold("Before I can take a shortcut back to the Warcamp, an ENVOY needs to Scout a Path."))
		return

	for(var/obj/structure/object in range(1, src))
		if(istype(object, /obj/structure/fluff/traveltile) || istype(object, /obj/structure/far_travel))
			can_shortcut = TRUE
			break

	if(!can_shortcut)
		to_chat(src, span_bold("Should I find a Travel Tile of any kind, I can take a shortcut back to my Warcamp."))
		return

	if(do_after(src, 100, FALSE, src))
		for(var/obj/structure/fluff/warband/shortcut/warband_shortcut in SSwarbands.warband_machines)
			if(warband_shortcut.warband_ID == mind.warband_ID)
				if(warband_shortcut.disabled)
					to_chat(src, span_userdanger("Something's wrong. I've been cut off, and I'll need to return through the frontline."))
				else
					visible_message(span_bold("[src] slips somewhere beyond sight!"))
					loc = warband_shortcut.loc
				break 
		return TRUE

	return TRUE

/////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// CONNECT WARCAMP
/*
	spawns a travel tile to a newly spawned set of intermission & outskirts maps, which connect to the warcamp
	the spawned maps vary depending on where the travel tile is spawned
	
	requires a rock wall nearby
	area limited

	spawns a few extra tiles near the first that will try to place themselves adjacent to a rock wall

*/
/mob/living/carbon/human/proc/connect_warcamp()
	set name = "SCOUT PATH TO WARCAMP"
	set category = "Warband"

	if(SSwarbands.warband_managers_busy == TRUE) // we don't want multiple maps getting spawned at the same time
		to_chat(src, span_userdanger("I'll need to wait for a moment."))
		return

	if(mind.warband_manager.outskirts_established == TRUE)
		to_chat(src, span_userdanger("A path has already been scouted."))
		return

	var/area/zone = loc.loc

	var/list/allowed_area_types = list(
		/area/rogue/under/underdark,
		/area/rogue/under/cave,
		/area/rogue/indoors/cave,
		/area/rogue/under/cavewet,
		/area/rogue/outdoors/woods,
		/area/rogue/outdoors/bog,
		/area/rogue/outdoors/mountains/decap,
		/area/rogue/outdoors/beach,
		/area/rogue/outdoors/mountains
	)
	var/list/blacklisted_area_types = list(
		/area/rogue/outdoors/beach/forest/hamlet,
		/area/rogue/indoors/cave/underhamlet,
	)

	var/is_allowed = FALSE
	for(var/type_path in allowed_area_types)
		if(istype(zone, type_path))
			is_allowed = TRUE
			break

	var/is_blacklisted = FALSE
	for(var/type_path in blacklisted_area_types)
		if(istype(zone, type_path))
			is_blacklisted = TRUE
			break

	if(!is_allowed || is_blacklisted)
		to_chat(src, span_danger("This isn't a suitable location. I should go far away from here."))        
		return

	var/has_mineral_turf = locate(/turf/closed/mineral) in range(1, src)
	if(!has_mineral_turf)
		to_chat(src, span_green("This is a good location. I should get my bearings beside a ROCK WALL before I plot a route back to camp."))		
		return

	if(is_allowed && !istype(zone, blacklisted_area_types))
		if(SSwarbands.warband_managers_busy == TRUE)	// we don't want multiple maps getting spawned at the same time
			to_chat(src, span_userdanger("I'll need to wait for a moment."))
			return

		if(mind.warband_manager.outskirts_established == TRUE)
			to_chat(src, span_userdanger("A path has already been scouted."))
			return

		for(var/turf/nearby_turf in range(4, src))
			if(nearby_turf.contents == /obj/structure/fluff/traveltile)
				to_chat(src, span_userdanger("I'm too close to an existing path."))				
				return

		if(!mind.warband_manager.warcamp_established) // if this is being done without a warcamp, we check if there's a free space.
			var/obj/effect/landmark/warcamp/found_slot
			for(var/obj/effect/landmark/warcamp/open_warcamp_slot in GLOB.landmarks_list)
				found_slot = TRUE
				break
			if(!found_slot)
				to_chat(src, span_userdanger("The entire countryside is occupied. I can't establish a Warcamp."))
				if(src.mind.special_role == "Warlord") // if they're a warlord, assume they're a deserter and let them place a Recruitment Point
					to_chat(src, span_userdanger("I can, however, declare a Recruitment Point to rally my troops..."))
					if(do_after(src, 90, target = src))
						var/obj/structure/fluff/warband/warband_recruit/outpost = new /obj/structure/fluff/warband/warband_recruit(src.loc)
						outpost.warband_ID = mind.warband_ID
						outpost.linked_warband = mind.warband_manager						
						mind.warband_manager.warcamp_established = TRUE
						verbs -= /mob/living/carbon/human/proc/connect_warcamp
				return

		SSwarbands.warband_managers_busy = TRUE
		visible_message(span_notice("[src] begins scouting for a new path..."))
		var/turf/initial_turf = loc
		if(do_after(src, 30, target = src))
			var/terrain_key
			
			if(istype(zone, /area/rogue/under/cave) || istype(zone, /area/rogue/under/underdark) || istype(zone, /area/rogue/under/cavewet) || istype(zone, /area/rogue/indoors/cave) || istype(zone, /area/rogue/outdoors/caves))
				terrain_key = "cave"
			else if(istype(zone, /area/rogue/outdoors/mountains) || istype(zone, /area/rogue/outdoors/mountains/decap))
				terrain_key = "mountains"
			else if(istype(zone, /area/rogue/outdoors/beach))
				terrain_key = "coast"
			else if(istype(zone, /area/rogue/outdoors/woods))
				terrain_key = "woods"
			else if(istype(zone, /area/rogue/outdoors/bog))
				terrain_key = "bog"

			if(!terrain_key)
				to_chat(src, span_userdanger("Something's wrong. I should attempt this somewhere else."))
				SSwarbands.warband_managers_busy = FALSE
				return

			var/datum/map_template/chosen_outskirts_map = SSwarbands.get_cached_template(TEMPLATE_OUTSKIRTS, terrain_key)
			var/datum/map_template/chosen_intermission_map = SSwarbands.get_cached_template(TEMPLATE_INTERMISSION, terrain_key)

			if(!chosen_outskirts_map || !chosen_intermission_map)
				to_chat(src, span_userdanger("Something's wrong. I should attempt this somewhere else."))
				SSwarbands.warband_managers_busy = FALSE
				return
			if(mind.warband_manager.outskirts_established == TRUE)
				to_chat(src, span_userdanger("A path has already been scouted."))
				return
			var/outskirts_landmark_found = FALSE
			var/obj/effect/landmark/warcamp_outskirts/used_outskirts_landmark
			for(var/obj/effect/landmark/warcamp_outskirts/outskirts_landmark in GLOB.landmarks_list)
				chosen_outskirts_map.load(outskirts_landmark.loc, centered = TRUE)
				used_outskirts_landmark = outskirts_landmark
				outskirts_landmark_found = TRUE
				break

			if(used_outskirts_landmark)
				qdel(used_outskirts_landmark)

			var/intermission_landmark_found = FALSE
			var/obj/effect/landmark/warcamp_intermission/used_intermission_landmark
			for(var/obj/effect/landmark/warcamp_intermission/intermission_landmark in GLOB.landmarks_list)
				chosen_intermission_map.load(intermission_landmark.loc, centered = TRUE)
				used_intermission_landmark = intermission_landmark
				intermission_landmark_found = TRUE
				break

			if(used_intermission_landmark)
				qdel(used_intermission_landmark)

			// spawns the travel tiles to the intermission
			// attempts to get the spawned tiles to hug the wall
			if(outskirts_landmark_found && intermission_landmark_found)
				visible_message(span_info("[src] reveals a path to the Warcamp!"))
				mind.warband_manager.outskirts_established = TRUE
				var/obj/structure/fluff/traveltile/warband/new_path = new /obj/structure/fluff/traveltile/warband/azure_to_intermission(initial_turf)
				new_path.warband_ID = mind.warband_ID

				var/list/spawn_locations = list()
				var/list/preferred_spawn_locations = list()
				for(var/turf/T in range(1, initial_turf))
					if(istype(T, /turf/open/floor) && T != initial_turf) // not the turf we're on
						spawn_locations += T
						for(var/turf/neighbor_turf in range(1, T))
							if(istype(neighbor_turf, /turf/closed/mineral))
								preferred_spawn_locations += T
								break

				// create a warcamp next, if there's an available space and no warcamp
				// guaranteed to be the case during a Desertion
				if(src.mind.warband_manager.warcamp_established == FALSE)
					for(var/obj/effect/landmark/warcamp/open_warcamp_slot in GLOB.landmarks_list)
						src.mind.warband_manager.choose_map(latespawn = TRUE)
						break

				var/list/final_spawn_locations
				if(preferred_spawn_locations.len >= 2)
					final_spawn_locations = preferred_spawn_locations
				else
					final_spawn_locations = spawn_locations

				final_spawn_locations = shuffle(final_spawn_locations)

				var/tiles_to_place = min(2, final_spawn_locations.len)

				for(var/i = 1, i <= tiles_to_place, i++)
					var/turf/chosen_turf = final_spawn_locations[i]
					var/obj/structure/fluff/traveltile/warband/new_tile = new /obj/structure/fluff/traveltile/warband/azure_to_intermission(chosen_turf)
					new_tile.warband_ID = src.mind.warband_ID
				mind.warband_manager.set_IDs()
				mind.warband_manager.link_portals()
				mind.warband_manager.finalize_outskirts_encounter()
				SSwarbands.warband_managers_busy = FALSE
				for(var/obj/effect/solid_invisible_barrier/warband_spawnbarrier/spawn_barrier in SSwarbands.warband_machines)
					if(spawn_barrier.warband_ID == mind.warband_manager.warband_ID)
						SSwarbands.warband_machines -= spawn_barrier
						qdel(spawn_barrier)
			else
				return
		else
			visible_message(span_warning("[src] halts their scouting."))
			SSwarbands.warband_managers_busy = FALSE
			return
	else
		to_chat(src, span_warning("This isn't a suitable location."))
		return

	return TRUE

/////////////////////////////////////////////////////////////
///////////////////////////////////////////////// ACCEPT KICK
/*
	when a lieutenant's subordinate is exiled by their warlord, they are given a choice

	DEFY EXILE
		the subordinate keeps their lieutenant's mob faction
		exile is defied by default (otherwise, a subordinate getting exiled mid-coup (and seperately from the lieutenant) could result in a bunch of Silly Situations)
		this just affirms it

	ACCEPT
		the subordinate is removed from their lieutenant's mob faction
		the subordinate is removed from their lieutenant's list of subordinates
		alternatively, they can just directly use the Exile spell on them to the same effect

*/
/mob/living/carbon/human/proc/accept_kick()
	set name = "RESOLVE EXILES"
	set category = "Warband"

	var/mob/living/carbon/human/target
	var/personal_faction_tag = "[src.real_name]_faction"

	if(!mind.unresolved_exile_names.len)
		to_chat(src, span_warning("There are no decrees I must resolve."))
		return

	var/exile_choice = input(src, "Who should I settle?", "EXILE") as null|anything in mind.unresolved_exile_names
	if(exile_choice)
		for(var/mob/living/carbon/human/exile in GLOB.player_list) // get the mob w/the exile's name
			if(exile.real_name == exile_choice)
				target = exile
				break
	else
		return

	if(!target)
		to_chat(src, span_warning("They're gone. I should consider the matter resolved."))
		mind.unresolved_exile_names -= exile_choice
		return

	if(!(target.real_name in mind.unresolved_exile_names))
		to_chat(src, span_warning("I've already made a decision."))
		return

	var/readycheck = input(src, "Will I endorse the exile of [target.real_name]?") in list("Defy Exile (Keep as Personal Associate)", "Accept (Cut Ties)", "Cancel")

	if(!target) // last check, in case they far travel mid deliberation
		to_chat(src, span_warning("They're gone. I should consider the matter resolved."))
		mind.unresolved_exile_names -= exile_choice
		return

	if(readycheck == "Defy Exile (Keep as Personal Associate)")
		if(target && target.mind.warband_recruiter_name != real_name) // if they have a new recruiter, set the recruiter back to us
			target.mind.warband_recruiter_name = real_name
		for(var/mob/warband_member in mind.warband_manager.members)
			if(isliving(warband_member))
				to_chat(warband_member, span_warning("A zad arrives with the [src.job]'s seal. They reject the decree of [target.real_name]'s exile, and have ordered their own men to treat [target.real_name] as an associate."))
		mind.unresolved_exile_names -= target.real_name

	if(readycheck == "Accept (Cut Ties)")
		if(personal_faction_tag in target.faction)
			target.faction -= personal_faction_tag

		for(var/mob/warband_member in src.mind.warband_manager.members)
			if(isliving(warband_member))
				to_chat(warband_member, span_warning("A zad arrives with the [src.job]'s seal. They have embraced the decree of [target.real_name]'s exile."))
		if(target && target.mind.warband_recruiter_name != real_name) // if they have a new recruiter, another lieutenant stole them, so we stop here
			mind.subordinates -= target
			mind.unresolved_exile_names -= target.real_name			
			return
		
		mind.unresolved_exile_names -= target.real_name

		target.mind.warband_recruiter_name = null

	else
		return

///////////////////////////////////////////////////////////
///////////////////////////////////////////////// ENLIGHTEN
/*
	allows the Prophet to grant "enlightenment" to another character
	converts them to the Prophet's patron and grants them T4 Cleric status
	cannot convert characters who already have devotion

	converts suffer a curse and cannot regain devotion. it's effectively a Temporary Cleric
*/ 
/mob/living/carbon/human/proc/enlighten()
	set name = "ENLIGHTEN"
	set desc = "Grant someone enlightenment. They will pay a terrible price."
	set category = "Warband"

	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/potential_target in oview(1, src))
		if(potential_target.stat != DEAD)
			nearby_targets += potential_target

	if(!nearby_targets.len)
		to_chat(src, span_warning("There is no one nearby to enlighten."))
		return FALSE

	var/mob/living/carbon/human/chosen_target = input(src, "Who shall receive enlightenment?", "ENLIGHTENMENT") as null|anything in nearby_targets
	if(!chosen_target)
		return FALSE

	if(!chosen_target.mind)
		to_chat(src, span_warning("[chosen_target] is far too dumb for this affair to be worth any God's time, much less my own."))
		return FALSE

	if(get_dist(src, chosen_target) > 1)
		to_chat(src, span_warning("[chosen_target] is too far away."))
		return FALSE

	if(chosen_target.mind && chosen_target.mind.enlightened)
		to_chat(src, span_warning("[chosen_target] has already been enlightened."))
		return FALSE

	if(chosen_target.devotion) // can't convert someone who's already a cleric
		to_chat(src, span_warning("A shame. [chosen_target.patron.name] shields them."))
		return FALSE

	if(get_dist(src, chosen_target) > 1)
		to_chat(src, span_warning("[chosen_target] has moved away."))
		return FALSE

	visible_message(span_boldwarning("[src] raises a palm toward [chosen_target]'s face..."))
	to_chat(src, span_warning("I prepare to grant [chosen_target.real_name] enlightenment..."))

	if(!do_after(src, 50, target = chosen_target))
		to_chat(src, span_warning("The ritual was interrupted."))
		return FALSE

	to_chat(chosen_target, span_userdanger("[src] offers me enlightenment. It will come at a grand price."))
	var/target_choice = alert(chosen_target, "Do I accept [src]'s offer of enlightenment?", "ENLIGHTENMENT", "I ACCEPT", "I REFUSE")
	
	if(target_choice != "I ACCEPT")
		to_chat(chosen_target, span_warning("I remain in the dark."))
		return FALSE

	if(get_dist(src, chosen_target) > 1)
		to_chat(src, span_warning("[chosen_target] has moved away."))
		return FALSE

	visible_message(span_boldwarning("[src] presses their palm against [chosen_target]'s face."))
	apply_enlightenment(chosen_target)
	return TRUE

/mob/living/carbon/human/proc/apply_enlightenment(mob/living/carbon/human/target)
	to_chat(target, span_userdanger("Truth floods through me!"))
	target.visible_message(span_warning("[target] convulses!"))
	target.electrocute_act(0, src)
	target.set_patron(patron.type)
	var/datum/devotion/C = new /datum/devotion(target, target.patron)
	C.grant_miracles(target, cleric_tier = CLERIC_T4, devotion_limit = CLERIC_REQ_4, start_maxed = TRUE)
	var/new_curse = get_curse_for_patron(patron.type)
	if(new_curse)
		target.add_curse(new_curse)
		to_chat(target, span_userdanger("These miracles are not mine to wield. [src.patron.name]'s curse weighs upon me."))
	if(!HAS_TRAIT(target, TRAIT_DNR) && target.patron.type != patron.type && patron.type != /datum/patron/old_god) // if they had a different patron, they get the DNR trait
		ADD_TRAIT(target, TRAIT_DNR, TRAIT_GENERIC)
		target.emote("agony", forced = TRUE)
		to_chat(target, span_userdanger("In place of my lux lies an agonizing vacancy. It is elsewhere, and it will never be mine again."))
	target.mind.enlightened = TRUE
	target.verbs -= /mob/living/carbon/human/proc/clericpray // can't pray
	return TRUE
