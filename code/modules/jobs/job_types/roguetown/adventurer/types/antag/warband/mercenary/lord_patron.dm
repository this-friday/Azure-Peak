/datum/advclass/warband/mercenary/warlord/patron
	title = "PATRON"
	name = "Patron"
	tutorial = "The PATRON serves as the Company's employer - and one who's almost certainly no warrior themselves. Nevertheless, if you wish something done right..."
	outfit = /datum/outfit/job/roguetown/warband/warband_patron
	ignore_locks = TRUE
	forgoes_subclass = TRUE
	traits_applied = list(TRAIT_FORMATIONFIGHTER, TRAIT_LAWEXPERT)
	subclass_skills = list(
		/datum/skill/misc/reading = SKILL_LEVEL_MASTER,
		/datum/skill/misc/riding = SKILL_LEVEL_EXPERT,
	)

/datum/outfit/job/roguetown/warband/warband_patron/pre_equip(mob/living/carbon/human/H)
	..()

	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/natural/feather = 1,
	)

	var/list/styles = list(
		"Merchant",
		"Noble",
	)
	var/style_choice = input(H, "How should the PATRON be styled?", "STYLE") as anything in styles
	if(!style_choice)
		style_choice = "Merchant"

	switch(style_choice)
		if("Merchant")
			head = /obj/item/flowercrown/matricaria
			cloak = /obj/item/clothing/cloak/sleevedtabard/patron
			armor = /obj/item/clothing/suit/roguetown/shirt/robe/merchant
			shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/puritan
			pants = /obj/item/clothing/under/roguetown/tights/sailor
			belt = /obj/item/storage/belt/rogue/leather
			shoes = /obj/item/clothing/shoes/roguetown/boots/leather
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/appraise/secular)

		if("Noble")
			ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
			if(should_wear_femme_clothes(H))
				r_hand = /obj/item/rogueweapon/mace/parasol
				belt = /obj/item/storage/belt/rogue/leather/cloth/lady
				armor = /obj/item/clothing/suit/roguetown/shirt/dress/gown/wintergown
				shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
				id = /obj/item/clothing/ring/signet
				shoes = /obj/item/clothing/shoes/roguetown/shortboots
			else
				pants = /obj/item/clothing/under/roguetown/tights
				armor = /obj/item/clothing/suit/roguetown/shirt/tunic/noblecoat
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/lowcut
				shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
				belt = /obj/item/storage/belt/rogue/leather
				id = /obj/item/clothing/ring/signet

/obj/item/clothing/cloak/sleevedtabard/patron
	name = "patron's overcoat"
