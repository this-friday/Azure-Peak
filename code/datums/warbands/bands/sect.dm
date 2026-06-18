/datum/warbands/sect
	title = "SECT"
	name = "Sect"
	summary = "A band of fanatics driven to arms; if not by delusion, by a divine obligation."
	warning = "...of single-minded fanaticism and ritual."
	subtyperequired = TRUE
	subtypes = list(WARBAND_SECTS)
	aspects = list(ASPECT_SURPRISE, ASPECT_FORT, ASPECT_HOST, ASPECT_FIGUREHEAD, ASPECT_BATTLETESTED, ASPECT_SCUM, ASPECT_WAR, ASPECT_RANDOM, ASPECT_ENVY, ASPECT_BADSPAWN, ASPECT_HORDE, ASPECT_SPLINTERED, ASPECT_MARKED, ASPECT_SUPPLIES)
	spawns = RESPAWNS_MEDIUM
	combatmusic = list('sound/music/cmode/antag/combat_thewall.ogg')

	warlordclasses = list(/datum/advclass/warband/sect/warlord/prophet)

	lieutenantclasses = list(/datum/advclass/warband/sect/lieutenant/justiciar, 
							/datum/advclass/warband/sect/lieutenant/versekeeper, 
							/datum/advclass/warband/sect/lieutenant/sentinel)

	gruntclasses = list(/datum/advclass/warband/sect/grunt/crusader, 
						/datum/advclass/warband/sect/grunt/cultist, 
						/datum/advclass/warband/sect/grunt/zealot)

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////

/datum/warbands/sect/on_warband_confirmed(datum/warband_manager/manager, intensity = 1)
	var/patron_name = "the chosen patron"
	if(manager.faithlocks.len)
		var/patron_type = manager.faithlocks[1]
		var/datum/patron/temp_patron = new patron_type()
		patron_name = temp_patron.name
		qdel(temp_patron)
	for(var/mob/living/member in manager.lobby_members)
		to_chat(member, "<span style='color:#e8bf67'>SECT RESTRICTION:</span> The Sect is in service to <span style='color:#e8bf67'>[patron_name]</span>. Your character must serve them.")
		member.playsound_local(member, 'sound/misc/notice (2).ogg', 100, FALSE)

/datum/warbands/sect/on_warlord_equip(mob/living/carbon/human/warlord, datum/warband_manager/manager)
	warlord.verbs += /mob/living/carbon/human/proc/enlighten
	
//////////////////////////////////////////////////////////
///////////////////////////////////////////////// SUBTYPES

////////////////////////////////////////////////
//////////////////////////////////////////// TEN

/datum/warbands/subtypes/ten
	title = "TEN"
	quote = "''TEN ANGELS descended from on-high, slaughtering heretic and undeath alike. For us, TEN ANGELS sacrificed their holiest of creations.''"
	quote_followup = "DAWN: UNDIVIDED - 2:4"
	warcamp = /datum/map_template/warcamp_standard
	warning = "...of devotion to the Ten."
	combatmusic = list('sound/music/combat_holy.ogg')

/datum/warbands/subtypes/ten/build_input_fields()
	var/datum/treaty/input_field/option_dropdown/patron_field = new()
	patron_field.key = "patron"
	patron_field.label = "Chosen Patron"
	patron_field.placeholder = "Select a Patron..."
	patron_field.options = list("Astrata", "Noc", "Dendor", "Abyssor", "Ravox", "Necra", "Xylix", "Pestra", "Malum", "Eora")
	input_fields += patron_field

/datum/warbands/subtypes/ten/on_warband_confirmed(datum/warband_manager/manager, intensity = 1)
	var/list/patron_name_to_type = list(
		"Astrata" = /datum/patron/divine/astrata,
		"Noc" = /datum/patron/divine/noc,
		"Dendor" = /datum/patron/divine/dendor,
		"Abyssor" = /datum/patron/divine/abyssor,
		"Ravox" = /datum/patron/divine/ravox,
		"Necra" = /datum/patron/divine/necra,
		"Xylix" = /datum/patron/divine/xylix,
		"Pestra" = /datum/patron/divine/pestra,
		"Malum" = /datum/patron/divine/malum,
		"Eora" = /datum/patron/divine/eora
	)
	var/list/my_inputs = manager.selection_inputs["[src.type]"]
	var/patron_name = my_inputs ? my_inputs["patron"] : null
	if(!patron_name || !(patron_name in patron_name_to_type))
		patron_name = pick(patron_name_to_type) // in absence of a choice (such as during a timeout), we pick a random one
	manager.faithlocks = list(patron_name_to_type[patron_name])

/datum/warbands/subtypes/ten/on_locks_applied(datum/warband_manager/manager)
	return TRUE // sect sends its own message in on_warband_confirmed

