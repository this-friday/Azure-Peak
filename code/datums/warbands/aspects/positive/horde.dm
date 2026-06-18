////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// increase to the base squad size (aka the squad size BEFORE any multipliers)

/datum/warbands/aspects/horde
	title = "HORDE"
	summary = "Our squads become a sprawling mass of eager combatants."
	desc = "Increases squad size by 1 per intensity."
	warning = "...of a relentless tide that threatens to completely drown the battlefield."
	points = -1
	max_intensity = 3

// rank 1: -1 | rank 2: -3 | rank 3: -5
/datum/warbands/aspects/horde/get_points_at_intensity(intensity)
	return -(1 + (intensity - 1) * 2)

/datum/warbands/aspects/horde/on_warband_confirmed(datum/warband_manager/manager, intensity = 1)
	manager.squad_size_bonus += 1 * intensity
