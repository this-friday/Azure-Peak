/datum/treaty/terms/codify_law
	name = "Codify Law"
	authorities = list(/datum/job/roguetown/lord)
	desc = "A codified law cannot be removed."
	hint = "...something about codifying a law..."
	apply_priority = 10 // it's essential that this runs AFTER remove_law

/datum/treaty/terms/codify_law/build_input_fields()
	var/datum/treaty/input_field/textarea/law_text = new()
	law_text.key = "text"
	law_text.label = "Law Text"
	law_text.placeholder = "Enter the law to be codified..."
	law_text.min_length = 5
	law_text.max_length = 2048
	input_fields += law_text

/datum/treaty/terms/codify_law/duplicate_check(datum/treaty/terms/existing)
	if(!istype(existing, /datum/treaty/terms/codify_law))
		return FALSE
	return text == existing.text

/datum/treaty/terms/codify_law/apply(obj/item/treaty/treaty)
	if(GLOB.laws_frozen || !text)
		return
	var/new_law_index = length(GLOB.laws_of_the_land) + 1
	make_law(text, silent = TRUE)
	GLOB.codified_laws += new_law_index
	return "Law [new_law_index] codified: [text]"
