/datum/advclass/warband/standard/grunt/scout
	title = "SCOUT"
	name = "Scout"
	tutorial = "The SCOUT relies on a swift pair of legs and keen eyes. Should they find themselves cornered into a proper fight, they'll have hell to pay."
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_MEDIUMARMOR, TRAIT_WOODWALKER, TRAIT_LONGSTRIDER, TRAIT_FORMATIONFIGHTER, TRAIT_KEENEARS)
	subclass_stats = list(
		STATKEY_SPD = 3,
		STATKEY_CON = -4,
		STATKEY_WIL = 2,
		STATKEY_PER = 6,
	)
	subclass_skills = list(
		/datum/skill/combat/crossbows = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/bows = SKILL_LEVEL_MASTER,
		/datum/skill/combat/slings = SKILL_LEVEL_MASTER,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
	)
	outfit = /datum/outfit/job/roguetown/warband/standard/grunt/scout

/datum/outfit/job/roguetown/warband/standard/grunt/scout/pre_equip(mob/living/carbon/human/H)
	head = /obj/item/clothing/head/roguetown/helmet/leather/advanced
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black
	cloak = /obj/item/clothing/cloak/tabard/stabard/warband
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
	wrists = /obj/item/clothing/wrists/roguetown/bracers/brigandine
	beltr = /obj/item/quiver/bodkin
	beltl = /obj/item/quiver/bodkin
	backl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve

	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special,
		/obj/item/flashlight/flare/torch/lantern/prelit,
		/obj/item/rogueweapon/scabbard/sheath,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew,
		/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette = 1,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1
		)
