/datum/warbands/sect
	title = "SECT"
	name = "Sect"
	summary = "A band of fanatics driven to arms; if not by delusion, by a divine obligation."
	warning = "...of single-minded fanaticism and ritual."
	subtyperequired = TRUE
	subtypes = list(WARBAND_SECTS)
	aspects = list(ASPECT_SURPRISE, ASPECT_FORT, ASPECT_HOST, ASPECT_FIGUREHEAD, ASPECT_BATTLETESTED, ASPECT_SCUM, ASPECT_WAR, ASPECT_RANDOM, ASPECT_ENVY, ASPECT_BADSPAWN, ASPECT_HORDE, ASPECT_SPLINTERED, ASPECT_MARKED)
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


/datum/warbands/sect/on_warband_confirmed(atom/movable/screen/warband/manager/manager)
	for(var/mob/living/member in manager.lobby_members)
		to_chat(member, "<span style='color:#e8bf67'>SECT RESTRICTION:</span> Once the Warlord finalizes, all members will be faithlocked to the Warlord's chosen patron.")
		member.playsound_local(member, 'sound/misc/notice (2).ogg', 100, FALSE)

/datum/warbands/sect/on_warlord_equip(mob/living/carbon/human/warlord, atom/movable/screen/warband/manager/manager)
	warlord.verbs += /mob/living/carbon/human/proc/enlighten
	
// narrows the faithlock from the subtype's permitted patrons down to the warlord's specific patron
// gives them the Enlighten verb, too
/datum/warbands/sect/on_warlord_spawned(mob/living/carbon/human/warlord, atom/movable/screen/warband/manager/manager)
	var/patron_allowed = FALSE
	if(manager.faithlocks.len)
		for(var/allowed_patron in manager.faithlocks)
			if(ispath(warlord.patron.type, allowed_patron))
				patron_allowed = TRUE
				break

	if(!patron_allowed && manager.faithlocks.len)
		var/new_patron = pick(manager.faithlocks)
		warlord.set_patron(new_patron)
		to_chat(warlord, span_warning("Your patron has been adjusted to match the sect's requirements."))

	manager.faithlocks = list(warlord.patron.type)
	var/patron_name = warlord.patron.name
	for(var/mob/living/member in manager.lobby_members)
		to_chat(member, span_boldwarning("<span style='color:#e8bf67'>SECT FAITHLOCK APPLIED:</span> All characters are now required to serve <span style='color:#e8bf67'>[patron_name].</span>"))
		member.playsound_local(member, 'sound/misc/notice (2).ogg', 100, FALSE)



//////////////////////////////////////////////////////////
///////////////////////////////////////////////// SUBTYPES
/datum/warbands/subtypes/ten
	title = "TEN"
	quote = "''TEN ANGELS descended from on-high, slaughtering heretic and undeath alike. For us, TEN ANGELS sacrificed their holiest of creations.''"
	quote_followup = "DAWN: UNDIVIDED - 2:4"
	warcamp = /datum/map_template/warcamp_standard
	warning = "...of devotion to the Ten."
	faithlock = list(ALL_DIVINE_PATRONS)
	combatmusic = list('sound/music/combat_holy.ogg')

// side note while we're here: antagonists that can't be negotiated with are generally off-theme for Warbands
// if you absolutely need to add one, please leave them at a high rarity
/datum/warbands/subtypes/ascendant
	rarity = 2	// an ascendant sect treads on narrative ground covered by a ton of other antagonists, so we'll make them uncommon
	storytellerlimit = /datum/storyteller/graggar // by well-tread narrative ground i'm referring to a massacre
	title = "ASCENDANT"
	treaty_name = "The Holy Ecclesial"
	quote = "''Shine thy fury upon me, oh Dark Star! I sing thy slaughter's psalm, and thy word is sweet!''"
	quote_followup = "- A posthumous translation of a serial butcher's words - which were otherwise unintelligible."
	warning = "...of devotion to the Four."
	warcamp = /datum/map_template/warcamp_standard
	faithlock = list(ALL_INHUMEN_PATRONS)
	combatmusic = list('sound/music/combat2.ogg')
	outskirts_wave = /datum/outskirts_wave/ascendant

/datum/warbands/subtypes/psydon
	title = "OLD GOD"
	treaty_name = "We of the True Faith"
	quote = "''I miss you, Dead God. Psydon, I miss you. You, who cast down thy heart in our name. \
	We who sin in our pursuit of virtue. We who reject you with every breath and step. We who have created edifice and altar to devils in thy stead.''"
	quote_followup = "- Excerpt from The Apostate, Unknown Author"
	warning = "...of devotion to the Old God."
	warcamp = /datum/map_template/warcamp_standard
	faithlock = list(/datum/patron/old_god)
	combatmusic = list('sound/music/combat_inqordinator.ogg')

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
