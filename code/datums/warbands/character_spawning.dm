
/*	
	CHARACTER SPAWNING
	- everything that happens as a character is spawned from the lobby

	1 - SPAWN CHARACTER			// spawn a character w/the options selected from the lobby
	2 - EQUIP CHARACTER			// final step of spawning a character | equips them, sets their traits + adds them to the faction			
	3 - ASSIGN GRUNT			// binds lieutenants to grunts and vice versa	
	4 - CHANGE CHARACTER		// changes the current character slot
	5 - LOAD CHARACTER			// loads the current character slot
	6 - STAT WIPE				// performs a full stat & trait wipe on the target mob
	7 - GIVE TREATY				// hands out a treaty item to a Warlord or Lieutenant on spawn
	8 - RANDOM CLASSES			// generates 3 random classes for the Wildcard class
	9 - DETERMINE SQUAD SIZE	// decide the size of a character's NPC squad

*/

///////////////////////////////////////////////////
/////////////////////////////////// SPAWN CHARACTER
/*
	if they're the warlord, move them to their warcamp's warlord spawn landmark, then delete said landmark
		adds them to the warband manager's members list
		gives them:
			knowledge of other members in the warband
			knowledge of important figures in the duchy
			the baseline warband verbs (shortcut & communicate)

*/
/atom/movable/screen/warband/manager/proc/spawn_character(classpath, mob/user, subclasspath, is_leader, is_latespawn = FALSE)
	var/datum/advclass/class_path = new classpath()
	var/datum/advclass/subclass_path = subclasspath ? new subclasspath() : null

	var/role = user.mind.special_role
	var/is_lieutenant = (role == "Lieutenant" || role == "Aspirant Lieutenant")

	if(is_leader)
		var/turf/warlord_landmark_turf
		for(var/obj/effect/landmark/start/warlordlate/warlord_spawn in GLOB.landmarks_list)
			warlord_landmark_turf = get_turf(warlord_spawn)
			user.forceMove(warlord_spawn.loc)
			qdel(warlord_spawn)
			break

		for(var/datum/warbands/aspects/aspect in selected_aspects)
			aspect.on_warlord_spawned(user, src)
		selected_warband?.on_warlord_spawned(user, src)
		selected_subtype?.on_warlord_spawned(user, src)

		// we mark the nearest rally point to the warlord's spawn as the spawn turf for anyone coming out of the lobby
		var/obj/structure/fluff/warband/warband_recruit/nearest_rally
		var/shortest_distance = 99
		for(var/obj/structure/fluff/warband/warband_recruit/rally in SSwarbands.warband_machines)
			if(rally.warband_ID == warband_ID)
				var/distance = get_dist(user, rally)
				if(distance < shortest_distance)
					shortest_distance = distance
					nearest_rally = rally

		warband_spawn_turf = nearest_rally ? get_turf(nearest_rally) : warlord_landmark_turf
	else if(!is_latespawn)
		user.forceMove(warband_spawn_turf)

	for(var/mob/living/carbon/human/important_figure in importantfigures)
		user.mind.i_know_person(important_figure.mind)

	for(var/mob/living/carbon/human/pal in members)
		user.mind.i_know_person(pal.mind)
		user.mind.person_knows_me(pal.mind)

	equip_character(class_path, subclass_path, is_leader, user)

	user.faction |= list("warband_[warband_ID]")
	user.verbs += /mob/living/carbon/human/proc/shortcut
	user.verbs += /mob/living/carbon/human/proc/communicate
	REMOVE_TRAIT(user, TRAIT_FORCED_LOOC, TRAIT_GENERIC)
	members += user
	user.nutrition = NUTRITION_LEVEL_FULL
	user.hydration = HYDRATION_LEVEL_FULL

	if(is_leader || is_lieutenant)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/exile)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/associate)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/grunt_order)
		addtimer(CALLBACK(src, PROC_REF(give_treaty), user), 10 SECONDS)
		if(is_lieutenant)
			user.verbs += /mob/living/carbon/human/proc/desert
			user.verbs += /mob/living/carbon/human/proc/accept_kick

	switch(role)
		if("Grunt")
			assign_grunt(grunt = user)
			selected_warband?.on_grunt_spawned(user, src)
			selected_subtype?.on_grunt_spawned(user, src)
			for(var/datum/warbands/aspects/aspect in selected_aspects)
				aspect.on_grunt_spawned(user, src)
		if("Lieutenant", "Aspirant Lieutenant")
			assign_grunt(lieutenant = user)
			selected_warband?.on_lieutenant_spawned(user, src)
			selected_subtype?.on_lieutenant_spawned(user, src)
			for(var/datum/warbands/aspects/aspect in selected_aspects)
				aspect.on_lieutenant_spawned(user, src)

