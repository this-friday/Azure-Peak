///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////// TERM: ACKNOWLEDGE SUPERIOR WIZARD
/*
 	warband-unique term (Sorcerer-King only)
	if the Court Magician signs this, they suffer a round-long -5 mood debuff

*/
/datum/treaty/terms/unique/wizard
	name = "Acknowledge Superior Wizard"
	desc = "Admit the arcyne superiority of the SORCERER-KING, henceforth and forever."
	warbandlock = /datum/warbands/wizard
	authorities = list(/datum/job/roguetown/magician)
	hint = "...every other sentence is about how magnificent some wizard is..."
	// the wizard has acknowledged that they:
	var/static/list/base_insult = list("are, quote, 'a fraud in all manners arcyne'", \
								"are, quote, 'a clay-brained charlatan'", \
								"are, quote, 'a drooling hylic'")
	var/static/list/followup = list("who is 'lucky they haven't annihilated themselves casting cantrips, much less trying to breathe'", \
							"whose 'only attentions from Noc likely came in the form of a meteorite falling into their skull'", \
							"who 'come their death, will be damned to cluelessly roam the Underworld for all eternity' as the Carriageman is, quote, 'likely to mistake them for a fogbeast or a similar such brainless creechur'", \
							"who should 'forsake the secrets of the universe and embrace their ultimate destiny of tilling fields'")

/datum/treaty/terms/unique/wizard/duplicate_check(datum/treaty/terms/existing)
	return type == existing.type

/datum/treaty/terms/unique/wizard/apply(obj/item/treaty/treaty)
	if(!signatures.len)
		return
	var/signatory_name = signatures[1]
	var/mob/living/subpar_mage = treaty.text_to_mob(signatory_name)
	var/chosen_base_insult = pick(base_insult)
	var/chosen_followup = pick(followup)
	if(subpar_mage)
		subpar_mage.add_stress(/datum/stressevent/wizardterm)
		subpar_mage.playsound_local(subpar_mage, 'sound/ddstress.ogg', 100, FALSE)
		return "The [subpar_mage.job], [subpar_mage.real_name], has acknowledged that they [chosen_base_insult] [chosen_followup]."
	return
