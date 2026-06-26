////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// warband members get branded as outlaws
// how deep in the hierarchy the bounties reach scales with intensity:
//		Intensity 1: only the Warlord is wanted
//		Intensity 2: warlord + lieutenants
//		Intensity 3: warlord + lieutenants + grunts. The Whole House Gone Mad, Bruv
// each outlawed member has a chance to give a tiny (1) disorder bump

/datum/warbands/aspects/outlaw
	title = "SCUM"
	summary = "Members of our host are wanted by the Azurian Justiciary. To say this will strain negotiations is an understatement."
	desc = "Members are branded as outlaws. Their presence incurs Disorder, as if Wretches were recruited. \
	Each rank of intensity brands a new category of members. 1: the Warlord | 2: + every Lieutenant | 3: + every Grunt."
	warning = "...of wretched blackguards accompanying the enemy host."
	points = 1
	max_intensity = 3

/datum/warbands/aspects/outlaw/get_points_at_intensity(intensity)
	return intensity

// the Warlord is branded at intensity 1+
/datum/warbands/aspects/outlaw/on_warlord_spawned(mob/living/carbon/human/warlord, datum/warband_manager/manager)
	outlaw_member(warlord, manager)

// lieutenants are branded at intensity 2+
/datum/warbands/aspects/outlaw/on_lieutenant_spawned(mob/living/carbon/human/lieutenant, datum/warband_manager/manager)
	var/chosen_intensity = manager.aspect_intensities["[type]"] || 1
	if(chosen_intensity >= 2)
		outlaw_member(lieutenant, manager)

// grunts are branded at intensity 3
/datum/warbands/aspects/outlaw/on_grunt_spawned(mob/living/carbon/human/grunt, datum/warband_manager/manager)
	var/chosen_intensity = manager.aspect_intensities["[type]"] || 1
	if(chosen_intensity >= 3)
		outlaw_member(grunt, manager)

/datum/warbands/aspects/outlaw/proc/outlaw_member(mob/living/carbon/human/member, datum/warband_manager/manager)
	if(prob(30)) // the disorder bump is randomized, as otherwise this would be 100% guaranteed to Completely Blow Your Disorder The Fuck Out, which isn't entirely the point here
		manager.disorder++
	addtimer(CALLBACK(src, PROC_REF(spawn_followup), member, manager), 5 SECONDS)

// separated from the initial spawn proc, to prevent it from blocking the menus from fading out
/datum/warbands/aspects/outlaw/proc/spawn_followup(mob/living/carbon/human/member, datum/warband_manager/manager)
	var/my_crime = tgui_input_text(member, "What is your crime?", "Crime")

	if(!my_crime)
		my_crime = "countless crimes against the Crown"

	var/bounty_amount = rand(100, 1000)
	var/race = member.dna.species
	var/gender = member.gender
	var/list/d_list = member.get_mob_descriptors()
	var/descriptor_height = build_coalesce_description_nofluff(d_list, member, list(MOB_DESCRIPTOR_SLOT_HEIGHT), "%DESC1%")
	var/descriptor_body = build_coalesce_description_nofluff(d_list, member, list(MOB_DESCRIPTOR_SLOT_BODY), "%DESC1%")
	var/descriptor_voice = build_coalesce_description_nofluff(d_list, member, list(MOB_DESCRIPTOR_SLOT_VOICE), "%DESC1%")

	add_bounty(member.real_name, race, gender, descriptor_height, descriptor_body, descriptor_voice, bounty_amount, FALSE, my_crime, "The Justiciary of Azuria")
	GLOB.outlawed_players |= member.real_name
	ADD_TRAIT(member, TRAIT_OUTLAW, JOB_TRAIT)
