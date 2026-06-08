/datum/treaty_flavor
	var/name = "Warband"
	var/desc = ""
	var/job_owner 			// a job path given to the faction to determine ownership | used in preset factions	
	var/owner				// a real_name given to the faction to determine ownership | used in generated factions
	var/vault				// money (literally not real at all)
	var/list/member_names = list()
	var/icon = 'icons/roguetown/weapons/shields32.dmi'
	var/icon_state = "ironsh"

/datum/treaty_flavor/azure
	name = "The Crown"
	desc = "It is the year 1513, and within the ruins of the Holy Land there yet stands a Grand Duchy."
	job_owner = /datum/job/roguetown/lord
	icon = 'icons/roguetown/weapons/legacy_shield_heraldry.dmi'
	icon_state = "ironsh_azure peak"

/datum/treaty_flavor/heartfelt
	name = "The Heartfelt"
	desc = "Fortune has always been cruel to the Heartfelt."
	job_owner = /datum/migrant_role/heartfelt/lord
	vault = 2
	icon = 'icons/roguetown/weapons/legacy_shield_heraldry.dmi'
	icon_state = "woodsh_peacemaker"

/datum/treaty_flavor/church
	name = "The Holy See"
	desc = "And so must Ten servants be worshipped as Lords; for He is gone, and we cannot remain alone."
	job_owner = /datum/job/roguetown/priest
	vault = 3500
	icon = 'icons/roguetown/weapons/shields32.dmi'
	icon_state = "gsshield"

/datum/treaty_flavor/orthodoxy
	name = "The Orthodoxy"
	desc = "Deep within old halls, older men weep in memory of the eldest God."
	job_owner = /datum/job/roguetown/inquisitor
	vault = 700
	icon = 'icons/roguetown/weapons/shields32.dmi'
	icon_state = "psyshield"

/datum/treaty_flavor/farm
	name = "The Soilfolk"
	desc = "Several families of land-tending yeomen, graciously granted workable soil by the Crown."
	vault = 1500
	job_owner = /datum/job/roguetown/farmer
	icon = 'icons/roguetown/weapons/shields32.dmi'
	icon_state = "deprived"

/datum/treaty_flavor/guild
	name = "The Guild"
	desc = "Stonemasons, tailors and artificers share very little in common. \
	And yet, these little commonalities are pressing enough to see a grand fraternity forged."
	vault = 1500
	job_owner = /datum/job/roguetown/guildmaster
	icon = 'icons/roguetown/weapons/shields32.dmi'
	icon_state = "artificershield"

/datum/treaty_flavor/merchant
	name = "The Merchant"
	desc = "A humble merchant. No more, no less."
	vault = 2000
	job_owner = /datum/job/roguetown/merchant
	icon = 'icons/roguetown/weapons/shields32.dmi'
	icon_state = "bronzeshield"

/datum/treaty_flavor/proc/generate_faction(mob/user, faction_name = "Unknown Domain", faction_desc = "", stewardhidden = FALSE)
	if(user)
		owner = user.real_name	
	var/given_name = faction_name
	var/given_desc = faction_desc

	if(given_name == "Unknown Domain" && user)
		given_name = "[user.real_name]'s Domain"
	if(given_name == "Warband" && user)
		given_name = "[user.real_name]'s Warband"
	
	name = verify_faction_name(given_name, user) // no two names can be the exact same
	desc = "[given_desc]"

	vault = rand(400, 1400)

	var/datum/treaty_flavor/generated_faction = src
	generated_faction.member_names |= user.real_name
	if(owner) // adds the faction to the subsystem's cache
		SSwarbands.name_to_faction_cache[owner] = generated_faction
	if(job_owner)
		SSwarbands.job_to_faction_cache[job_owner] = generated_faction
	SSwarbands.treaty_flavor_factions += generated_faction
	return generated_faction

/datum/treaty_flavor/proc/verify_faction_name(base_name, mob/user)
	var/proposed_name = base_name
	var/counter = 1
	var/name_exists = TRUE
	
	while(name_exists)
		name_exists = FALSE
		for(var/datum/treaty_flavor/faction in SSwarbands.treaty_flavor_factions)
			if(faction.name == proposed_name)
				name_exists = TRUE
				break
		
		if(name_exists)
			counter++
			if(user && user.real_name)
				proposed_name = "[user.real_name]'s [base_name] ([counter])"
			else
				proposed_name = "[base_name] ([counter])"
	
	return proposed_name
