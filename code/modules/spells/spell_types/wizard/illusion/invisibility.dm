// an arcane/non-miracle variant of /datum/action/cooldown/spell/noc/invisibility
/datum/action/cooldown/spell/invisibility
	name = "Invisibility"
	desc = "Make another (or yourself) invisible for some time. Duration scales with intelligence. Casting, attacking or being attacked will cancel the duration."
	button_icon = 'icons/mob/actions/nocmiracles.dmi'
	button_icon_state = "invisibility"
	sound = 'sound/misc/area.ogg'
	spell_color = GLOW_COLOR_ILLUSION
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = TRUE
	cast_range = 3
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = 30

	invocation_type = INVOCATION_NONE

	charge_required = TRUE
	charge_time = 1 SECONDS
	charge_drain = 3
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	cooldown_time = 30 SECONDS

	associated_skill = /datum/skill/magic/arcane
	associated_stat = STATKEY_INT

	spell_requirements = SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

/datum/action/cooldown/spell/invisibility/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return FALSE
	var/mob/living/spelltarget = cast_on
	if(spelltarget.anti_magic_check(TRUE, TRUE))
		return FALSE
	spelltarget.visible_message(span_warning("[spelltarget] starts to fade into thin air!"), span_notice("You start to become invisible!"))
	var/mob/living/caster = owner
	var/dur = 15 + min(max(caster.STAINT - 10, 0) * 2.5, 12.5)
	if(dur >= cooldown_time)
		cooldown_time = dur + 5 SECONDS
	animate(spelltarget, alpha = 0, time = 1 SECONDS, easing = EASE_IN)
	spelltarget.mob_timers[MT_INVISIBILITY] = world.time + dur SECONDS
	addtimer(CALLBACK(spelltarget, TYPE_PROC_REF(/mob/living, update_sneak_invis), TRUE), dur SECONDS)
	addtimer(CALLBACK(spelltarget, TYPE_PROC_REF(/atom/movable, visible_message), span_warning("[spelltarget] fades back into view."), span_notice("You become visible again.")), dur SECONDS)
	return TRUE
