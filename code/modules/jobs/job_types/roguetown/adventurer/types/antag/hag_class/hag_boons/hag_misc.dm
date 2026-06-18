// lifts a treaty-decreed Exile's sunlight brand (/datum/treaty/terms/exile)
/datum/hag_boon/misc/cleanse_exile
	name = "Cleanse - Exile"
	desc = "Usually, a treaty can see someone exiled from civilized lands. With this, we can cleanse that brand and allow them to walk free."
	points = 10

/datum/hag_boon/misc/cleanse_exile/apply_boon_effect(mob/living/L)
	var/datum/component/sunlight_vulnerability/exile/brand = L.GetComponent(/datum/component/sunlight_vulnerability/exile)
	if(brand)
		qdel(brand)
		to_chat(L, span_boldnotice("An ancient bog-magyck seeps beneath my skin, and tangles its way across my lux. The brand of my exile, once sealed to my very being, comes undone."))
	. = ..()

// breaks a treaty-decreed Grave Seal (/datum/treaty/terms/seal_grave), before or after the target's death
/datum/hag_boon/misc/cleanse_grave_seal
	name = "Cleanse - Grave Seal"
	desc = "A treaty can see someone's corpse damned and sealed, complicating resurrection. With this, we can break that seal."
	points = 10

/datum/hag_boon/misc/cleanse_grave_seal/apply_boon_effect(mob/living/L)
	var/cleansed = FALSE
	var/datum/component/grave_seal/seal = L.GetComponent(/datum/component/grave_seal)
	if(seal)
		qdel(seal)
		cleansed = TRUE
	var/datum/component/sunlight_vulnerability/grave_seal/sun_curse = L.GetComponent(/datum/component/sunlight_vulnerability/grave_seal)
	if(sun_curse)
		qdel(sun_curse)
		cleansed = TRUE
	if(cleansed)
		to_chat(L, span_boldnotice("Something old and mossy pries the divine seal from my grave. My death is my own."))
	. = ..()
