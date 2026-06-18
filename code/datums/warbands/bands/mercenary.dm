/datum/warbands/mercenary
	title = "MERCENARY COMPANY"
	name = "Mercenary Company"
	treaty_name = "The Company"
	summary = "So numerous are the potential motives for a band of mercenaries, that the idea \
	they're fighting for mammon becomes a mere afterthought."
	warning = "...an entire company's worth of mercenaries soon to be upon us."
	subtyperequired = TRUE
	subtypes = list(WARBAND_MERCENARIES)
	aspects = list(ASPECT_SURPRISE, ASPECT_FORT, ASPECT_BATTLETESTED, ASPECT_HOST, ASPECT_ENVY, ASPECT_RANDOM, ASPECT_SCUM, ASPECT_WAR, ASPECT_BADSPAWN, ASPECT_HORDE, ASPECT_SPLINTERED, ASPECT_MARKED, ASPECT_SUPPLIES, ASPECT_PATRON)
	warcamp = /datum/map_template/warcamp_standard
	spawns = RESPAWNS_LOW
	combatmusic = list('sound/music/combat_veteran.ogg')
	universal_subclasses_enabled = TRUE
	subclass_required = TRUE

	warlordclasses = list(/datum/advclass/warband/mercenary/warlord/captain)

	lieutenantclasses = list(/datum/advclass/warband/mercenary/lieutenant/vanguard,
							/datum/advclass/warband/mercenary/lieutenant/tactician,
							/datum/advclass/warband/mercenary/lieutenant/skirmisher)

	gruntclasses = list(/datum/advclass/warband/mercenary/grunt/merc)

/datum/warbands/mercenary/get_base_squad_size(mob/user, datum/advclass/primary_class)
	if(istype(primary_class, /datum/advclass/warband/mercenary/warlord/patron))
		return 5
	return ..()

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// NOTE ON HOW CLASSES WORK HERE
/*
	the classes in the parent lists above ^ (captain, vanguard, merc) hold the PRIMARY classes
	each subtype's universal classes live in its universal_classes lists, one per role tier:
		grunt-tier entries (universal_gruntclasses) are given as secondary options to EVERYONE (including Lieutenants and the Warlord)
		if a warlord or lieutenant tier has an entry, it overrides the grunt-tier pool for that role

*/

// so as an example:
/datum/warbands/subtypes/routier
	title = "OTAVAN ROUTIERS"
	treaty_name = "Exemplars of Otava"
	quote = "I ask only that you stand as a witness. Come dae, my men and I shall make this little field here, famous."
	quote_followup = " - A Routier conscripting an archivist."
	universal_gruntclasses = list(/datum/advclass/mercenary/routier) // all 3 roles get Routier as a secondary class
	combatmusic = list('sound/music/combat_routier.ogg')

// and as a second example:
/datum/warbands/subtypes/ruma
	title = "RUMA CLAN"
	universal_warlordclasses = list(/datum/advclass/mercenary/seonjang) // the warlord gets one exclusive subclass (seonjang)
	universal_gruntclasses = list(/datum/advclass/mercenary/rumaclan, /datum/advclass/mercenary/rumaclan_sasu) // while grunts and lieutenants only get these two
	combatmusic = list('sound/music/combat_kazengite.ogg')

/datum/warbands/subtypes/northmen
	title = "NORTHMEN"
	universal_warlordclasses = list(/datum/advclass/mercenary/gronn_heavy, /datum/advclass/mercenary/atgervi_shaman)
	universal_lieutenantclasses = list(/datum/advclass/mercenary/atgervi)
	universal_gruntclasses = list(/datum/advclass/mercenary/gronn)
	combatmusic = list('sound/music/combat_shaman2.ogg')
	faithlock = ALL_GRONNIC_PATRONS

/datum/warbands/subtypes/blackoak
	title = "BLACK OAK"
	treaty_name = "Azuria-in-Exile"
	racelock = list(/datum/species/human/halfelf, /datum/species/elf/wood, /datum/species/elf/dark)
	universal_gruntclasses = list(/datum/advclass/mercenary/blackoak, /datum/advclass/mercenary/blackoak_ranger)
	combatmusic = list('sound/music/combat_blackoak.ogg')

