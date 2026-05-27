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

/datum/warbands/aspects/marked/on_grunt_spawned(mob/living/carbon/human/grunt, atom/movable/screen/warband/manager/manager)
	var/max_assassins = manager.aspect_intensities["/datum/warbands/aspects/marked"] || 1
	max_assassins = 2 + (max_assassins - 1) * 2
	if(manager.marked_assassin_count >= max_assassins && prob(50))
		return // until we reach the assassin cap, there's a 50% chance that a spawning Grunt becomes an assassin

	var/mob/living/carbon/human/warlord
	for(var/mob/living/carbon/human/member in manager.members)
		if(member.mind?.special_role == "Warlord")
			warlord = member
			break

	if(!warlord)
		return

	manager.marked_assassin_count++

	var/datum/antagonist/warband/grunt/grunt_antag
	var/datum/objective/warband/assassin/kill_objective = new

	kill_objective.owner = grunt.mind
	kill_objective.target = warlord.mind

	for(var/datum/antagonist/antag in grunt.mind.antag_datums)
		if(istype(antag, /datum/antagonist/warband/grunt))
			grunt_antag = antag
			break
	grunt_antag.objectives |= kill_objective
	grunt.mind.announce_objectives()

	to_chat(grunt, span_userdanger("The Warlord must die. That, I know."))
