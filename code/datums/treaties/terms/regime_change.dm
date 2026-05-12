/////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// TERM: REGIME CHANGE
/*
	changes the realm's declared governing style as if a usurpation rite was completed
	the ruler, however, isn't overthrown. they're just expected to play into the new theme

	to enforce this, two signatures are required from characters who would otherwise be assent-capable for the chosen usurpation style

	beyond this the ruler themselves doesn't need to meet the requirements

	as a treat, this also technically allows the Duke to play around with the usurpation rites (as they themselves are the only non-antagonist who starts with a Treaty)
*/
/datum/treaty/terms/regime_change
	name = "Reformation"
	desc = "The current ruler shall adopt the prescribed form of governance, and elevate Ministers to act as advisors for the new regime. The ruler themselves is NOT overthrown."
	hint = "...something about changing how the realm is governed..."
	authorities = list()
	minimum_signatures = 3
	var/list/minister_signatures = list() // separate tracker for Minister signatures

	// psydonian tribunal & sacred supercession are currently excluded, as they're VERY closely tied to the Inquisitor & Bishop respectively
	// there's merit to a more generic Theocracy, but that's currently out of scope as writing flavortext for each god would boil my psyche
	var/static/list/style_to_rite = list(
		"Grand Duchy" =				/datum/usurpation_rite/solar_succession,
		"Merchant Republic"	=		/datum/usurpation_rite/golden_accord,
		"Republic" =				/datum/usurpation_rite/popular_acclaim,
		"Progressive Dominion" =	/datum/usurpation_rite/progressive_dominion,
		"Magocracy" =				/datum/usurpation_rite/lunar_ascension,
		"Stratocracy" =				/datum/usurpation_rite/martial_supercession,
	)

	var/static/list/style_info_cache = list()

// builds authorities via by_field resolver, so the minister count can vary by the chosen style
/datum/treaty/terms/regime_change/build_authorities()
	var/datum/treaty/authority_resolver/by_field/resolver = new()
	resolver.field_key = "target"
	resolver.mapping["Republic"] = list(/datum/job/roguetown/lord, "Minister", "Minister", "Minister", "Minister")
	resolver.fallback = list(/datum/job/roguetown/lord, "Minister", "Minister")
	authorities += resolver

// minimum_signatures should stay in sync with the length of the Required Authorities here (and only here, generally)
/datum/treaty/terms/regime_change/get_authorities()
	var/list/resolved = ..()
	minimum_signatures = resolved.len
	return resolved

/datum/treaty/terms/regime_change/Destroy()
	minister_signatures = null
	return ..()

/datum/treaty/terms/regime_change/build_input_fields()
	var/datum/treaty/input_field/option_dropdown/style = new()
	style.key = "target"
	style.label = "Governance Style"
	style.options = list(
		"Grand Duchy",
		"Merchant Republic",
		"Republic",
		"Progressive Dominion",
		"Magocracy",
		"Stratocracy",
	)
	input_fields += style

	var/datum/treaty/input_field/display/info = new()
	info.key = "style_info"
	info.display_key = "target"
	info.placeholder = "Select a governance style to see details."
	for(var/governance_style in style_to_rite)
		if(!style_info_cache[governance_style])
			var/rite_type = style_to_rite[governance_style]
			var/datum/usurpation_rite/rite = new rite_type()
			var/list/blocks = list()
			UNTYPED_LIST_ADD(blocks, list("label" = governance_style, "text" = (rite.reformation_desc || rite.desc)))
			var/minister_text = rite.minister_eligibility_hint
			if(rite.minister_restriction_hint)
				minister_text += (minister_text ? "\n" : "") + rite.minister_restriction_hint
			if(minister_text)
				UNTYPED_LIST_ADD(blocks, list("label" = "Who Serves as a Minister?", "text" = minister_text))
			style_info_cache[governance_style] = blocks
			qdel(rite)
		info.content_map[governance_style] = style_info_cache[governance_style]
	input_fields += info

