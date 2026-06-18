////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// a chest filled with 8 of the chosen item spawns w/the warlord
// intensity 1-3: each rank unlocks an additional item slot + chest

/datum/warbands/aspects/supplies
	title = "SUPPLY CACHE"
	summary = "We are well-supplied for the coming campaign."
	desc = "Choose a supply item. A chest containing 8 of the chosen item spawns alongside the Warlord. Each additional intensity rank unlocks a new item slot and its own chest."
	warning = "...bearing a well-supplied cache of arms."
	points = -1
	max_intensity = 3

/datum/warbands/aspects/supplies/get_points_at_intensity(intensity)
	return -(intensity)

/datum/warbands/aspects/supplies/proc/item_options()
	return list(
		"Red",
		"Javelins",
		"Lances",
		"Kite Shields",
		"Plate Cuirass",
		"Bribes",
		"Poison",
		"Polehammers",
		"Battle Axes",
		"Mantraps",
		"Siegebows",
		"Longswords",
	)

/datum/warbands/aspects/supplies/proc/item_type_map()
	return list(
		"Red" = /obj/item/reagent_containers/glass/bottle/rogue/healthpotnew,
		"Javelins" = /obj/item/quiver/javelin,
		"Lances" = /obj/item/rogueweapon/spear/lance,
		"Kite Shields" = /obj/item/rogueweapon/shield/tower/metal,
		"Plate Cuirass" = /obj/item/clothing/suit/roguetown/armor/plate/cuirass,
		"Bribes" = /obj/item/storage/belt/rogue/pouch/coins/poor,
		"Poison" = /obj/item/reagent_containers/glass/bottle/rogue/poison,
		"Polehammers" = /obj/item/rogueweapon/eaglebeak,
		"Battle Axes" = /obj/item/rogueweapon/stoneaxe/battle,
		"Mantraps" = /obj/item/restraints/legcuffs/beartrap,
		"Siegebows" = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/heavy,
		"Longswords" = /obj/item/rogueweapon/sword/long,
	)

// one dropdown per intensity rank
// the frontend slices inputs by current rank to reveal them in order
/datum/warbands/aspects/supplies/build_input_fields()
	var/list/options = item_options()
	for(var/i = 1 to max_intensity)
		var/datum/treaty/input_field/option_dropdown/item_field = new()
		item_field.key = "item_[i]"
		item_field.label = "Supply Item"
		item_field.placeholder = "Select a supply item..."
		item_field.options = options
		input_fields += item_field

// certain warband types upgrade certain types of supply caches
/datum/warbands/aspects/supplies/proc/resolve_item_upgrades(item_type, datum/warband_manager/manager)
	if(item_type == /obj/item/rogueweapon/sword/long)
		for(var/patron_type in manager.faithlocks)
			if(ispath(patron_type, /datum/patron/inhumen/zizo)) // zizo sects, for example, get Avantyne longswords over regular longswords
				return /obj/item/rogueweapon/sword/long/avantyne
	return item_type

// returns an assoc list of extra item types + a quantity to spawn alongside the main item
/datum/warbands/aspects/supplies/proc/bonus_items(item_type)
	if(item_type == /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/heavy)
		return list(/obj/item/quiver/bolt/heavy/standard = 8)
	return list()

/datum/warbands/aspects/supplies/on_warlord_spawned(mob/living/carbon/human/warlord, datum/warband_manager/manager)
	var/list/my_inputs = manager.selection_inputs["[type]"]
	var/list/type_map = item_type_map()
	var/turf/spawn_turf = get_turf(warlord)
	var/chosen_intensity = manager.aspect_intensities["[type]"] || 1

	for(var/i = 1 to chosen_intensity)
		var/item_type = my_inputs ? type_map[my_inputs["item_[i]"]] : null
		if(!item_type)
			continue

		item_type = resolve_item_upgrades(item_type, manager)
		var/list/bonuses = bonus_items(item_type)
		var/obj/structure/closet/crate/chest/gold/chest = new(spawn_turf)
		chest.name = "supply cache"
		for(var/j = 1 to 8)
			new item_type(chest)
		for(var/bonus_type in bonuses)
			for(var/k = 1 to bonuses[bonus_type])
				new bonus_type(chest)
