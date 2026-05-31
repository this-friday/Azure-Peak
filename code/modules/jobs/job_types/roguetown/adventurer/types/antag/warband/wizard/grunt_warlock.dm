/datum/advclass/warband/wizard/grunt/warlock
	title = "WARLOCK"
	name = "Warlock"
	tutorial = "Guilty of divine thievery, the WARLOCK finds themselves cursed. Their future is short, and should be suffered at one's own peril."
	outfit = /datum/outfit/job/roguetown/warband/wizard/grunt/warlock
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_FORMATIONFIGHTER, TRAIT_RITUALIST, TRAIT_ARCYNE)
	subclass_stats = list(
		STATKEY_SPD = 2,
		STATKEY_WIL = 1,
		STATKEY_INT = 2,
		STATKEY_PER = 2,
	)
	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_LEGENDARY,
		/datum/skill/misc/reading = SKILL_LEVEL_MASTER,
		/datum/skill/craft/alchemy = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/warband/wizard/grunt/warlock/pre_equip(mob/living/carbon/human/H)
	..()
	H.mind.enlightened = TRUE // not here for any real reason outside of staying consistent with the 'warlocks' / temp casters created by a Sect warlord
	if(should_wear_femme_clothes(H))
		shirt = /obj/item/clothing/suit/roguetown/armor/corset
		armor = /obj/item/clothing/suit/roguetown/shirt/tunic/silktunic/thrall
		pants = /obj/item/clothing/under/roguetown/skirt/black
	else
		armor = /obj/item/clothing/suit/roguetown/shirt/tunic/black
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest/thrall
	head = /obj/item/clothing/head/roguetown/witchhat/thrall
	cloak = /obj/item/clothing/cloak/thrall
	gloves = /obj/item/clothing/gloves/roguetown/leather
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/rogueweapon/scabbard/sword	
	beltr = /obj/item/clothing/neck/roguetown/psicross/wood
	backl = /obj/item/storage/backpack/rogue/satchel/black
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	l_hand = /obj/item/rogueweapon/sword/long
	backpack_contents = list(
		/obj/item/ritechalk = 1,
		/obj/item/rope/chain = 1,
		/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette = 1,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1
		)

	if(H.mind)
		if(H.patron.type == /datum/patron/divine/noc || H.patron.type == /datum/patron/inhumen/zizo || !H.get_curse_for_patron(H.patron.type))
			H.set_patron(/datum/patron/divine/astrata)

		var/curse_path = H.get_curse_for_patron(H.patron.type)
		if(curse_path)
			H.add_curse(curse_path)

		// given full Telomancy
		var/datum/magic_aspect/telomancy/telomancy = new()
		telomancy.grant_all_spells(H.mind)
		qdel(telomancy)

		var/datum/devotion/C = new /datum/devotion(H, H.patron)
		C.grant_miracles(H, cleric_tier = CLERIC_T4, devotion_limit = CLERIC_REQ_4, start_maxed = TRUE)
		H.verbs -= /mob/living/carbon/human/proc/clericpray // cannot regain devotion

/obj/item/clothing/head/roguetown/witchhat/thrall
	color = "#b2b2b2"

/obj/item/clothing/suit/roguetown/shirt/tunic/silktunic/thrall
	color = "#808080"
