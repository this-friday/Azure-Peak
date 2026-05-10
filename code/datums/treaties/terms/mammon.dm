/datum/treaty/terms/cointribute
	name = "Mammon"
	desc = "A tribute of coin. Coin may be demanded at an excess beyond a target's coffers - at which point they are sunk into a deficit."
	hint = "...there's a few details about an exchange of mammon..."
	authorities = list("target")

/datum/treaty/terms/cointribute/build_input_fields()
	var/datum/treaty/input_field/faction_dropdown/payer = new()
	payer.key = "target"
	payer.label = "Payer"
	payer.placeholder = "Select Faction..."
	payer.exclude_key = "receiver"
	input_fields += payer

	var/datum/treaty/input_field/faction_dropdown/recipient = new()
	recipient.key = "receiver"
	recipient.label = "Recipient"
	recipient.placeholder = "Select Faction..."
	recipient.exclude_key = "target"
	input_fields += recipient

	var/datum/treaty/input_field/number/amount = new()
	amount.key = "number"
	amount.label = "Amount"
	amount.min_value = 1
	amount.max_value = 20000
	input_fields += amount

/datum/treaty/terms/cointribute/duplicate_check(datum/treaty/terms/existing)
	if(!istype(existing, /datum/treaty/terms/cointribute))
		return FALSE
	return src.target == existing.target && src.receiver == existing.receiver

/datum/treaty/terms/cointribute/apply(obj/item/treaty/treaty)
	if(!src.target || !src.receiver || !src.number)
		return
	if(src.target == src.receiver)
		treaty.visible_message(span_danger("...but one of the terms yet remains in the flame. A faction cannot pay tribute to itself."))
		return

	var/datum/territory_faction/source_faction = treaty.text_to_faction(src.target)
	var/datum/territory_faction/dest_faction = treaty.text_to_faction(src.receiver)

	if(!source_faction || !dest_faction)
		treaty.visible_message(span_danger("...but one of the terms yet remains in the flame. A faction expected to be involved in tribute either dissolved before said tribute could be made, or never existed to begin with."))
		return

	if(source_faction.name == "The Crown")
		if(SStreasury.treasury_value >= src.number)
			SStreasury.withdraw_money_treasury(src.number, "Treaty Tribute")
			if(dest_faction.name == "The Crown")
				SStreasury.give_money_treasury(src.number, "Treaty Tribute")
			else
				dest_faction.vault += src.number
		else
			var/amount_available = SStreasury.treasury_value
			var/deficit = src.number - amount_available
			SStreasury.withdraw_money_treasury(amount_available, "Treaty Tribute")
			if(dest_faction.name == "The Crown")
				SStreasury.give_money_treasury(amount_available, "Treaty Tribute")
			else
				dest_faction.vault += amount_available
			SStreasury.treasury_value = -deficit
			SStreasury.log_to_steward("-[deficit] deficit from excess Treaty demands.")
	else
		var/amount_to_transfer = max(0, source_faction.vault)
		if(dest_faction.name == "The Crown")
			SStreasury.give_money_treasury(amount_to_transfer, "Treaty Tribute")
		else
			dest_faction.vault += amount_to_transfer
		source_faction.vault -= src.number
	return
