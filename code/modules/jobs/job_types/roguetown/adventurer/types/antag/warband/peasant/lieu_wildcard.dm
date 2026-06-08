// draws from a pool of every lieutenant class (and, rarely, warlord class) from every warband
// presents 3 options
/datum/advclass/warband/rebellion/lieutenant/wildcard
	title = "WILDCARD"
	name = "Wildcard"
	tutorial = "So long as the WILDCARD is dedicated to the cause, they shall be a welcome ally."
	outfit = /datum/outfit/job/roguetown/warband/rebellion/lieutenant/wildcard
	traits_applied = list(TRAIT_LAWEXPERT, TRAIT_FORMATIONFIGHTER)
	subclass_stats = list(

	)
	subclass_skills = list(

	)

/datum/outfit/job/roguetown/warband/rebellion/lieutenant/wildcard/proc/random_classes()
	var/list/final_class_list = list()
	var/list/all_lieutenant_classes = list()
	var/list/all_warlord_classes = list()
	var/list/excluded_classes = list(
		/datum/advclass/warband/rebellion/lieutenant/wildcard,
		/datum/advclass/warband/mercenary
	)
	
	for(var/datum/warbands/warband as anything in SSwarbands.all_warbands)
		for(var/lieutenant_type in warband.lieutenantclasses)
			var/excluded = FALSE
			for(var/path in excluded_classes)
				if(ispath(lieutenant_type, path))
					excluded = TRUE
					break
			if(!excluded)
				var/datum/advclass/cached = SSwarbands.all_warband_class_types[lieutenant_type]
				if(cached)
					all_lieutenant_classes |= cached

		for(var/warlord_type in warband.warlordclasses)
			var/excluded = FALSE
			for(var/path in excluded_classes)
				if(ispath(warlord_type, path))
					excluded = TRUE
					break
			if(!excluded)
				var/datum/advclass/cached = SSwarbands.all_warband_class_types[warlord_type]
				if(cached)
					all_warlord_classes |= cached

	// roll 3 classes
	// 90% chance for a lieutenant class, 10% for a warlord class
	for(var/i in 1 to 3)
		if(prob(90))
			if(all_lieutenant_classes.len)
				final_class_list += pick(all_lieutenant_classes)
		else
			if(all_warlord_classes.len)
				final_class_list += pick(all_warlord_classes)

	return final_class_list

/datum/outfit/job/roguetown/warband/rebellion/lieutenant/wildcard/pre_equip(mob/living/carbon/human/H)
	..()
	var/list/rolled_classes = random_classes()
	var/datum/advclass/classchoice = input("Choose your class", "WILDCARD") as anything in rolled_classes
	if(istype(classchoice, /datum/advclass))
		classchoice.equipme(H)
