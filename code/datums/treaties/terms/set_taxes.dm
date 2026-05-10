
/////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// TERM: SET TAXES
/*
 	this is probably gonna be gone in a second since I have no idea how the new economy works
	but for pre-parity testing purposes:

*/
/datum/treaty/terms/set_tax
	name = "Adjust Tax Rate"
	desc = "A tax rate established here shall remain for yils."
	hint = "...something about taxes..."

/datum/treaty/terms/set_tax/build_input_fields()
	var/datum/treaty/input_field/option_dropdown/category = new()
	category.key = "target"
	category.label = "Tax Category"
	category.options = list("Nobility", "Yeomanry", "Peasantry", "Clergy")
	input_fields += category

	var/datum/treaty/input_field/number/rate = new()
	rate.key = "number"
	rate.label = "Tax Rate (%)"
	rate.min_value = 1
	rate.max_value = 100
	input_fields += rate

// adjusting the clergy's tax rate requires either the lord OR the priest
// anything else just needs the lord
/datum/treaty/terms/set_tax/build_authorities()
	var/datum/treaty/authority_resolver/by_field/resolver = new()
	resolver.field_key = "target"
	resolver.mapping = list(
		"Clergy" = list(/datum/job/roguetown/lord, /datum/job/roguetown/priest),
	)
	resolver.fallback = list(/datum/job/roguetown/lord)
	authorities += resolver

// same type + same category = duplicate
// same type + different category = fine
/datum/treaty/terms/set_tax/duplicate_check(datum/treaty/terms/existing)
	if(!istype(existing, /datum/treaty/terms/set_tax))
		return FALSE
	return target == existing.target

/datum/treaty/terms/set_tax/apply(obj/item/treaty/treaty)
	if(!target || !number)
		return
	if(target in GLOB.locked_tax_categories)
		return
	if(target in SStreasury.taxation_cat_settings)
		SStreasury.taxation_cat_settings[target]["taxAmount"] = number
		GLOB.locked_tax_categories += target
		SStreasury.log_to_steward("[target] tax set to [number]% and locked, as demanded by a treaty.")
		return "[target] tax set to [number]% and locked!"
	return
