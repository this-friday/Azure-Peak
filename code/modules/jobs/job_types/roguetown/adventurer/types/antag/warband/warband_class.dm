/datum/mind
	COOLDOWN_DECLARE(squad_spawn_cooldown)
	COOLDOWN_DECLARE(treaty_cooldown)

/datum/advclass
	var/title							// name that exclusively appears in class selection
	var/datum/storytellerlimit			// required storyteller influence for the class to be available
	var/rarity							// the required number of storyteller influences before a storyteller-limited class is unlocked
	var/ignore_locks = FALSE			// class ignores an associated warband's faith/racelocks

	var/ignores_uni_class_requirement = FALSE		// when a class is associated with a warband that requires a universal class, this allows them to ignore that
	var/use_subclasses = FALSE

/*
	warbands use two different subclass methods: "Universal Class" and "Subclass"
		CLASSIC SUBCLASS
			- the classic subclass method, where we just rely on a class datum's subtypes
			- a class datum's subtypes are selectable in its class tab
			- flag it with the use_subclasses variable
			- see /datum/advclass/warband/mercenary/warlord/patron for an example

		UNIVERSAL CLASS (formerly "Multiclass")
			- Universal classes are so specific to the Mercenary Warband (/datum/warbands/mercenary) that I can't really see them being used for anything else
			- if you're thinking of adding subclasses, you're almost 100% thinking of the Classic method
			- but for posterity's sake:
				it equips two classes at once
					the first class is taken from the source's primary class lists (warlordclasses/lieutenantclasses/gruntclasses)
					the second class comes from the warband's & subtype's universal class lists

					universal classes mirror the primary shape: one list per role tier (universal_warlordclasses/universal_lieutenantclasses/universal_gruntclasses)
					grunt-tier entries are offered as secondary options to everyone (including Lieutenants and the Warlord)
					warlord/lieutenant-tier entries are only offered to them, replacing the grunt-tier pool for that role

			- requires universal_subclasses_enabled on the WARBAND, plus universal_*classes entries on the warband and/or its subtypes
			- a primary class with its own subclass grants (use_subclasses or a classes list) overrides the universal pool

*/


///////////////////////////////////////////////////////////
///////////////////////////////////////////////// ASSOCIATE
/* 
	the following variables track association & exile status
		warband_exile_IDs 			// given when someone is exiled | it's the ID of their former warband
		warband_recruiter_name		// given when a veteran is spawned, an outsider is associated, or an exiled veteran is associated by a new lieutenant
		allies						// a list in the warband manager that includes each ally

	ASSOCIATE attempts to give the target as many of your faction tags as it can, and add them as an ally
		you should always be able to give someone your personal faction tag ([user.real_name]_faction)
		exiled characters cannot be added as allies, except by the warlord

	exile & associate are split into two different spells, as accidentally doing one when you meant to do the other could be really rough
*/
/obj/effect/proc_holder/spell/invoked/associate
	name = "Associate"
	desc = "Adds or removes a target from the Warband's list of allies."
	overlay_state = "love"
	range = 16
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	antimagic_allowed = TRUE
	recharge_time = 1 SECONDS
	hide_charge_effect = TRUE

