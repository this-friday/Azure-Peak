/datum/advclass/warband/rebellion/lieutenant/firebrand
	title = "FIREBRAND"
	name = "Firebrand"
	tutorial = "It's said that the FIREBRAND was once a gentle, well-learned tinkerer. The revolution's crucible melted his innocence, forging him into a butcher."
	outfit = /datum/outfit/job/roguetown/warband/rebellion/lieutenant/firebrand
	traits_applied = list(TRAIT_LAWEXPERT, TRAIT_FORMATIONFIGHTER, TRAIT_LONGSTRIDER)
	subclass_stats = list(
		STATKEY_INT = 3,
		STATKEY_WIL = 2,
		STATKEY_STR = 1,
		STATKEY_CON = 1,
		STATKEY_PER = 1
	)
	subclass_skills = list(
		/datum/skill/combat/crossbows = SKILL_LEVEL_MASTER,
		/datum/skill/combat/axes = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/maces = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/carpentry = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/masonry = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/engineering = SKILL_LEVEL_MASTER,
		/datum/skill/craft/blacksmithing = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/armorsmithing = SKILL_LEVEL_EXPERT, 
		/datum/skill/craft/weaponsmithing = SKILL_LEVEL_EXPERT,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/smelting = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/traps = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/ceramics = SKILL_LEVEL_JOURNEYMAN,
	)


/datum/outfit/job/roguetown/warband/rebellion/lieutenant/firebrand/pre_equip(mob/living/carbon/human/H)
	..()

	r_hand = /obj/item/satchel_bomb
	l_hand = /obj/item/satchel_bomb
	head = /obj/item/clothing/head/roguetown/articap
	armor = /obj/item/clothing/suit/roguetown/armor/plate/paalloy/artificer
	cloak = /obj/item/clothing/cloak/apron/waist/brown
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/blacksmith
	pants = /obj/item/clothing/under/roguetown/trou/artipants
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/artificer
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/pick/militia/steel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/slurbow
	backl = /obj/item/storage/backpack/rogue/backpack
	backpack_contents = list(/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew = 1,
		/obj/item/rogueweapon/hammer/steel = 1,	
		/obj/item/lockpickring/mundane = 1,		
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/contraption/linker = 1,	
		/obj/item/flint = 1,
		/obj/item/bomb/smoke = 2,
		/obj/item/impact_grenade/explosion = 4,
		/obj/item/ammo_casing/caseless/rogue/bolt/pyro = 4
	)
	H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/sweep)
