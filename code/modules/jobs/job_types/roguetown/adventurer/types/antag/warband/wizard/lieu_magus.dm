/datum/advclass/warband/wizard/lieutenant/magus
	title = "MAGUS"
	name = "Magus"
	tutorial = "The MAGUS has bound themselves wholly to a single aspect of the arcyne."
	outfit = /datum/outfit/job/roguetown/warband/wizard/lieutenant/magus
	traits_applied = list(TRAIT_FORMATIONFIGHTER, TRAIT_LAWEXPERT, TRAIT_ARCYNE, TRAIT_ALCHEMY_EXPERT)
	subclass_stats = list(
		STATKEY_CON = -2,
		STATKEY_INT = 7,
	)
	subclass_skills = list(
		/datum/skill/craft/alchemy = SKILL_LEVEL_EXPERT,
		/datum/skill/magic/arcane = SKILL_LEVEL_MASTER,
		/datum/skill/combat/staves = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
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

/datum/outfit/job/roguetown/warband/wizard/lieutenant/magus/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/wizhat
	mask = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/down/blue
	cloak = /obj/item/clothing/cloak/thrall
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe/mageblue
	pants = /obj/item/clothing/under/roguetown/tights/random
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/battleskirt/black
	beltl = /obj/item/storage/magebag
	if(!H?.mind)
		return
	var/list/options = list()
	for(var/path in GLOB.magic_aspects_major)
		var/datum/magic_aspect/aspect = path
		options[initial(aspect.name)] = path
	if(!length(options))
		return
	var/chosen_name = input(H, "Choose an aspect of magic. Its every spell is yours.", "ABSOLUTE MASTERY") as null|anything in options
	if(!chosen_name)
		chosen_name = pick(options)
	var/aspect_path = options[chosen_name]
	if(!ispath(aspect_path, /datum/magic_aspect))
		return
	var/datum/magic_aspect/granted = new aspect_path
	granted.grant_all_spells(H.mind, bonus_castings = 1)
	to_chat(H, span_notice("I have bound myself to the aspect of [granted.name]. Its every spell flows through me."))
	qdel(granted)

/obj/item/clothing/head/roguetown/roguehood/shalal/hijab/down/blue
	color = "#4756d8"