/datum/warbands/subtypes/condottiero
	title = "CONDOTTIERO"
	universal_warlordclasses = list(/datum/advclass/mercenary/etrusca_condottiero)
	universal_lieutenantclasses = list(/datum/advclass/mercenary/etrusca_condottiero)
	universal_gruntclasses = list(/datum/advclass/mercenary/etrusca_balestrieri)
	combatmusic = list('sound/music/combat_condottiero.ogg')

/datum/warbands/subtypes/raneshen
	title = "DESERT RIDERS"
	aspects = list(ASPECT_CAVALRY)
	universal_warlordclasses = list(/datum/advclass/mercenary/desert_rider)
	universal_lieutenantclasses = list(/datum/advclass/mercenary/desert_rider)
	universal_gruntclasses = list(/datum/advclass/mercenary/desert_rider_sahir, /datum/advclass/mercenary/desert_rider_almah, /datum/advclass/mercenary/desert_rider_zeybek)
	combatmusic = list('sound/music/combat_desertrider.ogg')

/datum/warbands/subtypes/forlorn
	title = "THE FORLORN HOPE"
	universal_gruntclasses = list(/datum/advclass/mercenary/forlorn)
	combatmusic = list('sound/music/combat_blackstar.ogg')

/datum/warbands/subtypes/grudgebearer
	title = "DWARVEN GRUDGEBEARERS"
	racelock = list(/datum/species/dwarf/mountain)
	universal_gruntclasses = list(/datum/advclass/mercenary/grudgebearer_soldier, /datum/advclass/mercenary/grudgebearer)
	combatmusic = list('sound/music/combat_dwarf.ogg')

/datum/warbands/subtypes/steppesman
	title = "STEPPESMEN"
	aspects = list(ASPECT_CAVALRY)
	universal_gruntclasses = list(/datum/advclass/mercenary/steppesman)
	combatmusic = list('sound/music/combat_steppe.ogg')

/datum/warbands/subtypes/grenzel
	title = "GRENZELHOFTIAN"
	quote = "Fought with him for fifteen yils, and I honest to Gods couldn't tell you a damn thing about him. When you hire his kind you're paying for the sword, not the man."
	quote_followup = "- The Count of Morngrove, recalling his long-time guardian and companion."
	universal_gruntclasses = list(/datum/advclass/mercenary/grenzelhoft, /datum/advclass/mercenary/grenzelhoft_halberdier, /datum/advclass/mercenary/grenzelhoft_crossbowman, /datum/advclass/mercenary/grenzelhoft_mage)
	combatmusic = list('sound/music/combat_grenzelhoft.ogg')

/datum/warbands/subtypes/warscholar
	title = "WARSCHOLARS"
	quote = "For if Endurance - if lyfe itself - is prayer, so must we prepare for death. We should hope to unravel His mysteries with what little time we're spared, 'fore we join Him."
	quote_followup = "- A dramatic Warscholar, upon chipping his mask."
	universal_gruntclasses = list(/datum/advclass/mercenary/warscholar, /datum/advclass/mercenary/warscholar_pontifex, /datum/advclass/mercenary/warscholar_vizier)
	faithlock = list(/datum/patron/old_god)
	combatmusic = list('sound/music/warscholar.ogg')

/datum/warbands/subtypes/underdweller
	title = "UNDERDWELLERS"
	racelock =	list(/datum/species/dwarf/mountain, /datum/species/elf/dark, /datum/species/kobold, /datum/species/goblinp,	/datum/species/anthromorphsmall)
	universal_gruntclasses = list(/datum/advclass/mercenary/underdweller)
	combatmusic = list('sound/music/combat_delf.ogg')

/datum/warbands/subtypes/anthrax
	title = "ANTHRAXI"
	racelock =	list(/datum/species/elf/dark)
	universal_gruntclasses = list(/datum/advclass/mercenary/anthrax, /datum/advclass/mercenary/anthrax_assassin)
	combatmusic = list('sound/music/combat_delf.ogg')

/datum/warbands/subtypes/vaquero
	title = "VAQUERO"
	aspects = list(ASPECT_CAVALRY)
	treaty_name = "The Posse"
	universal_gruntclasses = list(/datum/advclass/mercenary/vaquero)
	combatmusic = list('sound/music/combat_vaquero.ogg')

