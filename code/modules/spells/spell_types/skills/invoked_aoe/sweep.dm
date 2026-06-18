/////////////////////////////////////////
/////////////////////////////////// SWEEP
/*
	an AOE knockdown & knockback given to Warband characters
	strength scales with the caster's current tempo (more damage + a shorter cooldown for each tier)

	attempting a sweep without tempo will fumble the sweep & neuter the effects

	a sweep can be parried if a victim hits a riposte/clash. the effect depends on the result:
		- WIN: 	they're unaffected by the sweep (aside from a 1 tile nudge)
		- DRAW: they're knocked back but remain standing
		- LOSS: they suffer double damage and double knockback

*/

#define SWEEP_CLASH_VICTIM_LOSES	1
#define SWEEP_CLASH_DRAW			2
#define SWEEP_CLASH_VICTIM_WINS		3

/datum/looping_sound/martial
	mid_sounds = list('sound/combat/clash_disarm_us.ogg')
	mid_length = 180
	volume = 100

/obj/effect/proc_holder/spell/invoked/sweep
	name = "Sweep"
	desc = "Drive back whomever might surround you. A Sweep's effectiveness scales with your Tempo, and a target can attempt to riposte the Sweep at great risk to themselves."
	releasedrain = 50
	chargedrain = 1
	chargetime = 5
	recharge_time = 25 SECONDS
	is_cdr_exempt = TRUE
	ignore_los = TRUE
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 2
	chargedloop = /datum/looping_sound/martial
	associated_skill = /datum/skill/misc/athletics
	overlay_state = "call_to_arms"
	ignore_cockblock = TRUE
	gesture_required = TRUE
	req_inhand = /obj/item/rogueweapon
	var/maxthrow = 3
	var/repulse_force = MOVE_FORCE_EXTREMELY_STRONG
	var/sweep_range = 1 // how large is the AOE?
	var/base_damage = 15
	
	var/strike_delay = 0.3 SECONDS	// the pause between the ground telegraph appearing and the strike landing
	var/tempo_damage_step = 0.25	// extra damage multiplier per tempo tier (tier 3 at +25% = +75%)
	var/tempo_cd_step = 5 SECONDS	// cooldown reduction per tempo tier

/obj/effect/proc_holder/spell/invoked/sweep/proc/get_tempo_tier(mob/living/user)
	if(user.has_status_effect(/datum/status_effect/buff/tempo_three))
		return 3
	if(user.has_status_effect(/datum/status_effect/buff/tempo_two))
		return 2
	if(user.has_status_effect(/datum/status_effect/buff/tempo_one))
		return 1
	return 0

/obj/effect/proc_holder/spell/invoked/sweep/proc/is_sweep_foe(mob/living/carbon/AM, mob/living/carbon/human/user, datum/component/trail_follow/manager)
	if(AM == user || AM.anchored)
		return FALSE	// you aren't a foe
	if(AM.mind && AM.mind.warband_ID && AM.mind.warband_ID == user.mind.warband_ID)
		return FALSE	// allies aren't foes
	if(AM.stat != CONSCIOUS)
		return FALSE	// corpses aren't foes
	if(manager && (AM in manager.members))
		return FALSE	// friends aren't foes
	return TRUE

/obj/effect/proc_holder/spell/invoked/sweep/cast(list/targets, mob/living/carbon/human/user, stun_amt = 5)
	var/base_recharge = initial(recharge_time)
	var/datum/component/trail_follow/manager = user.GetComponent(/datum/component/trail_follow)
	if(!manager)
		manager = user.AddComponent(/datum/component/trail_follow)

	var/tempo_tier = get_tempo_tier(user)

	// cooldown scales with our tempo tier
	var/reduction = tempo_tier * tempo_cd_step
	recharge_time = max(1 SECONDS, base_recharge - reduction)

	// damage scales with our tempo tier
	var/final_damage = base_damage * (1 + (tempo_tier * tempo_damage_step))

	var/list/strike_turfs = list()
	for(var/turf/T in RANGE_TURFS(sweep_range, user))
		if(T.density)
			continue
		strike_turfs += T
		var/obj/effect/temp_visual/special_intent/fx = new(T, strike_delay)
		fx.icon = 'icons/effects/effects.dmi'
		fx.icon_state = "trap"

	playsound(user, 'sound/combat/wooshes/blunt/wooshlarge (1).ogg', 80, TRUE)
	addtimer(CALLBACK(src, PROC_REF(resolve_sweep), user, strike_turfs, final_damage, tempo_tier), strike_delay)

	return TRUE

