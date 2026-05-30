/datum/round_event_control/antagonist/solo/warlord
	name = "Warlord"
	tags = list(
		TAG_COMBAT,
		TAG_VILLIAN,
		TAG_WAR
	)
	roundstart = TRUE
	antag_flag = ROLE_WARLORD
	shared_occurence_type = SHARED_HIGH_THREAT
	earliest_start = 0 SECONDS

	max_occurrences = 1
	weight = 2

	min_players = 40
	required_enemies = 25
	enemy_roles = list("Man at Arms",
	"Sergeant",
	"Knight",
	"Captain",
	"Squire",
	"Marshal",
	"Court Magician",
	"Warden",
	"Court Agent",
	"Veteran",
	"Templar",
	"Martyr",
	"Mercenary",
	"Adventurer")


	restricted_roles = DEFAULT_ANTAG_BLACKLISTED_ROLES
	typepath = /datum/round_event/antagonist/solo/warlord
	antag_datum = /datum/antagonist/warband/warlord

/datum/round_event_control/antagonist/solo/warlord/get_antag_amount()
	var/grunts_per_lt = GRUNTS_PER_LIEUTENANT + max(0, (get_active_player_count() - 40) / 15)
	grunts_per_lt = min(grunts_per_lt, GRUNTS_PER_LIEUTENANT_MAX)
	return 1 + LIEUTENANTS_PER_WARLORD + (LIEUTENANTS_PER_WARLORD * grunts_per_lt)

// when we grab mobs to serve as antagonists at roundstart, soilson & warden have instantaneous, uninterruptable input() dialog boxes that aren't behind class selection (which we otherwise COULD interrupt)
// this gives us runtimes, so we're just excluding them for now
/datum/round_event_control/antagonist/solo/warlord/New()
	..()
	restricted_roles += list("Soilson", "Warden")

/datum/round_event/antagonist/solo/warlord
	var/datum/mind/warlord_mind
	var/list/lieutenant_minds = list()
	var/list/grunt_minds = list()

/datum/round_event/antagonist/solo/warlord/start()
	if(!setup_minds.len)
		return

	setup_minds = shuffle(setup_minds)
	var/turf/spawn_loc
	for(var/obj/effect/landmark/start/warlord/the_box in GLOB.landmarks_list)
		spawn_loc = get_turf(the_box)
		break

	// we'd like our warlord candidates to present evidence of basic sentience (10+ PQ), as they're gonna have a lot on their plate
	// in their absence we'll allow anyone
	var/list/preferred = list()
	for(var/datum/mind/M in setup_minds)
		if(get_playerquality(M.key) > WARLORD_PQ)
			preferred += M
	var/list/warlord_pool = preferred.len ? preferred : setup_minds
	warlord_mind = pick(warlord_pool)
	setup_minds -= warlord_mind

	// scale grunts per lieutenant based on active player count
	// +1 for every 15 active players past the 40-player baseline
	var/grunts_per_lt = GRUNTS_PER_LIEUTENANT + max(0, (get_active_player_count() - 40) / 15)

	// fill lieutenants before any grunts
	var/lt_end = min(setup_minds.len, LIEUTENANTS_PER_WARLORD)
	for(var/i in 1 to lt_end)
		lieutenant_minds += setup_minds[i]

	// fill grunts afterwards
	var/grunt_start = lt_end + 1
	var/grunt_end = min(setup_minds.len, lt_end + (lieutenant_minds.len * grunts_per_lt))
	if(grunt_start <= grunt_end)
		for(var/i in grunt_start to grunt_end)
			grunt_minds += setup_minds[i]

	// Spawn everyone
	if(warlord_mind?.current)
		process_candidate(warlord_mind, "Warlord", /datum/antagonist/warband/warlord, spawn_loc)
	var/lt_num = 1
	for(var/datum/mind/lt_mind in lieutenant_minds)
		if(lt_mind.current)
			process_candidate(lt_mind, "Lieutenant", /datum/antagonist/warband/lieutenant, spawn_loc, lt_num++)
	var/grunt_num = 1
	for(var/datum/mind/grunt_mind in grunt_minds)
		if(grunt_mind.current)
			process_candidate(grunt_mind, "Grunt", /datum/antagonist/warband/grunt, spawn_loc, grunt_num++)


/datum/round_event/antagonist/solo/warlord/proc/process_candidate(datum/mind/target_mind, role_name, datum_path, turf/loc, unique_number = 0)
	target_mind.current.loc = loc // send them to The Box
	var/datum/job/J = SSjob.GetJob(target_mind.current.job)
	J?.current_positions = max(J?.current_positions-1, 0)
	SSjob.AssignRole(target_mind.current, role_name)
	target_mind.add_antag_datum(datum_path)
	if(unique_number)
		var/datum/antagonist/warlord_unit = target_mind.has_antag_datum(datum_path)
		if(warlord_unit)
			warlord_unit.unique_number = unique_number
