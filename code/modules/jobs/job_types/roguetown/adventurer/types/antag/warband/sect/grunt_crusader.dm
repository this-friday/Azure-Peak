/datum/advclass/warband/sect/grunt/crusader
	title = "CRUSADER"
	name = "Crusader"
	tutorial = "As mighty in faith and arms as the CRUSADER may be, he remains as dull as the dirt soon to bury him."
	outfit = /datum/outfit/job/roguetown/warband/sect/grunt/crusader
	traits_applied = list(TRAIT_HEAVYARMOR, TRAIT_STEELHEARTED, TRAIT_FORMATIONFIGHTER)
	subclass_stats = list(
		STATKEY_STR = 4,
		STATKEY_INT = -4,
		STATKEY_CON = 4,
		STATKEY_WIL = 4,
		STATKEY_SPD = -3,
	)
	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_JOURNEYMAN,		
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/riding = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/warband/sect/grunt/crusader/pre_equip(mob/living/carbon/human/H)
	..()

	head = /obj/item/clothing/head/roguetown/helmet/sallet/visored/iron
	backr = /obj/item/clothing/cloak/cape/crusader
	cloak = /obj/item/clothing/cloak/tabard/stabard/crusader/undivided/generic
	belt = /obj/item/storage/belt/rogue/leather
	pants = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	neck = /obj/item/clothing/neck/roguetown/coif/heavypadding
	backl = /obj/item/rogueweapon/shield/tower/metal
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced

	if(H.patron.type == /datum/patron/divine/undivided)
		head = /obj/item/clothing/head/roguetown/helmet/bascinet
		mask = /obj/item/clothing/mask/rogue/facemask
		id = /obj/item/clothing/neck/roguetown/psicross/undivided

	if(H.patron.type == /datum/patron/divine/astrata)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/astratan
		id = /obj/item/clothing/neck/roguetown/psicross/astrata

	if(H.patron.type == /datum/patron/divine/noc)
		id = /obj/item/clothing/neck/roguetown/psicross/noc

	if(H.patron.type == /datum/patron/divine/dendor)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/dendorhelm
		mask = /obj/item/clothing/mask/rogue/facemask
		id = /obj/item/clothing/neck/roguetown/psicross/dendor
	
	if(H.patron.type == /datum/patron/divine/abyssor)
		id = /obj/item/clothing/neck/roguetown/psicross/abyssor

	if(H.patron.type == /datum/patron/divine/ravox)
		id = /obj/item/clothing/neck/roguetown/psicross/ravox
	
	if(H.patron.type == /datum/patron/divine/necra)
		id = /obj/item/clothing/neck/roguetown/psicross/necra

	if(H.patron.type == /datum/patron/divine/eora)
		head = /obj/item/clothing/head/roguetown/helmet/sallet/eoran
		mask = /obj/item/clothing/mask/rogue/facemask/steel
		id = /obj/item/clothing/neck/roguetown/psicross/eora

	if(H.patron.type == /datum/patron/divine/pestra)
		id = /obj/item/clothing/neck/roguetown/psicross/pestra

	if(H.patron.type == /datum/patron/divine/malum)
		id = /obj/item/clothing/neck/roguetown/psicross/malum
	
	if(H.patron.type == /datum/patron/divine/xylix)
		id = /obj/item/clothing/neck/roguetown/psicross/xylix

	if(H.patron.type == /datum/patron/inhumen/graggar)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/graggar
		armor = /obj/item/clothing/suit/roguetown/armor/plate/fluted/graggar
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/inhumen/zizo)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/zizo
		armor = /obj/item/clothing/suit/roguetown/armor/plate/full/zizo
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/inhumen/baotha)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/guard
		armor = /obj/item/clothing/suit/roguetown/armor/plate/scale
		mask = /obj/item/flowercrown/salvia
		cloak = /obj/item/clothing/cloak/forrestercloak/snow/alt
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/inhumen/matthios)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/matthios
		armor = /datum/anvil_recipe/armor/steel/cuirass/fluted
		cloak = /obj/item/clothing/cloak/half/purple
		belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/steel
		r_hand = /obj/item/rogueweapon/whip
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/old_god)
		head = /obj/item/clothing/head/roguetown/helmet/heavy/psybucket
		armor = /obj/item/clothing/suit/roguetown/armor/plate/fluted/ornate
		id = /obj/item/clothing/neck/roguetown/psicross
		cloak = /obj/item/clothing/cloak/tabard/psydontabard
		shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
		var/weapons = list("LONGSWORD","SPEAR","FLAIL","MACE","WAR AXE")
		var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
		switch(weapon_choice)
			if("LONGSWORD")
				r_hand = /obj/item/rogueweapon/sword/long/oldpsysword
			if("SPEAR")
				r_hand = /obj/item/rogueweapon/spear/psyspear/old
			if("FLAIL")
				r_hand = /obj/item/rogueweapon/flail/sflail/psyflail
			if("MACE")
				r_hand = /obj/item/rogueweapon/mace/goden/psymace
			if("WAR AXE")
				r_hand = /obj/item/rogueweapon/stoneaxe/battle/psyaxe
	else
		var/weapontype = list("SWORD","HAMMER","AXE","HALBERD")
		var/category_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapontype
		switch(category_choice)
			if("SWORD")
				r_hand = /obj/item/rogueweapon/greatsword
				beltl = /obj/item/rogueweapon/sword/short/messer
			if("HAMMER")
				r_hand = /obj/item/rogueweapon/mace/warhammer/steel
			if("AXE")
				r_hand = /obj/item/rogueweapon/stoneaxe/battle
				beltl = /obj/item/rogueweapon/stoneaxe/hurlbat
				beltr = /obj/item/rogueweapon/stoneaxe/hurlbat
			if("HALBERD")
				r_hand = /obj/item/rogueweapon/halberd
				beltl = /obj/item/rogueweapon/sword/short

/obj/item/clothing/cloak/tabard/stabard/crusader/undivided/generic
	name = "crusader's tabard"
	color = "#C5BDB2"
