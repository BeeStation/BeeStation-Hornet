#define SIGIL_INVOKATION_ALPHA 120
#define SIGIL_INVOKED_ALPHA 200

/obj/structure/destructible/clockwork/sigil
	name = "sigil"
	desc = "It's a sigil that does something."
	max_integrity = 10
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "sigilvitality"
	density = FALSE
	alpha = 60

	/// How long you have to stand on the sigil before it activates
	var/effect_charge_time = 0 SECONDS
	/// The atom that this sigil is currently affecting
	var/affected_atom
	/// Color while inactive
	var/idle_color = COLOR_WHITE
	/// Color faded to while someone stands on top
	var/invokation_color = "#F1A03B"
	/// Color pulsed when sigil succeeds
	var/success_color = "#EBC670"
	/// Color pulsed when the sigil fails
	var/fail_color = "#d47433"
	/// The timer for the sigil's charge time
	var/active_timer
	/// If set to TRUE, the sigil will repeatedly apply the affect to the thing above it
	var/looping = FALSE
	/// If set to FALSE, the sigil can affect any atom.
	var/living_only = TRUE

/obj/structure/destructible/clockwork/sigil/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/**
 * Somebody is interacting with the sigil with their hands, lets break it
 */
/obj/structure/destructible/clockwork/sigil/attack_hand(mob/user, list/modifiers)
	. = ..()
	// Break the sigil
	animate(src, transform = matrix() * 1.5, alpha = 0, time = 3)
	sleep(3)
	if(active_timer)
		deltimer(active_timer)
		active_timer = null
	qdel(src)

/**
 * An atom has moved on top of the sigil
 * Try to apply effects to the target atom if the following checks pass
 */
/obj/structure/destructible/clockwork/sigil/proc/on_entered(datum/source, atom/movable/target_atom)
	SIGNAL_HANDLER

	if(!isliving(target_atom) && living_only)
		return
	if(affected_atom)
		return
	if(active_timer)
		return

	try_apply_effects(target_atom)

/**
 * An atom has moved off the sigil
 * If the target atom is the affected atom, stop affecting it
 */
/obj/structure/destructible/clockwork/sigil/proc/on_exited(datum/source, atom/movable/target_atom)
	SIGNAL_HANDLER

	if(affected_atom == target_atom)
		affected_atom = null
		animate(src, color = idle_color, alpha = initial(alpha), time = 5)
		if(active_timer)
			deltimer(active_timer)
			active_timer = null

/**
 * Basic checks to see if the target atom can be affected by this sigil
 */
/obj/structure/destructible/clockwork/sigil/proc/can_affect(atom/movable/target_atom)
	if(ismob(target_atom))
		var/mob/mob_target = target_atom
		if(mob_target.can_block_magic(MAGIC_RESISTANCE_HOLY))
			return FALSE

	return TRUE

/**
 * Try to apply the effects to the target atom
 * If can_affect() returns FALSE, we won't apply effects and will instead play an animation
 */
/obj/structure/destructible/clockwork/sigil/proc/try_apply_effects(atom/movable/target_atom)
	if(!can_affect(target_atom))
		on_fail()
		return

	affected_atom = target_atom

	// The effect charge time is 0, lets instantly apply the effect
	if(effect_charge_time <= 0)
		apply_effects()
	else
		animate(src, color = invokation_color, alpha = SIGIL_INVOKATION_ALPHA, effect_charge_time)
		active_timer = addtimer(CALLBACK(src, PROC_REF(apply_effects)), effect_charge_time, TIMER_UNIQUE | TIMER_STOPPABLE)

/**
 * Play a success animation and apply the effects to the target atom
 * When inhereting this, call . = ..() at the END
 */
/obj/structure/destructible/clockwork/sigil/proc/apply_effects()
	if(!can_affect(affected_atom))
		return

	color = success_color
	transform = matrix() * 1.2
	alpha = SIGIL_INVOKED_ALPHA

	if(looping)
		animate(src, transform = matrix(), color = invokation_color, alpha = SIGIL_INVOKATION_ALPHA, time = effect_charge_time)
		active_timer = addtimer(CALLBACK(src, PROC_REF(apply_effects)), effect_charge_time, TIMER_UNIQUE | TIMER_STOPPABLE)
	else
		active_timer = null
		affected_atom = null
		animate(src, transform = matrix(), color = idle_color, alpha = initial(alpha), time = effect_charge_time)

/**
 * We failed to apply the effects to the target atom
 * Reset timer and affected atom, then play a failure animation
 * When inhereting this, call . = ..() at the END
 */
/obj/structure/destructible/clockwork/sigil/proc/on_fail()
	// Reset timer and affected atom
	if(active_timer)
		deltimer(active_timer)
		active_timer = null
	affected_atom = null

	// Flavor
	color = fail_color
	transform = matrix() * 1.2
	alpha = 140
	animate(src, transform = matrix(), color = idle_color, alpha = initial(alpha), time = 5)

#undef SIGIL_INVOKATION_ALPHA
#undef SIGIL_INVOKED_ALPHA
