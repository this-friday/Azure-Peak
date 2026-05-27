////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// every lieutenant becomes an aspirant
// if they were already an aspirant, they get an additional objective

/datum/warbands/aspects/envy
	title = "THRONE OF ENVY"
	summary = "We are unified by circumstance, and circumstance alone."
	desc = "All Lieutenants are guaranteed to be Aspirants. If someone was already an Aspirant, they gain an additional objective."
	warning = "...of an inner retinue of backstabbing scum."
	points = 1

/datum/warbands/aspects/envy/on_warband_confirmed(atom/movable/screen/warband/manager/manager, intensity = 1)
	for(var/mob/living/carbon/human/member in manager.lobby_members)
		if(member.mind.special_role != "Lieutenant" && member.mind.special_role != "Aspirant Lieutenant")
			continue

		var/was_already_aspirant = (member.mind.special_role == "Aspirant Lieutenant")
		member.mind.special_role = "Aspirant Lieutenant"

		var/datum/antagonist/warband/lieutenant/lieu_antag
		for(var/datum/antagonist/antag in member.mind.antag_datums)
			if(istype(antag, /datum/antagonist/warband/lieutenant))
				lieu_antag = antag
				break

		lieu_antag.aspirant = TRUE
		var/list/aspirant_objectives = list(
			/datum/objective/warband/aspirant/wormtongue,
			/datum/objective/warband/aspirant/disorder,
			/datum/objective/warband/aspirant/order,
			/datum/objective/warband/aspirant/standard,
			/datum/objective/warband/aspirant/coin
		)
		if(was_already_aspirant)
			for(var/datum/objective/existing_obj in lieu_antag.objectives)
				for(var/obj_type in aspirant_objectives)
					if(istype(existing_obj, obj_type))
						aspirant_objectives -= obj_type
						break
		var/chosen_type = pick(aspirant_objectives)
		var/datum/objective/warband/aspirant/new_objective = new chosen_type
		new_objective.owner = member.mind
		lieu_antag.objectives += new_objective
		member.mind.announce_objectives()

		if(was_already_aspirant)
			to_chat(member, span_userdanger("Throne of Envy has been selected. I have been given an additional objective."))
		else
			to_chat(member, span_userdanger("Throne of Envy has been selected. I am now an Aspirant Lieutenant with my own ambitions."))
