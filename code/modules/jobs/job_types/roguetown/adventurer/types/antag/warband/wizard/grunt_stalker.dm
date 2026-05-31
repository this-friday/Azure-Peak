/datum/advclass/warband/wizard/grunt/stalker
	title = "STALKER"
	name = "Stalker"
	tutorial = "Wheresoever the weakest of the Warband's foes lurk, so too shall the STALKER - hidden beneath Noc's cloak with hooked blades at the ready."
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_FORMATIONFIGHTER, TRAIT_LIGHT_STEP, TRAIT_DUALWIELDER)
	subclass_stats = list(
		STATKEY_STR = -4,
		STATKEY_SPD = 5,
		STATKEY_CON = -4,
		STATKEY_WIL = 3,
		STATKEY_INT = 3,
		STATKEY_PER = 4,
	)
	subclass_skills = list(
		/datum/skill/misc/sneaking = SKILL_LEVEL_MASTER,
		/datum/skill/misc/climbing = SKILL_LEVEL_MASTER,
		/datum/skill/misc/stealing = SKILL_LEVEL_MASTER,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_MASTER,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/arcane = SKILL_LEVEL_NOVICE,
	
	)
	outfit = /datum/outfit/job/roguetown/warband/wizard/grunt/stalker

/datum/outfit/job/roguetown/warband/wizard/grunt/stalker/pre_equip(mob/living/carbon/human/H)
	head = /obj/item/clothing/head/roguetown/roguehood/shalal/thrall
	mask = /obj/item/clothing/mask/rogue/facemask/bronze/classic
	cloak = /obj/item/clothing/cloak/thrall
	armor = /obj/item/clothing/suit/roguetown/armor/leather/cuirass/stalker
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	gloves = /obj/item/clothing/gloves/roguetown/angle
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/iron
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest/thrall
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	r_hand = /obj/item/rogueweapon/sword/sabre/hook
	l_hand = /obj/item/rogueweapon/sword/sabre/hook
	if(H.mind)
		var/datum/magic_aspect/illusion/illusion = new() // 2 castings of every Illusion spell (currently just Invisibility)
		var/datum/action/cooldown/spell/blink/blink = new() // 2 castings of Blink	
		blink.set_bonus_castings(1)			
		illusion.grant_all_spells(H.mind, bonus_castings = 1)
		qdel(illusion)
		H.mind.AddSpell(blink)
		H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/fetch)
		H.mind.AddSpell(new	/datum/action/cooldown/spell/nondetection)
		H.mind.AddSpell(new /datum/action/cooldown/spell/mirror_transform)
		H.mind.AddSpell(new /datum/action/cooldown/spell/touch/prestidigitation)

/obj/item/clothing/suit/roguetown/armor/leather/cuirass/stalker
	color = "#3a1816"
