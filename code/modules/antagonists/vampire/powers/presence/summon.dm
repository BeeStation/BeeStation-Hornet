/**
 *	SUMMON
 *	Target can no longer act and is forced to approach the vampire.
 *	Uses an AI controller to force movement towards the caster.
 */
/datum/action/vampire/targeted/summon
	name = "Summon"
	desc = "Compel a mortal to approach you against their will."
	button_icon_state = "power_command" // Uses command icon as a placeholder
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

	// Must be a carbon
	if(!iscarbon(target_atom))
		return FALSE
	var/mob/living/carbon/carbon_target = target_atom

	// No mind
	if(!carbon_target.mind)
		owner.balloon_alert(owner, "[carbon_target] is mindless.")
		return FALSE

	// Vampire/Vassal/Curator check
	if(IS_VAMPIRE(carbon_target) || IS_VASSAL(carbon_target) || IS_CURATOR(carbon_target))
		owner.balloon_alert(owner, "immune to your presence.")
		return FALSE

	// Silicon check
	if(carbon_target.has_unlimited_silicon_privilege)
		owner.balloon_alert(owner, "[carbon_target] is immune.")
		return FALSE

	// Is our target alive or unconscious?
	if(carbon_target.stat != CONSCIOUS)
		owner.balloon_alert(owner, "[carbon_target] is not [(carbon_target.stat == DEAD || HAS_TRAIT(carbon_target, TRAIT_FAKEDEATH)) ? "alive" : "conscious"].")
		return FALSE

	// Must be able to see
	if(carbon_target.is_blind())
		owner.balloon_alert(owner, "[carbon_target] is blind.")
		return FALSE

	// Already being summoned?
	if(carbon_target.has_status_effect(/datum/status_effect/summoned))
		owner.balloon_alert(owner, "[carbon_target] is already being summoned.")
		return FALSE

	return TRUE

/datum/action/vampire/targeted/summon/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/carbon/carbon_target = target_atom

	// Apply the summon effect
	carbon_target.apply_status_effect(/datum/status_effect/summoned, summon_duration, owner)

	// Feedback
	owner.balloon_alert(owner, "summoning [carbon_target]")
	to_chat(carbon_target, span_awe("An irresistible compulsion draws you towards [owner]..."), type = MESSAGE_TYPE_WARNING)
	to_chat(owner, span_notice("You beckon [carbon_target] towards you."), type = MESSAGE_TYPE_INFO)

	carbon_target.playsound_local(null, 'sound/vampires/mesmerize.ogg', 70, FALSE, pressure_affected = FALSE)

/// Status effect for being summoned towards the vampire
/datum/status_effect/summoned
	id = "summoned"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 30 SECONDS
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/summoned
	/// The vampire who is summoning us
	var/mob/living/source_vampire
	/// The AI controller forcing movement
	var/datum/ai_controller/summoned_human/ai_controller
	/// Flag to allow AI-controlled movement to bypass the block
	var/ai_moving = FALSE

/datum/status_effect/summoned/on_creation(mob/living/new_owner, set_duration, mob/living/vampire)
	if(isnum_safe(set_duration))
		duration = set_duration
	source_vampire = vampire
	return ..()

/datum/status_effect/summoned/Destroy()
	source_vampire = null
	if(ai_controller)
		QDEL_NULL(ai_controller)
	return ..()

/datum/status_effect/summoned/on_apply()
	if(!iscarbon(owner))
		return FALSE
	// Incapacitate them - they can't act while being summoned
	ADD_TRAIT(owner, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_MUTE, TRAIT_STATUS_EFFECT(id))

	// Block player movement input - we control their movement now
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(block_player_move))

	// Pink screen effect
	owner.overlay_fullscreen("summoned", /atom/movable/screen/fullscreen/color_vision/pink, 1)

	// Create the AI controller to handle movement (pass src so it can set ai_moving flag)
	ai_controller = new(owner, source_vampire, src)

	return TRUE

