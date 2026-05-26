/datum/advclass/warband/wizard/grunt/warlock
	title = "WARLOCK"
	name = "Warlock"
	tutorial = "Guilty of divine thievery, the WARLOCK finds themselves cursed. Their future is short, and should be suffered at one's own peril."
	outfit = /datum/outfit/job/roguetown/warband/wizard/grunt/warlock
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_FORMATIONFIGHTER, TRAIT_RITUALIST, TRAIT_ARCYNE)
	subclass_stats = list(
		STATKEY_SPD = 2,
		STATKEY_CON = -2,
		STATKEY_WIL = 1,
		STATKEY_INT = 5,
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
		H.mind.AddSpell(new /datum/action/cooldown/spell/touch/prestidigitation)
		H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/soulshot)
		H.mind.AddSpell(new /datum/action/cooldown/spell/conjure_aegis)
		if(H.patron.type == /datum/patron/divine/undivided || H.patron.type == /datum/patron/old_god || \
		   H.patron.type == /datum/patron/inhumen/matthios || H.patron.type == /datum/patron/inhumen/graggar || \
		   H.patron.type == /datum/patron/inhumen/baotha)	// if their current patron lacks a spellset, they choose one from the list
			var/curseclass = list("Astrata","Abyssor","Ravox","Necra","Xylix","Pestra","Malum","Eora","Noc","Zizo")
			var/curseclass_choice = input("I was cursed by...", "WOE") as anything in curseclass
			var/patron_path = list(
				"Astrata" = /datum/patron/divine/astrata,
				"Abyssor" = /datum/patron/divine/abyssor,
				"Noc" = /datum/patron/divine/noc,
				"Ravox" = /datum/patron/divine/ravox,
				"Necra" = /datum/patron/divine/necra,
				"Xylix" = /datum/patron/divine/xylix,
				"Pestra" = /datum/patron/divine/pestra,
				"Malum" = /datum/patron/divine/malum,
				"Eora" = /datum/patron/divine/eora,
				"Zizo" = /datum/patron/inhumen/zizo
			)
			var/selected_patron_type = patron_path[curseclass_choice]
			if(selected_patron_type)
				H.set_patron(selected_patron_type)
		
		if(H.patron.type == /datum/patron/divine/astrata)
			H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/fireball)
			H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/fireball)
			H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/fireball)
			H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/spitfire)
		
		else if(H.patron.type == /datum/patron/divine/abyssor)
			H.mind.AddSpell(new /datum/action/cooldown/spell/snap_freeze)
			H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/frost_bolt)
			H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/frost_bolt)
		
		else if(H.patron.type == /datum/patron/divine/noc)
			ADD_TRAIT(H, TRAIT_ANTIMAGIC, TRAIT_GENERIC)
		
		else if(H.patron.type == /datum/patron/divine/ravox)
			H.mind.AddSpell(new /datum/action/cooldown/spell/giants_strength)
			H.mind.AddSpell(new /datum/action/cooldown/spell/blade_burst)
			H.mind.AddSpell(new /datum/action/cooldown/spell/blade_burst)
		
		else if(H.patron.type == /datum/patron/divine/necra)
			H.mind.AddSpell(new /datum/action/cooldown/spell/wither)
			H.mind.AddSpell(new /datum/action/cooldown/spell/wither)
		
		else if(H.patron.type == /datum/patron/divine/xylix)
			H.mind.AddSpell(new /datum/action/cooldown/spell/haste)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/invisibility)
			ADD_TRAIT(H, TRAIT_ZJUMP, TRAIT_GENERIC)
		
		else if(H.patron.type == /datum/patron/divine/pestra)
			H.mind.AddSpell(new /datum/action/cooldown/spell/wither)
		
		else if(H.patron.type == /datum/patron/divine/malum)
			H.mind.AddSpell(new /datum/action/cooldown/spell/fortitude)
			H.mind.AddSpell(new /datum/action/cooldown/spell/stoneskin)
			H.mind.AddSpell(new /datum/action/cooldown/spell/gravity)
			H.mind.AddSpell(new /datum/action/cooldown/spell/magicians_brick)
			H.mind.AddSpell(new /datum/action/cooldown/spell/magicians_brick)
			H.mind.AddSpell(new /datum/action/cooldown/spell/magicians_brick)
		
		else if(H.patron.type == /datum/patron/divine/eora)
			H.mind.AddSpell(new /datum/action/cooldown/spell/ensnare)
			H.mind.AddSpell(new /datum/action/cooldown/spell/ensnare)
			H.mind.AddSpell(new /datum/action/cooldown/spell/mindlink)
		
		else if(H.patron.type == /datum/patron/inhumen/zizo)
			ADD_TRAIT(H, TRAIT_ANTIMAGIC, TRAIT_GENERIC)
		
		var/datum/devotion/C = new /datum/devotion(H, H.patron)
		C.grant_miracles(H, cleric_tier = CLERIC_T4, devotion_limit = CLERIC_REQ_4, start_maxed = TRUE)
		H.verbs -= /mob/living/carbon/human/proc/clericpray // cannot regain devotion

/obj/item/clothing/head/roguetown/witchhat/thrall
	color = "#b2b2b2"

/obj/item/clothing/suit/roguetown/shirt/tunic/silktunic/thrall
	color = "#808080"
