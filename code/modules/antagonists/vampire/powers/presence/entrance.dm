/**
 *	ENTRANCE
 *	A stunning spell that slows, mutes, and impairs the target for a short duration.
 *	Like a softer mesmerize - target isn't fully out of commission but is very impaired.
 */
/datum/action/vampire/targeted/entrance
	name = "Entrance"
	desc = "Capture a mortal's attention momentarily, leaving them slowed, muted, and dazed."
	button_icon_state = "power_mez" // Uses mesmerize icon as a placeholder
	power_explanation = "Click any player to entrance them, leaving them momentarily impaired.\n\
		Your target will be slowed, muted, and unable to use items for a short duration.\n\
		This is a softer form of control - they can still move and resist, but are heavily hindered."
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 80
	cooldown_time = 60 SECONDS
	target_range = 7
	prefire_message = "Whose attention will you capture?"

	/// Duration of the entrance effect
	var/entrance_duration = 30 SECONDS

/datum/action/vampire/targeted/entrance/check_valid_target(atom/target_atom)
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

	// Is our target alive or unconscious?
	if(carbon_target.stat != CONSCIOUS)
		owner.balloon_alert(owner, "[carbon_target] is not [(carbon_target.stat == DEAD || HAS_TRAIT(carbon_target, TRAIT_FAKEDEATH)) ? "alive" : "conscious"].")
		return FALSE

	// Already entranced?
	if(carbon_target.has_status_effect(/datum/status_effect/entranced))
		owner.balloon_alert(owner, "[carbon_target] is already entranced.")
		return FALSE

	return TRUE

/datum/action/vampire/targeted/entrance/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/carbon/carbon_target = target_atom

	// Apply the entrance effect
	carbon_target.apply_status_effect(/datum/status_effect/entranced, entrance_duration, owner)

	// Feedback
	owner.balloon_alert(owner, "entranced [carbon_target]")
	to_chat(carbon_target, span_awe("Your mind goes blank..."), type = MESSAGE_TYPE_WARNING)
	to_chat(owner, span_notice("You capture [carbon_target]'s attention, leaving them dazed."), type = MESSAGE_TYPE_INFO)

	carbon_target.playsound_local(null, 'sound/vampires/mesmerize.ogg', 50, FALSE, pressure_affected = FALSE)

/// Status effect for being entranced
/datum/status_effect/entranced
	id = "entranced"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 30 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/entranced
	/// The vampire who entranced us
	var/mob/living/source_vampire

/datum/status_effect/entranced/on_creation(mob/living/new_owner, set_duration, mob/living/vampire)
	if(isnum_safe(set_duration))
		duration = set_duration
	source_vampire = vampire
	return ..()

/datum/status_effect/entranced/Destroy()
	source_vampire = null
	return ..()

/datum/status_effect/entranced/on_apply()
	if(!iscarbon(owner))
		return FALSE
	// Mute them
	ADD_TRAIT(owner, TRAIT_MUTE, TRAIT_STATUS_EFFECT(id))
	// Block item usage
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(id))
	// Slow them significantly
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/entranced)
	// Jitter effect
	owner.set_jitter_if_lower(duration)
	// Pink screen effect
	owner.overlay_fullscreen("entranced", /atom/movable/screen/fullscreen/color_vision/pink, 1)
	return TRUE

/datum/status_effect/entranced/on_remove()
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(id))
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/entranced)
	owner.clear_fullscreen("entranced", 10)
	to_chat(owner, span_awe("Your mind clears and you regain your focus."))

/datum/status_effect/entranced/get_examine_text()
	return span_warning("[owner.p_They()] seem[owner.p_s()] dazed and unfocused.")

/// Alert for entranced status
/atom/movable/screen/alert/status_effect/entranced
	name = "Entranced"
	desc = "Your mind has been captured by a supernatural presence. You cannot speak or use items."
	icon_state = "hypnosis"

/// Movespeed modifier for the entranced status effect
/datum/movespeed_modifier/status_effect/entranced
	multiplicative_slowdown = 1.5

/// Pink screen overlay for presence powers
/atom/movable/screen/fullscreen/color_vision/pink
	color = "#ff69b4"
	alpha = 50
