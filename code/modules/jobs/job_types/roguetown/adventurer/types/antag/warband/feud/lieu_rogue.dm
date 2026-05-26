/datum/advclass/warband/standard/lieutenant/spymaster
	title = "SPYMASTER"
	name = "Spymaster"
	tutorial = "The SPYMASTER's foresight was pivotal in arranging the Duchy's invasion. Now, they shall personally oversee the final stretch of their plans."
	outfit = /datum/outfit/job/roguetown/warband/standard/lieutenant/spymaster
	subclass_languages = list(/datum/language/thievescant)
	traits_applied = list(TRAIT_MEDIUMARMOR, TRAIT_SENTINELOFWITS, TRAIT_DODGEEXPERT, TRAIT_PERFECT_TRACKER, TRAIT_LAWEXPERT, TRAIT_FORMATIONFIGHTER)
	subclass_stats = list(
		STATKEY_STR = -3,
		STATKEY_CON = -1,
		STATKEY_SPD = 6,
		STATKEY_WIL = 2,
		STATKEY_INT = 4,
		STATKEY_PER = 4,
	)
	subclass_skills = list(
		/datum/skill/misc/climbing = SKILL_LEVEL_LEGENDARY,
		/datum/skill/misc/sneaking = SKILL_LEVEL_MASTER,
		/datum/skill/misc/stealing = SKILL_LEVEL_MASTER,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_MASTER,	
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/crossbows = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/bows = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/riding = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/warband/standard/lieutenant/spymaster/pre_equip(mob/living/carbon/human/H)
	..()
	H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/sweep)
	cloak = /obj/item/clothing/cloak/tabard/stabard/warband
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	backr = /obj/item/storage/backpack/rogue/satchel/black
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/rogueweapon/scabbard/sheath
	beltr = /obj/item/rogueweapon/scabbard/sword	
	l_hand = /obj/item/rogueweapon/huntingknife/idagger/steel/parrying
	r_hand = /obj/item/rogueweapon/sword/rapier
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	mask = /obj/item/clothing/mask/rogue/spectacles
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/poison = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/bomb/smoke = 2
		)
