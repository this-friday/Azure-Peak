////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// reduces the Warlord's stats & removes their Sweep spell
// gives a tiny (1) disorder reduction

/datum/warbands/aspects/figurehead
	title = "FIGUREHEAD"
	summary = "The Warlord's selfless devotion to his Warband has shaped it into a force to be reckoned with. \
	In comparison - and as a single combatant - the Warlord himself is rather weak."
	desc = "The Warlord's STR is capped to 8, and his SPD and CON to 10. On top of that, he loses the Sweep action."
	warning = "...of a driven, beloved leader."
	points = 1

// STR: 8 | SPD: 10 | CON: 10
/datum/warbands/aspects/figurehead/on_warlord_equip(mob/living/carbon/human/warlord, datum/warband_manager/manager)
	if(warlord.mind)
		for(var/obj/effect/proc_holder/spell/sweep_spell in warlord.mind.spell_list)
			if(sweep_spell.name == "Sweep")
				warlord.mind.RemoveSpell(sweep_spell)
		if(warlord.actions)
			for(var/datum/action/spell_action/sweepaction in warlord.actions)
				if(sweepaction.name == "Sweep")
					qdel(sweepaction)
	if(warlord.STASTR > 8)
		warlord.STASTR = 8
	if(warlord.STASPD > 10)
		warlord.STASPD = 10
	if(warlord.STACON > 10)
		warlord.STACON = 10

/datum/warbands/aspects/figurehead/on_warband_confirmed(datum/warband_manager/manager, intensity = 1)
	manager.disorder -= 1
