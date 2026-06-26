
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
	8 - DETERMINE SQUAD SIZE	// decide the size of a character's NPC squad

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
/datum/warband_manager/proc/spawn_character(classpath, mob/user, subclasspath, is_leader, is_latespawn = FALSE)
	if(!ispath(classpath, /datum/advclass))
		classpath = /datum/advclass/warband/standard/grunt/veteran // fallback to John Soldier if we're missing a classpath
	if(subclasspath && !ispath(subclasspath, /datum/advclass))
		subclasspath = null
	if(warband_class_for(classpath) && initial(classpath:ignores_uni_class_requirement))
		subclasspath = null
	var/datum/advclass/class_path = new classpath()
	var/datum/advclass/subclass_path = subclasspath ? new subclasspath() : null

	// record the picks against the warband's slot limits (maximum_possible_slots)
	taken_class_counts[classpath] += 1
	if(subclasspath)
		taken_class_counts[subclasspath] += 1

	var/role = user.mind.special_role
	var/is_lieutenant = (role == ROLE_WARLORD_LIEUTENANT || role == ROLE_WARLORD_ASPIRANT)

	if(is_leader)
		var/turf/warlord_landmark_turf
		for(var/obj/effect/landmark/start/warlordlate/warlord_spawn in GLOB.landmarks_list)
			warlord_landmark_turf = get_turf(warlord_spawn)
			user.forceMove(warlord_spawn.loc)
			qdel(warlord_spawn)
			break

		// no warcamp was loaded, so there's no warlord landmark
		if(!warlord_landmark_turf && warband_spawn_turf)
			user.forceMove(warband_spawn_turf)

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

		// prefer the nearest rally point, then the warlord landmark, then a field spawn turf already set by choose_map
		warband_spawn_turf = nearest_rally ? get_turf(nearest_rally) : (warlord_landmark_turf || warband_spawn_turf)
	else if(!is_latespawn)
		user.forceMove(warband_spawn_turf)

	for(var/mob/living/carbon/human/important_figure in importantfigures)
		user.mind.i_know_person(important_figure.mind)

	for(var/mob/living/carbon/human/pal in members)
		user.mind.i_know_person(pal.mind)
		user.mind.person_knows_me(pal.mind)

	equip_character(class_path, subclass_path, is_leader, user)

	user.faction |= list("warband_[warband_ID]")
	add_verb(user, /mob/living/carbon/human/proc/shortcut)
	add_verb(user, /mob/living/carbon/human/proc/communicate)
	REMOVE_TRAIT(user, TRAIT_FORCED_LOBBY_CHAT, TRAIT_GENERIC)
	members += user
	user.nutrition = NUTRITION_LEVEL_FULL
	user.hydration = HYDRATION_LEVEL_FULL

	if(is_leader || is_lieutenant)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/exile)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/associate)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/grunt_order)
		addtimer(CALLBACK(src, PROC_REF(give_treaty), user), 10 SECONDS)
		if(is_lieutenant)
			add_verb(user, /mob/living/carbon/human/proc/desert)
			add_verb(user, /mob/living/carbon/human/proc/accept_kick)

	switch(role)
		if(ROLE_WARLORD_GRUNT)
			assign_grunt(grunt = user)
			selected_warband?.on_grunt_spawned(user, src)
			selected_subtype?.on_grunt_spawned(user, src)
			for(var/datum/warbands/aspects/aspect in selected_aspects)
				aspect.on_grunt_spawned(user, src)
		if(ROLE_WARLORD_LIEUTENANT, ROLE_WARLORD_ASPIRANT)
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
/datum/warband_manager/proc/equip_character(datum/advclass/class, datum/advclass/subclass, isleader, mob/living/carbon/human/user)
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
			if(user.mind.special_role == ROLE_WARLORD_LIEUTENANT || user.mind.special_role == ROLE_WARLORD_ASPIRANT) // and if they're a lieutenant we also give them one of their own
				var/datum/treaty_flavor/lieu_faction = new /datum/treaty_flavor()
				lieu_faction.generate_faction(user, stewardhidden = TRUE)
				user.mind.associated_factions |= lieu_faction

	user.faction |= list("[user.real_name]_faction")
	ADD_TRAIT(user, TRAIT_BREADY, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_NO_XP, TRAIT_GENERIC) // we want them doing Literally Anything Else besides farming for skills
	determine_squad_size(user, class)

