/**
 *	SUMMON
 *	Target can no longer act and is forced to approach the vampire.
 *	Uses an AI controller to force movement towards the caster.
 */
/datum/action/vampire/targeted/summon
	name = "Summon"
	desc = "Compel a mortal to approach you against their will."
	button_icon_state = "power_summon"
	power_explanation = "Click any player to summon them towards you.\n\
		Your target will be unable to act and will be compelled to walk towards you.\n\
		The effect ends when they reach you, after a duration, or if line of sight is broken.\n\
		They must be able to see you to be affected."
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 100
	cooldown_time = 60 SECONDS
	target_range = 10
	prefire_message = "Who will you summon to your presence?"

	/// Maximum duration of the summon effect
	var/summon_duration = 30 SECONDS

/datum/action/vampire/targeted/summon/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	if(!iscarbon(target_atom))
		return FALSE
	var/mob/living/carbon/carbon_target = target_atom

	if(!carbon_target.mind)
		owner.balloon_alert(owner, "[carbon_target] is mindless.")
		return FALSE

	if(HAS_MIND_TRAIT(carbon_target, TRAIT_VAMPIRE_ALIGNED) || IS_CURATOR(carbon_target))
		owner.balloon_alert(owner, "immune to your presence.")
		return FALSE

	if(carbon_target.has_unlimited_silicon_privilege)
		owner.balloon_alert(owner, "[carbon_target] is immune.")
		return FALSE

	if(carbon_target.stat != CONSCIOUS)
		owner.balloon_alert(owner, "[carbon_target] is not [(carbon_target.stat == DEAD || HAS_TRAIT(carbon_target, TRAIT_FAKEDEATH)) ? "alive" : "conscious"].")
		return FALSE

	if(carbon_target.is_blind())
		owner.balloon_alert(owner, "[carbon_target] is blind.")
		return FALSE

	if(carbon_target.has_status_effect(/datum/status_effect/summoned))
		owner.balloon_alert(owner, "[carbon_target] is already being summoned.")
		return FALSE

	return TRUE

/datum/action/vampire/targeted/summon/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/carbon/carbon_target = target_atom

	carbon_target.apply_status_effect(/datum/status_effect/summoned, summon_duration, owner)

	owner.balloon_alert(owner, "summoning [carbon_target]")
	to_chat(carbon_target, span_awe("An irresistible compulsion draws you..."), type = MESSAGE_TYPE_WARNING)
	to_chat(owner, span_notice("You beckon [carbon_target] towards you."), type = MESSAGE_TYPE_INFO)

/// Status effect for being summoned towards the vampire
/datum/status_effect/summoned
	id = "summoned"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 30 SECONDS
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/summoned
	/// The vampire who is summoning us
	var/mob/living/source_vampire
	/// The move loop handling our movement
	var/datum/move_loop/move_loop
	/// How long between each step
	var/step_delay = 0.6 SECONDS
	/// How many consecutive grace ticks have elapsed while the summon is resolving
	var/grace_counter = 0
	/// How many grace ticks must elapse (while a finishing condition holds) before the summon completes with a stun
	var/grace_period = 10

/datum/status_effect/summoned/on_creation(mob/living/new_owner, set_duration, mob/living/vampire)
	if(isnum_safe(set_duration))
		duration = set_duration
	source_vampire = vampire
	return ..()

/datum/status_effect/summoned/Destroy()
	source_vampire = null
	if(!QDELETED(move_loop))
		qdel(move_loop)
	move_loop = null
	return ..()

/datum/status_effect/summoned/on_apply()
	if(!iscarbon(owner))
		return FALSE
	owner.add_traits(list(TRAIT_INCAPACITATED, TRAIT_MUTE), TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(block_player_move))
	owner.add_client_colour(/datum/client_colour/glass_colour/pink)
	start_movement()
	return TRUE

/// Blocks the player from moving themselves while summoned
/datum/status_effect/summoned/proc/block_player_move(mob/source, atom/new_loc)
	SIGNAL_HANDLER
	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/// Starts or restarts the movement loop towards the vampire
