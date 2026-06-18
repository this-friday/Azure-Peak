/mob/living/carbon/human/species/human/northern/goon
	ai_controller = /datum/ai_controller/human_npc/melee/goon
	ambushable = FALSE
	dodgetime = 30
	d_intent = INTENT_PARRY
	faction = list() // we don't want to start w/the 'neutral' faction
	var/warband_ID
	var/datum/warbands/warband
	var/datum/warbands/subtypes/subtype
	var/static/list/abandon_textoptions = list("succumbs to an old infection - collapsing first to their knees, then crashing down face first.", "succumbs to the elements.", "goes pale and faints soon afterwards. Their breath stills.", "is lost to a hunger long unsated. They die thin and frail.")
	var/mob/squad_leader

	// when a grunt is equipped, we cache the type of any item that can be disarmed/dismembered from them (gloves, weapons etc)
	// when they're recycled, we regenerate those items and only those items
	// thus, we can have them be partially lootable while still being able to recycle them properly
	var/saved_r_weapon
	var/saved_l_weapon
	var/saved_mask
	var/saved_neck
	var/saved_head
	var/saved_gloves
	var/saved_shoes
	var/saved_mouth

/mob/living/carbon/human/species/human/northern/goon/is_hostile_mouseover(mob/viewer)
	return TRUE

// used when a grunt squad is cleared out
/mob/living/carbon/human/species/human/northern/goon/proc/abandonevent()
	if(stat == CONSCIOUS || stat == SOFT_CRIT || stat == UNCONSCIOUS)
		adjustOxyLoss(200)
		adjustToxLoss(200)
		var/abandon_message = pick(abandon_textoptions)
		visible_message(span_info("[src] [abandon_message]"))
		addtimer(CALLBACK(src, PROC_REF(rot_event)), rand(1 MINUTES, 12 MINUTES))
	else
		rot_event()

/mob/living/carbon/human/species/human/northern/goon/proc/rot_event()
	visible_message(span_info("[src]'s corpse is taken by the Rot."))
	new /obj/effect/decal/remains/human(src.loc)
	recycle()

// killed by ocean & sewer tiles, so the warband's avenues of attack are limited
/mob/living/carbon/human/species/human/northern/goon/proc/drownevent()
	emote("agony", forced = TRUE)
	visible_message(span_warning("[src] thrashes and flails in the water, drowning under the weight of their gear!"))
	addtimer(CALLBACK(src, PROC_REF(drown_followup)), 3 SECONDS)

/mob/living/carbon/human/species/human/northern/goon/proc/drown_followup()
	adjustOxyLoss(200)
	adjustToxLoss(200)

/mob/living/carbon/human/species/human/northern/goon/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(after_creation)), 1 SECONDS)

/mob/living/carbon/human/species/human/northern/goon/Destroy()
	if(squad_leader)
		var/datum/component/trail_follow/squad = squad_leader.GetComponent(/datum/component/trail_follow)
		if(squad)
			squad.remove_follower(src, wake = FALSE)
			squad.members -= src
	squad_leader = null
	saved_mask = null
	saved_neck = null
	saved_head = null
	saved_gloves = null
	saved_shoes = null
	saved_r_weapon = null
	saved_l_weapon = null
	warband = null
	subtype = null
	..()
	// it looks like complex mobs hard delete themselves. this happens so far back in the inheritance chain that i'm just completely lost
	// if that's ever made to Not Be The Case this harddel hint should probably be removed
	return QDEL_HINT_HARDDEL

// costs roughly the same CPU as equipping a mob
// but we're still avoiding hard deleting OR creating a fresh mob, so this is ok. i think. yeah it's fine
/mob/living/carbon/human/species/human/northern/goon/proc/recycle()
	fully_heal(admin_revive = TRUE)
	revive(FALSE, TRUE)
	ADD_TRAIT(src, TRAIT_UNDERWHELMING, TRAIT_GENERIC) // restore it if an outskirts deployment (or anything else) stripped it
	full_repair()
	if(ai_controller)
		ai_controller.can_idle = TRUE
		ai_controller.set_ai_status(AI_STATUS_OFF)
		ai_controller.set_movement_target(ai_controller.type, null)
		ai_controller.movement_path = null
		ai_controller.movement_target_source = null
		ai_controller.clear_blackboard_key(BB_OUTSKIRTS_OBJECTIVE_REF)		
		ai_controller.clear_blackboard_key(BB_OUTSKIRTS_CACHED_PATH)
		ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		ai_controller.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)
		ai_controller.clear_blackboard_key(BB_TRAVEL_DESTINATION)
		ai_controller.clear_blackboard_key(BB_OUTSKIRTS_BESIEGING_MOBS)
		ai_controller.clear_blackboard_key(BB_OUTSKIRTS_REACHED_OBJECTIVE)
		ai_controller.set_blackboard_key(BB_AGGRO_MAINTAIN_RANGE, 12)
		ai_controller.blackboard[BB_MOB_AGGRO_TABLE] = list()
		ai_controller.CancelActions()
	moveToNullspace()
	if(squad_leader)
		var/datum/component/trail_follow/squad_component = squad_leader.GetComponent(/datum/component/trail_follow)
		squad_component.remove_follower(src, wake = FALSE)
		squad_component.members -= src
		squad_leader = null
	reequip_extremities()
	refresh_eyes()
	for(var/datum/warband_manager/warband_manager in SSwarbands.warband_managers)
		if(warband_manager.warband_ID == warband_ID)
			var/list/cache_to_use = warband_manager.get_grunt_cache()
			cache_to_use += src
			break

