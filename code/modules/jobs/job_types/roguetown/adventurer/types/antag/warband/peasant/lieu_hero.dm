/datum/advclass/warband/rebellion/lieutenant/folkhero
	title = "FOLK HERO"
	name = "Folk Hero"
	tutorial = "The FOLK HERO is no warrior. And yet through a string of fantastic circumstances, they've found themselves at the center-stage of the Rebellion."
	outfit = /datum/outfit/job/roguetown/warband/rebellion/lieutenant/folkhero
	traits_applied = list(TRAIT_FORMATIONFIGHTER, TRAIT_SEEDKNOW, TRAIT_NOSTINK, TRAIT_LONGSTRIDER, TRAIT_MEDIUMARMOR)
	subclass_stats = list(
		STATKEY_LCK = 10,
		STATKEY_WIL = 10,
		STATKEY_CON = 2,
		STATKEY_PER = 2,
	)
	subclass_skills = list(
		/datum/skill/labor/farming = SKILL_LEVEL_EXPERT,
		/datum/skill/labor/butchering = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/tanning = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/labor/lumberjacking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/slings = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/polearms = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/maces = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/axes = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/shields = SKILL_LEVEL_NOVICE,		
		/datum/skill/combat/knives = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/carpentry = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/sewing = SKILL_LEVEL_APPRENTICE,	
		/datum/skill/misc/tracking = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
	)


/datum/outfit/job/roguetown/warband/rebellion/lieutenant/folkhero/pre_equip(mob/living/carbon/human/H)
	..()
	
	if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/dress/gen/random
		shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/random
		cloak = /obj/item/clothing/cloak/apron/brown
	else
		pants = /obj/item/clothing/under/roguetown/tights/random
		armor = /obj/item/clothing/suit/roguetown/armor/leather/vest
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	r_hand = /obj/item/rogueweapon/sword/long/heirloom		
	head = /obj/item/clothing/head/roguetown/armingcap
	mask = /obj/item/clothing/head/roguetown/roguehood
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/rope
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew = 1, 
	/obj/item/flashlight/flare/torch = 1, 
	/obj/item/rogueweapon/huntingknife = 1, 
	/obj/item/flint = 1)
	H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/sweep)
