////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// up to two grunts are given an objective to kill the Warlord

/datum/warbands/aspects/marked
	title = "MARKED"
	summary = "Assassins lurk in the Warband's ranks. Their sole mission is to murder the Warlord."
	desc = "Up to 2 grunts are given an objective to kill the Warlord. Each rank of intensity allows an additional 2 assassins."
	warning = "...of a plot to kill their own Warlord."
	points = 1
	max_intensity = 3

/datum/warbands/aspects/marked/get_points_at_intensity(intensity)
	return intensity

/datum/warbands/aspects/marked/on_grunt_spawned(mob/living/carbon/human/grunt, datum/warband_manager/manager)
	var/intensity_rank = manager.aspect_intensities["[src.type]"] || 1
	var/max_assassins = 2 + (intensity_rank - 1) * 2
	if(manager.marked_assassin_count >= max_assassins)
		return // hard cap based on the chosen intensity (minimum of 2)
	if(!prob(50))
		return // until the cap is reached, each spawning Grunt has a 50% chance of becoming an assassin

	var/mob/living/carbon/human/warlord
	for(var/mob/living/carbon/human/member in manager.members)
		if(member.mind?.special_role == ROLE_WARLORD)
			warlord = member
			break

	if(!warlord)
		return

	var/datum/antagonist/warband/grunt/grunt_antag
	for(var/datum/antagonist/antag in grunt.mind.antag_datums)
		if(istype(antag, /datum/antagonist/warband/grunt))
			grunt_antag = antag
			break
	if(!grunt_antag)
		return

	manager.marked_assassin_count++

	var/datum/objective/warband/assassin/kill_objective = new
	kill_objective.owner = grunt.mind
	kill_objective.target = warlord.mind
	grunt_antag.objectives |= kill_objective
	grunt.mind.announce_objectives()

	to_chat(grunt, span_userdanger("The Warlord must die. That, I know."))
