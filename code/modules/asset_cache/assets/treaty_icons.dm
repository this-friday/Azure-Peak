/datum/asset/spritesheet/treaty_icons
	name = "treaty_icons"

/datum/asset/spritesheet/treaty_icons/create_spritesheets()
	for(var/datum/treaty_flavor/faction as anything in SSwarbands.treaty_flavor_factions)
		var/icon = faction::icon
		var/icon_state = faction::icon_state

		if(!icon || !icon_state)
			continue

		Insert("[sanitize_css_class_name("factionicon_[REF(faction)]")]", icon, icon_state)