///////////////////////////////////////////////////
/////////////////////////////////// EQUIP CHARACTER
/*
	equips them w/the provided advclasses
	gives them the baseline Warband traits (at the moment: Battle Ready & No XP)
	makes any aspect tweaks to their stats

*/
/atom/movable/screen/warband/manager/proc/equip_character(datum/advclass/class, datum/advclass/subclass, isleader, mob/living/carbon/human/user)
	user.cmode_music_override = combatmusic
	user.advjob = class.name
	class.equipme(user)
	user.job = class.name

	if(subclass)
		subclass.equipme(user)
		user.job = subclass.name

	if(isleader)
		selected_warband?.on_warlord_equip(user, src)
		selected_subtype?.on_warlord_equip(user, src)
		for(var/datum/warbands/aspects/aspect in selected_aspects)
			aspect.on_warlord_equip(user, src)
	else
		if(linked_faction) // if they aren't the warlord we'll need to add them as a member of the linked faction
			linked_faction.member_names += user.real_name
			if(!(linked_faction in user.mind.associated_factions))
				user.mind.associated_factions += linked_faction
			if(user.mind.special_role == "Lieutenant" || user.mind.special_role == "Aspirant Lieutenant") // and if they're a lieutenant we also give them one of their own
				var/datum/territory_faction/lieu_faction = new /datum/territory_faction()
				lieu_faction.generate_faction(user, stewardhidden = TRUE)
				user.mind.associated_factions |= lieu_faction

	user.faction |= list("[user.real_name]_faction")
	ADD_TRAIT(user, TRAIT_BREADY, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_NO_XP, TRAIT_GENERIC) // we want them doing Literally Anything Else besides farming for skills
	determine_squad_size(user)

