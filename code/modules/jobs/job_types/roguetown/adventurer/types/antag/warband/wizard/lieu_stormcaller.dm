/datum/advclass/warband/wizard/lieutenant/stormcaller
	title = "STORMCALLER"
	name = "Stormcaller"
	tutorial = ""
	outfit = /datum/outfit/job/roguetown/warband/wizard/lieutenant/stormcaller
	traits_applied = list(TRAIT_FORMATIONFIGHTER, TRAIT_LAWEXPERT, TRAIT_ARCYNE, TRAIT_ALCHEMY_EXPERT, TRAIT_DUALWIELDER)
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_CON = -2,
		STATKEY_INT = 6,
		STATKEY_SPD = 2,
	)
	subclass_skills = list(
		/datum/skill/misc/reading = SKILL_LEVEL_LEGENDARY,
		/datum/skill/combat/staves = SKILL_LEVEL_EXPERT,
		/datum/skill/magic/arcane = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/alchemy = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
	)
	subclass_mage_aspects = list("mastery" = TRUE, "major" = 2, "minor" = 3, "utilities" = 9, "ward" = TRUE)

/datum/outfit/job/roguetown/warband/wizard/lieutenant/stormcaller/pre_equip(mob/living/carbon/human/H)
	..()

	r_hand = /obj/item/rogueweapon/spear/lance
	l_hand = /obj/item/rogueweapon/spear/lance
	head = /obj/item/clothing/head/roguetown/wizhat
	mask = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/down/blue
	cloak = /obj/item/clothing/cloak/thrall
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe/mageblue
	pants = /obj/item/clothing/under/roguetown/tights/random
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/battleskirt/black
	beltl = /obj/item/storage/magebag
	if(H.mind)
		if(H.patron.type == /datum/patron/inhumen/zizo)
			H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/blood_bolt)
		else
			H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/lightning_bolt)
		H.mind.AddSpell(new /datum/action/cooldown/spell/thunderstrike)
		H.mind.AddSpell(new /datum/action/cooldown/spell/thunderstrike)
		H.mind.AddSpell(new	/datum/action/cooldown/spell/blink)
		H.mind.AddSpell(new /datum/action/cooldown/spell/leap)
		H.mind.AddSpell(new /datum/action/cooldown/spell/gravity)
		H.mind.AddSpell(new /datum/action/cooldown/spell/haste)

/obj/item/clothing/head/roguetown/roguehood/shalal/hijab/down/blue
	color = "#4756d8"
