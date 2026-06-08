/obj/item/treaty
	name = "treaty"
	desc = "An aged scroll of parchment tightly bound by a ribbon. Across the ribbon, countless prayers to order are inscribed in a faded, crimson script. \
	It's a disquieting thing; warm to the touch as if one is holding sun-scorched leather, and accompanied by a faint stench of ash."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "scroll_closed"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

	// a treaty's "first party" and "second party" are just flavor. it's possible that none of the listed terms could apply to either of them
	var/firstparty		// the first party in the treaty
	var/secondparty		// the second party in the treaty

	var/list/terms = list()				// all potential terms
	var/list/active_terms = list()		// the actual, written terms on a treaty
	var/list/warband_sources = list()	// treaties from certain warbands & aspects can have unique terms
	var/list/user_cooldowns = list()
	var/list/job_titles = list()

/obj/item/treaty/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("<span style='color:#e8bf67'>OPEN:</span> Unroll the treaty by resizing the window.")
	. += span_info("<span style='color:#e8bf67'>DRAFT:</span> Holding a feather in your off-hand, choose terms from the 'Available Terms' section in order to draft them.")
	. += span_info("<span style='color:#e8bf67'>SIGN:</span> The relevant authorities for a Term must sign within the 'Active Terms' section.")
	. += span_info("<span style='color:#e8bf67'>FINALIZE:</span> Hurling a completed treaty into an open flame at dawn will finalize it.")
	. += span_info("<span style='color:#e8bf67'>SWIFT FINALIZE:</span> Invoke the Ignition miracle upon a completed treaty.")
	. += span_info("<span style='color:#ae1919'>BEWARE I:</span> If a single term is unsigned, finalization will fail. Freeform terms are exceptions.")
	. += span_info("<span style='color:#ae1919'>BEWARE II:</span> Burning a treaty at any time BESIDES dawn will result in failure. Only a SWIFT FINALIZE can circumvent this requirement.")
	. += span_info("<span style='color:#ae1919'>BEWARE III:</span> Drafting a new Term will un-sign all signed terms.")

/obj/item/treaty/Initialize()
	..()
	for(var/term_option in WARBAND_TERMS)
		terms += new term_option
	SSwarbands.treaties += src

/obj/item/treaty/spark_act()
	fire_act()

/obj/item/treaty/Destroy()
	SSwarbands.treaties -= src
	for(var/datum/treaty/terms/term in active_terms)
		qdel(term)
	for(var/datum/treaty/terms/term in terms)
		qdel(term)
	active_terms = null
	terms = null
	warband_sources = null
	user_cooldowns = null
	job_titles = null
	return ..()

//////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// ADD UNIQUE TERMS
/*
	when a treaty is spawned by a warband, this proc adds any unique terms the warband might have
*/
/obj/item/treaty/proc/add_unique_terms(atom/movable/screen/warband/manager/warband_manager)
	var/datum/warbands/warband = warband_manager.selected_warband
	if(warband)
		if(istype(warband, /datum/warbands/wizard))
			terms += new /datum/treaty/terms/unique/wizard

////////////////////////////////////////////////////////////
///////////////////////////////////////////////// GET WEALTH
/*
	get a faction's vault for the treaty's "Wealth" display
	the town's faction vault is directly linked to its treasury
	for everyone else, it just returns the actual vault value from their faction datum
*/
/obj/item/treaty/proc/get_wealth(faction_name)
	if(faction_name == "The Crown")
		return SStreasury.discretionary_fund.balance
	for(var/datum/treaty_flavor/faction in SSwarbands.treaty_flavor_factions)
		if(faction.name == faction_name)
			return faction.vault
	return FALSE

/obj/item/treaty/attack_self(mob/user)
	ui_interact(user)

/obj/item/treaty/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/natural/feather))
		return attack_self(user)
	return ..()

//////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// HELPERS

// adding or editing a term unsigns all others
/obj/item/treaty/proc/unsign_all_terms()
	if(active_terms.len)
		for(var/datum/treaty/terms/term in src.active_terms)
			term.signed = FALSE
			term.signatures.Cut()
			term.on_signatures_reset()
			term.signature_weight_total = 0

/obj/item/treaty/proc/apply_params_to_term(datum/treaty/terms/term, list/params)
	if(params["text"])
		term.text = params["text"]
	if(params["number"])
		var/n = text2num(params["number"])
		if(n)
			term.number = n
	if(params["target"])
		term.target = params["target"]
	if(params["receiver"])
		term.receiver = params["receiver"]
	if(params["obj_target"])
		term.obj_target = params["obj_target"]
	if(params["custom_name"])
		term.custom_name = params["custom_name"]
	var/list/standard_keys = list("text", "number", "target", "receiver", "obj_target", "custom_name")
	for(var/key in params)
		if(!(key in standard_keys))
			term.extra[key] = params[key]

// compares the provided term against the rest of the treaty's active terms to search for duplicates
/obj/item/treaty/proc/check_duplicate_term(datum/treaty/terms/new_term, skip_index)
	for(var/i = 1 to active_terms.len)
		if(skip_index && i == skip_index)
			continue
		var/datum/treaty/terms/existing = active_terms[i]
		if(new_term.duplicate_check(existing))
			return TRUE
	return FALSE

/obj/item/treaty/proc/get_display_name(authority)
	if(ispath(authority))
		if(!(authority in job_titles))
			if(ispath(authority, /datum/job))
				job_titles[authority] = initial(authority:title)
			else if(ispath(authority, /datum/migrant_role))
				job_titles[authority] = initial(authority:name)
			else
				job_titles[authority] = "[authority]"
		return job_titles[authority]
	return authority
