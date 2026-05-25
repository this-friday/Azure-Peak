// every lieutenant becomes an aspirant
// if they were already an aspirant, they get an additional objective
/datum/warbands/aspects/envy
	title = "THRONE OF ENVY"
	summary = "We are unified by circumstance, and circumstance alone."
	desc = "All Lieutenants are guaranteed to be Aspirants."
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

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// the warband's disorder is increased by 4
// opposite of (/datum/warbands/aspects/morale)

/datum/warbands/aspects/splintered
	title = "SPLINTERED"
	summary = "Old grievances have already fractured the warband's chain of command."
	desc = "Begin with +4 Disorder."
	warning = "...of a warband in open disarray. It's a miracle they got here at all."
	points = 1
 
/datum/warbands/aspects/splintered/on_warband_confirmed(atom/movable/screen/warband/manager/manager, intensity = 1)
	manager.disorder += 4

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// the warband's initial exit (aka: before they establish their travel tiles) is based off of quest markers
// this forces the initial exit to a Hard quest marker

/datum/warbands/aspects/badexit
	title = "BAD TRIP"
	summary = "Fate denied an easy path into the Duchy. The Warcamp's initial exit will be someplace awful."
	desc = "By default, the Warband's initial exit is based off of quest markers. BAD TRIP forcibly elects a Hard quest marker."
	warning = "...taking an obscure route into the Duchy."
	points = 1

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
	return 1 + intensity

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

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// reduces the Warlord's stats & removes their Sweep spell
// gives a tiny (1) disorder reduction

/datum/warbands/aspects/figurehead
	title = "FIGUREHEAD"
	summary = "The Warlord's selfless devotion to his Warband has shaped it into a force to be reckoned with. \
	In comparison - and as a single combatant - the Warlord himself is rather weak."
	desc = "The Warlord's STR is capped to 8, and his SPD and CON to 10. On top of that, he loses the Sweep action."
	warning = "...of a driven, beloved leader."
	points = 1

// STR: 8 | SPD: 10 | CON: 10
/datum/warbands/aspects/figurehead/on_warlord_equip(mob/living/carbon/human/warlord, atom/movable/screen/warband/manager/manager)
	if(warlord.mind)
		for(var/obj/effect/proc_holder/spell/sweep_spell in warlord.mind.spell_list)
			if(sweep_spell.name == "Sweep")
				warlord.mind.RemoveSpell(sweep_spell)
		if(warlord.actions)
			for(var/datum/action/spell_action/sweepaction in warlord.actions)
				if(sweepaction.name == "Sweep")
					qdel(sweepaction)
	if(warlord.STASTR > 8)
		warlord.STASTR = 8
	if(warlord.STASPD > 10)
		warlord.STASPD = 10
	if(warlord.STACON > 10)
		warlord.STACON = 10

/datum/warbands/aspects/figurehead/on_warband_confirmed(atom/movable/screen/warband/manager/manager, intensity = 1)
	manager.disorder -= 1

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// selects a random negative aspect

/datum/warbands/aspects/fated_suffering
	title = "FATED SUFFERING"
	summary = "There's nothing we can do."
	desc = "A negative aspect is chosen at random."
	warning = "...of an ill-omen hanging over a wretched, pathetic lot."
	points = 2 // larger point yield, to make this an Actual Choice

/datum/warbands/aspects/fated_suffering/on_warband_confirmed(atom/movable/screen/warband/manager/manager, intensity = 1)
	var/list/selected_types = list()
	var/list/selected_asclasses = list()
	for(var/datum/warbands/aspects/picked in manager.selected_aspects)
		selected_types += picked.type
		if(picked.asclass)
			selected_asclasses += picked.asclass

	// note: this draws from the ENTIRE pool of aspects, not just those that are ordinarily assigned to the warband's current selections
	var/list/available = list()
	for(var/datum/warbands/aspects/candidate in manager.aspects)
		if(istype(candidate, /datum/warbands/aspects/fated_suffering))
			continue
		if(candidate.points <= 0)
			continue // skip positive/bonus aspects
		if(candidate.type in selected_types)
			continue // already selected
		if(candidate.asclass && (candidate.asclass in selected_asclasses))
			continue // would conflict with an existing aspect's class slot
		available += candidate

	if(!available.len)
		for(var/mob/living/member in manager.lobby_members)
			to_chat(member, span_warning("Fated Suffering was chosen, but you're already at rock bottom."))
		return

	var/datum/warbands/aspects/chosen = pick(available)
	manager.selected_aspects += chosen

	chosen.on_warband_confirmed(manager) // fire the chosen aspect's own confirmation hook

	for(var/mob/living/member in manager.lobby_members)
		to_chat(member, span_redteamradio("Fated Suffering has selected [chosen.title]."))


////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// the first lieutenant to spawn is branded as an outlaw
// also gives a tiny (1) disorder bump, as if a wretch were recruited

/datum/warbands/aspects/outlaw
	title = "SCUM"
	summary = "A Lieutenant is wanted by the Azurian Justiciary. To say this will strain negotiations is an understatement."
	desc = "A Lieutenant is a wanted criminal. Their presence incurs a tiny (1) Disorder bump, as if a Wretch were recruited."
	warning = "...of a known, wanted man accompanying the enemy host."
	points = 1

/datum/warbands/aspects/outlaw/on_lieutenant_spawned(mob/living/carbon/human/lieutenant, atom/movable/screen/warband/manager/manager)
	manager.disorder++
	var/my_crime = tgui_input_text(lieutenant, "What is your crime?", "Crime")

	if(!my_crime)
		my_crime = "countless crimes against the Crown"
	
	var/bounty_amount = rand(900, 1125) // a step above the max bandit bounty
	var/race = lieutenant.dna.species
	var/gender = lieutenant.gender
	var/list/d_list = lieutenant.get_mob_descriptors()
	var/descriptor_height = build_coalesce_description_nofluff(d_list, lieutenant, list(MOB_DESCRIPTOR_SLOT_HEIGHT), "%DESC1%")
	var/descriptor_body = build_coalesce_description_nofluff(d_list, lieutenant, list(MOB_DESCRIPTOR_SLOT_BODY), "%DESC1%")
	var/descriptor_voice = build_coalesce_description_nofluff(d_list, lieutenant, list(MOB_DESCRIPTOR_SLOT_VOICE), "%DESC1%")

	add_bounty(lieutenant.real_name, race, gender, descriptor_height, descriptor_body, descriptor_voice, bounty_amount, FALSE, my_crime, "The Justiciary of Azuria")
	GLOB.outlawed_players |= lieutenant.real_name
	ADD_TRAIT(lieutenant, TRAIT_OUTLAW, JOB_TRAIT)
