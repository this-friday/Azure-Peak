///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// TERM: ABOLISH LAW
/*
	removes the law w/the given number
	it could technically just be reworded & reinstated, but preventing that code-wise is futile, so we're just not gonna worry about it
	
*/
/datum/treaty/terms/remove_law
	name = "Abolish Law"
	authorities = list(/datum/job/roguetown/lord, /datum/job/roguetown/hand, /datum/job/roguetown/marshal)
	desc = "A law is chosen to be abolished."
	hint = "...something about abolishing a law..."
	apply_priority = -10 // must ALWAYS run before codify_law, otherwise the numbers switching around mid-submission results in Shit Getting Lowkirkenuinely Fucked

/datum/treaty/terms/remove_law/build_input_fields()
	var/datum/treaty/input_field/number/law_num = new()
	law_num.key = "number"
	law_num.label = "Law Number"
	law_num.min_value = 1
	law_num.max_value = 99
	input_fields += law_num

/datum/treaty/terms/remove_law/duplicate_check(datum/treaty/terms/existing)
	if(!istype(existing, /datum/treaty/terms/remove_law))
		return FALSE
	return number == existing.number

/datum/treaty/terms/remove_law/apply_sort_key()
	return -number

/datum/treaty/terms/remove_law/apply(obj/item/treaty/treaty)
	if(GLOB.laws_frozen || !number)
		return
	if(number in GLOB.codified_laws)
		return
	if(number >= 1 && number <= length(GLOB.laws_of_the_land) && GLOB.laws_of_the_land[number])
		var/law_text = remove_law(number, silent = TRUE)
		if(law_text)
			return "Law [number] abolished: [law_text]"
	else
		treaty.visible_message(span_warning("...but one of the terms yet remains in the flame. It seems law [number] doesn't exist, and thus cannot be abolished."))
	return
