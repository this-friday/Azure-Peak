/datum/treaty/terms/freeze_laws
	name = "Freeze Laws"
	authorities = list(/datum/job/roguetown/lord)
	desc = "No law can be instated or erased for the forseeable future."
	hint = "...something about something else getting frozen..."

/datum/treaty/terms/freeze_laws/duplicate_check(datum/treaty/terms/existing)
	return type == existing.type

/datum/treaty/terms/freeze_laws/apply(obj/item/treaty/treaty)
	GLOB.laws_frozen = TRUE
	return "In our ruler's infinite wisdom, all present laws have been frozen. So long as the Sun rises, no change shall be permitted."
