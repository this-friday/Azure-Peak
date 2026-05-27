/datum/warbands/standard
	title = "FEUD"
	name = "Rival Lord"
	summary = "No feud can go unresolved. Settlements between men of low standing are simple - an apology here, or an exchange of cattle and mammon there. \
	But great men cannot settle. Honor demands apologies to be signed in blood and thousands of cattle to fall before spear-point."
	warning = "...a foreign Banner on the march towards the capital."
	combatmusic = list('sound/music/combat_squire.ogg')
	aspects = list(ASPECT_FORT, ASPECT_SURPRISE, ASPECT_BATTLETESTED, ASPECT_HOST, ASPECT_FIGUREHEAD, ASPECT_SCUM, ASPECT_WAR, ASPECT_ENVY, ASPECT_RANDOM, ASPECT_BADSPAWN, ASPECT_HORDE, ASPECT_SPLINTERED, ASPECT_MARKED, ASPECT_CAVALRY, ASPECT_SUPPLIES)
	spawns = RESPAWNS_MEDIUM
	warcamp = /datum/map_template/warcamp_standard

	warlordclasses = list(/datum/advclass/warband/standard/warlord/lord)

	lieutenantclasses = list(/datum/advclass/warband/standard/lieutenant/knight,
							/datum/advclass/warband/standard/lieutenant/preacher,
							/datum/advclass/warband/standard/lieutenant/spymaster,
							/datum/advclass/warband/standard/lieutenant/magician)

	gruntclasses = list(/datum/advclass/warband/standard/grunt/veteran,
						/datum/advclass/warband/standard/grunt/scout,
						/datum/advclass/warband/standard/grunt/rider,
						/datum/advclass/warband/standard/grunt/sapper)

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////

/datum/warbands/standard/get_base_squad_size(mob/user)
	if(user.job == "Rival Lord")
		return 8
	return ..()

////////////////////////////////////////////////////////////
///////////////////////////////////////////////// NPC OUTFIT

/datum/outfit/job/roguetown/human/species/human/northern/goon/pre_equip(mob/living/carbon/human/species/human/northern/goon/H)
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	pants = /obj/item/clothing/under/roguetown/chainlegs/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/black
	cloak = /obj/item/clothing/cloak/tabard/stabard/warband
	r_hand = /obj/item/rogueweapon/shield/heater
	neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
	l_hand = /obj/item/rogueweapon/sword/iron

	if(prob(50))
		head = /obj/item/clothing/head/roguetown/helmet/sallet/iron
	else
		head = null	
	if(prob(50))
		gloves = /obj/item/clothing/gloves/roguetown/plate/iron
	else
		gloves = /obj/item/clothing/gloves/roguetown/chain/iron