// when the Shatter Morale warhorn wears off, they regain the Underwhelming trait
/mob/living/carbon/human/species/human/northern/goon/proc/become_underwhelming()
	if(ai_controller?.blackboard[BB_OUTSKIRTS_CACHED_PATH]) // unless they're in an outskirts encounter, in which case they should stay oppressive
		return
	ADD_TRAIT(src, TRAIT_UNDERWHELMING, TRAIT_GENERIC)

/mob/living/carbon/human/species/human/northern/goon/proc/full_repair()
	for(var/obj/item/I in contents)
		if(I.obj_integrity < I.max_integrity)
			I.obj_integrity = I.max_integrity
			if(I.obj_broken)
				I.obj_fix()
		if(I.body_parts_covered_dynamic != I.body_parts_covered)
			I.repair_coverage()

// when a grunt is equipped, we cache the type of any item that can be disarmed/dismembered from them (gloves, weapons etc)
// when they're recycled, we regenerate those items and only those items
/mob/living/carbon/human/species/human/northern/goon/proc/reequip_extremities()
	// hands/weapons
	var/obj/item/current_r = get_held_items_for_side(RIGHT_HANDS)
	var/obj/item/current_l = get_held_items_for_side(LEFT_HANDS)	
	if(current_r && !istype(current_r, saved_r_weapon))
		dropItemToGround(current_r)
		current_r = null
	if(saved_r_weapon && !current_r)
		put_in_r_hand(new saved_r_weapon())
		
	if(current_l && !istype(current_l, saved_l_weapon))
		dropItemToGround(current_l)
		current_l = null
	if(saved_l_weapon && !current_l)
		put_in_l_hand(new saved_l_weapon())

	// extremities
	if(saved_mask && !istype(wear_mask,	saved_mask))
		equip_to_slot_or_del(new saved_mask(), SLOT_WEAR_MASK)
	if(saved_mouth && !istype(mouth, saved_mouth))
		equip_to_slot_or_del(new saved_mouth(), SLOT_MOUTH)
	if(saved_neck && !istype(wear_neck, saved_neck))
		equip_to_slot_or_del(new saved_neck(), SLOT_NECK)
	if(saved_head && !istype(head, saved_head))
		equip_to_slot_or_del(new saved_head(), SLOT_HEAD)
	if(saved_gloves	&& !istype(gloves, saved_gloves))
		equip_to_slot_or_del(new saved_gloves(), SLOT_GLOVES)
	if(saved_shoes && !istype(shoes, saved_shoes))
		equip_to_slot_or_del(new saved_shoes(), SLOT_SHOES)

	for(var/obj/item/equipped_item in get_equipped_items() + held_items)
		ADD_TRAIT(equipped_item, TRAIT_NODROP, TRAIT_GENERIC)

/mob/living/carbon/human/species/human/northern/goon/after_creation()
	..()
	job = "Goon"
	ADD_TRAIT(src, TRAIT_NOMOOD, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_FORMATIONFIGHTER, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_LEECHIMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_BREADY, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_UNDERWHELMING, TRAIT_GENERIC)
	equipOutfit(new /datum/outfit/job/roguetown/human/species/human/northern/goon/base_grunt_stats)

/mob/living/carbon/human/species/human/northern/goon/proc/equip_for_warband()
	if(!warband)
		return
	equipOutfit(warband.get_grunt_outfit(src))
	apply_appearance()

	// cache anything they could lose via disarming/dismemberment
	var/obj/item/r = get_held_items_for_side(RIGHT_HANDS)
	var/obj/item/l = get_held_items_for_side(LEFT_HANDS)
	saved_r_weapon = r?.type
	saved_l_weapon = l?.type
	saved_mask = wear_mask?.type
	saved_neck = wear_neck?.type
	saved_head = head?.type
	saved_mouth = mouth?.type
	saved_gloves = gloves?.type
	saved_shoes = shoes?.type
	for(var/obj/item/equipped_item in get_equipped_items() + held_items)
		ADD_TRAIT(equipped_item, TRAIT_NODROP, TRAIT_GENERIC)
	if(!GetComponent(/datum/component/ai_aggro_system)) // here rather than in after_creation
		AddComponent(/datum/component/ai_aggro_system)
	return

