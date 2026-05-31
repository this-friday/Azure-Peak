/datum/advclass/warband/wizard/grunt/layman
	title = "LAYMAN"
	name = "Layman"
	tutorial = "The LAYMAN is denied the Sorcerer-King's greatest secrets. He only serves with brute force."
	outfit = /datum/outfit/job/roguetown/warband/wizard/grunt/layman
	traits_applied = list(TRAIT_HEAVYARMOR, TRAIT_STEELHEARTED, TRAIT_FORMATIONFIGHTER)
	subclass_stats = list(
		STATKEY_SPD = -1,
		STATKEY_CON = 2,
		STATKEY_WIL = 4,
		STATKEY_INT = -2,
		STATKEY_PER = 2,
	)
	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/carpentry = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/crafting = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,	
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/polearms = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/alchemy = SKILL_LEVEL_NOVICE,
		/datum/skill/magic/arcane = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/warband/wizard/grunt/layman/pre_equip(mob/living/carbon/human/H)
	r_hand = /obj/item/rogueweapon/sword/long/broadsword/bronze
	cloak = /obj/item/clothing/cloak/thrall
	beltr = /obj/item/reagent_containers/glass/bottle/rogue/manapot
	belt = /obj/item/storage/belt/rogue/leather/black
	backl = /obj/item/storage/backpack/rogue/satchel
	head = /obj/item/clothing/head/roguetown/helmet/bronzegladiator
	mask = /obj/item/clothing/head/roguetown/roguehood/shalal/thrall
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full/bronze
	wrists = /obj/item/clothing/wrists/roguetown/bracers/bronze
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest/thrall
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/bronzeskirt
	neck = /obj/item/clothing/neck/roguetown/bevor/bronze
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron/layman
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/bronze
	id = /obj/item/clothing/neck/roguetown/psicross/noc/bronze
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette = 1,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1
		)

	if(H.mind)
		H.mind.AddSpell(new	/datum/action/cooldown/spell/mending)
		H.mind.AddSpell(new	/datum/action/cooldown/spell/conjure_aegis)
		var/coverclass = list("Guidance","Hawk's Eyes","Giant's Strength","Stoneskin","Fortitude","Haste")
		var/coverclass_choice = input("I was taught a simple spell to aid our efforts!", "I REMEMBER") as anything in coverclass
		switch(coverclass_choice)
			if("Guidance")
				H.mind.AddSpell(new /datum/action/cooldown/spell/guidance)
			if("Hawk's Eyes")
				H.mind.AddSpell(new /datum/action/cooldown/spell/hawks_eyes)
			if("Giant's Strength")
				H.mind.AddSpell(new /datum/action/cooldown/spell/giants_strength)
			if("Stoneskin")
				H.mind.AddSpell(new /datum/action/cooldown/spell/stoneskin)
			if("Fortitude")
				H.mind.AddSpell(new /datum/action/cooldown/spell/fortitude)
			if("Haste")
				H.mind.AddSpell(new /datum/action/cooldown/spell/haste)

/obj/item/clothing/gloves/roguetown/plate/iron/layman
	name = "bronze gauntlets"
	desc = ""
	color = "#f7bf6e"

/obj/item/clothing/head/roguetown/roguehood/shalal/thrall
	name = "layman's headscarf"
	desc = ""
	color = "#3a1816"
	icon_state = "shalal_t"
	item_state = "shalal_t"
	alternate_worn_layer = 6
	layer = 6
	armor = ARMOR_PADDED
	max_integrity = ARMOR_INT_HELMET_CLOTH
	adjustable = CAN_CADJUST
	sewrepair = TRUE
	mask_override = TRUE
	overarmor = FALSE

/obj/item/clothing/suit/roguetown/shirt/undershirt/priest/thrall
	color ="#904d4d"