//////////////////////////////////////////////////////////////
///////////////////////////////////////////////// ASSIGN GRUNT
/*
	binds lieutenants to grunts and vice versa, depending on who is spawning
	limit of 2 grunts per lieutenant
	
	MODES:
	1. lieutenant provided: when a lieutenant spawns, collect all unassigned grunts. add them to the mind.subordinates list until they hit the cap
	2. grunt provided: when a grunt spawns, find them a lieutenant. add their name to the grunt's mind.warband_recruiter_name entry, and add themselves to the lieutenant's mind.subordinates
	
*/
/atom/movable/screen/warband/manager/proc/assign_grunt(mob/living/carbon/human/lieutenant, mob/living/carbon/human/grunt)
	var/grunts_per_lt = GRUNTS_PER_LIEUTENANT + max(0, (get_active_player_count() - 40) / 15)

	// MODE 1: a lieutenant spawns
	if(lieutenant && !grunt)
		if(!lieutenant.mind)
			return

		if(lieutenant.mind.special_role != "Lieutenant" && lieutenant.mind.special_role != "Aspirant Lieutenant")
			return

		var/list/unassigned_grunts = list()
		for(var/mob/living/carbon/human/member in members)
			if(!member.mind)
				continue
			if(member.mind.special_role == "Grunt" && !member.mind.warband_recruiter_name)
				unassigned_grunts += member
		if(!unassigned_grunts.len)
			to_chat(lieutenant, span_greenteamradio("My subordinates are yet to arrive."))
			return
		
		var/assigned_count = 0
		for(var/mob/living/carbon/human/waiting_grunt in unassigned_grunts)
			if(assigned_count >= grunts_per_lt)
				break
			
			lieutenant.mind.subordinates += waiting_grunt
			waiting_grunt.mind.warband_recruiter_name = lieutenant.real_name
			to_chat(waiting_grunt, span_greenteamradio("My Lieutenant, [lieutenant.real_name], has arrived."))
			to_chat(lieutenant, span_greenteamradio("[waiting_grunt.real_name] is my subordinate."))
			assigned_count++
		return
	
	// MODE 2: a grunt spawns
	if(grunt && !lieutenant)
		if(!grunt.mind || grunt.mind.special_role != "Grunt")
			return
		if(grunt.mind.warband_latespawn)
			return // if they're a latespawn, they should already be given subordinate status by the spawn structure
		var/list/available_lieutenants = list()
		for(var/mob/living/carbon/human/member in members)
			if(!member.mind)
				continue
			if(member.mind.special_role == "Lieutenant" || member.mind.special_role == "Aspirant Lieutenant")
				if(member.mind.subordinates.len < grunts_per_lt)
					available_lieutenants += member
		
		if(!available_lieutenants.len)
			to_chat(grunt, span_greenteamradio("My Lieutenant is yet to arrive."))
			return

		var/mob/living/carbon/human/chosen_lieutenant
		var/lowest_count = 999

		for(var/mob/living/carbon/human/lieu in available_lieutenants)
			var/current_count = lieu.mind.subordinates.len
			if(current_count < lowest_count)
				lowest_count = current_count
				chosen_lieutenant = lieu
		
		if(chosen_lieutenant)
			chosen_lieutenant.mind.subordinates += grunt
			grunt.mind.warband_recruiter_name = chosen_lieutenant.real_name
			to_chat(grunt, span_greenteamradio("[chosen_lieutenant.real_name] is my Lieutenant."))
			to_chat(chosen_lieutenant, span_greenteamradio("[grunt.real_name], my subordinate, has arrived."))
		return

	return

//////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// CHANGE CHARACTER
/*
	changes the client's active character slot
	this is effectively just the 'change character' button in the pref menu

*/
/atom/movable/screen/warband/manager/proc/select_pref_slot(mob/user)
	var/list/choices = list()
	var/datum/preferences/prefs = user.client.prefs

	if(!prefs || !prefs.path)
		return

	var/savefile/S = new /savefile(prefs.path)
	if(!S)
		return

	for(var/i=1, i<=prefs.max_save_slots, i++)
		var/name
		S.cd = "/character[i]"
		S["real_name"] >> name
		if(name) // only show slots with a name saved
			choices["[name] (SLOT [i])"] = i

	if(!choices.len)
		return

	var/choice_slot = input(user, "CHOOSE A HERO", "ROGUETOWN") as null|anything in choices
	if(!choice_slot)
		return

	prefs.load_character(choices[choice_slot])
	return

