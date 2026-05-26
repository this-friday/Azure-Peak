/datum/advclass/warband/wizard/lieutenant/conjurer
	title = "GAOLER"
	name = "Gaoler"
	tutorial = ""
	outfit = /datum/outfit/job/roguetown/warband/wizard/lieutenant/conjurer
	traits_applied = list(TRAIT_ARCYNE, TRAIT_ALCHEMY_EXPERT, TRAIT_FORMATIONFIGHTER, TRAIT_LAWEXPERT)
	subclass_stats = list(
		STATKEY_STR = -2,
		STATKEY_CON = 6,
		STATKEY_WIL = 6,
		STATKEY_INT = -1,
	)
	subclass_skills = list(
		/datum/skill/misc/reading = SKILL_LEVEL_LEGENDARY,
		/datum/skill/craft/alchemy = SKILL_LEVEL_LEGENDARY,
		/datum/skill/magic/arcane = SKILL_LEVEL_MASTER,
		/datum/skill/combat/staves = SKILL_LEVEL_EXPERT,
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
	subclass_mage_aspects = list("mastery" = TRUE, "major" = 2, "minor" = 3, "utilities" = 9, "ward" = TRUE)

/datum/outfit/job/roguetown/warband/wizard/lieutenant/conjurer/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/wizhat/yellow
	mask = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/down/yellow
	cloak = /obj/item/clothing/cloak/thrall
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe/mageyellow
	pants = /obj/item/clothing/under/roguetown/tights/random
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/battleskirt/black
	beltl = /obj/item/storage/magebag
	r_hand = /obj/item/rogueweapon/woodstaff/implement
	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern/prelit,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew,
		/obj/item/alch/airdust,
		/obj/item/alch/waterdust,
		/obj/item/alch/firedust,
		/obj/item/rogueweapon/huntingknife/idagger/silver/arcyne
	)
	if(H.mind)
		H.mind.AddSpell(new /datum/action/cooldown/spell/forcewall)
		H.mind.AddSpell(new /datum/action/cooldown/spell/forcewall)
		H.mind.AddSpell(new /datum/action/cooldown/spell/gravity_anchor)
		H.mind.AddSpell(new /datum/action/cooldown/spell/battle_ward)

/obj/item/clothing/head/roguetown/roguehood/shalal/hijab/down/yellow
	color = "#c1b144"

/obj/item/clothing/head/roguetown/roguehood/shalal/hijab/down


/obj/item/clothing/head/roguetown/roguehood/shalal/hijab/down/Initialize()
	. = ..()
	var/datum/component/adjustable_clothing/adjust_component = GetComponent(/datum/component/adjustable_clothing)
	if(adjust_component)
		adjust_component.toggle_open(src)
