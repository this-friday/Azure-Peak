/datum/advclass/warband/sect/lieutenant/versekeeper
	title = "VERSEKEEPER"
	name = "Versekeeper"
	tutorial = "Of all the prophet's apostles, the VERSEKEEPER is the most essential. What good is the cult's truth without a herald to spread it?"
	outfit = /datum/outfit/job/roguetown/warband/sect/lieutenant/versekeeper
	traits_applied = list(TRAIT_SENTINELOFWITS, TRAIT_DODGEEXPERT, TRAIT_FORMATIONFIGHTER, TRAIT_LAWEXPERT)
	subclass_stats = list(
		STATKEY_INT = 7,		
		STATKEY_SPD = -3,
		STATKEY_WIL = 6,
	)
	subclass_skills = list(
		/datum/skill/misc/music = SKILL_LEVEL_MASTER,
		/datum/skill/combat/polearms = SKILL_LEVEL_MASTER,
		/datum/skill/combat/staves = SKILL_LEVEL_MASTER,
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_MASTER,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/axes = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/riding = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/shields = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/roguetown/warband/sect/lieutenant/versekeeper/pre_equip(mob/living/carbon/human/H)
	..()

	neck = /obj/item/clothing/neck/roguetown/bevor/keeper
	armor = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/hierophant/keeper
	cloak = /obj/item/clothing/cloak/thief_cloak/keeper
	head = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/keeper
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe/monk
	mask = /obj/item/clothing/mask/rogue/duelmask/keeper
	belt = /obj/item/storage/belt/rogue/leather/rope/dark
	backl = /obj/item/storage/backpack/rogue/backpack
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/strongmanapot,
		/obj/item/rope/chain, 
		/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew,
		/obj/item/flashlight/flare/torch/lantern/prelit
	)

	if(H.mind)
		var/weapons = list("Harp","Lute","Accordion","Guitar","Hurdy-Gurdy","Viola","Vocal Talisman", "Psyaltery", "Flute")
		var/weapon_choice = tgui_input_list(H, "Choose your instrument.", "TAKE UP ARMS", weapons)
		switch(weapon_choice)
			if("Harp")
				backr = /obj/item/rogue/instrument/harp
			if("Lute")
				backr = /obj/item/rogue/instrument/lute
			if("Accordion")
				backr = /obj/item/rogue/instrument/accord
			if("Guitar")
				backr = /obj/item/rogue/instrument/guitar
			if("Hurdy-Gurdy")
				backr = /obj/item/rogue/instrument/hurdygurdy
			if("Viola")
				backr = /obj/item/rogue/instrument/viola
			if("Vocal Talisman")
				backr = /obj/item/rogue/instrument/vocals
			if("Psyaltery")
				backr = /obj/item/rogue/instrument/psyaltery
			if("Flute")
				backr = /obj/item/rogue/instrument/flute

	if(H.patron.type == /datum/patron/divine/undivided)
		id = /obj/item/clothing/neck/roguetown/psicross/undivided
		cloak = /obj/item/clothing/cloak/undivided

	if(H.patron.type == /datum/patron/divine/astrata)
		cloak = /obj/item/clothing/cloak/templar/astratan
		id = /obj/item/clothing/neck/roguetown/psicross/astrata

	if(H.patron.type == /datum/patron/divine/noc)
		id = /obj/item/clothing/neck/roguetown/psicross/noc

	if(H.patron.type == /datum/patron/divine/dendor)
		id = /obj/item/clothing/neck/roguetown/psicross/dendor

	if(H.patron.type == /datum/patron/divine/abyssor)
		id = /obj/item/clothing/neck/roguetown/psicross/abyssor

	if(H.patron.type == /datum/patron/divine/ravox)
		id = /obj/item/clothing/neck/roguetown/psicross/ravox
	
	if(H.patron.type == /datum/patron/divine/necra)
		id = /obj/item/clothing/neck/roguetown/psicross/necra

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

	if(H.patron.type == /datum/patron/inhumen/graggar)
		cloak = /obj/item/clothing/cloak/graggar
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/inhumen/zizo)
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/inhumen/baotha)
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/inhumen/matthios)
		cloak = /obj/item/clothing/cloak/half/purple
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy

	if(H.patron.type == /datum/patron/old_god)
		armor = /obj/item/clothing/suit/roguetown/armor/plate/fluted/ornate
		id = /obj/item/clothing/neck/roguetown/psicross
		cloak = /obj/item/clothing/cloak/tabard/psydontabard

	var/datum/inspiration/I = new /datum/inspiration(H)
	I.grant_inspiration(H, bard_tier = BARD_T2)
	H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/sweep)

/obj/item/clothing/mask/rogue/duelmask/keeper
	color = "#2b292e"
	detail_color = "#264d26"
	desc = ""

/obj/item/clothing/neck/roguetown/bevor/keeper
	color = "#2b292e"

/obj/item/clothing/head/roguetown/roguehood/shalal/hijab/keeper
	color = "#5b4338"

/obj/item/clothing/cloak/thief_cloak/keeper
	color = "#5b4338"

/obj/item/clothing/suit/roguetown/armor/gambeson/heavy/hierophant/keeper
	name = "versekeeper's shawl"
	desc = ""
	naledicolor = FALSE
	color = "#644e43"
	shiftable = FALSE
