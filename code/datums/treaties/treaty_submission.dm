/obj/item/treaty/burn()
	// if(GLOB.tod == "dawn") FIXNOTE: uncommented 4 Ease Of Testing, don't leave this uncommented
	treaty_submission()

// uses the target name provided by the treaty to return a mob
/obj/item/treaty/proc/text_to_mob(target_name)
	if(!target_name)
		return
	for(var/mob/living/found_mob in GLOB.mob_list)
		if(found_mob.real_name == target_name && found_mob.mind)
			return found_mob
	return

// uses the target name provided by the treaty to return a faction
/obj/item/treaty/proc/text_to_faction(target_name)
	if(!target_name)
		return
	for(var/datum/treaty_flavor/faction in SSwarbands.treaty_flavor_factions)
		if(faction.name == target_name)
			return faction
	return

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// TREATY SUBMISSION
// burning a Treaty at dawn will activate it
// every term loaded onto a treaty takes effect
// if a single non-freeform term is unsigned, the entire treaty will fizzle out
/obj/item/treaty/proc/treaty_submission()
	for(var/datum/treaty/terms/term in active_terms)
		if(!term.signed && !term.open_signatures)
			visible_message(span_warning("The treaty crumbles. One or more terms weren't signed."))
			SSwarbands.treaties -= src
			qdel(src)
			return FALSE

	visible_message(span_danger("The treaty evaporates in a flash of divine flame! Summer winds ferry its ashes to the heavens above."))

	// sort terms by (apply_priority ascending, then apply_sort_key ascending)
	var/list/ordered_terms = active_terms.Copy()
	ordered_terms = sortTim(ordered_terms, GLOBAL_PROC_REF(compare_terms_for_apply))

	// run each term's apply() proc and collect any announcement strings
	var/list/announcements = list()
	for(var/datum/treaty/terms/term in ordered_terms)
		var/result = term.apply(src)
		if(result)
			announcements += result

	if(announcements.len)
		priority_announce(announcements.Join("\n"), "AS DEMANDED BY TREATY", 'sound/misc/royal_decree.ogg')

	check_treaty_objectives()
	SSwarbands.treaties -= src
	src.moveToNullspace() // don't destroy it. send it into The Great Nowhere
	SSwarbands.submitted_treaties += src // for posterity
	return TRUE

// sorts ascending by apply_priority, then ascending by apply_sort_key as a tiebreaker
// sortTim uses call(cmp)(), so to avoid runtimes this is a Global Proc
/proc/compare_terms_for_apply(datum/treaty/terms/a, datum/treaty/terms/b)
	if(a.apply_priority != b.apply_priority)
		return a.apply_priority - b.apply_priority
	return a.apply_sort_key() - b.apply_sort_key()

/////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// CHECK LIEUTENANT OBJECTIVES
// objectiveslop
// if a treaty meets certain conditions for an antagonist, this greentexts them
/obj/item/treaty/proc/check_treaty_objectives()
	for(var/datum/treaty/terms/term in active_terms)
		if(term.author)
			var/is_lieutenant = (term.author.special_role == "Lieutenant" || term.author.special_role == "Aspirant Lieutenant")
			var/is_warlord = (term.author.special_role == "Warlord")
			if(is_lieutenant)
				for(var/datum/objective/obj in term.author.get_all_objectives())
					if(istype(obj, /datum/objective/warband/aspirant/standard))
						obj.completed = TRUE
						to_chat(term.author.current, span_notice("One of my objectives has been fulfilled!"))
						break
			if(is_warlord)
				for(var/datum/objective/obj in term.author.get_all_objectives())
					if(istype(obj, /datum/objective/warband/warlord))
						obj.completed = TRUE
						to_chat(term.author.current, span_notice("My objective has been fulfilled!"))
						break
