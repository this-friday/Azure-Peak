/datum/advclass/warband/sect/lieutenant/sentinel
	title = "SENTINEL"
	name = "Sentinel"
	tutorial = "Pity the infidel who dares to cross grounds overseen by the mighty, all-seeing SENTINEL."
	maximum_possible_slots = 1
	outfit = /datum/outfit/job/roguetown/warband/sect/lieutenant/sentinel
	traits_applied = list(TRAIT_KEENEARS, TRAIT_LAWEXPERT, TRAIT_FORMATIONFIGHTER, TRAIT_HEAVYARMOR, TRAIT_GOODLOVER)
	subclass_stats = list(
		STATKEY_PER = 10,
		STATKEY_SPD = -2,
		STATKEY_CON = 2,
		STATKEY_WIL = 2,
		STATKEY_INT = 2,
	)
	subclass_skills = list(
		/datum/skill/combat/bows = SKILL_LEVEL_LEGENDARY,
		/datum/skill/combat/slings = SKILL_LEVEL_MASTER,
		/datum/skill/misc/sneaking = SKILL_LEVEL_MASTER,
		/datum/skill/misc/tracking = SKILL_LEVEL_MASTER,		
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
	)

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

/obj/item/clothing/head/roguetown/helmet/heavy/frogmouth/cursed
	var/active_item = FALSE

/obj/item/clothing/head/roguetown/helmet/heavy/frogmouth/cursed/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/head/roguetown/helmet/heavy/frogmouth/cursed/equipped(mob/living/user, slot)
	. = ..()
	if(active_item)
		return
	if(slot == SLOT_HEAD)
		active_item = TRUE
		ADD_TRAIT(user, TRAIT_BITERHELM, TRAIT_GENERIC)

/obj/item/clothing/head/roguetown/helmet/heavy/frogmouth/cursed/dropped(mob/living/user)
	..()
	if(!active_item)
		return
	active_item = FALSE
	REMOVE_TRAIT(user, TRAIT_BITERHELM, TRAIT_GENERIC)

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

/datum/outfit/job/roguetown/warband/sect/lieutenant/sentinel/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/helmet/heavy/frogmouth/cursed
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/longbow
	neck = /obj/item/clothing/neck/roguetown/coif/heavypadding
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full/fluted
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	pants = /obj/item/clothing/under/roguetown/platelegs
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	beltr = /obj/item/quiver/pyroarrows
	beltl = /obj/item/quiver/javelin/steel
	cloak = /obj/item/clothing/cloak/volfmantle
	backl = /obj/item/quiver/bodkin

	if(H.patron.type == /datum/patron/divine/undivided)
		id = /obj/item/clothing/neck/roguetown/psicross/undivided
		cloak = /obj/item/clothing/cloak/undivided

	if(H.patron.type == /datum/patron/divine/astrata)
		cloak = /obj/item/clothing/cloak/templar/astratan
		id = /obj/item/clothing/neck/roguetown/psicross/astrata

	if(H.patron.type == /datum/patron/divine/noc)
		id = /obj/item/clothing/neck/roguetown/psicross/noc
		cloak = /obj/item/clothing/cloak/tabard/devotee/noc

	if(H.patron.type == /datum/patron/divine/dendor)
		id = /obj/item/clothing/neck/roguetown/psicross/dendor
		cloak = /obj/item/clothing/cloak/tabard/devotee/dendor

	if(H.patron.type == /datum/patron/divine/abyssor)
		id = /obj/item/clothing/neck/roguetown/psicross/abyssor
		cloak = /obj/item/clothing/cloak/tabard/abyssorite

	if(H.patron.type == /datum/patron/divine/ravox)
		id = /obj/item/clothing/neck/roguetown/psicross/ravox
		cloak = /obj/item/clothing/cloak/templar/ravox
	
	if(H.patron.type == /datum/patron/divine/necra)
		id = /obj/item/clothing/neck/roguetown/psicross/necra
		cloak = /obj/item/clothing/cloak/templar/necran

	if(H.patron.type == /datum/patron/divine/eora)
		id = /obj/item/clothing/neck/roguetown/psicross/eora

	if(H.patron.type == /datum/patron/divine/pestra)
		cloak = /obj/item/clothing/cloak/templar/pestran
		id = /obj/item/clothing/neck/roguetown/psicross/pestra

	if(H.patron.type == /datum/patron/divine/malum)
		id = /obj/item/clothing/neck/roguetown/psicross/malum
		cloak = /obj/item/clothing/cloak/templar/malumite

	if(H.patron.type == /datum/patron/divine/xylix)
		cloak = /obj/item/clothing/cloak/templar/xylixian
		id = /obj/item/clothing/neck/roguetown/psicross/xylix
		
	if(H.patron.type == /datum/patron/inhumen/zizo)
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/inhumen/graggar)
		cloak = /obj/item/clothing/cloak/graggar
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/inhumen/baotha)
		mask = /obj/item/flowercrown/salvia
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/inhumen/matthios)
		cloak = /obj/item/clothing/cloak/half/purple
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/old_god)
		armor = /obj/item/clothing/suit/roguetown/armor/plate/fluted/ornate
		id = /obj/item/clothing/neck/roguetown/psicross
		cloak = /obj/item/clothing/cloak/tabard/psydontabard
	H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/sweep)
