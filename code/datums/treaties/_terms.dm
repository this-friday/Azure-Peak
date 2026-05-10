//////////// TERMS
//////////////////
// NOTE: if you're creating a new term type, add it to the #define WARBAND_TERMS list for it to appear as a selectable option in-game
/datum/treaty/terms
	var/name
	var/custom_name					// freeform terms can be renamed
	var/desc
	var/hint						// vague hint shown to non-experts as they view a treaty, rather than the term's actual description

	var/target						// the "source" / primary target
	var/receiver					// the "destination", if relevant
	var/obj_target

	var/list/authorities = list()	// characters listed here must sign before the term is confirmed
	var/list/signatures = list()
	var/minimum_signatures = 1		// minimum signature weight before a term is considered Signed
	var/signature_weight_total = 0	// some signatures are worth more than others
	var/open_signatures = FALSE		// when TRUE, any signature is accepted
	var/warbandlock					// certain terms can only be demanded by certain warbands
	var/signed = FALSE
	var/text = ""					// written text (new laws, freeform demands, etc)
	var/number = 0					// numeric value (tax rates, tribute amounts, etc)
	var/datum/mind/author			// the mind that drafted this term

	var/list/input_fields = list()	// built in build_input_fields()
	var/list/extra = list()			// overflow map for term-specific fields not covered by the standard vars
	var/apply_priority = 0			// term-submission priority in treaty_submission

/datum/treaty/terms/New()
	..()
	input_fields = list()
	extra = list()
	build_input_fields()
	build_authorities()

/datum/treaty/terms/Destroy()
	for(var/datum/treaty/input_field/field in input_fields)
		qdel(field)
	for(var/datum/treaty/authority_resolver/resolver in authorities)
		qdel(resolver)
	input_fields = null
	signatures = null
	authorities = null
	extra = null
	return ..()

// override in subtypes to populate input_fields
/datum/treaty/terms/proc/build_input_fields()
	return

// override in subtypes to add resolver datums into authorities
/datum/treaty/terms/proc/build_authorities()
	return

// override in subtypes to declare incompatibility with an existing active term
// return TRUE to block the new term from being added
/datum/treaty/terms/proc/duplicate_check(datum/treaty/terms/existing)
	return FALSE

// expands any authority_resolver datums in the authorities list into concrete values
/datum/treaty/terms/proc/get_authorities()
	var/list/resolved = list()
	for(var/entry in authorities)
		var/datum/treaty/authority_resolver/resolver = istype(entry, /datum/treaty/authority_resolver) ? entry : null
		if(resolver)
			resolved += resolver.resolve(src)
		else
			resolved += entry
	return resolved

// secondary sort key within the same apply_priority group
// used by treaty_submission to handle ordering edge cases (e.g. remove_law must run high->low)
/datum/treaty/terms/proc/apply_sort_key()
	return 0

// executes a term's actual in-game effects after a treaty is submitted
// returns an announcement string afterwards | return Nothing if you don't want a term's results to be announced
/datum/treaty/terms/proc/apply(obj/item/treaty/treaty)
	return
	
/datum/treaty/terms/proc/get_display_fields()
	var/list/result = list()
	for(var/datum/treaty/input_field/field in input_fields)
		if(istype(field, /datum/treaty/input_field/textarea)) 
			continue	// already shown via term.text block
		if(field.key == "custom_name") 
			continue	// already shown via term name header
		if(field.client_only) 
			continue
		UNTYPED_LIST_ADD(result, list("label" = field.label, "key" = field.key))
	return result

// serializes input fields into a list suitable for the UI
/datum/treaty/terms/proc/serialize_input_fields()
	var/list/result = list()
	for(var/datum/treaty/input_field/field in input_fields)
		UNTYPED_LIST_ADD(result, field.serialize())
	return result


// returns the display info panels for the Term while it's Active (not in a draft, but in the middle/signing section)
// override in subtypes to add term-specific details
/datum/treaty/terms/proc/get_info_blocks()
	return list()

// on certain terms, some signatures can be worth more than others (someone signing off on their own exile, for example) (/datum/treaty/terms/exile/get_signature_weight)
/datum/treaty/terms/proc/get_signature_weight(signer_name)
	return 1

/datum/treaty/terms/proc/can_sign_as_minister(mob/living/carbon/human/user)
	return FALSE

/datum/treaty/terms/proc/on_minister_signed(aide_name)
	return

/datum/treaty/terms/proc/on_signatures_reset()
	return