/datum/warbands/subtypes/freifechter
	title = "FREIFECTHERS"
	treaty_name = "The Freifechters of Aavnar"
	universal_gruntclasses = list(/datum/advclass/mercenary/freelancer, /datum/advclass/mercenary/freelancer_lancer, /datum/advclass/mercenary/freelancer_sabrist)
	combatmusic = list('sound/music/frei_fencer.ogg')

/datum/warbands/subtypes/hangyaku
	title = "HANGYAKU"
	universal_gruntclasses = list(/datum/advclass/mercenary/hangyaku, /datum/advclass/mercenary/chonin)
	combatmusic = list('sound/music/combat_kazengite.ogg')

/datum/warbands/subtypes/tithebound
	title = "TITHEBOUND"
	racelock = list(/datum/species/dracon, /datum/species/lizardfolk, /datum/species/kobold)
	faithlock = list(/datum/patron/divine/astrata, /datum/patron/inhumen/matthios)
	universal_gruntclasses = list(/datum/advclass/mercenary/lirvanmerc)
	combatmusic = list('sound/music/combat_matthios.ogg')

////////////////////////////////////////////////////////////
///////////////////////////////////////////////// NPC OUTFIT

/datum/warbands/mercenary/get_grunt_outfit(mob/living/carbon/human/species/human/northern/goon/goon)
	return /datum/outfit/job/roguetown/human/species/human/northern/goon/mercenary