/datum/treaty/terms/regime_change/duplicate_check(datum/treaty/terms/existing)
	return istype(existing, /datum/treaty/terms/regime_change)

// returns TRUE if the provided mob qualifies to act as a Minister for the chosen governance style
/datum/treaty/terms/regime_change/proc/check_minister_eligibility(mob/living/carbon/human/user)
	var/rite_type = style_to_rite[target]
	if(!rite_type)
		return FALSE
	var/datum/usurpation_rite/rite = new rite_type()
	var/result = rite.can_assent(user)
	qdel(rite)
	return result

/datum/treaty/terms/regime_change/can_sign_as_minister(mob/living/carbon/human/user)
	if(minister_signatures.len >= minimum_signatures - 1)
		return FALSE
	return check_minister_eligibility(user)

/datum/treaty/terms/regime_change/on_minister_signed(minister_name)
	minister_signatures += minister_name

/datum/treaty/terms/regime_change/on_signatures_reset()
	minister_signatures = list()

/datum/treaty/terms/regime_change/get_info_blocks()
	if(!target)
		return list()
	return style_info_cache[target] || list()


/datum/treaty/terms/regime_change/apply(obj/item/treaty/treaty)
	if(!target)
		return

	var/rite_type = style_to_rite[target]
	if(!rite_type)
		treaty.visible_message(span_danger("...but one of the terms yet remains in the flame. A real '[target]', it seems, has never worked."))
		return

	var/datum/usurpation_rite/rite = new rite_type()
	var/new_title = rite.new_ruler_title
	var/new_title_f = rite.new_ruler_title_f
	var/new_realm_type = rite.new_realm_type
	var/new_realm_short = rite.new_realm_type_short
	var/minister_title = rite.new_minister_title
	var/minister_title_f = rite.new_minister_title_f
	var/roundend_epilogue = rite.roundend_epilogue
	qdel(rite)

	// return if we're attempting to regime change to the regime style we're already under (?)
	if(SSticker.realm_type == new_realm_type)
		treaty.visible_message(span_warning("...but one of the terms yet remains in the flame. The realm is already governed as a [new_realm_type]."))
		return

	var/datum/job/roguetown/lord_job = SSjob.GetJob("Grand Duke")
	if(lord_job)
		lord_job.display_title = new_title
		lord_job.f_title = new_title_f

	SSticker.realm_type = new_realm_type
	SSticker.realm_type_short = new_realm_short
	if(SSticker.rulermob)
		SSticker.set_ruler_mob(SSticker.rulermob)

	if(roundend_epilogue)
		SSticker.roundend_epilogue = roundend_epilogue

	SStreasury.abolished_decree_ids = list()

	// combs through the human list to find the Ministers, and applies their relevant title
	if(minister_title && minister_signatures.len)
		for(var/mob/living/carbon/human/found_minister in GLOB.human_list)
			if(!(found_minister.real_name in minister_signatures) || !found_minister.mind)
				continue
			var/given_title = (found_minister.gender == FEMALE && minister_title_f) ? minister_title_f : minister_title
			found_minister.job = given_title

	// announcement section
	var/bossman = SSticker.rulermob ? SSticker.rulermob.real_name : "they"
	var/addendum = ""
	if(minister_title && minister_signatures.len)
		if(minister_signatures.len == 1)
			addendum = "To this end, [minister_signatures[1]] has been appointed as a [minister_title]"
		else
			var/list/name_list = minister_signatures.Copy()
			var/last = name_list[name_list.len]
			name_list.len--
			addendum = "To this end, [name_list.Join(", ")] and [last] have been appointed as [minister_title]s"

	return "As established by treaty and sworn under oath, the land of [SSticker.realm_name] will now govern itself as a [new_realm_type]. \
			Formerly a Grand Duke, [bossman] will now rule as a [new_title]. [addendum]."
