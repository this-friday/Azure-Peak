///////////////////////////////////////////////////////////
///////////////////////////////////////////////// VARIABLES
// warband max playercount (10 at minimum)
#define GRUNTS_PER_LIEUTENANT 2 // minimum grunts per lieutenant | scales at a rate of +1 for every 15 active players past 40, as seen here: (/datum/round_event/antagonist/solo/warlord/start())
#define GRUNTS_PER_LIEUTENANT_MAX 99
#define LIEUTENANTS_PER_WARLORD 3

// universal statblock applied to all Goon NPCs
#define WARBAND_NPC_STR 14
#define WARBAND_NPC_SPD 12
#define WARBAND_NPC_CON 13
#define WARBAND_NPC_WIL 14
#define WARBAND_NPC_LCK 10
#define WARBAND_NPC_INT 10
#define WARBAND_NPC_PER 10

// the default squad size for Goons
#define ALLIED_NPC_MINIMUM 4

// the respawn pool/tickets for a warband's Goon NPCs
#define WARBAND_BASE_RESPAWNS 400 // the initial minimum | the final total is combined with another RESPAWNS_ define, based on the chosen Warband
#define RESPAWNS_MINIMAL 25
#define RESPAWNS_LOW 50
#define RESPAWNS_MEDIUM 100
#define RESPAWNS_HIGH 200
#define RESPAWNS_HORDE 500

// percent chance that a Lieutenant is chosen to be an Aspirant
#define ASPIRANT_CHANCE 65 // should remain high, as the main balancing factor for warbands is their inclination to Implode & Kill Each Other

// we'd like our warlord candidates to present evidence of basic sentience (10+ PQ), as they're gonna have a lot on their plate
#define WARLORD_PQ 10 // in their absence we'll still allow people below the PQ threshold to be a warlord, similar to how it works for Lord/Duke

//////////////////////////////////////////////////////
///////////////////////////////////////////////// MAPS

#define OUTSKIRTS_TEMPLATE_TYPES list(\
	"cave"		= list(/datum/map_template/outskirts/cave_a), \
	"mountains"	= list(/datum/map_template/outskirts/mountains_a), \
	"coast"		= list(/datum/map_template/outskirts/coast_a), \
	"woods"		= list(/datum/map_template/outskirts/river_a), \
	"bog"		= list(/datum/map_template/outskirts/bog_a) \
)

#define INTERMISSION_TEMPLATE_TYPES list(\
	"cave"		= list(/datum/map_template/intermission/cave_a), \
	"mountains"	= list(/datum/map_template/intermission/mountains_a), \
	"coast"		= list(/datum/map_template/intermission/coast_a), \
	"woods"		= list(/datum/map_template/intermission/woods_a), \
	"bog"		= list(/datum/map_template/intermission/bog_a) \
)

////////////////////////////////////////////////////////
///////////////////////////////////////////////// DATUMS

// ASPECTS
#define ASPECT_RANDOM			/datum/warbands/aspects/fated_suffering
#define ASPECT_SURPRISE			/datum/warbands/aspects/surprise
#define ASPECT_FORT				/datum/warbands/aspects/fort
#define ASPECT_HOST				/datum/warbands/aspects/extraspawns
#define ASPECT_FIGUREHEAD		/datum/warbands/aspects/figurehead
#define ASPECT_ENVY				/datum/warbands/aspects/envy
#define ASPECT_BADSPAWN			/datum/warbands/aspects/badexit
#define ASPECT_MARKED			/datum/warbands/aspects/marked
#define ASPECT_SPLINTERED		/datum/warbands/aspects/splintered
#define ASPECT_HORDE			/datum/warbands/aspects/horde
#define ASPECT_BATTLETESTED		/datum/warbands/aspects/battletested
#define ASPECT_MORALE			/datum/warbands/aspects/morale
#define ASPECT_WAR				/datum/warbands/aspects/war
#define ASPECT_SCUM				/datum/warbands/aspects/outlaw
#define ASPECT_CAVALRY			/datum/warbands/aspects/cavalry
#define ASPECT_SUPPLIES			/datum/warbands/aspects/supplies
#define ASPECT_PATRON			/datum/warbands/aspects/patron

