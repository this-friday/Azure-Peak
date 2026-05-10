// authority resolvers let a term's required signatories vary based on a field's value
// an example can be found in /datum/treaty/terms/regime_change/build_authorities()
/datum/treaty/authority_resolver

// returns a list of resolved authority values for the given term
/datum/treaty/authority_resolver/proc/resolve(datum/treaty/terms/term)
	return list()

/datum/treaty/authority_resolver/by_field
	var/field_key = ""
	var/list/mapping = list()
	var/list/fallback = list()

/datum/treaty/authority_resolver/by_field/New()
	..()
	mapping = list()
	fallback = list()

/datum/treaty/authority_resolver/by_field/Destroy()
	mapping = null
	fallback = null
	return ..()

/datum/treaty/authority_resolver/by_field/resolve(datum/treaty/terms/term)
	var/val = term.vars[field_key]
	if(val && (val in mapping))
		return mapping[val]
	return fallback
