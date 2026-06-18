// component given to a victim via the Seal Grave term (/datum/treaty/terms/seal_grave)
// if someone marked with a seal is resurrected, they get a variant of sunlight vulnerability (see /datum/component/sunlight_vulnerability/grave_seal)
// can be cleansed by Hags via /datum/hag_boon/misc/cleanse_grave_seal, before or after the target's death
/datum/component/grave_seal
	var/sealed = FALSE // TRUE once the target has died with the seal upon them

/datum/component/grave_seal/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_death))
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	var/mob/living/L = parent
	if(L.stat == DEAD)
		sealed = TRUE

/datum/component/grave_seal/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	if(sealed)
		return
	sealed = TRUE
	to_chat(source, span_userdanger("My grave is sealed by divine sanction. Should I rise again, the Sun itself will reject me."))

/datum/component/grave_seal/proc/on_revive(mob/living/source, full_heal, admin_revive)
	SIGNAL_HANDLER
	if(!sealed)
		return
	source.AddComponent(/datum/component/sunlight_vulnerability/grave_seal)
	to_chat(source, span_userdanger("I have been resurrected. Daelight will burn me for my trespass."))
