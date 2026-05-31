/datum/advclass/warband/rebellion/grunt/conspirator
	title = "CONSPIRATOR"
	name = "Conspirator"
	tutorial = "The CONSPIRATOR is a citizen of the Azure Peak swayed to a new cause. A valuable thing - for in times like these, there's nothing deadlier than a friendly face."
	outfit = /datum/outfit/job/roguetown/warband/rebellion/grunt/conspirator
	traits_applied = list(TRAIT_DODGEEXPERT, TRAIT_LIGHT_STEP, TRAIT_KEENEARS)
	subclass_stats = list(
		STATKEY_SPD = 4,
		STATKEY_CON = -3,
		STATKEY_INT = 1,
	)
	subclass_skills = list(
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/sneaking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/stealing = SKILL_LEVEL_EXPERT,
	)
	subclass_stashed_items = list(
		"Dagger" = /obj/item/rogueweapon/huntingknife/idagger/steel,
	)

/datum/outfit/job/roguetown/warband/rebellion/grunt/conspirator/pre_equip(mob/living/carbon/human/H)
	..()

	var/coverclass = list("Servant","Sexton","Guildsman","Farmer","Apothecary")
	var/coverclass_choice = input("Before I was inspired to join the Rebellion, I was an unremarkable...", "I REMEMBER") as anything in coverclass
	switch(coverclass_choice)
		if("Servant")
			H.adjust_skillrank_up_to(/datum/skill/craft/cooking, 3, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/crafting, 3, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/sewing, 3, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/medicine, 1, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/reading, 1, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/labor/farming, 2, TRUE)
			var/subclass = list("Butler","Maid","Servant")
			var/subclass_choice = input("They still know me as a...", "I REMEMBER") as anything in subclass
			switch(subclass_choice)
				if("Butler")
					var/datum/outfit/job/roguetown/servant/butler/towner_outfit = new()
					towner_outfit.pre_equip(H)
					H.job = "Manservant"
					H.advjob = "Manservant"

				if("Maid")
					var/datum/outfit/job/roguetown/servant/maid/towner_outfit = new()
					towner_outfit.pre_equip(H)
					H.job = "Maid"
					H.advjob = "Maid"

				if("Servant")
					var/datum/outfit/job/roguetown/servant/servant/towner_outfit = new()
					towner_outfit.pre_equip(H)
					H.job = "Servant"
					H.advjob = "Servant"

		if("Sexton")
			var/datum/outfit/job/roguetown/sexton/groundskeeper/towner_outfit = new()
			towner_outfit.pre_equip(H)
			H.job = "Sexton"
			H.advjob = "Sexton"
			H.adjust_skillrank_up_to(/datum/skill/misc/medicine = 1, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/magic/holy = 2, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/sewing = 2, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/reading = 1, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/crafting = 1, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/cooking = 1, TRUE)

		if("Guildsman")
			var/guild = list("Smith","Artificer","Architect")
			var/guild_choice = input("I was a...", "I REMEMBER") as anything in guild
			switch(guild_choice)
				if("Smith")
					var/datum/outfit/job/roguetown/guildsman/blacksmith/towner_outfit = new()
					towner_outfit.pre_equip(H)
					H.job = "Guild Blacksmith"
					H.advjob = "Guild Blacksmith"
				if("Artificer")
					var/datum/outfit/job/roguetown/guildsman/artificer/towner_outfit = new()
					towner_outfit.pre_equip(H)
					H.job = "Artificer"
					H.advjob = "Artificer"
				if("Architect")
					var/datum/outfit/job/roguetown/guildsman/architect/towner_outfit = new()
					towner_outfit.pre_equip(H)
					H.job = "Architect"
					H.advjob = "Architect"

		if("Farmer")
			var/datum/outfit/job/roguetown/farmer/towner_outfit = new()
			towner_outfit.pre_equip(H)
			if(should_wear_femme_clothes(H))
				H.job = "Soilbride"
				H.advjob = "Soilbride"
			else
				H.job = "Soilson"
				H.advjob = "Soilson"
			H.adjust_skillrank_up_to(/datum/skill/labor/farming = 4, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/labor/butchering = 4, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/wrestling = 3, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/unarmed = 2, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/tanning = 3, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/polearms = 3, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/riding = 3, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/crafting = 2, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/carpentry = 2, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails = 1, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/medicine = 1, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/sewing = 1, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/cooking = 1, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/masonry = 1, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/reading = 1, TRUE)
			H.change_stat("strength", 3)
			H.change_stat("constitution", 1)
			ADD_TRAIT(H, TRAIT_SEEDKNOW, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
		if("Apothecary")
			var/datum/outfit/job/roguetown/apothecary/basic/towner_outfit = new()
			towner_outfit.pre_equip(H)
			H.job = "Apothecary"
			H.advjob = "Apothecary"			
			H.adjust_skillrank_up_to(/datum/skill/misc/medicine = 4, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/reading = 3, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/alchemy = 3, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/polearms = 2, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/sewing = 2, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/wrestling = 1, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/crafting = 1, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/athletics = 1, TRUE)
			H.change_stat("intelligence", 3)
			H.change_stat("perception", 2)
			ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_MEDICINE_EXPERT, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_ALCHEMY_EXPERT, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)
