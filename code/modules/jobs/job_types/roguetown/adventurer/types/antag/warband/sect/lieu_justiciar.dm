/datum/advclass/warband/sect/lieutenant/justiciar
	title = "JUSTICIAR"
	name = "Justiciar"
	tutorial = "No weapon formed against the JUSTICIAR shall prosper, and no falsehood shall go uncondemned."
	outfit = /datum/outfit/job/roguetown/warband/sect/lieutenant/justiciar
	traits_applied = list(TRAIT_HEAVYARMOR, TRAIT_LAWEXPERT, TRAIT_FORMATIONFIGHTER, TRAIT_COMBAT_AWARE)
	subclass_stats = list(
		STATKEY_STR = 4,
		STATKEY_CON = 4,
		STATKEY_WIL = 2,
		STATKEY_SPD = 3
	)
	subclass_skills = list(
		/datum/skill/combat/whipsflails = SKILL_LEVEL_MASTER,
		/datum/skill/combat/polearms = SKILL_LEVEL_MASTER,
		/datum/skill/combat/swords = SKILL_LEVEL_MASTER,
		/datum/skill/combat/axes = SKILL_LEVEL_MASTER,
		/datum/skill/combat/maces = SKILL_LEVEL_MASTER,
		/datum/skill/combat/shields = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/holy = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/roguetown/warband/sect/lieutenant/justiciar/pre_equip(mob/living/carbon/human/H)
	..()

	backl = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/clothing/cloak/volfmantle
	neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	belt = /obj/item/storage/belt/rogue/leather
	pants = /obj/item/clothing/under/roguetown/platelegs
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special,
		/obj/item/flashlight/flare/torch/lantern/prelit,
		/obj/item/reagent_containers/glass/bottle/rogue/strongmanapot,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew,
		/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette,
		/obj/item/reagent_containers/glass/bottle/waterskin
		)

	if(H.patron.type == /datum/patron/divine/undivided)
		head = /obj/item/clothing/head/roguetown/helmet/bascinet
		mask = /obj/item/clothing/mask/rogue/facemask/steel
		id = /obj/item/clothing/neck/roguetown/psicross/undivided
		r_hand = /obj/item/rogueweapon/sword/long/undivided
		cloak = /obj/item/clothing/cloak/templar/undivided

	if(H.patron.type == /datum/patron/divine/astrata)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/astratan
		r_hand = /obj/item/rogueweapon/sword/long/exe/astrata
		id = /obj/item/clothing/neck/roguetown/psicross/astrata
		cloak = /obj/item/clothing/cloak/tabard/devotee/astrata

	if(H.patron.type == /datum/patron/divine/noc)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/nochelm
		mask = /obj/item/clothing/mask/rogue/facemask
		id = /obj/item/clothing/neck/roguetown/psicross/noc
		r_hand = /obj/item/rogueweapon/sword/sabre/nockhopesh
		cloak = /obj/item/clothing/cloak/tabard/devotee/noc

	if(H.patron.type == /datum/patron/divine/dendor)
		head = /obj/item/clothing/head/roguetown/dendormask
		mask = /obj/item/clothing/mask/rogue/facemask/steel
		id = /obj/item/clothing/neck/roguetown/psicross/dendor
		cloak = /obj/item/clothing/cloak/tabard/devotee/dendor
		r_hand = /obj/item/rogueweapon/halberd/bardiche/scythe

	if(H.patron.type == /datum/patron/divine/abyssor)
		var/weapons = list("TIDECLEAVER","BAROTRAUMA")
		var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
		switch(weapon_choice)
			if("TIDECLEAVER")
				r_hand = /obj/item/rogueweapon/stoneaxe/battle/abyssoraxe
			if("BAROTRAUMA")
				r_hand = /obj/item/rogueweapon/katar/abyssor
		head = /obj/item/clothing/head/roguetown/helmet/sallet/visored
		id = /obj/item/clothing/neck/roguetown/psicross/abyssor
		cloak = /obj/item/clothing/cloak/tabard/abyssorite

	if(H.patron.type == /datum/patron/divine/ravox)
		head = /obj/item/clothing/head/roguetown/helmet/sallet/visored
		id = /obj/item/clothing/neck/roguetown/psicross/ravox
		cloak = /obj/item/clothing/cloak/templar/ravox
		r_hand = /obj/item/rogueweapon/mace/goden/steel/ravox
	
	if(H.patron.type == /datum/patron/divine/necra)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/guard/bogman
		id = /obj/item/clothing/neck/roguetown/psicross/necra
		cloak = /obj/item/clothing/cloak/templar/necran
		r_hand = /obj/item/rogueweapon/flail/sflail/necraflail

	if(H.patron.type == /datum/patron/divine/eora)
		var/weapons = list("HEARTSTRING","CLOSE CARESS")
		var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
		switch(weapon_choice)
			if("HEARTSTRING")
				r_hand = /obj/item/rogueweapon/sword/rapier/eora
			if("CLOSE CARESS")
				gloves = /obj/item/clothing/gloves/roguetown/knuckles/eora
		head = /obj/item/clothing/head/roguetown/helmet/sallet/eoran
		mask = /obj/item/clothing/mask/rogue/facemask/steel
		id = /obj/item/clothing/neck/roguetown/psicross/eora

	if(H.patron.type == /datum/patron/divine/pestra)
		head = /obj/item/clothing/head/roguetown/helmet/bascinet/pigface
		cloak = /obj/item/clothing/cloak/templar/pestran
		r_hand = /obj/item/rogueweapon/huntingknife/idagger/steel/pestrasickle
		l_hand = /obj/item/rogueweapon/huntingknife/idagger/steel/parrying
		id = /obj/item/clothing/neck/roguetown/psicross/pestra
	
	if(H.patron.type == /datum/patron/divine/malum)
		head = /obj/item/clothing/head/roguetown/helmet/sallet/visored
		id = /obj/item/clothing/neck/roguetown/psicross/undivided
		cloak = /obj/item/clothing/cloak/templar/malumite
		r_hand = /obj/item/rogueweapon/greatsword/grenz/flamberge/malum

	if(H.patron.type == /datum/patron/divine/xylix)
		wrists = null	
		head = /obj/item/clothing/head/roguetown/helmet/sallet/visored
		cloak = /obj/item/clothing/cloak/templar/xylixian
		r_hand = /obj/item/rogueweapon/whip

	if(H.patron.type == /datum/patron/inhumen/graggar)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/graggar
		armor = /obj/item/clothing/suit/roguetown/armor/plate/fluted/graggar
		r_hand = /obj/item/rogueweapon/halberd
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/inhumen/zizo)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/zizo
		armor = /obj/item/clothing/suit/roguetown/armor/plate/full/zizo
		r_hand = /obj/item/rogueweapon/sword/long/zizo
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/inhumen/baotha)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/guard
		mask = /obj/item/flowercrown/salvia
		cloak = /obj/item/clothing/cloak/forrestercloak/snow/alt
		r_hand = /obj/item/rogueweapon/spear/partizan
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/inhumen/matthios)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/matthios
		armor = /datum/anvil_recipe/armor/steel/cuirass/fluted
		cloak = /obj/item/clothing/cloak/half/purple
		belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/steel
		r_hand = /obj/item/rogueweapon/whip
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/old_god)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle
		armor = /obj/item/clothing/suit/roguetown/armor/plate/fluted/ornate
		belt = /obj/item/storage/belt/rogue/leather
		id = /obj/item/clothing/neck/roguetown/psicross
		cloak = /obj/item/clothing/cloak/tabard/psydontabard/alt
		shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
		var/weapons = list("LONGSWORD","SPEAR","FLAIL","MACE","HANDAXE","WHIP")
		var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
		switch(weapon_choice)
			if("LONGSWORD")
				r_hand = /obj/item/rogueweapon/sword/long/psysword
			if("SPEAR")
				r_hand = /obj/item/rogueweapon/spear/psyspear
			if("FLAIL")
				r_hand = /obj/item/rogueweapon/flail/sflail/psyflail
			if("MACE")
				r_hand = /obj/item/rogueweapon/mace/goden/psymace
			if("HANDAXE")
				r_hand = /obj/item/rogueweapon/stoneaxe/battle/psyaxe
			if("WHIP")
				r_hand = /obj/item/rogueweapon/whip/psywhip_lesser
		return TRUE
	H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/sweep)

/obj/item/clothing/cloak/half/purple
	color = CLOTHING_PURPLE

/obj/item/clothing/cloak/forrestercloak/snow/alt
	name = "heartbreaker's shroud"
	desc = "A heavy cloak. When worn, a numbing comfort settles over one's nerves."
	color = CLOTHING_PURPLE

