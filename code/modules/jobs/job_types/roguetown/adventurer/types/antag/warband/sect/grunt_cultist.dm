/datum/advclass/warband/sect/grunt/cultist
	title = "CULTIST"
	name = "Cultist"
	tutorial = "The CULTIST has been shaped into the perfect tool for the Sect: a serf wise enough for skilled labor, \
	pious enough to channel the full might of their God, and foolish enough to serve their Prophet."
	outfit = /datum/outfit/job/roguetown/warband/sect/grunt/cultist
	
	traits_applied = list(TRAIT_RITUALIST, TRAIT_FORMATIONFIGHTER, TRAIT_DODGEEXPERT)
	subclass_stats = list(
		STATKEY_WIL = 4,
		STATKEY_INT = 4,
		STATKEY_SPD = 3,
		STATKEY_PER = 2,
		STATKEY_STR = -1,
		STATKEY_CON = -2,
	)

	subclass_skills = list(
		/datum/skill/misc/medicine = SKILL_LEVEL_MASTER,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/carpentry = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/crafting = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/sewing = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/traps = SKILL_LEVEL_EXPERT,
		/datum/skill/labor/mining = SKILL_LEVEL_EXPERT,
		/datum/skill/labor/lumberjacking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/engineering = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/weaponsmithing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/blacksmithing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/smelting = SKILL_LEVEL_APPRENTICE,
	)


/datum/outfit/job/roguetown/warband/sect/grunt/cultist/pre_equip(mob/living/carbon/human/H)
	..()
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	r_hand = /obj/item/rogueweapon/huntingknife/idagger/steel/corroded
	head = /obj/item/clothing/mask/rogue/sack
	belt = /obj/item/storage/belt/rogue/leather
	pants = /obj/item/clothing/under/roguetown/chainlegs/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers/copper/cultist
	gloves = /obj/item/clothing/gloves/roguetown/angle
	neck = /obj/item/clothing/neck/roguetown/coif/heavypadding
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	backl = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special,
		/obj/item/flashlight/flare/torch/lantern/prelit,
		/obj/item/ritechalk,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew,
		/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette,
		/obj/item/reagent_containers/glass/bottle/waterskin
		)
	if(H.patron.type == /datum/patron/divine/undivided)
		neck = /obj/item/clothing/neck/roguetown/psicross/undivided
	if(H.patron.type == /datum/patron/divine/astrata)
		neck = /obj/item/clothing/neck/roguetown/psicross/astrata
	if(H.patron.type == /datum/patron/divine/noc)
		neck = /obj/item/clothing/neck/roguetown/psicross/noc
		backpack_contents = (/obj/item/reagent_containers/glass/bottle/rogue/strongmanapot)
	if(H.patron.type == /datum/patron/divine/ravox)
		neck = /obj/item/clothing/neck/roguetown/psicross/ravox
		backpack_contents = (/obj/item/book/rogue/law)
	if(H.patron.type == /datum/patron/divine/necra)
		neck = /obj/item/clothing/neck/roguetown/psicross/necra
		backpack_contents = list(/obj/item/rogueweapon/shovel/small, /obj/item/natural/bundle/stick)
	if(H.patron.type == /datum/patron/divine/abyssor)
		neck = /obj/item/clothing/neck/roguetown/psicross/abyssor
	if(H.patron.type == /datum/patron/divine/dendor)
		neck = /obj/item/clothing/neck/roguetown/psicross/dendor
	if(H.patron.type == /datum/patron/divine/malum)
		neck = /obj/item/clothing/neck/roguetown/psicross/malum
	if(H.patron.type == /datum/patron/divine/xylix)
		neck = /obj/item/clothing/neck/roguetown/psicross/xylix
	if(H.patron.type == /datum/patron/divine/eora)
		neck = /obj/item/clothing/neck/roguetown/psicross/eora
	if(H.patron.type == /datum/patron/divine/pestra)
		neck = /obj/item/clothing/neck/roguetown/psicross/pestra
		backpack_contents = list(/obj/item/natural/bundle/cloth, /obj/item/needle)
	if(H.patron.type == /datum/patron/inhumen/zizo)
		neck = /obj/item/clothing/neck/roguetown/psicross
	if(H.patron.type == /datum/patron/inhumen/graggar)
		neck = /obj/item/clothing/neck/roguetown/psicross
	if(H.patron.type == /datum/patron/inhumen/matthios)
		neck = /obj/item/clothing/neck/roguetown/psicross
	if(H.patron.type == /datum/patron/inhumen/baotha)
		neck = /obj/item/clothing/neck/roguetown/psicross
	if(H.patron.type == /datum/patron/old_god)
		head = /obj/item/clothing/mask/rogue/sack/psy
		neck = /obj/item/clothing/neck/roguetown/psicross
		shirt = /obj/item/clothing/suit/roguetown/shirt/robe/monk/holy

/obj/item/clothing/wrists/roguetown/bracers/copper/cultist
	color = "#8a8a8a"