//////////////////////////////////////////////////////
//////////////////////////////////////////// ASCENDANT

/datum/warbands/subtypes/ascendant
	rarity = 2	// an ascendant sect treads on narrative ground covered by a ton of other antagonists, so we'll make them uncommon
	storytellerlimit = /datum/storyteller/graggar // by well-tread narrative ground i'm referring to a massacre
	title = "ASCENDANT"
	treaty_name = "The Holy Ecclesial"
	quote = "''Shine thy fury upon me, oh Dark Star! I sing slaughter's psalm, and thy word is sweet!''"
	quote_followup = "- A posthumous translation of a serial butcher's words - which were otherwise unintelligible."
	warning = "...of devotion to the Four."
	warcamp = /datum/map_template/warcamp_standard
	combatmusic = list('sound/music/combat2.ogg')
	outskirts_wave = /datum/outskirts_wave/ascendant

/datum/warbands/subtypes/ascendant/build_input_fields()
	var/datum/treaty/input_field/option_dropdown/patron_field = new()
	patron_field.key = "patron"
	patron_field.label = "Chosen Patron"
	patron_field.placeholder = "Select a Patron..."
	patron_field.options = list("Zizo", "Graggar", "Matthios", "Baotha")
	input_fields += patron_field

/datum/warbands/subtypes/ascendant/on_warband_confirmed(datum/warband_manager/manager, intensity = 1)
	var/list/patron_name_to_type = list(
		"Zizo" = /datum/patron/inhumen/zizo,
		"Graggar" = /datum/patron/inhumen/graggar,
		"Matthios" = /datum/patron/inhumen/matthios,
		"Baotha" = /datum/patron/inhumen/baotha
	)
	var/list/my_inputs = manager.selection_inputs["[src.type]"]
	var/patron_name = my_inputs ? my_inputs["patron"] : null
	if(!patron_name || !(patron_name in patron_name_to_type))
		patron_name = pick(patron_name_to_type)
	manager.faithlocks = list(patron_name_to_type[patron_name])

/datum/warbands/subtypes/ascendant/on_locks_applied(datum/warband_manager/manager)
	return TRUE // sect sends its own message in on_warband_confirmed

///////////////////////////////////////////////////
//////////////////////////////////////////// PSYDON

/datum/warbands/subtypes/psydon
	title = "OLD GOD"
	treaty_name = "We of the True Faith"
	quote = "''I miss you, Dead God. Psydon, I miss you. You, who cast down thy heart in our name. \
	We who sin in our pursuit of virtue. We who reject you with every breath and step. We who have created edifice and altar to devils in thy stead.''"
	quote_followup = "- Excerpt from The Apostate, Unknown Author"
	warning = "...of devotion to the Old God."
	warcamp = /datum/map_template/warcamp_standard
	combatmusic = list('sound/music/combat_inqordinator.ogg')

/datum/warbands/subtypes/psydon/build_input_fields()
	var/datum/treaty/input_field/option_dropdown/patron_field = new()
	patron_field.key = "patron"
	patron_field.label = "Chosen Patron"
	patron_field.placeholder = "Select a Patron..."
	patron_field.options = list("Psydon")
	input_fields += patron_field

/datum/warbands/subtypes/psydon/on_warband_confirmed(datum/warband_manager/manager, intensity = 1)
	manager.faithlocks = list(/datum/patron/old_god)

/datum/warbands/subtypes/psydon/on_locks_applied(datum/warband_manager/manager)
	return TRUE // sect sends its own message in on_warband_confirmed

/datum/warbands/subtypes/psydon/New()
	..()
	if(prob(50)) // jazz roll
		combatmusic = list('sound/music/inquisitorcombat.ogg')

////////////////////////////////////////////////////////////
///////////////////////////////////////////////// NPC OUTFIT

/datum/warbands/sect/get_grunt_outfit(mob/living/carbon/human/species/human/northern/goon/goon)
	return /datum/outfit/job/roguetown/human/species/human/northern/goon/cultist

/datum/outfit/job/roguetown/human/species/human/northern/goon/cultist/pre_equip(mob/living/carbon/human/species/human/northern/goon/H)
	subtype = H.subtype
	if(prob(60))
		r_hand = /obj/item/rogueweapon/whip
	else
		r_hand = /obj/item/rogueweapon/mace/goden/aalloy
	belt = /obj/item/storage/belt/rogue/leather
	pants = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	wrists = /obj/item/clothing/wrists/roguetown/bracers/copper/cultist
	gloves = /obj/item/clothing/gloves/roguetown/angle
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	if(subtype.type == WARBAND_SECT_PSYDON)
		mask = /obj/item/clothing/mask/rogue/sack/psy
	else
		mask = /obj/item/clothing/mask/rogue/sack
