/datum/warbands/peasant
	storytellerlimit = /datum/storyteller/matthios
	rarity = 1
	title = "PEASANT REBELLION"
	name = "Peasant Rebellion"
	treaty_name = "The People"
	summary = "Turmoil in the Duchy's countryside has boiled into a full-blown rebellion."
	warning = "...turmoil in Azuria's distant countryside, and roving bands of unruly peasants."
	aspects = list(ASPECT_SURPRISE, ASPECT_HOST, ASPECT_FIGUREHEAD, ASPECT_ENVY, ASPECT_SCUM, ASPECT_WAR, ASPECT_RANDOM, ASPECT_BADSPAWN, ASPECT_HORDE, ASPECT_SPLINTERED, ASPECT_MARKED)
	combatmusic = list('sound/music/combat_routier.ogg')
	spawns = RESPAWNS_HORDE
	warcamp = /datum/map_template/warcamp_peasant

	warlordclasses = list(/datum/advclass/warband/rebellion/warlord/ringleader)

	lieutenantclasses = list(/datum/advclass/warband/rebellion/lieutenant/folkhero, 
							/datum/advclass/warband/rebellion/lieutenant/firebrand, 
							/datum/advclass/warband/rebellion/lieutenant/turncoat, 
							/datum/advclass/warband/rebellion/lieutenant/wildcard)

	gruntclasses = list(/datum/advclass/warband/rebellion/grunt/militiaman, 
						/datum/advclass/warband/rebellion/grunt/conspirator)

/datum/warbands/peasant/get_base_squad_size(mob/user)
	return 8

////////////////////////////////////////////////////////////
///////////////////////////////////////////////// NPC OUTFIT
/datum/warbands/peasant/get_grunt_outfit(mob/living/carbon/human/species/human/northern/goon/goon)
	return /datum/outfit/job/roguetown/human/species/human/northern/goon/peasant

/datum/outfit/job/roguetown/human/species/human/northern/goon/peasant/pre_equip(mob/living/carbon/human/species/human/northern/goon/H)
	head = /obj/item/clothing/head/roguetown/armingcap
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/rope
	neck = /obj/item/clothing/neck/roguetown/coif
	pants =	/obj/item/clothing/under/roguetown/heavy_leather_pants

	if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/dress/gen/random
		shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/random
		cloak = /obj/item/clothing/cloak/apron/brown
	else
		armor = /obj/item/clothing/suit/roguetown/armor/leather/vest
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random

	if(prob(50))
		if(prob(30))
			l_hand = /obj/item/rogueweapon/spear/militia
		else
			l_hand = /obj/item/rogueweapon/pitchfork
	else
		if(prob(30))
			l_hand = /obj/item/rogueweapon/flail/peasantwarflail
		else
			l_hand = /obj/item/rogueweapon/mace/woodclub/crafted
