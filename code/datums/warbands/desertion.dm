/////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// ABANDON WARBAND
/*
	handles both desertions & exiles

	WHO GETS WHAT IN THE DIVORCE:
		everyone the deserter marked as an ally shifts factions w/them
		the deserter's subordinates shift factions w/them

*/
/mob/living/carbon/human/proc/desert()
	set name = "DESERT WARBAND"
	set category = "RoleUnique.Warband"

	if(stat == DEAD)
		to_chat(src, span_boldred("It's too late..."))
		return FALSE
	abandon_warband(FALSE, FALSE, FALSE)

/mob/living/carbon/human/proc/abandon_warband(kicked = FALSE, grunt_kick = FALSE, autoresolve = FALSE)
	var/disorder = mind.warband_manager.disorder
	var/initial_ID = mind.warband_ID
	var/old_faction_string = "warband_[mind.warband_ID]"

	var/troops_available = mind.warband_manager.spawns

	var/stolen_troop_percentage
	if(mind.special_role == ROLE_WARLORD_ASPIRANT) // aspirant rebellions are done to greater effect
		stolen_troop_percentage = 30
	else
		stolen_troop_percentage = 3

	// each point of disorder increases the number of stolen troops by 15%
	stolen_troop_percentage += (disorder * 15)

	var/stolen_troops = round((troops_available * stolen_troop_percentage) / 100)

	if(grunt_kick) // if a grunt is kicked
		for(var/mob/living/bossman in mind.warband_manager.members)
			if(isliving(bossman))
				to_chat(bossman, span_boldred("Word spreads that [real_name], our [job], has been exiled."))
				bossman.playsound_local(bossman, 'sound/misc/warband/exile_warhorn_altb.ogg', 80, FALSE, pressure_affected = FALSE)
			if(bossman.real_name == mind.warband_recruiter_name)
				if(!autoresolve) // if we're autoresolving, their direct boss is the one who exiled them, so we can skip past this as they don't need to be alerted
					bossman.mind.unresolved_exile_names += real_name
					to_chat(bossman, span_warning("My subordinate, [real_name], has been branded an exile by my Warband. I can resolve this (RESOLVE EXILES in the Warband Tab)"))
		to_chat(src, span_boldred("I have been exiled from the Warband."))
		faction.Remove(old_faction_string)
		faction -= list("warband_[initial_ID]")
		mind.warband_manager.members -= src
		mind.warband_manager = null
		mind.warband_ID = 0
		mind.warband_exile_IDs += initial_ID
		return

	// if they weren't kicked, they're manually deserting
	if(!kicked) // allows them to Go Out In Style (make an announcement)
		manual_desertion(stolen_troops, troops_available, old_faction_string, initial_ID)

	else // if they WERE kicked
		to_chat(src, span_userdanger("I have been declared an exile by my Warband."))
		verbs -= /mob/living/carbon/human/proc/desert
		mind.warband_exile_IDs += initial_ID
		for(var/mob/warband_member in src.mind.warband_manager.members)
			if(isliving(warband_member))
				to_chat(warband_member, span_boldred("Word spreads that [src.real_name], our [src.job], has been exiled. [stolen_troops] of our rank-and-file \
				have deserted to accompany them."))
				warband_member.playsound_local(warband_member, 'sound/misc/warband/exile_warhorn_altb.ogg', 100, FALSE, pressure_affected = FALSE)
		desertion_results(stolen_troops, troops_available, old_faction_string, initial_ID)
		return
	return TRUE

// desertion w/announcement
/mob/living/carbon/human/proc/manual_desertion(stolen_troops, troops_available, old_faction_string, initial_ID)
	var/calltext = tgui_input_text(src, "You are preparing to DESERT your Warband. This will be a public declaration. What will you say?", "DESERTION")
	if(!calltext)
		return
	visible_message(span_boldred("[src] blows into a warhorn!"))
	priority_announce("The [job] has deserted the [mind.warband_manager.selected_warband.name] accompanied by around [stolen_troops] of their rank-and-file. \
	Their words of departure are rumored to be as follows:\n \n [calltext]", title = "WORD SPREADS OF DESERTION", sound = 'sound/misc/warband/exile_warhorn_altb.ogg', sender = src, receiver = /mob/living/carbon/human)
	// if this being a round-wide announcement would be too annoying, it could be restricted to only display to warband members
	// but atm i think it'd be fun to let everyone in on the drama

	if(mind.warband_ID != initial_ID) // if the initial ID doesn't match, they likely got kicked while they were preparing the message
		to_chat(src, span_userdanger("I've already been exiled."))
		return
	desertion_results(stolen_troops, troops_available, old_faction_string, initial_ID)

