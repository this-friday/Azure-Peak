/datum/advclass/warband/standard/grunt/rider
	title = "RIDER"
	name = "Rider"
	tutorial = "Together, the RIDER and his war-saiga form a single, inseparable instrument. Skulls shall burst before the man's lance, and formations shall crumble beneath the beast's hooves."
	traits_applied = list(TRAIT_MEDIUMARMOR, TRAIT_STEELHEARTED)
	subclass_stats = list(
		STATKEY_STR = 3,
		STATKEY_SPD = -3,
		STATKEY_CON = 3,
		STATKEY_WIL = 3,
		STATKEY_PER = 3,
	)
	subclass_skills = list(
		/datum/skill/misc/riding = SKILL_LEVEL_MASTER,
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/maces = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_JOURNEYMAN,
	)
	outfit = /datum/outfit/job/roguetown/warband/standard/grunt/rider
	horse = /mob/living/simple_animal/hostile/retaliate/rogue/saiga/tame/saddled 


/datum/outfit/job/roguetown/warband/standard/grunt/rider/pre_equip(mob/living/carbon/human/H)
	head = /obj/item/clothing/head/roguetown/helmet/winged
	cloak = /obj/item/clothing/cloak/tabard/stabard/warband
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson	
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale	
	pants = /obj/item/clothing/under/roguetown/chainlegs/iron
	neck = /obj/item/clothing/neck/roguetown/bevor/iron
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	belt = /obj/item/storage/belt/rogue/leather/black
	beltl = /obj/item/rogueweapon/sword/sabre
	beltr = /obj/item/quiver/javelin/steel
	backr = /obj/item/storage/backpack/rogue/satchel/black
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	r_hand = /obj/item/rogueweapon/spear/lance
	l_hand = /obj/item/rogueweapon/shield/tower/metal

	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special,
		/obj/item/flashlight/flare/torch/lantern/prelit,
		/obj/item/rogueweapon/scabbard/sheath,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew,
		/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette,
		/obj/item/reagent_containers/glass/bottle/waterskin
		)

	var/helmets = list(
	"Simple Helmet" 	= /obj/item/clothing/head/roguetown/helmet,
	"Kettle Helmet" 	= /obj/item/clothing/head/roguetown/helmet/kettle,
	"Bascinet Helmet"	= /obj/item/clothing/head/roguetown/helmet/bascinet,
	"Sallet Helmet"		= /obj/item/clothing/head/roguetown/helmet/sallet,
	"Winged Helmet" 	= /obj/item/clothing/head/roguetown/helmet/winged,
	"Skull Cap"			= /obj/item/clothing/head/roguetown/helmet/skullcap,
	"None"
	)
	var/helmchoice = input("Choose your Helm.", "TAKE UP HELMS") as anything in helmets
	if(helmchoice != "None")
		head = helmets[helmchoice]