/datum/status_effect/summoned/proc/start_movement()
	if(move_loop)
		qdel(move_loop)
	if(QDELETED(source_vampire) || QDELETED(owner))
		return
	// min_dist = 1 so the loop stops stepping once we're adjacent, rather than
	// homing onto the vampire's exact tile (which would step onto them and
	// place-swap on help intent).
	move_loop = SSmove_manager.move_to(owner, source_vampire, 1, step_delay, timeout = INFINITY)
	if(move_loop)
		RegisterSignal(move_loop, COMSIG_QDELETING, PROC_REF(on_move_loop_deleted))

/// Called when the move loop is deleted externally
/datum/status_effect/summoned/proc/on_move_loop_deleted(datum/source)
	SIGNAL_HANDLER
	move_loop = null

/// End point for the summon. Applies a brief stun(only meaningful on the "arrived" finish)
/datum/status_effect/summoned/proc/end_summon(stun_duration = 2 SECONDS)
	if(QDELETED(src))
		return
	if(stun_duration > 0 && !QDELETED(owner))
		owner.Stun(stun_duration)
	qdel(src)

/// Advances the shared grace countdown by a tick. Every early finishing condition funnels through here,
/// so the vampire always gets the same visible countdown before it ends.
/datum/status_effect/summoned/proc/advance_resolution(reason)
	grace_counter++
	// Grace spent: finish with the standard stun.
	if(grace_counter > grace_period)
		end_summon(2 SECONDS)
		return
	if(QDELETED(source_vampire))
		return
	// Announce the reason and total on the first grace tick, then count down.
	if(grace_counter == 1)
		owner.balloon_alert(source_vampire, "[reason] ([grace_period]s)", color = COLOR_DARK_RED)
	else
		owner.balloon_alert(source_vampire, "[grace_period - grace_counter + 1]...", color = COLOR_DARK_RED)

/datum/status_effect/summoned/on_remove()
	owner.remove_traits(list(TRAIT_INCAPACITATED, TRAIT_MUTE), TRAIT_STATUS_EFFECT(id))

	UnregisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE)

	owner.remove_client_colour(/datum/client_colour/glass_colour/pink)

	if(move_loop)
		UnregisterSignal(move_loop, COMSIG_QDELETING)
		qdel(move_loop)
		move_loop = null

	// Stop any residual movement
	SSmove_manager.stop_looping(owner)

	to_chat(owner, span_awe("The compulsion fades and you regain control of yourself."))

/datum/status_effect/summoned/tick(seconds_between_ticks)
	// Summoner gone for good: cut the strings cleanly, no countdown and no stun.
	if(QDELETED(source_vampire) || source_vampire.stat == DEAD)
		end_summon(0)
		return

	// Arrived before the vampire: stop pursuing and let the grace countdown resolve it.
	if(owner.Adjacent(source_vampire))
		// Flavour announcement on the very first grace tick.
		if(grace_counter == 0)
			to_chat(owner, span_awe("You have arrived before [source_vampire]..."))
			to_chat(source_vampire, span_notice("[owner] has arrived before you."))
		// Don't keep trying to move while we're resolving.
		if(move_loop)
			UnregisterSignal(move_loop, COMSIG_QDELETING)
			qdel(move_loop)
			move_loop = null
		advance_resolution("arrived")
		return

	// Line of sight broken: also resolves through the shared grace countdown.
	if(!(source_vampire in view(10, owner)))
		if(grace_counter == 0)
			to_chat(owner, span_awe("You lose sight of your target, but the compulsion lingers..."))
		advance_resolution("sight broken")
		return

	// Make sure we're facing the vampire
	owner.face_atom(source_vampire)

	// Restart movement if it stopped for some reason (blocked by obstacle, etc)
	if(!move_loop)
		start_movement()

/datum/status_effect/summoned/get_examine_text()
	return span_warning("[owner.p_They()] [owner.p_are()] walking with a blank expression, as if compelled.")

/// Alert for summoned status
/atom/movable/screen/alert/status_effect/summoned
	name = "Summoned"
	desc = "You are being compelled to approach. You cannot resist."
	icon_state = "vampire_summon"

