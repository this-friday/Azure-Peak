/datum/antagonist/warband/lieutenant
	var/aspirant = FALSE
	name = "Lieutenant"
	roundend_category = "Warlord"
	antagpanel_category = "Warlord"
	job_rank = ROLE_WARLORD_LIEUTENANT
	is_lieutenant = TRUE
	confess_lines = list(
		"A WAR IN THEIR NAME!",
		"I HAVE SERVED FAITHFULLY!",
		"IT WAS MY DUTY!",
	)
	rogue_enabled = TRUE

/datum/antagonist/warband/grunt
	name = "Grunt"
	roundend_category = "Warlord"
	antagpanel_category = "Warlord"
	job_rank = ROLE_WARLORD_GRUNT
	confess_lines = list(
		"THIS LAND MUST BURN!",
		"IT IS NOT MY WILL!",
		"M'LOOOOOOOOOOOOOOOOOOOOOOOOORD!!", // why are you torturing a grunt, bro. Wtf
	)
	rogue_enabled = TRUE

/datum/antagonist/warband/lieutenant/get_replacement_name()
	return unique_number ? "Lieutenant #[unique_number]" : "Lieutenant"

/datum/antagonist/warband/grunt/get_replacement_name()
	return unique_number ? "Grunt #[unique_number]" : "Grunt"

/datum/antagonist/warband/lieutenant/post_spawn_setup()
	aspirant_roll()

/datum/antagonist/warband/lieutenant/proc/aspirant_roll()
	var/final_aspirant_chance = 50
	if(owner.warband_manager)
		var/atom/movable/screen/warband/manager/source_warband_manager = owner.warband_manager
		final_aspirant_chance = source_warband_manager.aspirant_chance
	if(prob(final_aspirant_chance))
		aspirant = TRUE
	return

///////////////
///////////////
///////////////
/datum/antagonist/warband/lieutenant/greet()
	..()
	if(aspirant)
		owner.special_role = "Aspirant Lieutenant"
		to_chat(owner.current, span_userdanger("I mustn't forget myself. My service is simply a means to an end."))
		var/atom/movable/screen/introtext/aspirant/intro_text = new /atom/movable/screen/introtext/aspirant
		var/list/intro_sounds = list(
			'sound/misc/warband/selection_introc.ogg'
		)
		var/chosen_song = pick(intro_sounds)
		var/sound/S = sound(chosen_song, repeat = 0, wait = 0, channel = 0, volume = 90)
		SEND_SOUND(owner.current, S)
		owner.current.playsound_local(owner.current, chosen_song, 100, FALSE, pressure_affected = FALSE)
		owner.current.client.screen += intro_text
		animate(intro_text, alpha = 255, time = 50)
		forge_objectives()
		return
	owner.special_role = name
	to_chat(owner.current, span_userdanger("My Warlord calls upon my service."))
	var/list/intro_sounds = list(
		'sound/misc/warband/selection_introc.ogg'
	)
	var/chosen_song = pick(intro_sounds)
	var/sound/S = sound(chosen_song, repeat = 0, wait = 0, channel = 0, volume = 60)
	SEND_SOUND(owner.current, S)
	var/atom/movable/screen/introtext/lieutenant/intro_text = new /atom/movable/screen/introtext/lieutenant
	owner.current.client.screen += intro_text
	animate(intro_text, alpha = 255, time = 50)
	forge_objectives()

/datum/antagonist/warband/grunt/greet()
	..()
	owner.special_role = name
	to_chat(owner.current, span_userdanger("My Lieutenant calls upon my service."))
	var/list/intro_sounds = list(
		'sound/misc/warband/selection_introc.ogg'
	)
	var/chosen_song = pick(intro_sounds)
	var/sound/S = sound(chosen_song, repeat = 0, wait = 0, channel = 0, volume = 60)
	SEND_SOUND(owner.current, S)
	var/atom/movable/screen/introtext/veteran/intro_text = new /atom/movable/screen/introtext/veteran
	owner.current.client.screen += intro_text
	animate(intro_text, alpha = 255, time = 50)

/datum/antagonist/warband/lieutenant/proc/forge_objectives(envy_reroll = FALSE)
	if(!envy_reroll)
		var/datum/objective/warband/aspirant/greatergood/base_objective = new
		base_objective.owner = owner
		objectives += base_objective

	if(aspirant)
		var/list/aspirant_objectives = list(
			/datum/objective/warband/aspirant/wormtongue,
			/datum/objective/warband/aspirant/disorder,
			/datum/objective/warband/aspirant/order,
			/datum/objective/warband/aspirant/standard,
			/datum/objective/warband/aspirant/coin
		)
		if(envy_reroll)
			for(var/datum/objective/existing_obj in objectives)
				for(var/obj_type in aspirant_objectives)
					if(istype(existing_obj, obj_type))
						aspirant_objectives -= obj_type
						break
		var/chosen_type = pick(aspirant_objectives)
		var/datum/objective/warband/aspirant/aspirant_objective = new chosen_type
		aspirant_objective.owner = owner
		objectives += aspirant_objective
	if(!envy_reroll)
		owner.announce_objectives()
