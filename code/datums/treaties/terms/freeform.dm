/datum/treaty/terms/freeform
	name = "Freeform"
	desc = "As written."
	hint = "...something I truly can't make heads or tails of..."
	open_signatures = TRUE

/datum/treaty/terms/freeform/build_input_fields()
	var/datum/treaty/input_field/text_input/title = new()
	title.key = "custom_name"
	title.label = "Term Title"
	title.placeholder = "Enter Term Title..."
	title.min_length = 3
	input_fields += title

	var/datum/treaty/input_field/textarea/details = new()
	details.key = "text"
	details.label = "Details"
	details.placeholder = "Enter details (5-2048 chars)"
	details.min_length = 5
	details.max_length = 2048
	input_fields += details
