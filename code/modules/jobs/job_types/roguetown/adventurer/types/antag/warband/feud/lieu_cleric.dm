/datum/advclass/warband/standard/lieutenant/preacher
	title = "PREACHER"
	name = "Preacher"
	tutorial = "The PREACHER is an advisor upon matters of faith. A vital ally, for the warpath strays deathly close to Holy Ground."
	outfit = /datum/outfit/job/roguetown/warband/standard/lieutenant/preacher
	traits_applied = list(TRAIT_MEDIUMARMOR, TRAIT_RITUALIST, TRAIT_LAWEXPERT, TRAIT_FORMATIONFIGHTER)
	subclass_stats = list(
		STATKEY_CON = 3,
		STATKEY_WIL = 6,
		STATKEY_INT = 4,
		STATKEY_PER = -2,
	)
	subclass_skills = list(
		/datum/skill/misc/reading = SKILL_LEVEL_MASTER,
		/datum/skill/combat/wrestling = SKILL_LEVEL_MASTER,
		/datum/skill/combat/unarmed = SKILL_LEVEL_MASTER,
		/datum/skill/combat/polearms = SKILL_LEVEL_MASTER,
		/datum/skill/magic/holy = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/medicine = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/crafting = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/alchemy = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/cooking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/sewing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/farming = SKILL_LEVEL_APPRENTICE,
	)
	subclass_languages = list(/datum/language/grenzelhoftian)

/datum/outfit/job/roguetown/warband/standard/lieutenant/preacher/pre_equip(mob/living/carbon/human/H)
	..()
	H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/sweep)
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	pants = /obj/item/clothing/under/roguetown/tights/black
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	beltl = /obj/item/rogueweapon/scabbard/sheath
	belt = /obj/item/storage/belt/rogue/leather/rope/dark
	backl = /obj/item/storage/backpack/rogue/satchel
	l_hand = /obj/item/rogueweapon/woodstaff
	gloves = /obj/item/clothing/gloves/roguetown/bandages/pugilist
	backpack_contents = list(
		/obj/item/needle = 1,
		/obj/item/ritechalk = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette = 1,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1
	)

	if(H.patron.type == /datum/patron/divine/undivided)
		wrists = /obj/item/clothing/neck/roguetown/psicross/undivided
	if(H.patron.type == /datum/patron/divine/astrata)
		wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
		gloves = /obj/item/clothing/gloves/roguetown/leather
		cloak = /obj/item/clothing/cloak/templar/astratan
	if(H.patron.type == /datum/patron/divine/noc)
		wrists = /obj/item/clothing/neck/roguetown/psicross/noc
		backpack_contents = (/obj/item/reagent_containers/glass/bottle/rogue/strongmanapot)
		cloak = /obj/item/clothing/suit/roguetown/shirt/robe/noc
	if(H.patron.type == /datum/patron/divine/ravox)
		head = /obj/item/clothing/head/roguetown/roguehood/ravoxgorget
		wrists = /obj/item/clothing/neck/roguetown/psicross/ravox
		cloak = /obj/item/clothing/cloak/templar/ravox
		neck = /obj/item/clothing/neck/roguetown/bevor
		backpack_contents = (/obj/item/book/rogue/law)
	if(H.patron.type == /datum/patron/divine/necra)
		wrists = /obj/item/clothing/neck/roguetown/psicross/necra
		cloak = /obj/item/clothing/cloak/templar/necran
		shirt = null
		ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_SOUL_EXAMINE, TRAIT_GENERIC)
	if(H.patron.type == /datum/patron/divine/abyssor)
		cloak = /obj/item/clothing/cloak/tabard/abyssorite
		wrists = /obj/item/clothing/neck/roguetown/psicross/abyssor
		ADD_TRAIT(H, TRAIT_WATERBREATHING, TRAIT_GENERIC)
	if(H.patron.type == /datum/patron/divine/dendor)
		head = /obj/item/clothing/head/roguetown/dendormask
		cloak = /obj/item/clothing/suit/roguetown/shirt/robe/dendor
		wrists = /obj/item/clothing/neck/roguetown/psicross/dendor
		gloves = /obj/item/clothing/gloves/roguetown/leather
	if(H.patron.type == /datum/patron/divine/malum)
		cloak = /obj/item/clothing/cloak/templar/malumite
		wrists = /obj/item/clothing/neck/roguetown/psicross/malum
		H.adjust_skillrank_up_to(/datum/skill/craft/blacksmithing = 3)
		H.adjust_skillrank_up_to(/datum/skill/craft/armorsmithing = 3)
		H.adjust_skillrank_up_to(/datum/skill/craft/weaponsmithing = 3)
		H.adjust_skillrank_up_to(/datum/skill/craft/smelting = 3)
	if(H.patron.type == /datum/patron/divine/xylix)
		wrists = /obj/item/clothing/neck/roguetown/luckcharm
		cloak = /obj/item/clothing/cloak/templar/xylixian
		shirt = null
		pants = /obj/item/clothing/under/roguetown/skirt/black
		wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
		H.adjust_skillrank_up_to(/datum/skill/misc/sneaking = 5)
		H.adjust_skillrank_up_to(/datum/skill/misc/music = 4)		
		H.adjust_skillrank_up_to(/datum/skill/misc/climbing = 3)
		H.adjust_skillrank_up_to(/datum/skill/misc/lockpicking = 3)
	if(H.patron.type == /datum/patron/divine/eora)
		wrists = /obj/item/clothing/neck/roguetown/psicross/eora
		cloak = /obj/item/clothing/suit/roguetown/shirt/robe/eora
		ADD_TRAIT(H, TRAIT_BEAUTIFUL, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)
		H.cmode_music = 'sound/music/cmode/church/combat_eora.ogg'
	if(H.patron.type == /datum/patron/divine/pestra)
		wrists = /obj/item/clothing/neck/roguetown/psicross/pestra
		head = /obj/item/clothing/head/roguetown/helmet/heavy/pestran
		cloak = /obj/item/clothing/cloak/templar/pestran
		gloves = /obj/item/clothing/gloves/roguetown/leather
		beltr = /obj/item/storage/belt/rogue/surgery_bag/full
		backpack_contents = list(/obj/item/natural/bundle/cloth, /obj/item/needle/pestra)
	if(H.patron.type == /datum/patron/inhumen/zizo)
		wrists = /obj/item/clothing/neck/roguetown/psicross
	if(H.patron.type == /datum/patron/inhumen/graggar)
		wrists = /obj/item/clothing/neck/roguetown/psicross
	if(H.patron.type == /datum/patron/inhumen/matthios)
		wrists = /obj/item/clothing/neck/roguetown/psicross
	if(H.patron.type == /datum/patron/inhumen/baotha)
		wrists = /obj/item/clothing/neck/roguetown/psicross
	if(H.patron.type == /datum/patron/old_god)
		wrists = /obj/item/clothing/neck/roguetown/psicross/silver
		cloak = /obj/item/clothing/cloak/tabard/psydontabard
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T4, passive_gain = CLERIC_REGEN_MAJOR, start_maxed = TRUE)