// SUBTYPES (SECTS)
#define WARBAND_SECT_TEN 		/datum/warbands/subtypes/ten 
#define WARBAND_SECT_FOUR		/datum/warbands/subtypes/ascendant
#define WARBAND_SECT_PSYDON		/datum/warbands/subtypes/psydon

#define WARBAND_SECTS list(WARBAND_SECT_TEN, WARBAND_SECT_FOUR, WARBAND_SECT_PSYDON)

// SUBTYPES (MERCENARIES)
#define WARBAND_MERC_NORTHMEN		/datum/warbands/subtypes/northmen
#define WARBAND_MERC_GRENZEL		/datum/warbands/subtypes/grenzel
#define WARBAND_MERC_BLACKOAK		/datum/warbands/subtypes/blackoak
#define WARBAND_MERC_CONDO			/datum/warbands/subtypes/condottiero
#define WARBAND_MERC_DESERTRIDER	/datum/warbands/subtypes/raneshen
#define WARBAND_MERC_FORLORN		/datum/warbands/subtypes/forlorn
#define WARBAND_MERC_FREI			/datum/warbands/subtypes/freifechter
#define WARBAND_MERC_GRUDGE			/datum/warbands/subtypes/grudgebearer
#define WARBAND_MERC_ROUTIER		/datum/warbands/subtypes/routier
#define WARBAND_MERC_RUMA			/datum/warbands/subtypes/ruma
#define WARBAND_MERC_STEPPE			/datum/warbands/subtypes/steppesman
#define WARBAND_MERC_UNDERDWELLER	/datum/warbands/subtypes/underdweller
#define WARBAND_MERC_VAQUERO		/datum/warbands/subtypes/vaquero
#define WARBAND_MERC_WARSCHOLAR		/datum/warbands/subtypes/warscholar
#define WARBAND_MERC_DROW			/datum/warbands/subtypes/anthrax
#define WARBAND_MERC_HANGYAKU		/datum/warbands/subtypes/hangyaku
#define WARBAND_MERC_TITHEBOUND 	/datum/warbands/subtypes/tithebound

#define WARBAND_MERCENARIES list(WARBAND_MERC_NORTHMEN, WARBAND_MERC_GRENZEL, WARBAND_MERC_BLACKOAK, WARBAND_MERC_CONDO, \
								WARBAND_MERC_DESERTRIDER, WARBAND_MERC_FORLORN, WARBAND_MERC_FREI, WARBAND_MERC_GRUDGE, \
								WARBAND_MERC_ROUTIER, WARBAND_MERC_RUMA, WARBAND_MERC_STEPPE, WARBAND_MERC_WARSCHOLAR, \
								WARBAND_MERC_VAQUERO, WARBAND_MERC_UNDERDWELLER, WARBAND_MERC_DROW, WARBAND_MERC_HANGYAKU, \
								WARBAND_MERC_TITHEBOUND)

// terms in this list are given to EVERY treaty | exclude unique terms from here (such as /datum/treaty/terms/unique/wizard)
#define WARBAND_TERMS list(/datum/treaty/terms/regime_change, /datum/treaty/terms/codify_law, /datum/treaty/terms/remove_law, /datum/treaty/terms/freeze_laws, \
						/datum/treaty/terms/abolish_charter, /datum/treaty/terms/seal_grave, /datum/treaty/terms/exile, /datum/treaty/terms/blood_pact, \
						/datum/treaty/terms/attainder, /datum/treaty/terms/peace, /datum/treaty/terms/freeform)

// treaty flavor datums
#define TFACTION_AZURE /datum/treaty_flavor/azure
#define TFACTION_CHURCH /datum/treaty_flavor/church
#define TFACTION_HEARTFELT /datum/treaty_flavor/heartfelt
#define TFACTION_ORTHODOX /datum/treaty_flavor/orthodoxy
#define TFACTION_SOILER	/datum/treaty_flavor/farm
#define TFACTION_GUILD /datum/treaty_flavor/guild
#define TFACTION_MERCHANT /datum/treaty_flavor/merchant

#define DEFAULT_TREATY_FLAVOR_FACTIONS list(TFACTION_AZURE, TFACTION_CHURCH, TFACTION_HEARTFELT, TFACTION_ORTHODOX, TFACTION_SOILER, TFACTION_GUILD, TFACTION_MERCHANT)


#define TEMPLATE_OUTSKIRTS 1
#define TEMPLATE_INTERMISSION 2