//////////////////////////////////////////////////////////////
///////////////////////////////////////////////// ASSIGN GRUNT
/*
	binds lieutenants to grunts and vice versa, depending on who is spawning
	limit of 2 grunts per lieutenant
	
	MODES:
	1. lieutenant provided: when a lieutenant spawns, collect all unassigned grunts. add them to the mind.subordinates list until they hit the cap
	2. grunt provided: when a grunt spawns, find them a lieutenant. add their name to the grunt's mind.warband_recruiter_name entry, and add themselves to the lieutenant's mind.subordinates
	
*/
/datum/warband_manager/proc/assign_grunt(mob/living/carbon/human/lieutenant, mob/living/carbon/human/grunt)
	var/grunts_per_lt = warband_grunts_per_lieutenant()

	// MODE 1: a lieutenant spawns
	if(lieutenant && !grunt)
		if(!lieutenant.mind)
			return

		if(lieutenant.mind.special_role != ROLE_WARLORD_LIEUTENANT && lieutenant.mind.special_role != ROLE_WARLORD_ASPIRANT)
			return

		var/list/unassigned_grunts = list()
		for(var/mob/living/carbon/human/member in members)
			if(!member.mind)
				continue
			if(member.mind.special_role == ROLE_WARLORD_GRUNT && !member.mind.warband_recruiter_name)
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
		if(!grunt.mind || grunt.mind.special_role != ROLE_WARLORD_GRUNT)
			return
		if(grunt.mind.warband_latespawn)
			return // if they're a latespawn, they should already be given subordinate status by the spawn structure
		var/list/available_lieutenants = list()
		for(var/mob/living/carbon/human/member in members)
			if(!member.mind)
				continue
			if(member.mind.special_role == ROLE_WARLORD_LIEUTENANT || member.mind.special_role == ROLE_WARLORD_ASPIRANT)
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
/datum/warband_manager/proc/select_pref_slot(mob/user)
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

	var/choice_slot = tgui_input_list(user, "CHOOSE A HERO", "ROGUETOWN", choices)
	if(!choice_slot)
		return

	prefs.load_character(choices[choice_slot])
	return

//////////////////////////////
////////////// LOAD APPEARANCE
/*
	applies the client's active character slot to the current mob

*/ 
/datum/warband_manager/proc/load_appearance(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/client/source = user?.client || target?.client
	if(!source?.prefs)
		return
	source.prefs.copy_to(target)
	target.dna.update_dna_identity()
	target.hud_used?.zone_select?.update_icon()
	statwipe(target)
	GLOB.chosen_names += target.real_name

///////////////////////////////////////////////////////////
///////////////////////////////////////////////// STAT WIPE
/*
	wipes the stats given by preference copying (statpacks, virtue traits, etc)

*/

/datum/warband_manager/proc/statwipe(mob/living/carbon/human/user)
	// skillwipe
	if(!user.skills || !user.skills.known_skills)
		return
	user.skills.known_skills = list()
	user.skills.skill_experience = list()

	// traitwipe
	if(user.status_traits)
		for(var/trait in user.status_traits)
			if(trait == "hearing_sensitive")
				continue
			if(!user.status_traits)
				break
			var/list/trait_sources = user.status_traits[trait]
			if(!trait_sources)
				continue
			for(var/source in trait_sources)
				REMOVE_TRAIT(user, trait, source)

	// statwipe
	user.STASTR = 10
	user.STASPD = 10
	user.STACON = 10
	user.STAWIL = 10
	user.STAINT = 10
	user.STAPER = 10
	user.STALUC = 10

	// spellwipe
	user.actions = list()
	user.mind.RemoveAllSpells()
	if(/mob/living/carbon/human/proc/devotionreport in user.verbs)
		remove_verb(user, /mob/living/carbon/human/proc/devotionreport)
		remove_verb(user, /mob/living/carbon/human/proc/clericpray)

/////////////////////////////////////////////////////////////
///////////////////////////////////////////////// GIVE TREATY
/* 
	after a tiny delay, gives recently-spawned warlords & lieutenants a free treaty

*/
/datum/warband_manager/proc/give_treaty(mob/living/carbon/human/user)
	if(!user || !user.mind)
		return
	if(!IS_WARBAND_OFFICER(user.mind))
		return
	if(!linked_faction)
		return
	
	var/obj/item/treaty/new_treaty = new /obj/item/treaty(user.loc)
	new /obj/item/natural/feather(user.loc)
	new_treaty.firstparty = linked_faction.name
	new_treaty.secondparty = "The Crown"
	new_treaty.set_warband_source(src)
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
/datum/warband_manager/proc/determine_squad_size(mob/user, datum/advclass/primary_class)
	var/calculated_size = selected_warband?.get_base_squad_size(user, primary_class) || 4

	calculated_size += squad_size_bonus	// applied before doubling so the warlord's multiplier scales it correctly
 
	if(user.mind.special_role == ROLE_WARLORD)
		calculated_size *= 2

	user.mind.squad_size = calculated_size