/datum/outfit/job/roguetown/human/species/human/northern/goon/mercenary/pre_equip(mob/living/carbon/human/species/human/northern/goon/H)
	subtype = H.subtype
	if(subtype)
		switch(subtype.type)
			if(WARBAND_MERC_NORTHMEN)
				H.skin_tone = SKIN_COLOR_GRONN
				H.update_body()
				r_hand = /obj/item/rogueweapon/stoneaxe/woodcut/steel/atgervi
				l_hand = /obj/item/rogueweapon/shield/atgervi
				head = /obj/item/clothing/head/roguetown/helmet
				gloves = /obj/item/clothing/gloves/roguetown/angle/atgervi
				shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/atgervi
				armor = /obj/item/clothing/suit/roguetown/armor/brigandine/gronn
				pants = /obj/item/clothing/under/roguetown/trou/leather/atgervi
				wrists = /obj/item/clothing/wrists/roguetown/bracers
				shoes = /obj/item/clothing/shoes/roguetown/boots/leather/atgervi
				belt = /obj/item/storage/belt/rogue/leather
				neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
			if(WARBAND_MERC_DROW)
				H.set_species(/datum/species/elf/dark)
				H.skin_tone = SKIN_COLOR_LLURTH_DREIR
				H.update_body()
				r_hand = /obj/item/rogueweapon/shield/tower/spidershield
				l_hand = /obj/item/rogueweapon/sword/sabre/stalker
				shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
				belt = /obj/item/storage/belt/rogue/leather/black
				pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/shadowpants
				head = /obj/item/clothing/neck/roguetown/chaincoif/full/black
				shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/shadowrobe
				gloves = /obj/item/clothing/gloves/roguetown/plate/shadowgauntlets
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
				mask = /obj/item/clothing/mask/rogue/facemask/shadowfacemask
			if(WARBAND_MERC_BLACKOAK)
				H.set_species(pick(/datum/species/human/halfelf, /datum/species/elf/dark, /datum/species/elf/wood))
				H.update_body()
				head = /obj/item/clothing/head/roguetown/helmet/heavy/elven_helm
				armor = /obj/item/clothing/suit/roguetown/armor/plate/elven_plate
				neck = /obj/item/clothing/neck/roguetown/chaincoif
				beltl = /obj/item/rogueweapon/huntingknife/idagger/steel/special
				shoes = /obj/item/clothing/shoes/roguetown/boots/elven_boots
				cloak = /obj/item/clothing/cloak/forrestercloak
				gloves = /obj/item/clothing/gloves/roguetown/elven_gloves
				belt = /obj/item/storage/belt/rogue/leather/black
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
				pants = /obj/item/clothing/under/roguetown/trou/leather
				r_hand = /obj/item/rogueweapon/halberd/glaive
			if(WARBAND_MERC_CONDO)
				H.skin_tone = SKIN_COLOR_ETRUSCA
				H.update_body()
				shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
				cloak = /obj/item/clothing/cloak/half/red
				gloves = /obj/item/clothing/gloves/roguetown/angle
				belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/iron
				head = /obj/item/clothing/head/roguetown/helmet
				armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
				l_hand = /obj/item/rogueweapon/sword/short
				shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
				pants = /obj/item/clothing/under/roguetown/trou/leather
				neck = /obj/item/clothing/neck/roguetown/chaincoif
			if(WARBAND_MERC_DESERTRIDER)
				H.skin_tone = SKIN_COLOR_LALVESTINE
				H.update_body()
				r_hand = /obj/item/rogueweapon/sword/sabre/shamshir
				l_hand = /obj/item/rogueweapon/shield/tower/raneshen
				head = /obj/item/clothing/head/roguetown/helmet/sallet/raneshen
				neck = /obj/item/clothing/neck/roguetown/bevor
				armor = /obj/item/clothing/suit/roguetown/armor/plate/scale
				shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/raneshen
				wrists = /obj/item/clothing/wrists/roguetown/bracers/brigandine
				gloves = /obj/item/clothing/gloves/roguetown/chain
				pants = /obj/item/clothing/under/roguetown/splintlegs
				shoes = /obj/item/clothing/shoes/roguetown/shalal
				belt = /obj/item/storage/belt/rogue/leather/shalal
			if(WARBAND_MERC_FORLORN)
				H.skin_tone = SKIN_COLOR_LALVESTINE
				H.update_body()
				if(prob(60))
					r_hand = /obj/item/rogueweapon/sword/falchion/militia
					l_hand = /obj/item/rogueweapon/shield/heater
				else
					r_hand = /obj/item/rogueweapon/greataxe/militia
				shoes = /obj/item/clothing/shoes/roguetown/boots
				neck = /obj/item/clothing/neck/roguetown/gorget/forlorncollar
				mask = /obj/item/clothing/mask/rogue/wildguard
				pants = /obj/item/clothing/under/roguetown/splintlegs
				gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
				wrists = /obj/item/clothing/wrists/roguetown/bracers/brigandine
				belt = /obj/item/storage/belt/rogue/leather
				shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
			if(WARBAND_MERC_FREI)
				H.skin_tone = SKIN_COLOR_AVAR
				H.update_body()
				r_hand = /obj/item/rogueweapon/sword/long/etruscan
				armor = /obj/item/clothing/suit/roguetown/armor/plate/cuirass/fencer
				belt = /obj/item/storage/belt/rogue/leather/sash
				shirt = /obj/item/clothing/suit/roguetown/armor/leather/heavy/freifechter
				pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan/generic
				shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced/short
				gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			if(WARBAND_MERC_GRENZEL)
				H.skin_tone = SKIN_COLOR_GRENZELHOFT
				H.update_body()
				if(prob(60))
					r_hand = /obj/item/rogueweapon/greatsword/grenz
				else
					r_hand = /obj/item/rogueweapon/halberd
				belt = /obj/item/storage/belt/rogue/leather
				shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/grenzelhoft
				head = /obj/item/clothing/head/roguetown/grenzelhofthat
				pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/grenzelpants
				shoes = /obj/item/clothing/shoes/roguetown/grenzelhoft
				gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves
			if(WARBAND_MERC_GRUDGE)
				H.set_species(/datum/species/dwarf/mountain)
				H.update_body()
				if(prob(60))
					r_hand = /obj/item/rogueweapon/stoneaxe/battle
				else
					r_hand = /obj/item/rogueweapon/mace/goden/steel
				shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
				neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
				cloak = /obj/item/clothing/cloak/forrestercloak/snow
				belt = /obj/item/storage/belt/rogue/leather/black
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
				wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
				gloves = /obj/item/clothing/gloves/roguetown/angle
				pants = /obj/item/clothing/under/roguetown/trou/leather
				armor = /obj/item/clothing/suit/roguetown/armor/plate/cuirass/iron
				head = /obj/item/clothing/head/roguetown/helmet/heavy/bucket/iron
				mask = /obj/item/clothing/mask/rogue/facemask
			if(WARBAND_MERC_HANGYAKU)
				H.skin_tone = SKIN_COLOR_KAZENGUN
				H.update_body()
				r_hand = /obj/item/rogueweapon/spear/naginata
				belt = /obj/item/storage/belt/rogue/leather
				neck = /obj/item/clothing/neck/roguetown/gorget/steel/kazengun
				head = /obj/item/clothing/head/roguetown/helmet/kettle/jingasa/npc
				armor = /obj/item/clothing/suit/roguetown/armor/brigandine/haraate/npc
				shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/random
				pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/kazengun/npc
				shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced/kazengun/npc
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				gloves = /obj/item/clothing/gloves/roguetown/plate/kote/npc
			if(WARBAND_MERC_ROUTIER)
				H.skin_tone = SKIN_COLOR_OTAVA
				H.update_body()
				if(prob(60))
					r_hand = /obj/item/rogueweapon/sword/short/falchion
				else
					r_hand = /obj/item/rogueweapon/mace/steel/morningstar
				wrists = /obj/item/clothing/wrists/roguetown/bracers
				belt = /obj/item/storage/belt/rogue/leather
				neck = /obj/item/clothing/neck/roguetown/fencerguard
				armor = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/otavan
				shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
				pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
				shoes = /obj/item/clothing/shoes/roguetown/boots/otavan
				gloves = /obj/item/clothing/gloves/roguetown/otavan
			if(WARBAND_MERC_RUMA)
				H.skin_tone = SKIN_COLOR_KAZENGUN
				H.update_body()
				r_hand = /obj/item/rogueweapon/sword/sabre/mulyeog/rumahench
				l_hand = /obj/item/rogueweapon/scabbard/sword/kazengun/steel
				belt = /obj/item/storage/belt/rogue/leather
				armor = /obj/item/clothing/suit/roguetown/armor/regenerating/skin/easttats
				cloak = /obj/item/clothing/cloak/eastcloak1
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt2
				pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants2
				shoes = /obj/item/clothing/shoes/roguetown/armor/rumaclan
				gloves = /obj/item/clothing/gloves/roguetown/eastgloves2
			if(WARBAND_MERC_STEPPE)
				H.skin_tone = SKIN_COLOR_AVAR
				H.update_body()
				mask = /obj/item/clothing/mask/rogue/facemask/steel/steppesman
				belt = /obj/item/storage/belt/rogue/leather/black
				pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
				shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
				shoes = /obj/item/clothing/shoes/roguetown/boots/leather
				head = /obj/item/clothing/head/roguetown/helmet/sallet/shishak
				gloves = /obj/item/clothing/gloves/roguetown/chain
				armor = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/chargah
				r_hand = /obj/item/rogueweapon/shield/iron/steppesman
				l_hand = /obj/item/rogueweapon/sword/sabre/steppesman
				neck = /obj/item/clothing/neck/roguetown/chaincoif
			if(WARBAND_MERC_UNDERDWELLER)
				H.set_species(/datum/species/elf/dark)
				H.skin_tone = SKIN_COLOR_LLURTH_DREIR
				H.update_body()
				head = /obj/item/clothing/head/roguetown/helmet/kettle/minershelm
				pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
				wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				mask = /obj/item/clothing/mask/rogue/ragmask/black
				shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
				shoes = /obj/item/clothing/shoes/roguetown/boots/leather
				belt = /obj/item/storage/belt/rogue/leather/black
				neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
				r_hand = /obj/item/rogueweapon/stoneaxe/woodcut/pick
				l_hand = /obj/item/rogueweapon/shield/wood
			if(WARBAND_MERC_VAQUERO)
				H.skin_tone = SKIN_COLOR_ETRUSCA
				H.update_body()
				shoes = /obj/item/clothing/shoes/roguetown/boots
				neck = /obj/item/clothing/neck/roguetown/gorget
				pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
				belt = /obj/item/storage/belt/rogue/leather
				gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
				l_hand = /obj/item/rogueweapon/sword/rapier/vaquero
				r_hand = /obj/item/rogueweapon/huntingknife/idagger/steel/parrying/vaquero
			if(WARBAND_MERC_WARSCHOLAR)
				H.skin_tone = SKIN_COLOR_NALEDI
				H.update_body()
				r_hand = /obj/item/rogueweapon/woodstaff/quarterstaff/iron
				mask = /obj/item/clothing/mask/rogue/lordmask/naledi
				head = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/npc
				head = /obj/item/clothing/head/roguetown/roguehood/pontifex
				armor = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/pontifex
				shirt = /obj/item/clothing/suit/roguetown/shirt/robe/pointfex
				pants = /obj/item/clothing/under/roguetown/trou/leather/pontifex/npc
				wrists = /obj/item/clothing/wrists/roguetown/allwrappings/npc
				belt = /obj/item/storage/belt/rogue/leather
				shoes = /obj/item/clothing/shoes/roguetown/boots
			if(WARBAND_MERC_TITHEBOUND)
				H.set_species(/datum/species/lizardfolk)
				var/body_color_hex = pick("4a5e3d", "532828", "6d5e36") // organs take a hex with a #, mcolor takes one Without a #
				var/body_color = "#[body_color_hex]"
				var/horn_color = pick("#1a1a1a", "#2b2b2b", "#363636")
				if(H.dna && H.dna.features)
					H.dna.features["mcolor"] = body_color_hex

				var/obj/item/organ/tail/lizard/tail = H.getorgan(/obj/item/organ/tail)
				if(tail) // idk how necessary this is, but this is how psy_vault_guard does it. Trust The Plan
					tail.Remove(H, 1)
					QDEL_NULL(tail)
				tail = new /obj/item/organ/tail/lizard()
				tail.accessory_colors = body_color
				tail.Insert(H)
				
				var/obj/item/organ/snout/lizard/snout = H.getorgan(/obj/item/organ/snout)
				if(snout)
					snout.Remove(H, 1)
					QDEL_NULL(snout)
				snout = new /obj/item/organ/snout()
				snout.set_accessory_type(pick(/datum/sprite_accessory/snout/sharp, /datum/sprite_accessory/snout/round), body_color)
				snout.accessory_colors = body_color
				snout.Insert(H)

				var/obj/item/organ/frills/lizard/frills = H.getorgan(/obj/item/organ/frills)
				if(frills)
					frills.Remove(H, 1)
					QDEL_NULL(frills)
				frills = new /obj/item/organ/frills()
				frills.set_accessory_type(pick(/datum/sprite_accessory/frills/simple, /datum/sprite_accessory/frills/short, /datum/sprite_accessory/frills/aquatic), body_color)
				frills.accessory_colors = body_color
				frills.Insert(H)

				var/obj/item/organ/horns/horns = H.getorgan(/obj/item/organ/horns)
				if(horns)
					horns.Remove(H, 1)
					QDEL_NULL(horns)
				horns = new /obj/item/organ/horns()
				horns.set_accessory_type(pick(/datum/sprite_accessory/horns/simple, /datum/sprite_accessory/horns/curled), horn_color)
				horns.accessory_colors = horn_color
				horns.Insert(H)
				H.update_body()
				cloak = /obj/item/clothing/cloak/ordinatorcape/lirvas
				wrists = /obj/item/clothing/wrists/roguetown/bracers/lirvas
				neck = /obj/item/clothing/neck/roguetown/gorget/steel/gold
				armor = /obj/item/clothing/suit/roguetown/armor/regenerating/skin/disciple/lirvas
				pants = /obj/item/clothing/under/roguetown/chainlegs/kilt/gold
				shoes = /obj/item/clothing/shoes/roguetown/sandals
				gloves = /obj/item/clothing/gloves/roguetown/angle
				backr = /obj/item/storage/backpack/rogue/satchel/black
				l_hand = /obj/item/rogueweapon/woodstaff/quarterstaff/iron

	else // if there isn't an available subtype loadout for whatever reason, we just use the grunts from Feud
		H.equipOutfit(new /datum/outfit/job/roguetown/human/species/human/northern/goon)

/obj/item/clothing/head/roguetown/helmet/kettle/jingasa/npc
	detail_color = CLOTHING_RED

/obj/item/clothing/suit/roguetown/armor/brigandine/haraate/npc
	detail_color = CLOTHING_RED

/obj/item/clothing/gloves/roguetown/plate/kote/npc
	detail_color = CLOTHING_RED

/obj/item/clothing/under/roguetown/heavy_leather_pants/kazengun/npc
	color = CLOTHING_RED

/obj/item/clothing/shoes/roguetown/boots/leather/reinforced/kazengun/npc
	detail_color = CLOTHING_RED

/obj/item/clothing/head/roguetown/roguehood/shalal/hijab/npc
	color = CLOTHING_BLACK

/obj/item/clothing/under/roguetown/trou/leather/pontifex/npc
	color = CLOTHING_BLACK

/obj/item/clothing/wrists/roguetown/allwrappings/npc
	color = CLOTHING_BLACK
