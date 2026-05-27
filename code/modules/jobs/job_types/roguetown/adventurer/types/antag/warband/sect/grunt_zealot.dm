/datum/advclass/warband/sect/grunt/zealot
	title = "ZEALOT"
	name = "Zealot"
	tutorial = "The ZEALOT has ruined martial arts. Gone are graceful dodges, stances and maneuvers. \
	His victories are owed to blind fury, and fury alone."
	outfit = /datum/outfit/job/roguetown/warband/sect/grunt/zealot

	traits_applied = list(TRAIT_NOPAIN, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_STEELHEARTED, TRAIT_FORMATIONFIGHTER)
	subclass_stats = list(
		STATKEY_STR = 3,
		STATKEY_CON = 6,
		STATKEY_WIL = 6,
		STATKEY_INT = -4,
		STATKEY_PER = -4,
	)

	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/warband/sect/grunt/zealot/pre_equip(mob/living/carbon/human/H)
	..()

	head = /obj/item/flowercrown/rosa
	mask = /obj/item/clothing/mask/rogue/facemask
	cloak = /obj/item/clothing/cloak/thief_cloak/keeper
	pants = /obj/item/clothing/under/roguetown/splintlegs
	armor = /obj/item/clothing/suit/roguetown/armor/brigandine/light
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe/monk
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full
	backl = /obj/item/storage/backpack/rogue/satchel
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special,
		/obj/item/flashlight/flare/torch/lantern/prelit,
		/obj/item/reagent_containers/glass/bottle/rogue/strongmanapot,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew,
		/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette,
		/obj/item/reagent_containers/glass/bottle/waterskin
		)

	if(H.patron.type == /datum/patron/divine/undivided)
		id = /obj/item/clothing/neck/roguetown/psicross/undivided

	if(H.patron.type == /datum/patron/divine/astrata)
		cloak = /obj/item/clothing/cloak/templar/astratan
		id = /obj/item/clothing/neck/roguetown/psicross/astrata
		
	if(H.patron.type == /datum/patron/divine/noc)
		id = /obj/item/clothing/neck/roguetown/psicross/noc

	if(H.patron.type == /datum/patron/divine/dendor)
		head = /obj/item/clothing/head/roguetown/briarthorns
		id = /obj/item/clothing/neck/roguetown/psicross/dendor

	if(H.patron.type == /datum/patron/divine/abyssor)
		id = /obj/item/clothing/neck/roguetown/psicross/abyssor

	if(H.patron.type == /datum/patron/divine/ravox)
		id = /obj/item/clothing/neck/roguetown/psicross/ravox
	
	if(H.patron.type == /datum/patron/divine/necra)
		id = /obj/item/clothing/neck/roguetown/psicross/necra

	if(H.patron.type == /datum/patron/divine/eora)
		id = /obj/item/clothing/neck/roguetown/psicross/eora

	if(H.patron.type == /datum/patron/divine/pestra)
		id = /obj/item/clothing/neck/roguetown/psicross/pestra

	if(H.patron.type == /datum/patron/divine/malum)
		id = /obj/item/clothing/neck/roguetown/psicross/malum
	
	if(H.patron.type == /datum/patron/divine/xylix)
		id = /obj/item/clothing/neck/roguetown/psicross/xylix

	if(H.patron.type == /datum/patron/inhumen/graggar)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/graggar
		cloak = /obj/item/clothing/cloak/graggar

	if(H.patron.type == /datum/patron/inhumen/zizo)
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/inhumen/baotha)
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy
		head = /obj/item/flowercrown/salvia

	if(H.patron.type == /datum/patron/inhumen/matthios)
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy
		armor = /obj/item/clothing/suit/roguetown/armor/brigandine/light
		cloak = /obj/item/clothing/cloak/half/purple
		belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/steel

	if(H.patron.type == /datum/patron/old_god)
		head = /obj/item/clothing/head/roguetown/helmet/blacksteel/psythorns
		mask = /obj/item/clothing/mask/rogue/sack/psy
		armor = /obj/item/clothing/suit/roguetown/armor/plate/cuirass/fencer/psydon
		id = /obj/item/clothing/neck/roguetown/psicross
		cloak = /obj/item/clothing/cloak/tabard/psydontabard/alt
		backr = /obj/item/clothing/cloak/thief_cloak/keeper
		wrists = /obj/item/clothing/wrists/roguetown/bracers/psythorns
		shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
		belt = /obj/item/storage/belt/rogue/leather