/obj/effect/proc_holder/spell/invoked/associate/cast(list/targets, mob/living/carbon/human/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		var/faction_tag = "warband_[user.mind.warband_ID]"
		var/personal_faction_tag = "[user.real_name]_faction"
		var/datum/component/trail_follow/manager = user.GetComponent(/datum/component/trail_follow)

		if(target == user)
			to_chat(user, span_warning("I cannot be further associated with myself than I already am."))
			return FALSE

		if(manager && (target in manager.members))
			to_chat(user, span_warning("[target.name] would follow me to the Underworld and back. Declaring them a mere 'associate' would be an insult."))
			return FALSE

		if(istype(target, /mob/living/simple_animal))
			if(personal_faction_tag in target.faction)
				target.faction -= personal_faction_tag
				to_chat(user, span_warning("I have released the [target.name] from my protection."))
				return TRUE
			else
				target.faction |= personal_faction_tag
				user.say("Leave the [target.name] be.")
				to_chat(user, span_green("My men will ignore the [target.name]."))
				return TRUE

		if(target.mind && target.mind.special_role == ROLE_WARLORD_ENVOY)
			to_chat(user, span_warning("That's an Envoy."))
			return

		if((personal_faction_tag in target.faction))
			to_chat(user, span_warning("They're already associated with me."))
			if(target.mind && (target.real_name in user.mind.unresolved_exile_names)) // if your subordinate got exiled, using Associate on them affirms that you wanna keep 'em as a pal
				user.mind.unresolved_exile_names -= target.real_name
				to_chat(user, span_warning("Since this was in question, I shall make it official."))
				for(var/mob/living/carbon/human/member in user.mind.warband_manager.members) 
					to_chat(member, span_warning("The [user.job], [user.real_name], acts in defiance of [target.real_name]'s decree of exile and has ordered their men to treat [target.real_name] as an associate."))

			return FALSE

		if(target.mind && target.mind.current)
			if(user.mind.warband_ID in target.mind.warband_exile_IDs) // if they're re-associating with an exile (warband ID is found in their exile ID list)
				if(!(target in user.mind.subordinates)) // only do this if they aren't already a subordinate
					// if a lieutenant's the one doing this, they become a personal ally
					if(user.mind.special_role == ROLE_WARLORD_LIEUTENANT || user.mind.special_role == ROLE_WARLORD_ASPIRANT) 
						for(var/mob/living/carbon/human/member in user.mind.warband_manager.members) 
							to_chat(member, span_warning("The [user.job], [user.real_name], acts in defiance of [target.real_name]'s decree of exile and has ordered their men to treat [target.real_name] as an associate."))
						if(!target.mind.warband_recruiter_name)
							target.mind.warband_recruiter_name = user.real_name 
						if(!(target in user.mind.subordinates)) // if they weren't our subordinate we adopt them
							user.mind.subordinates += target
						if(!(personal_faction_tag in target.faction))
							target.faction += personal_faction_tag
						return

					// if the warlord's the one doing this, they become a full ally
					else if(user.mind.special_role == ROLE_WARLORD)
						user.mind.warband_manager.allies += target
						to_chat(user, span_green("I have once again declared [target.name] an ally of our Warband."))
						user.say("Leave that one unharmed.")
						user.linepoint(target)
						return
					return

			if((faction_tag in target.faction))
				to_chat(user, span_warning("They're already associated with us. It'd be pointless."))
				return FALSE

			if(!(faction_tag in target.faction))
				target.faction |= faction_tag
				target.faction |= personal_faction_tag
				user.mind.warband_manager.allies += target

			if(target.mind.special_role && target.mind.warband_ID != user.mind.warband_ID) // if they are an antagonist (and not a warband member), increase disorder
				user.mind.warband_manager.disorder ++
			to_chat(user, span_green("I have declared [target.name] an ally of our Warband."))
			user.say("Leave that one unharmed.")
			user.linepoint(target)
			to_chat(target, span_green("The soldiers of the [user.mind.warband_manager.selected_warband.name] were ordered to leave me unharmed, by decree of their [user.job]."))
			target.mind.warband_recruiter_name = user.real_name // allies are given the recruiter's name as a variable
			for(var/mob/living/warlord in user.mind.warband_manager.members) // warlord should be made aware (unless they're the warlord, in which case they're already aware)
				if(warlord.mind.special_role == ROLE_WARLORD && warlord != user)
					to_chat(warlord, span_warning("Word spreads that [user.real_name], my [user.job], ordered their men to give someone safety within our ranks."))
		else
			to_chat(user, span_warning("We cannot associate ourselves with that."))

			return
		return TRUE
	return FALSE

/obj/effect/proc_holder/spell/invoked/exile
	name = "Exile"
	desc = "Exiles a target from the Warband."
	overlay_state = "curse2"
	range = 16
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	antimagic_allowed = TRUE
	recharge_time = 1 SECONDS
	hide_charge_effect = TRUE

/obj/effect/proc_holder/spell/invoked/exile/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		user.mind.warband_manager.exile(target, user, personal = TRUE)
		return TRUE
	return FALSE


///////////////////////////////////////////////////////
///////////////////////////////////////////////// ORDER
/* 
	give orders to your squad of mobs
	the given order depends on your target

*/
/obj/effect/proc_holder/spell/invoked/grunt_order
	name = "Order Grunts"
	desc = "Commands vary based on your target. \n \
	<span style='color:#e8bf67'>FOLLOW:</span> Target yourself. \n \
	<span style='color:#e8bf67'>CHARGE:</span> Target a tile. \n \
	<span style='color:#e8bf67'>NEUTRAL:</span> Target the COMBAT MODE button. A grunt's neutrality is easily disrupted. \n \
	<span style='color:#e8bf67'>FIGHT HARDER:</span> Target the STRONG INTENT button. (Cooldown) \n \
	<span style='color:#e8bf67'>SURVIVE:</span> Target the DEFEND INTENT button. (Cooldown) \n \
	<span style='color:#e8bf67'>EMERGENCY SUMMON:</span> Target the travel tiles leading to your warband's outskirts. \n \
	<span style='color:#e8bf67'>SHATTER MORALE:</span> Target the SPECIAL INTENT button. (Warlord Only | Large Cooldown)"
	range = 12
	associated_skill = /datum/skill/misc/athletics
	chargedrain = 1
	chargetime = 0 SECONDS
	releasedrain = 0 
	recharge_time = 1 SECONDS
	var/order_range = 12
	overlay_state = "recruit_guard"

/mob/living/carbon/human/proc/end_order_exhaustion()
	if(mind)
		mind.order_exhaustion = FALSE
		to_chat(src, span_userdanger("I am prepared to send out another Special Order."))

/obj/effect/proc_holder/spell/invoked/grunt_order/cast(list/targets, mob/user)
	var/mob/caster = user
	var/target = targets[1]

	// target is an intermission travel tile
	// spawn a squad as if it were a Rally Point
	if(istype(target, /obj/structure/fluff/traveltile/warband/azure_to_intermission) || \
		istype(target, /obj/structure/fluff/traveltile/warband/intermission_to_azure) || \
		istype(target, /obj/structure/fluff/traveltile/warband/outskirts_to_intermission))
		var/obj/structure/fluff/traveltile/warband/tile = target
		tile.summon_grunt_squad_at_tile(caster)
		return TRUE

	// ^ if the caster shares the tile's warband ID, the same can be done for the camp-facing outskirts tile, 
	if(istype(target, /obj/structure/fluff/traveltile/warband/outskirts_to_camp))
		var/obj/structure/fluff/traveltile/warband/outskirts_to_camp/camp_tile = target
		if(caster.mind.warband_ID == camp_tile.warband_ID)
			camp_tile.summon_grunt_squad_at_tile(caster)
			return TRUE
		else
			return FALSE

	// target is the caster
	// grunts follow them
	if(target == caster)
		src.process_grunts(order_type = "follow", target = caster)
		return

	// target is a location
	// grunts move towards the target location while scanning for enemies
	else
		var/turf/target_loc = get_turf(target)
		if(target_loc)
			src.process_grunts(order_type = "charge", target_location = target_loc)
			return TRUE
		else
			to_chat(caster, "They cannot go there.")
			return FALSE

// for targeting hud elements
/obj/effect/proc_holder/spell/invoked/grunt_order/InterceptClickOn(mob/living/caster, params, atom/target)
	if(istype(target, /atom/movable/screen/cmode))
		if(!can_cast(caster) || !cast_check(FALSE, caster))
			return FALSE
		process_grunts(order_type = "neutral")
		start_recharge()
		return TRUE

	if(istype(target, /atom/movable/screen/rmbintent))
		if(!can_cast(caster) || !cast_check(FALSE, caster))
			return FALSE
		if(target.name == "strong")
			process_grunts(order_type = "fight")
		else if(target.name == "defend")
			process_grunts(order_type = "survive")
		start_recharge()
		return TRUE

	// those outside the warband w/o the steelhearted trait get extremely stressed out
	// aura farm (temporarily override combat music for all players within 21 tiles)
	if(istype(target, /atom/movable/screen/quad_intents))
		if(!can_cast(caster) || !cast_check(FALSE, caster))
			return FALSE
		if(caster.mind.order_exhaustion)
			to_chat(caster, span_warning("I've given a special order recently. I'll need to wait."))
			return FALSE
		if(ishuman(caster))
			var/mob/living/carbon/human/H = caster
			if(H.mind && H.mind.special_role == ROLE_WARLORD)
				var/list/horn_sounds = list(
					'sound/misc/warband/warband_warhorn1.ogg',
					'sound/misc/warband/warband_warhorn2.ogg'
				)
				var/chosen_sound = pick(horn_sounds)
				var/sound/S = sound(chosen_sound, repeat = 0, wait = 0, channel = 0, volume = 100) // for those further away / in the upcoming For loop
				playsound(H, chosen_sound, 100, TRUE, 19, pressure_affected = FALSE, ignore_walls = TRUE)
				H.visible_message(span_danger("[H] sounds their warhorn!"))
				var/turf/origin_turf = get_turf(H)
				for(var/mob/living/player in GLOB.player_list) // this feels weird but it's how regular warhorns do it so i guess it's cool
					if(player.stat == DEAD)
						continue
					if(isbrain(player))
						continue
					if(player == H)
						continue

					var/distance = get_dist(player, origin_turf)
					if(distance > 40)
						continue

					if(distance > 7)
						var/dirtext = " to the "
						var/direction = get_dir(player, origin_turf)
						switch(direction)
							if(NORTH)
								dirtext += "north"
							if(SOUTH)
								dirtext += "south"
							if(EAST)
								dirtext += "east"
							if(WEST)
								dirtext += "west"
							if(NORTHWEST)
								dirtext += "northwest"
							if(NORTHEAST)
								dirtext += "northeast"
							if(SOUTHWEST)
								dirtext += "southwest"
							if(SOUTHEAST)
								dirtext += "southeast"
							else
								dirtext = ", although I cannot make out an exact direction"
						
						SEND_SOUND(player, S)
						to_chat(player, span_warning("I hear a warhorn somewhere [dirtext]."))
				
					// music override
					if(ishuman(player))
						var/mob/living/carbon/human/P = player
						if(P.cmode_music_override != H.mind.warband_manager.combatmusic)
							if(!P.cmode_music_override || P.cmode_music_override.len <= 0)
								P.originalcmode = P.cmode_music
							else if(!P.originalcmode) // if something's already overriding the music, we'll leave it alone
								P.originalcmode = P.cmode_music_override
							P.cmode_music_override = H.mind.warband_manager.combatmusic
							addtimer(CALLBACK(P, TYPE_PROC_REF(/mob/living/carbon/human, restore_original_cmode_music)), 5 MINUTES)
						if(!HAS_TRAIT(P, TRAIT_STEELHEARTED) && P.mind.warband_ID != H.mind.warband_ID && !(P in H.mind.warband_manager.allies))
							P.add_stress(/datum/stressevent/warband_warhorn) // allies & the steelhearted are exempt from the stress hit

				// temporarily removes the Underwhelming trait from every nearby goon
				for(var/mob/living/carbon/officer in H.mind.warband_manager.members)
					if(IS_WARBAND_OFFICER(officer.mind))
						var/datum/component/trail_follow/officer_manager = officer.GetComponent(/datum/component/trail_follow)
						if(!officer_manager)
							officer_manager = officer.AddComponent(/datum/component/trail_follow)
						for(var/mob/living/carbon/human/species/human/northern/goon/follower_npc in officer_manager.members)
							if(follower_npc.stat != CONSCIOUS || follower_npc.warband_ID != H.mind.warband_ID)
								continue // skip them if they're unconscious or swapped warbands
							if(get_dist(follower_npc, origin_turf) > 40)
								continue // skip them if they're too far away
							REMOVE_TRAIT(follower_npc, TRAIT_UNDERWHELMING, TRAIT_GENERIC)
							addtimer(CALLBACK(follower_npc, TYPE_PROC_REF(/mob/living/carbon/human/species/human/northern/goon, become_underwhelming)), 60 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

				caster.mind.order_exhaustion = TRUE
				addtimer(CALLBACK(caster, TYPE_PROC_REF(/mob/living/carbon/human, end_order_exhaustion)), 25 MINUTES)
				start_recharge()
				return TRUE
		return FALSE

	else
		return ..()

/obj/effect/proc_holder/spell/invoked/grunt_order/proc/process_grunts(order_type, turf/target_location = null, mob/living/target = null)
	var/mob/living/carbon/human/caster = usr
	var/count = 0
	var/msg = ""
	var/cooldown = FALSE

	if((order_type == "fight" || order_type == "survive") && caster.mind.order_exhaustion)
		to_chat(caster, span_warning("I've given a special order recently. I'll need to wait."))
		return

	var/datum/component/trail_follow/manager = caster.GetComponent(/datum/component/trail_follow)
	if(!manager)
		manager = caster.AddComponent(/datum/component/trail_follow)

	for(var/mob/other_mob in manager.members)
		if(!other_mob)
			manager.members -= other_mob
			continue
		if(get_dist(caster, other_mob) >= 15)
			continue
		if(istype(other_mob, /mob/living/carbon/human/species/human/northern/goon) && !other_mob.client)
			var/mob/living/carbon/human/species/human/northern/goon/grunt = other_mob
			if(grunt.ai_controller?.blackboard[BB_BASIC_MOB_FLEEING])
				continue
			if(grunt.stat != CONSCIOUS)
				continue

			count += 1
			switch(order_type)
				if("charge")
					manager.clear_followers()
					grunt.pet_passive = FALSE
					grunt.ai_controller?.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
					grunt.ai_controller?.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)
					if(grunt.ai_controller?.blackboard[BB_MOB_AGGRO_TABLE])
						grunt.ai_controller.blackboard[BB_MOB_AGGRO_TABLE] = list()
					grunt.ai_controller?.CancelActions()
					grunt.ai_controller?.set_blackboard_key(BB_TRAVEL_DESTINATION, get_turf(target_location))
					msg = "<span style='color:#ec3333'>charge.</span>"
		
				if("follow")
					manager.add_follower(grunt)	// adds to both members and followers
					msg = "<span style='color:#57536e'>follow me.</span>"
					
				if("neutral")
					manager.clear_followers()
					grunt.pet_passive = TRUE
					grunt.ai_controller?.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
					grunt.ai_controller?.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)
					grunt.ai_controller?.clear_blackboard_key(BB_TRAVEL_DESTINATION)
					if(grunt.ai_controller?.blackboard[BB_MOB_AGGRO_TABLE])
						grunt.ai_controller.blackboard[BB_MOB_AGGRO_TABLE] = list()
					grunt.ai_controller?.CancelActions()
					msg = "<span style='color:#747474'>stand at ease.</span>"

				if("fight")
					cooldown = TRUE
					grunt.pet_passive = FALSE
					grunt.apply_status_effect(/datum/status_effect/buff/warband_attack)
					msg = "<span style='color:#ff0000'>give 'em hell.</span>"
					
				if("survive")
					cooldown = TRUE
					grunt.pet_passive = FALSE
					grunt.apply_status_effect(/datum/status_effect/buff/warband_defend)
					msg = "<span style='color:#ea76d9'>hold fast.</span>"

	if(count>0)
		to_chat(caster, "I've ordered [count] grunts to " + msg)
		if(cooldown)
			caster.mind.order_exhaustion = TRUE
			addtimer(CALLBACK(caster, TYPE_PROC_REF(/mob/living/carbon/human, end_order_exhaustion)), 16 MINUTES)

		if(order_type == "survive")
			var/list/horn_sounds = list(
				'sound/misc/warband/defendhorn_1.ogg',
				'sound/misc/warband/defendhorn_2.ogg'
			)
			var/chosen_sound = pick(horn_sounds)
			playsound(caster, chosen_sound, 100, TRUE, 19, pressure_affected = FALSE, ignore_walls = TRUE)
			caster.visible_message(span_danger("[caster] bellows a slow, cautious tone with their warhorn!"))
		if(order_type == "fight")
			var/list/horn_sounds = list(
				'sound/misc/warband/attackhorn_1.ogg',
				'sound/misc/warband/attackhorn_2.ogg'
			)
			var/chosen_sound = pick(horn_sounds)
			playsound(caster, chosen_sound, 100, TRUE, 19, pressure_affected = FALSE, ignore_walls = TRUE)
			caster.visible_message(span_danger("[caster] signals an assault with a harsh, heavy warhorn!"))
	else
		to_chat(caster, "We weren't able to order anyone.")