// effects of desertion take place
/mob/living/carbon/human/proc/desertion_results(stolen_troops, troops_available, old_faction_string, initial_ID)
	var/extra_item = FALSE	// for schism variants
	var/datum/component/trail_follow/squad_manager = GetComponent(/datum/component/trail_follow)
	if(!squad_manager)
		squad_manager = AddComponent(/datum/component/trail_follow)
	troops_available = mind.warband_manager.spawns // reaffirm the available troops | could've changed while a manual desertion message was being typed
	if(stolen_troops > troops_available)
		stolen_troops = troops_available
	mind.warband_manager.spawns -= stolen_troops

	mind.warband_manager.members -= src

	var/datum/warband_manager/new_warband_manager
	new_warband_manager = new /datum/warband_manager
	new_warband_manager.schism_level = mind.warband_manager.schism_level + 1
	mind.special_role = ROLE_WARLORD
	SSmapping.retainer.warlords |= mind
	SSwarbands.register_manager(new_warband_manager)
	mind.warband_ID = new_warband_manager.warband_ID
	mind.warband_exile_IDs += initial_ID
	mind.warband_manager.disorder ++

	faction.Remove(old_faction_string)
	faction |= list("warband_[mind.warband_ID]")

	var/datum/treaty_flavor/personal_faction
	for(var/datum/treaty_flavor/faction in mind.associated_factions)
		if(faction.owner == real_name)
			personal_faction = faction
			break

	if(personal_faction)
		new_warband_manager.linked_faction = personal_faction

	for(var/mob/living/carbon/human/species/human/northern/goon/goon in squad_manager.members)
		goon.faction.Remove(old_faction_string)
		goon.faction |= list("warband_[mind.warband_ID]")
		goon.warband_ID = mind.warband_ID
	
	new_warband_manager.members += src

	switch(advjob) // ideally it'd be fun to give each Feud lieutenant their own schism path, but we don't have enough bands for this atm
		if("Preacher") // a preacher in schism creates a sect
			new_warband_manager.selected_warband = new /datum/warbands/sect
			if(patron.type in ALL_DIVINE_PATRONS)
				new_warband_manager.selected_subtype = new WARBAND_SECT_TEN
			else if(patron.type in ALL_INHUMEN_PATRONS)
				new_warband_manager.selected_subtype = new WARBAND_SECT_FOUR
			else if(patron.name == "Psydon")
				new_warband_manager.selected_subtype = new WARBAND_SECT_PSYDON
			new_warband_manager.faithlocks = list(patron.type)
			verbs += /mob/living/carbon/human/proc/enlighten

		if("Magician") // a magician in schism (potentially) creates a sorcerer-king 
			if(mind.warband_manager.disorder >= 5)
				for(var/obj/item/equipped_item in get_equipped_items() + held_items)
					if(istype(equipped_item, /obj/item/rogueweapon/woodstaff/implement/grand))
						extra_item = TRUE
			if(extra_item == TRUE)
				new_warband_manager.selected_warband = new /datum/warbands/wizard
				to_chat(src, span_boldred("I feel a shift in destiny's tides with my declaration. <span style='color:#801d1d'>The Wandering Tower calls to me.</span>"))
			else
				new_warband_manager.selected_warband = mind.warband_manager.selected_warband
				new_warband_manager.selected_subtype = mind.warband_manager.selected_subtype
		else
			new_warband_manager.selected_warband = mind.warband_manager.selected_warband
			new_warband_manager.selected_subtype = mind.warband_manager.selected_subtype

	for(var/mob/living/subordinate in mind.subordinates) // bring along associated grunts
		to_chat(subordinate, span_boldred("My Lieutenant has embraced open rebellion. My relations with the [src.mind.warband_manager.selected_warband.name] are in tatters."))
		subordinate.faction.Remove(old_faction_string)
		subordinate.faction |= list("warband_[src.mind.warband_ID]")
		subordinate.mind.warband_manager = new_warband_manager
		subordinate.mind.warband_ID = new_warband_manager.warband_ID
		subordinate.mind.warband_exile_IDs += initial_ID
		mind.warband_manager.members -= subordinate
		new_warband_manager.members += subordinate

	for(var/mob/living/ally in mind.warband_manager.allies)	// bring along associated allies
		if(ally.mind.warband_recruiter_name == real_name)
			if(ally.mind.special_role) // if they were an antagonist, bring their disorder over to the new warband. They're your problem now, Bro.
				mind.warband_manager.disorder --
				new_warband_manager.disorder ++
			to_chat(ally, span_boldred("The one who swore I'd be unharmed by the [mind.warband_manager.selected_warband.name] has embraced open rebellion. \
			I should assume my accord with their former allies is to be forgotten."))
			ally.faction.Remove(old_faction_string)
			ally.faction |= list("warband_[mind.warband_ID]")
			mind.warband_manager.allies -= ally
			new_warband_manager.allies += ally
	new_warband_manager.spawns -= WARBAND_BASE_RESPAWNS	// we want their respawns to ONLY!! be drawn from the number of stolen troops
	new_warband_manager.spawns += stolen_troops
	new_warband_manager.finalized = TRUE
	new_warband_manager.creation_stage = 3
	new_warband_manager.warlord_spawned = TRUE
	new_warband_manager.stop_creation_timer()
	if(new_warband_manager.has_compatible_cache(mind.warband_manager))
		new_warband_manager.share_cache_with(mind.warband_manager)
	verbs -= /mob/living/carbon/human/proc/desert
	verbs += /mob/living/carbon/human/proc/connect_warcamp
	mind.warband_manager = new_warband_manager
	mind.warband_manager.determine_squad_size(src)