// the delayed hit: redraw the zone with strike FX and hit whoever still stands in it
/obj/effect/proc_holder/spell/invoked/sweep/proc/resolve_sweep(mob/living/carbon/human/user, list/strike_turfs, final_damage, tempo_tier)
	if(!user || user.stat != CONSCIOUS)
		return

	var/datum/component/trail_follow/manager = user.GetComponent(/datum/component/trail_follow) // so we can get our list of follower NPCs

	for(var/mob/living/carbon/screenshaken in view(5, user))
		shake_camera(screenshaken, 10, 1)
		screenshaken.flash_fullscreen("stressflash")

	playsound(user, 'sound/combat/clash_struck.ogg', 80, TRUE)

	for(var/turf/T in strike_turfs)
		var/obj/effect/temp_visual/special_intent/fx = new(T, 0.5 SECONDS)
		fx.icon = 'icons/effects/effects.dmi'
		fx.icon_state = "sweep_fx"
		for(var/mob/living/carbon/AM in T)
			if(!is_sweep_foe(AM, user, manager))
				continue
			do_sparks(1, FALSE, AM)

			// if the sweep impacts someone who's trying to riposte, we run a Clash and change the result based on who wins
			var/is_clashing = FALSE
			if(ishuman(AM) && AM.has_status_effect(/datum/status_effect/buff/clash))
				if(AM.get_active_held_item() && user.get_active_held_item())
					is_clashing = TRUE

			if(is_clashing)
				var/mob/living/carbon/human/victim = AM
				var/clash_result = resolve_clash_outcome(victim, user)
				do_clash_flair(victim, user)
				victim.remove_status_effect(/datum/status_effect/buff/clash)
				switch(clash_result)
					if(SWEEP_CLASH_VICTIM_WINS)
						// if the victim wins the clash, the strike against them is considered fumbled
						to_chat(victim, span_notice("I turn [user]'s sweep aside!"))
						apply_fumbled_hit(victim, user, 1)
					if(SWEEP_CLASH_VICTIM_LOSES)
						// if a victim tries parrying a sweep & loses the clash roll, they suffer double the damage and double the knockback
						to_chat(victim, span_danger("[user] shatters my foolhardy attempt at a parry, and the blow lands twice as hard! My hubris?!"))
						if(tempo_tier > 0)
							apply_sweep_hit(victim, user, final_damage * 2, 2, TRUE)
						else // unless we have no tempo, in which case we just nudge them back by 1 tile
							apply_fumbled_hit(victim, user, 2)
					else
						to_chat(victim, span_danger("My guard buckles against [user]'s sweep!"))
						if(tempo_tier > 0) // during a draw, they're shoved back but stay armed & standing
							apply_sweep_hit(victim, user, final_damage, 1, FALSE)
						else
							apply_fumbled_hit(victim, user, 1)
			else
				if(tempo_tier > 0)
					apply_sweep_hit(AM, user, final_damage, 1, TRUE)
				else
					apply_fumbled_hit(AM, user, 1)

	user.visible_message(span_boldred("[user] sweeps their weapon, driving back their foes!"))

// a fumbled hit: push the foe back with no damage and no knockdown
/obj/effect/proc_holder/spell/invoked/sweep/proc/apply_fumbled_hit(mob/living/carbon/AM, mob/living/carbon/human/user, tiles = 1)
	var/atom/throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(AM, user)))
	to_chat(AM, span_danger("You're swept away by [user]!"))
	AM.safe_throw_at(throwtarget, tiles, 1, user, force = repulse_force)

// a full, tempo-fueled hit: brute damage, a knockdown, and a throw
/obj/effect/proc_holder/spell/invoked/sweep/proc/apply_sweep_hit(mob/living/carbon/AM, mob/living/carbon/human/user, damage, throw_mult = 1, knockdown = TRUE)
	var/distfromcaster = get_dist(user, AM)
	AM.adjustBruteLoss(damage)
	if(knockdown)
		AM.set_resting(TRUE, TRUE)
	if(distfromcaster == 0)
		AM.adjustBruteLoss(5 * throw_mult)
		to_chat(AM, span_danger("You're crushed into the floor by [user]!"))
	else
		to_chat(AM, span_danger("You're thrown back by [user]!"))
		var/atom/throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(AM, user)))
		var/throw_range = CLAMP((maxthrow - (CLAMP(distfromcaster - 2, 0, distfromcaster))), 3, maxthrow) * throw_mult
		AM.safe_throw_at(throwtarget, throw_range, 1, user, force = repulse_force)

/obj/effect/proc_holder/spell/invoked/sweep/proc/resolve_clash_outcome(mob/living/carbon/human/victim, mob/living/carbon/human/sweeper)
	var/obj/item/victim_weapon = victim.get_active_held_item()
	var/obj/item/sweeper_weapon = sweeper.get_active_held_item()
	if(!victim_weapon || !sweeper_weapon)
		return SWEEP_CLASH_DRAW

	var/list/odds = victim.get_clash_odds(sweeper, victim_weapon, sweeper_weapon)
	if(odds["instantloss"] && !odds["instantwin"])
		return SWEEP_CLASH_VICTIM_LOSES
	if(odds["instantwin"] && !odds["instantloss"])
		return SWEEP_CLASH_VICTIM_WINS

	var/victim_win = prob(odds["us"])
	var/sweeper_win = prob(odds["opp"])
	if(victim_win == sweeper_win)
		return SWEEP_CLASH_DRAW
	if(victim_win)
		return SWEEP_CLASH_VICTIM_WINS
	return SWEEP_CLASH_VICTIM_LOSES

/obj/effect/proc_holder/spell/invoked/sweep/proc/do_clash_flair(mob/living/carbon/human/victim, mob/living/carbon/human/user)
	victim.flash_fullscreen("whiteflash")
	var/turf/front = get_turf(victim)
	do_sparks(2, FALSE, front)
	victim.visible_message(span_boldwarning("[user]'s sweep crashes against [victim]'s guard!"))

#undef SWEEP_CLASH_VICTIM_LOSES
#undef SWEEP_CLASH_DRAW
#undef SWEEP_CLASH_VICTIM_WINS