/// Blocks the player from moving themselves while summoned (but allows AI movement)
/datum/status_effect/summoned/proc/block_player_move(mob/source, atom/new_loc)
	SIGNAL_HANDLER
	if(ai_moving)
		return NONE // Allow AI-controlled movement
	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/datum/status_effect/summoned/on_remove()
	REMOVE_TRAIT(owner, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAIT_STATUS_EFFECT(id))

	UnregisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE)

	owner.clear_fullscreen("summoned", 10)

	if(ai_controller)
		QDEL_NULL(ai_controller)

	to_chat(owner, span_awe("The compulsion fades and you regain control of yourself."))

/datum/status_effect/summoned/tick(seconds_between_ticks)
	// Check if vampire is still valid
	if(QDELETED(source_vampire) || source_vampire.stat == DEAD)
		qdel(src)
		return

	// Check if we've reached the vampire (adjacent)
	if(owner.Adjacent(source_vampire))
		to_chat(owner, span_awe("You have arrived before [source_vampire]..."))
		to_chat(source_vampire, span_notice("[owner] has arrived before you."))
		qdel(src)
		return

	// Check line of sight - if broken, end the effect
	if(!(source_vampire in view(10, owner)))
		to_chat(owner, span_awe("You lose sight of your summoner and the compulsion breaks."))
		qdel(src)
		return

/datum/status_effect/summoned/get_examine_text()
	return span_warning("[owner.p_They()] [owner.p_are()] walking with a blank expression, as if compelled.")

/// Alert for summoned status
/atom/movable/screen/alert/status_effect/summoned
	name = "Summoned"
	desc = "You are being compelled to approach someone. You cannot resist."
	icon_state = "mind_control"

/// AI controller for summoned humans. Forces them to walk towards the vampire
/datum/ai_controller/summoned_human
	ai_traits = CAN_ACT_WHILE_DEAD // Well, not really, but we want it to keep trying
	/// The vampire we're walking towards
	var/mob/living/target_vampire
	/// Reference to the status effect so we can set the ai_moving flag
	var/datum/status_effect/summoned/parent_effect
	/// Cooldown between steps - controls the stagger speed
	COOLDOWN_DECLARE(step_cooldown)
	/// How long between each step (slow, staggering movement)
	var/step_delay = 1.5 SECONDS

/datum/ai_controller/summoned_human/New(atom/new_pawn, mob/living/vampire, datum/status_effect/summoned/effect)
	target_vampire = vampire
	parent_effect = effect
	. = ..()

/datum/ai_controller/summoned_human/Destroy()
	target_vampire = null
	parent_effect = null
	return ..()

/datum/ai_controller/summoned_human/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	return ..()

/datum/ai_controller/summoned_human/able_to_run()
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target_vampire))
		return FALSE
	var/mob/living/living_pawn = pawn
	if(living_pawn.stat != CONSCIOUS)
		return FALSE
	return TRUE

/datum/ai_controller/summoned_human/process(delta_time)
	if(!able_to_run())
		return

	// Enforce step delay for slow, staggering movement
	if(!COOLDOWN_FINISHED(src, step_cooldown))
		return
	COOLDOWN_START(src, step_cooldown, step_delay)

	var/mob/living/living_pawn = pawn
	if(QDELETED(target_vampire) || !isturf(living_pawn.loc))
		return

	// Already adjacent, don't move
	if(living_pawn.Adjacent(target_vampire))
		return

	// Face and step towards the vampire
	living_pawn.face_atom(target_vampire)
	var/turf/target_turf = get_step(living_pawn.loc, get_dir(living_pawn.loc, target_vampire.loc))
	if(target_turf && target_turf != target_vampire.loc)
		// Set flag so the status effect knows this is AI movement, not player input
		if(parent_effect)
			parent_effect.ai_moving = TRUE
		living_pawn.Move(target_turf, get_dir(living_pawn.loc, target_turf))
		if(parent_effect)
			parent_effect.ai_moving = FALSE
