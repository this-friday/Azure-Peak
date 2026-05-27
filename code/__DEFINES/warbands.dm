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

// the respawn pool/'tickets' for a warband's Goon NPCs
#define WARBAND_BASE_RESPAWNS 400 // the initial minimum | the final total is combined with another RESPAWNS_ define, based on the chosen Warband
#define RESPAWNS_MINIMAL 25
#define RESPAWNS_LOW 50
#define RESPAWNS_MEDIUM 100
#define RESPAWNS_HIGH 200
#define RESPAWNS_HORDE 500

// percent chance that a Lieutenant is chosen to be an Aspirant
// should remain high, as the main balancing factor for warbands is their inclination to Implode & Kill Each Other
#define ASPIRANT_CHANCE 70

////////////////////////////////////////////////////////
///////////////////////////////////////////////// DATUMS

// WARBANDS
#define WARBANDS 	list(/datum/warbands/standard,  /datum/warbands/mercenary, /datum/warbands/sect, \
					/datum/warbands/storyteller/peasant, /datum/warbands/storyteller/wizard)

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
                            WARBAND_MERC_VAQUERO, WARBAND_MERC_UNDERDWELLER, WARBAND_MERC_DROW, WARBAND_MERC_HANGYAKU, WARBAND_MERC_TITHEBOUND)

// SUBTYPES (SECTS)
#define WARBAND_SECT_TEN 		/datum/warbands/subtypes/ten 
#define WARBAND_SECT_FOUR		/datum/warbands/subtypes/ascendant
#define WARBAND_SECT_PSYDON		/datum/warbands/subtypes/psydon

#define WARBAND_SECTS	list(WARBAND_SECT_TEN, WARBAND_SECT_FOUR, WARBAND_SECT_PSYDON)

// SUBTYPES (OTHER)
#define WARBAND_UNTAGGED_SUBTYPES	list()

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
// don't forget to add it to the list below, too

#define ASPECTS	 list(ASPECT_FORT, ASPECT_SURPRISE, ASPECT_HOST, ASPECT_SCUM, ASPECT_MARKED, \
					ASPECT_MORALE, ASPECT_WAR, ASPECT_RANDOM, ASPECT_SPLINTERED, ASPECT_HORDE, \
					ASPECT_FIGUREHEAD, ASPECT_ENVY, ASPECT_BATTLETESTED, ASPECT_BADSPAWN, \
					ASPECT_CAVALRY, ASPECT_SUPPLIES)

// TREATIES
// terms in this list are given to EVERY treaty | exclude unique terms from here (such as /datum/treaty/terms/unique/wizard)
#define WARBAND_TERMS list(/datum/treaty/terms/regime_change, /datum/treaty/terms/codify_law, /datum/treaty/terms/remove_law, /datum/treaty/terms/freeze_laws, \
						/datum/treaty/terms/abolish_charter, /datum/treaty/terms/seal_grave, /datum/treaty/terms/exile, /datum/treaty/terms/blood_pact, \
						/datum/treaty/terms/attainder, /datum/treaty/terms/peace, /datum/treaty/terms/freeform)

// treaty flavor datums
#define TFACTION_AZURE /datum/territory_faction/azure
#define TFACTION_CHURCH /datum/territory_faction/church
#define TFACTION_HEARTFELT /datum/territory_faction/heartfelt
#define TFACTION_ORTHODOX /datum/territory_faction/orthodoxy
#define TFACTION_SOILER	/datum/territory_faction/farm
#define TFACTION_GUILD /datum/territory_faction/guild
#define TFACTION_MERCHANT /datum/territory_faction/merchant

#define DEFAULT_TERRITORY_FACTIONS list(TFACTION_AZURE, TFACTION_CHURCH, TFACTION_HEARTFELT, TFACTION_ORTHODOX, TFACTION_SOILER, TFACTION_GUILD, TFACTION_MERCHANT)


#define TEMPLATE_OUTSKIRTS 1
#define TEMPLATE_INTERMISSION 2
#define TEMPLATE_WARCAMP 3
