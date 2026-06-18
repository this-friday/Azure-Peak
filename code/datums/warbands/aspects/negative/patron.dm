////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// replaces the warlord's class with a "Patron" class, who is a non-combatant flavored as the company's current employer, rather than an actual member of said company
// they also get a slightly larger squad size (+1 to the base squad)
// essentially just Figurehead but with a little more sauce

/datum/warbands/aspects/patron
	title = "BACKSEAT RIDER"
	summary = "The Company's current employer - a noble or a simple financier - wishes to oversee the operation themselves. They are the furthest thing from a warrior."
	desc = "The Warlord is simply the warband's current employer. His only available class is that of a helpless non-combatant."
	warning = "...of rumors that the company's employer has personally taken to the field."
	points = 1 // partial buff in the form of a Squad Size increase, so this is only a +1
	warlordclasses = list(/datum/advclass/warband/mercenary/warlord/patron)
	suppress_all_other_classes = TRUE // they're the only available class for warlords
