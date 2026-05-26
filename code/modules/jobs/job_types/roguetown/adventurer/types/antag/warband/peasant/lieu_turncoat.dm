/datum/advclass/warband/rebellion/lieutenant/turncoat
	title = "TURNCOAT"
	name = "Turncoat"
	tutorial = "Long-estranged from the Duchy's retinue, the TURNCOAT wields the experience of his service against his former employers."
	outfit = /datum/outfit/job/roguetown/warband/rebellion/lieutenant/turncoat
	traits_applied = list(TRAIT_LAWEXPERT, TRAIT_FORMATIONFIGHTER, TRAIT_HEAVYARMOR, TRAIT_SQUIRE_REPAIR, TRAIT_LONGSTRIDER)
	subclass_stats = list(
		STATKEY_STR = 4,
		STATKEY_SPD = 3,
		STATKEY_PER = 2,
		STATKEY_CON = 2,
		STATKEY_INT = 2,
	)
	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/axes = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/riding = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/warband/rebellion/lieutenant/turncoat/pre_equip(mob/living/carbon/human/H)
	..()
	H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/sweep)
	head = /obj/item/clothing/head/roguetown/helmet/heavy/bucket/iron
	backl = /obj/item/storage/backpack/rogue/satchel
	mask = /obj/item/clothing/mask/rogue/facemask/steel
	cloak = /obj/item/clothing/cloak/tabard/stabard/guardhood
	backr = /obj/item/rogueweapon/shield/iron
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full/iron
	neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron
	pants = /obj/item/clothing/under/roguetown/platelegs/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	beltr = /obj/item/rogueweapon/sword/short
	belt = /obj/item/storage/backpack/rogue/satchel/beltpack
	backpack_contents = list(/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew, 
	/obj/item/rogueweapon/hammer/iron, 
	/obj/item/polishing_cream, 
	/obj/item/armor_brush)