/mob/living/carbon/human/species/human/northern/goon/proc/apply_appearance()
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	if(!subtype || subtype.type != WARBAND_MERC_TITHEBOUND) // In my Fucked Up & Twisted World, Lizards Don't Get Any Hair
		var/hairf = pick(list(/datum/sprite_accessory/hair/head/bedhead, 
							/datum/sprite_accessory/hair/head/bob))
		var/hairm = pick(list(/datum/sprite_accessory/hair/head/ponytail1, 
							/datum/sprite_accessory/hair/head/shaved))
		var/beard = pick(list(/datum/sprite_accessory/hair/facial/vandyke,
							/datum/sprite_accessory/hair/facial/croppedfullbeard))

		var/datum/bodypart_feature/hair/head/new_hair = new()
		var/datum/bodypart_feature/hair/facial/new_facial = new()

		if(gender == FEMALE)
			new_hair.set_accessory_type(hairf, null, src)
		else
			new_hair.set_accessory_type(hairm, null, src)
			new_facial.set_accessory_type(beard, null, src)
		
		if(subtype && (subtype.type == WARBAND_MERC_DROW || subtype.type == WARBAND_MERC_HANGYAKU || subtype.type == WARBAND_MERC_RUMA || subtype.type == WARBAND_MERC_DESERTRIDER || subtype.type == WARBAND_MERC_CONDO || subtype.type == WARBAND_MERC_FORLORN))
			if(prob(50))
				new_hair.accessory_colors = "#1d1d1d"
				new_hair.hair_color = "#1d1d1d"
				new_facial.accessory_colors = "#1d1d1d"
				new_facial.hair_color = "#1d1d1d"
				hair_color = "#1d1d1d"		
			else
				new_hair.accessory_colors = "#24160a"
				new_hair.hair_color = "#24160a"
				new_facial.accessory_colors = "#24160a"
				new_facial.hair_color = "#24160a"
				hair_color = "#24160a"
		else
			if(prob(50))
				new_hair.accessory_colors = "#96403d"
				new_hair.hair_color = "#96403d"
				new_facial.accessory_colors = "#96403d"
				new_facial.hair_color = "#96403d"
				hair_color = "#96403d"
			else
				new_hair.accessory_colors = "#C7C755"
				new_hair.hair_color = "#C7C755"
				new_facial.accessory_colors = "#C7C755"
				new_facial.hair_color = "#C7C755"
				hair_color = "#C7C755"
		head.add_bodypart_feature(new_hair)
		head.add_bodypart_feature(new_facial)
		dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)

	dna.species.handle_body(src)

	refresh_eyes()
	update_hair()
	update_body()

/mob/living/carbon/human/species/human/northern/goon/proc/refresh_eyes()
	var/obj/item/organ/eyes/organ_eyes = getorgan(/obj/item/organ/eyes)
	if(organ_eyes)
		var/picked_eye_color = pick("#365334", "#395c70", "#30261e")
		organ_eyes.eye_color = picked_eye_color
		organ_eyes.accessory_colors = picked_eye_color + picked_eye_color

/datum/outfit/job/roguetown/human/species/human/northern/goon
	var/datum/warbands/subtypes/subtype

/datum/outfit/job/roguetown/human/species/human/northern/goon/base_grunt_stats/pre_equip(mob/living/carbon/human/species/human/northern/goon/H)
	if(prob(50))
		H.real_name = pick(world.file2list("strings/rt/names/human/humsoum.txt"))
	else
		H.real_name = pick(world.file2list("strings/rt/names/human/humnorm.txt"))
	H.name = H.real_name
	H.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/staves, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axes, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)	
	H.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/shields, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
	H.STASTR = WARBAND_NPC_STR
	H.STASPD = WARBAND_NPC_SPD
	H.STACON = WARBAND_NPC_CON
	H.STAWIL = WARBAND_NPC_WIL
	H.STALUC = WARBAND_NPC_LCK
	H.STAINT = WARBAND_NPC_INT
	H.STAPER = WARBAND_NPC_PER

#undef WARBAND_NPC_STR
#undef WARBAND_NPC_SPD
#undef WARBAND_NPC_CON
#undef WARBAND_NPC_WIL
#undef WARBAND_NPC_LCK
#undef WARBAND_NPC_INT
#undef WARBAND_NPC_PER
