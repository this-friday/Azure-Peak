/datum/warbands/storyteller/wizard
	storytellerlimit = /datum/storyteller/noc
	rarity = 3
	title = "SORCERER-KING"
	name = "Sorcerer-King"
	treaty_name = "The Court of the Sorcerer-King"
	summary = "Atop a great tower of stone is a perversion of the Divine Right. Within lies a man without history, without blood, yet as wrathful as any true king."
	warning = "...of a terrible, twisted citadel carried upon stormclouds. They say it fell as lightning, and stuck itself within the earth."
	warcamp = /datum/map_template/warcamp_wizard
	aspects = list(ASPECT_SURPRISE, ASPECT_HOST, ASPECT_ENVY, ASPECT_FIGUREHEAD, ASPECT_SCUM, ASPECT_WAR, ASPECT_BADSPAWN, ASPECT_RANDOM, ASPECT_SPLINTERED, ASPECT_MARKED, ASPECT_SUPPLIES)
	spawns = RESPAWNS_LOW
	combatmusic = list('sound/music/cmode/nobility/combat_courtmage.ogg')

	warlordclasses = list(/datum/advclass/warband/wizard/warlord/sorcerer)

	lieutenantclasses = list(/datum/advclass/warband/wizard/lieutenant/pyromancer,
							/datum/advclass/warband/wizard/lieutenant/stormcaller,
							/datum/advclass/warband/wizard/lieutenant/conjurer)

	gruntclasses = list(/datum/advclass/warband/wizard/grunt/stalker,
						/datum/advclass/warband/wizard/grunt/layman,
						/datum/advclass/warband/wizard/grunt/warlock)

////////////////////////////////////////////////////////////
///////////////////////////////////////////////// NPC OUTFIT
/datum/warbands/storyteller/wizard/get_grunt_outfit(mob/living/carbon/human/species/human/northern/goon/goon)
	return /datum/outfit/job/roguetown/human/species/human/northern/goon/layman

/datum/outfit/job/roguetown/human/species/human/northern/goon/layman/pre_equip(mob/living/carbon/human/species/human/northern/goon/H)
	r_hand = /obj/item/rogueweapon/mace/goden/steel
	cloak = /obj/item/clothing/cloak/thrall
	belt = /obj/item/storage/belt/rogue/leather/black
	head = /obj/item/clothing/mask/rogue/facemask/goldmask/layman/alt
	mask = /obj/item/clothing/head/roguetown/roguehood/shalal/thrall
	armor = /obj/item/clothing/suit/roguetown/armor/plate/half/iron/layman
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron/layman
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest/thrall
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/bronzeskirt
	neck = /obj/item/clothing/neck/roguetown/bevor/iron/layman
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron/layman
	shoes = /obj/item/clothing/shoes/roguetown/sandals
