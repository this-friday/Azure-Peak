//////////// INPUT FIELDS
/////////////////////////
// input field datums define which TSX widgets get rendered during term drafting

/datum/treaty/input_field
	var/key = ""			// which draft state key this populates (target, receiver, obj_target, text, number, custom_name, intermediateTarget)
	var/label = ""			// display label above the widget
	var/placeholder = ""	// the placeholder text in an input field BEFORE it's filled out
	var/required = TRUE		// blocks submission if the field is empty
	var/client_only = FALSE	// frontend state only; never sent in the inscribe payload (e.g. intermediateTarget)
	var/widget_type = ""	// set by subtypes; sent to frontend to pick the right widget
	var/list/clears_keys = list()	// when this field changes, these other field keys get cleared

/datum/treaty/input_field/proc/serialize()
	var/list/data = list(
		"key" 			= key,
		"label" 		= label,
		"placeholder"	= placeholder,
		"required"		= required,
		"client_only"	= client_only,
		"widget"		= widget_type,
		"clears_keys"	= clears_keys.Copy(),
	)
	return data

/datum/treaty/input_field/Destroy()
	clears_keys = null
	return ..()

///////////////////// TEXT INPUT
////////////////////////////////
// a single-line text input box
/datum/treaty/input_field/text_input
	widget_type = "text_input"
	var/min_length = 1

/datum/treaty/input_field/text_input/serialize()
	var/list/data = ..()
	data["min_length"] = min_length
	return data

///////////////////// TEXTAREA
//////////////////////////////
// a large, multi-line text input box
/datum/treaty/input_field/textarea
	widget_type = "textarea"
	var/min_length = 5
	var/max_length = 2048

/datum/treaty/input_field/textarea/serialize()
	var/list/data = ..()
	data["min_length"] = min_length
	data["max_length"] = max_length
	return data

///////////////////// NUMBER INPUT
/datum/treaty/input_field/number
	widget_type = "number_input"
	var/min_value = 1
	var/max_value = 999999
	var/step = 1

/datum/treaty/input_field/number/serialize()
	var/list/data = ..()
	data["min_value"]	= min_value
	data["max_value"]	= max_value
	data["step"]		= step
	return data

///////////////////// FACTION DROPDOWN
//////////////////////////////////////
// populated with all visible factions
/datum/treaty/input_field/faction_dropdown
	widget_type = "faction_dropdown"
	var/exclude_key = ""

/datum/treaty/input_field/faction_dropdown/serialize()
	var/list/data = ..()
	data["exclude_key"] = exclude_key
	return data

///////////////////// OPTION DROPDOWN
/////////////////////////////////////
// a dropdown bar populated with a list of strings
/datum/treaty/input_field/option_dropdown
	widget_type = "option_dropdown"
	var/list/options = list()

/datum/treaty/input_field/option_dropdown/New()
	..()
	options = list()

/datum/treaty/input_field/option_dropdown/Destroy()
	options = null
	return ..()

/datum/treaty/input_field/option_dropdown/serialize()
	var/list/data = ..()
	data["options"] = options.Copy()
	return data

///////////////////// DISPLAY
/////////////////////////////
// a read-only info panel (not an actual input field)
/datum/treaty/input_field/display
	widget_type = "display"
	required = FALSE
	client_only = TRUE
	var/display_key = ""
	var/list/content_map = list()

/datum/treaty/input_field/display/New()
	..()
	content_map = list()

/datum/treaty/input_field/display/Destroy()
	content_map = null
	return ..()

/datum/treaty/input_field/display/serialize()
	var/list/data = ..()
	data["display_key"] = display_key
	data["content_map"] = content_map.Copy()
	return data
