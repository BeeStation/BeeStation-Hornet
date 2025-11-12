/**
 *	MEZMERIZE
 *	 Locks a target in place for a certain amount of time.
 *
 * 	Level 2: Additionally mutes
 * 	Level 3: Can be used through face protection
 * 	Level 5: Doesn't need to be facing you anymore
 */
/datum/action/vampire/targeted/mesmerize
	name = "Mesmerize"
	desc = "Dominate the mind of a mortal who can see your eyes."
	button_icon_state = "power_mez"
	power_explanation = "Click any player to attempt to mesmerize them, and freeze them in place.\n\
		You cannot wear anything covering your face, and both parties must be facing eachother.\n\
		If your target is already mesmerized or a Curator, you will fail.\n\
		Once mesmerized, the target will be unable to move for a certain amount of time, scaling your rank.\n\
		At level 2, your target will additionally be muted.\n\
		At level 3, you will be able to use the power through masks and helmets.\n\
		At level 5, you will be able to mesmerize regardless of your target's direction."
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = VAMPIRE_CAN_BUY | VASSAL_CAN_BUY
	bloodcost = 30
	cooldown_time = 20 SECONDS
	target_range = 8
	power_activates_immediately = FALSE
	prefire_message = "Whom will you subvert to your will?"

	/// Reference to the target we've fed off of
	var/datum/weakref/target_ref

/datum/action/vampire/targeted/mesmerize/can_use()
	. = ..()
	if(!.)
		return FALSE

	// Must have eyes
	if(!owner.get_organ_slot(ORGAN_SLOT_EYES))
		to_chat(owner, span_warning("You have no eyes with which to mesmerize."))
		return FALSE

	// Must have eyes unobstructed
	var/mob/living/carbon/carbon_owner = owner
	if((carbon_owner.is_eyes_covered() && level_current <= 2) || !isturf(carbon_owner.loc))
		owner.balloon_alert(owner, "your eyes are concealed from sight.")
		return FALSE
	return TRUE

/datum/action/vampire/targeted/mesmerize/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Must be a carbon or silicon
	if(!iscarbon(target_atom) && !issilicon(target_atom))
		return FALSE
	var/mob/living/living_target = target_atom

	// No mind
	if(!living_target.mind)
		owner.balloon_alert(owner, "[living_target] is mindless.")
		return FALSE

	// Vampire/Curator check
	if(IS_VAMPIRE(living_target) || IS_CURATOR(living_target))
		owner.balloon_alert(owner, "too powerful.")
		return FALSE

	// Is our target alive or unconcious?
	if(living_target.stat != CONSCIOUS)
		owner.balloon_alert(owner, "[living_target] is not [(living_target.stat == DEAD || HAS_TRAIT(living_target, TRAIT_FAKEDEATH)) ? "alive" : "conscious"].")
		return FALSE

	// Is our target blind?
	if((!living_target.get_organ_slot(ORGAN_SLOT_EYES) || living_target.is_blind()) && !issilicon(living_target))
		owner.balloon_alert(owner, "[living_target] is blind.")
		return FALSE

	// Target facing me? (they face everyone on the floor)
	if(((living_target.mobility_flags & MOBILITY_STAND) && !is_source_facing_target(living_target, owner) && level_current < 5))
		owner.balloon_alert(owner, "[living_target] must be facing you.")
		return FALSE

	// Already mesmerized?
	if(HAS_TRAIT_FROM(living_target, TRAIT_MUTE, TRAIT_MESMERIZED))
		owner.balloon_alert(owner, "[living_target] is already in a hypnotic gaze.")
		return FALSE

/datum/action/vampire/targeted/mesmerize/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/living_target = target_atom
	target_ref = WEAKREF(living_target)

	// Mesmerizing silicons is instant
	if(issilicon(living_target))
		var/mob/living/silicon/silicon_target = living_target
		silicon_target.emp_act(EMP_HEAVY)
		owner.balloon_alert(owner, "temporarily shut [silicon_target] down.")
		power_activated_sucessfully() // PAY COST! BEGIN COOLDOWN!
		return

	owner.balloon_alert(owner, "attempting to hypnotize [living_target]...")
	if(!do_after(owner, 4 SECONDS, living_target, extra_checks = CALLBACK(src, PROC_REF(continue_active)), hidden = TRUE))
		return
	owner.balloon_alert(owner, "successfully mesmerized [living_target].")

	//Actually mesmerize them now
	var/power_time = 9 SECONDS + level_current * 1.5 SECONDS

	if(level_current >= 2)
		ADD_TRAIT(living_target, TRAIT_MUTE, TRAIT_MESMERIZED)

	living_target.Immobilize(power_time)
	living_target.next_move = world.time + power_time // <--- Use direct change instead. We want an unmodified delay to their next move
	living_target.notransform = TRUE // <--- Fuck it. We tried using next_move, but they could STILL resist. We're just doing a hard freeze.
	addtimer(CALLBACK(src, PROC_REF(end_mesmerize), living_target), power_time)

	power_activated_sucessfully() // PAY COST! BEGIN COOLDOWN!

/datum/action/vampire/targeted/mesmerize/continue_active()
	. = ..()
	if(!.)
		return FALSE

	if(!can_use())
		return FALSE

	var/mob/living/living_target = target_ref?.resolve()
	if(!living_target || !check_valid_target(living_target))
		return FALSE

/datum/action/vampire/targeted/mesmerize/deactivate_power()
	. = ..()
	target_ref = null

/datum/action/vampire/targeted/mesmerize/proc/end_mesmerize(mob/living/living_target)
	living_target.notransform = FALSE
	REMOVE_TRAIT(living_target, TRAIT_MUTE, TRAIT_MESMERIZED)

	if (living_target in view(6, get_turf(owner)))
		living_target.balloon_alert(owner, "snapped out of [living_target.p_their()] trance!")
