////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// warband starts off with negative disorder, effectively allowing them to recruit a wretch for free
// opposite of (/datum/warbands/aspects/splintered)

/datum/warbands/aspects/morale
	title = "TIGHT SHIP"
	summary = "The beatings continued until morale improved. Disorder is at an all-time low!"
	desc = "Reduces starting Disorder by 1 per intensity rank."
	warning = "...of a spirited, driven foe."
	points = -1
	max_intensity = 3
