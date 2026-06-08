/obj/item/treaty/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/treaty_icons)
	)

/obj/item/treaty/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TreatyMenu")
		ui.open()

/obj/item/treaty/ui_data(mob/user)
	var/list/data = ..()
	var/user_role = user.job
	var/user_name = user.real_name
	var/is_expert = HAS_TRAIT(user, TRAIT_LAWEXPERT)
	data["user_name"] = user_name
	data["user_role"] = user_role
	data["is_expert"] = is_expert

	var/datum/asset/spritesheet/spritesheet = get_asset_datum(/datum/asset/spritesheet/treaty_icons)

	if(firstparty)
		for(var/datum/treaty_flavor/faction in SSwarbands.treaty_flavor_factions)
			if(faction.name == firstparty)
				data["firstparty"] = list(
					"name" = faction.name,
					"desc" = faction.desc,
					"type" = faction.type,
					"icon" = spritesheet.icon_class_name(sanitize_css_class_name("factionicon_[REF(faction)]")),
					"owner" = faction.owner,
					"vault" = get_wealth(faction.name)
				)
				break

	if(secondparty)
		for(var/datum/treaty_flavor/faction in SSwarbands.treaty_flavor_factions)
			if(faction.name == secondparty)
				data["secondparty"] = list(
					"name" = faction.name,
					"desc" = faction.desc,
					"type" = faction.type,
					"icon" = spritesheet.icon_class_name(sanitize_css_class_name("factionicon_[REF(faction)]")),
					"owner" = faction.owner,
					"vault" = get_wealth(faction.name)
				)
				break

	var/list/current_terms = list()
	if(active_terms)
		var/i = 1
		for(var/datum/treaty/terms/term in active_terms)
			var/display_name = is_expert ? (term.custom_name ? term.custom_name : term.name) : "???"
			var/display_desc = is_expert ? term.desc : term.hint
			var/list/display_names = list()
			if(islist(term.authorities))
				for(var/authority_name in term.get_authorities())
					display_names += get_display_name(authority_name)
			UNTYPED_LIST_ADD(current_terms, list(
				"name" = display_name,
				"original_name" = term.name,
				"desc" = display_desc,
				"text" = term.text,
				"number" = term.number,
				"signed" = term.signed,
				"target" = term.target,
				"receiver" = term.receiver,
				"obj_target" = term.obj_target,
				"open_signatures" = term.open_signatures,
				"authorities" = display_names,
				"signatures" = term.signatures,
				"minimum_signatures" = term.minimum_signatures,
				"index" = i - 1,
				"inputs" = term.serialize_input_fields(),
				"display_fields" = term.get_display_fields(),
				"info_blocks" = term.get_info_blocks(),
			))
			i++
	data["terms"] = current_terms
	return data

/obj/item/treaty/ui_static_data(mob/user)
	var/list/data = ..()
	var/datum/asset/spritesheet/spritesheet = get_asset_datum(/datum/asset/spritesheet/treaty_icons)

	var/list/faction_list = list()
	for(var/datum/treaty_flavor/faction in SSwarbands.treaty_flavor_factions)
		var/show_faction = FALSE
		if(faction.type in DEFAULT_TREATY_FLAVOR_FACTIONS)
			show_faction = TRUE
		else if(faction.owner == user.real_name)
			show_faction = TRUE
		else if(user.real_name in faction.member_names)
			show_faction = TRUE
		else if(firstparty == faction.name || secondparty == faction.name)
			show_faction = TRUE
		if(show_faction)
			UNTYPED_LIST_ADD(faction_list, list(
				"name" = faction.name,
				"desc" = faction.desc,
				"owner" = faction.owner,
				"job_owner" = get_display_name(faction.job_owner),
				"type" = faction.type,
				"icon" = spritesheet.icon_class_name(sanitize_css_class_name("factionicon_[REF(faction)]"))
			))
	data["backend_factions"] = faction_list

	var/list/all_terms = list()
	for(var/datum/treaty/terms/term in terms)
		UNTYPED_LIST_ADD(all_terms, list(
			"name" = term.name,
			"desc" = term.desc,
			"hint" = term.hint,
			"open_signatures" = term.open_signatures,
			"inputs" = term.serialize_input_fields(),
		))
	data["all_terms"] = all_terms

	return data