//////////////////////////////
////////////// LOAD APPEARANCE
/*
	applies the client's active character slot to the current mob

*/ 
/atom/movable/screen/warband/manager/proc/load_appearance(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.client.prefs.copy_to(target)
	target.dna.update_dna_identity()
	statwipe(target)
	GLOB.chosen_names += target.real_name

///////////////////////////////////////////////////////////
///////////////////////////////////////////////// STAT WIPE
/*
	wipes the stats given by preference copying (statpacks, virtue traits, etc)

*/

/atom/movable/screen/warband/manager/proc/statwipe(mob/living/carbon/human/user)
	// skillwipe
	if(!user.skills || !user.skills.known_skills) 
		return 
	user.skills.known_skills = list()
	user.skills.skill_experience = list()

	// traitwipe
	if(user.status_traits) 
		for(var/trait in user.status_traits)
			if(trait != "hearing_sensitive")
				user.status_traits -= trait

	// statwipe
	user.STASTR = 10
	user.STASPD = 10
	user.STACON = 10
	user.STAWIL = 10
	user.STAINT = 10
	user.STAPER = 10

	// spellwipe
	user.actions = list()
	user.mind.RemoveAllSpells()
	if(/mob/living/carbon/human/proc/devotionreport in user.verbs)
		user.verbs -= /mob/living/carbon/human/proc/devotionreport
		user.verbs -= /mob/living/carbon/human/proc/clericpray

/////////////////////////////////////////////////////////////
///////////////////////////////////////////////// GIVE TREATY
/* 
	after a tiny delay, gives recently-spawned warlords & lieutenants a free treaty

*/
/atom/movable/screen/warband/manager/proc/give_treaty(mob/living/carbon/human/user)
	var/user_role = user.mind.special_role
	if(user_role != "Warlord" && user_role != "Lieutenant" && user_role != "Aspirant Lieutenant")
		return
	
	var/obj/item/treaty/new_treaty = new /obj/item/treaty(user.loc)
	new /obj/item/natural/feather(user.loc)
	new_treaty.firstparty = linked_faction.name
	new_treaty.secondparty = "The Crown"
	new_treaty.add_unique_terms(src)
	apply_casus_belli_to_treaty(new_treaty)

	to_chat(user, span_notice("I fetch the Treaty from my bag. If I lose it, I can draft spares from the Campaign Planner."))
	user.playsound_local(src, 'sound/foley/dropsound/gen_drop.ogg', 100, FALSE)

//////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// DETERMINE SQUAD SIZE
/*
	determine the size of the character's NPC squad
	4 by default
	warlords will always receive double the expected squad size

*/
/atom/movable/screen/warband/manager/proc/determine_squad_size(mob/user)
	var/calculated_size = selected_warband?.get_base_squad_size(user) || 4

	calculated_size += squad_size_bonus	// applied before doubling so the warlord's multiplier scales it correctly
 
	if(user.mind.special_role == "Warlord")
		calculated_size *= 2

	user.mind.squad_size = calculated_size

////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// RANDOM CLASSES
/*
	the Random Classes proc for the Wildcard Lieutenant Class

*/
/datum/outfit/job/roguetown/warband/rebellion/lieutenant/wildcard/proc/random_classes()
	var/list/final_class_list = list()
	var/list/all_lieutenant_classes = list()
	var/list/all_warlord_classes = list()
	var/list/excluded_classes = list(
		/datum/advclass/warband/rebellion/lieutenant/wildcard,
		/datum/advclass/warband/mercenary
	)

	for(var/warband_type in WARBANDS)
		var/datum/warbands/warband = new warband_type()
		if(!warband)
			continue

		for(var/lieutenant_type in warband.lieutenantclasses)
			var/excluded = FALSE
			for(var/path in excluded_classes)
				if(ispath(lieutenant_type, path))
					excluded = TRUE
					break
			if(!excluded)
				all_lieutenant_classes += new lieutenant_type
		
		for(var/warlord_type in warband.warlordclasses)
			var/excluded = FALSE
			for(var/path in excluded_classes)
				if(ispath(warlord_type, path))
					excluded = TRUE
					break
			if(!excluded)
				all_warlord_classes += new warlord_type
		
		qdel(warband)

	// roll 3 classes
	// 90% chance for a lieutenant class, 10% for a warlord class
	for(var/i in 1 to 3)
		if(prob(90))
			if(all_lieutenant_classes.len)
				final_class_list += pick(all_lieutenant_classes)
		else
			if(all_warlord_classes.len)
				final_class_list += pick(all_warlord_classes)

	return final_class_list

/datum/outfit/job/roguetown/warband/rebellion/lieutenant/wildcard/pre_equip(mob/living/carbon/human/H)
	..()
	var/list/rolled_classes = random_classes()
	var/datum/advclass/classchoice = input("Choose your class", "WILDCARD") as anything in rolled_classes
	if(istype(classchoice, /datum/advclass))
		classchoice.equipme(H)
