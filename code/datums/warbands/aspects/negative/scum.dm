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