/obj/item/treaty/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/living/user = usr
	var/user_key = user.ckey
	if(user_cooldowns[user_key] && world.time < user_cooldowns[user_key])
		return TRUE
	user_cooldowns[user_key] = world.time + 10

	var/user_name = user.real_name
	var/has_feather = FALSE
	if(istype(user.get_active_held_item(), /obj/item/natural/feather) || istype(user.get_inactive_held_item(), /obj/item/natural/feather))
		has_feather = TRUE
	var/is_expert = HAS_TRAIT(user, TRAIT_LAWEXPERT)
	var/list/write_sounds = list(
		'sound/misc/warband/treaty_create.ogg',
		'sound/misc/warband/treaty1.ogg',
		'sound/misc/warband/treaty2.ogg'
	)
	var/chosen_sound = pick(write_sounds)

	if(params["text"])
		params["text"] = sanitize(copytext(params["text"], 1, MAX_MESSAGE_LEN))
	if(params["custom_name"])
		params["custom_name"] = sanitize(copytext(params["custom_name"], 1, MAX_MESSAGE_LEN))

	var/original_name
	if(user.mind?.original_char)
		var/mob/living/original = user.mind.original_char
		original_name = original.real_name

	if(!has_feather)
		to_chat(user, span_warning("I should be holding a quill."))
		return FALSE
	if(!is_expert && action != "sign_term")
		to_chat(user, span_warning("I can't make heads or tails of this."))
		return FALSE

	switch(action)
		if("sign_term")
			var/term_index = text2num(params["index"]) + 1
			if(!term_index || term_index < 1 || term_index > active_terms.len)
				return
			var/datum/treaty/terms/term_to_sign = active_terms[term_index]
			if(term_to_sign.signed)
				to_chat(user, span_warning("It's already signed."))
				return
			if(user_name in term_to_sign.signatures)
				to_chat(user, span_warning("I've already signed this."))
				return

			var/is_authority = FALSE
			var/is_signing_as_minister = FALSE

			if(term_to_sign.open_signatures)
				is_authority = TRUE
			else
				var/list/auth_list = term_to_sign.get_authorities()

				for(var/auth in auth_list)
					if(ispath(auth))
						if(ispath(user.job_path, auth))
							is_authority = TRUE
							break
						if(!is_authority && ispath(user.mind?.original_char?.job_path, auth))
							is_authority = TRUE
							break
				// if a term has a 'target' listed as an authority & they match the term's .target name, they're an authority
				if(!is_authority && auth_list.Find("target"))
					if(term_to_sign.target == user_name || (original_name && term_to_sign.target == original_name))
						is_authority = TRUE
					else
						for(var/datum/treaty_flavor/faction in SSwarbands.treaty_flavor_factions)
							if(faction.name == term_to_sign.target)
								if(ismob(faction.owner) && faction.owner == user)
									is_authority = TRUE
								else if(faction.owner == user_name || (original_name && faction.owner == original_name))
									is_authority = TRUE
								else if(ispath(faction.job_owner, user.job_path) || (user.mind?.original_char && ispath(faction.job_owner, user.mind.original_char.job_path)))
									is_authority = TRUE
								break

				// if a term has a 'target' listed as an authority & they match the term's .target name, they're an authority
				if(!is_authority && auth_list.Find("receiver"))
					if(term_to_sign.receiver == user_name || (original_name && term_to_sign.receiver == original_name))
						is_authority = TRUE
					else
						for(var/datum/treaty_flavor/faction in SSwarbands.treaty_flavor_factions)
							if(faction.name == term_to_sign.receiver)
								if(ismob(faction.owner) && faction.owner == user)
									is_authority = TRUE
								else if(faction.owner == user_name || (original_name && faction.owner == original_name))
									is_authority = TRUE
								else if(ispath(faction.job_owner, user.job_path) || (user.mind?.original_char && ispath(faction.job_owner, user.mind.original_char.job_path)))
									is_authority = TRUE
								break

				// if a term has 'Minister' listed as an authority for a Reformation term (/datum/treaty/terms/regime_change), we check if they're a viable authority for this
				if(!is_authority && auth_list.Find("Minister"))
					if(term_to_sign.can_sign_as_minister(user))
						is_authority = TRUE
						is_signing_as_minister = TRUE

			if(is_authority)
				var/signature_name = original_name ? original_name : user_name
				term_to_sign.signatures += signature_name
				term_to_sign.signature_weight_total += term_to_sign.get_signature_weight(signature_name)
				if(is_signing_as_minister)
					term_to_sign.on_minister_signed(signature_name)
				if(!term_to_sign.open_signatures && term_to_sign.signature_weight_total >= term_to_sign.minimum_signatures)
					term_to_sign.signed = TRUE
				playsound(src, chosen_sound, 100, TRUE, -1)
				visible_message(span_warning("[usr] signs something on the treaty."))
				. = TRUE

		if("add_term")
			if(active_terms.len >= 10)
				to_chat(user, span_warning("The parchment is full."))
				return FALSE
			var/term_name = params["name"]
			if(!term_name)
				return
			for(var/datum/treaty/terms/prototype in terms)
				if(prototype.name != term_name)
					continue
				var/datum/treaty/terms/new_term = new prototype.type()
				apply_params_to_term(new_term, params)
				if(check_duplicate_term(new_term))
					to_chat(user, span_warning("This term conflicts with an existing term on the treaty."))
					qdel(new_term)
					return FALSE
				active_terms += new_term
				new_term.author = user.mind?.original_char?.mind || usr.mind
				unsign_all_terms()
				. = TRUE
				playsound(src, chosen_sound, 100, TRUE, -1)
				visible_message(span_warning("[usr] adds something to the treaty."))
				break

		if("edit_term")
			var/term_index = text2num(params["index"]) + 1
			var/term_name = params["name"]
			if(!term_name || !term_index || term_index < 1 || term_index > active_terms.len)
				return
			for(var/datum/treaty/terms/prototype in terms)
				if(prototype.name != term_name)
					continue
				var/datum/treaty/terms/new_term = new prototype.type()
				apply_params_to_term(new_term, params)
				if(check_duplicate_term(new_term, term_index))
					to_chat(user, span_warning("This term conflicts with an existing term on the treaty."))
					qdel(new_term)
					return FALSE
				qdel(active_terms[term_index])
				active_terms[term_index] = new_term
				new_term.author = user.mind?.original_char?.mind || usr.mind
				unsign_all_terms()
				. = TRUE
				playsound(src, 'sound/items/write.ogg', 100, FALSE)
				visible_message(span_warning("[usr] alters something on the treaty."))
				break

		if("set_party")
			var/faction_name = params["name"]
			var/party_id = text2num(params["party_id"])
			if(party_id == 1 && secondparty == faction_name)
				to_chat(user, span_warning("A faction cannot serve as both parties!"))
				return FALSE
			if(party_id == 2 && firstparty == faction_name)
				to_chat(user, span_warning("A faction cannot serve as both parties!"))
				return FALSE
			var/datum/treaty_flavor/found_faction
			for(var/datum/treaty_flavor/faction in SSwarbands.treaty_flavor_factions)
				if(faction.name == faction_name)
					found_faction = faction
					break
			if(found_faction)
				if(party_id == 1)
					firstparty = faction_name
				else
					secondparty = faction_name
				. = TRUE
				playsound(src, 'sound/misc/warband/treaty3.ogg', 100, TRUE, -1)
				visible_message(span_warning("[usr] adds something to the treaty."))

		if("remove_term")
			var/term_index = text2num(params["index"]) + 1
			if(!term_index || term_index < 1 || term_index > active_terms.len)
				return
			var/datum/treaty/terms/term_to_remove = active_terms[term_index]
			active_terms.Remove(term_to_remove)
			qdel(term_to_remove)
			unsign_all_terms()
			playsound(src, 'sound/misc/warband/treaty_cancel.ogg', 100, TRUE, -1)
			visible_message(span_warning("[usr] scratches something out on the treaty."))
			. = TRUE

	if(.)
		ui_interact(user)
