/datum/advclass/warband/standard/lieutenant/magician
	title = "MAGICIAN"
	name = "Wizard"
	tutorial = "A battlefield is no place for a MAGICIAN. Unfortunately for them, their sage mind and vast knowledge of the arcane makes them indispensible."
	outfit = /datum/outfit/job/roguetown/warband/standard/lieutenant/magician
	traits_applied = list(TRAIT_ARCYNE, TRAIT_ALCHEMY_EXPERT, TRAIT_FORMATIONFIGHTER, TRAIT_LAWEXPERT)
	subclass_stats = list(
		STATKEY_STR = -2,
		STATKEY_CON = 2,
		STATKEY_WIL = 3,
		STATKEY_INT = 6,
		STATKEY_PER = 4,
	)
	subclass_skills = list(
		/datum/skill/misc/reading = SKILL_LEVEL_LEGENDARY,
		/datum/skill/craft/alchemy = SKILL_LEVEL_EXPERT,
		/datum/skill/magic/arcane = SKILL_LEVEL_MASTER,
		/datum/skill/combat/polearms = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/riding = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_NOVICE,
	)
	subclass_mage_aspects = list("mastery" = FALSE, "major" = 2, "minor" = 3, "utilities" = 9, "ward" = TRUE)

/datum/outfit/job/roguetown/warband/standard/lieutenant/magician/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/wizhat/green/alt
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	gloves = /obj/item/clothing/gloves/roguetown/leather/black
	cloak = /obj/item/clothing/cloak/poncho/invader
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe/tabardblack/alt
	pants = /obj/item/clothing/under/roguetown/tights/random
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/black
	beltl = /obj/item/storage/magebag
	r_hand = /obj/item/rogueweapon/woodstaff
	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern/prelit, 
		/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew,
		/obj/item/recipe_book/alchemy,
		/obj/item/reagent_containers/glass/bottle/waterskin,
		/obj/item/book/spellbook,
		/obj/item/rogueweapon/huntingknife/idagger/silver/arcyne
	)

/obj/item/clothing/cloak/poncho/invader
	color = "#232B1E"
	detail_color = "#14100c"

/obj/item/clothing/head/roguetown/wizhat/green/alt
	color = "#333333"

/obj/item/clothing/suit/roguetown/shirt/robe/tabardblack/alt
	color = "#808080"
