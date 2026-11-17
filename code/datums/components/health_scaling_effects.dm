/**
 * ### Enrage buffs component
 *
 * Scales some statistics of a living mob (speed or attack power or such) based on how hurt it is.
 */
/datum/component/health_scaling_effects
	/// Health percentage (between 0 and 1) at which you are considered to get the full "max" effect
	var/max_health_threshold
	/// Health percentage (between 0 and 1) at which you are considered to get the full "min" effect
	var/min_health_threshold
	/// Modification to apply to your attack while your health is at or above the max threshold
	var/max_health_attack_modifier
	/// Modification to apply to your attack while your health is at or above the min threshold
	var/min_health_attack_modifier
	/// Modification to movement speed to apply while your health is at or above the max threshold
	var/max_health_slowdown
	/// Modification to movement speed to apply while your health is at or above the min threshold
	var/min_health_slowdown
	/// A callback which is sent the mob's current ratio between the max and min values, for updating mob-specific effects
	var/datum/callback/additional_status_callback

/datum/component/health_scaling_effects/Initialize(
	max_health_threshold = 1,
	min_health_threshold = 0.25,
	max_health_attack_modifier = 0,
	min_health_attack_modifier = 0,
	max_health_slowdown = 0,
	min_health_slowdown = 0,
	additional_status_callback = null,
)
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.max_health_threshold = max_health_threshold
	src.min_health_threshold = min_health_threshold
	src.max_health_attack_modifier = max_health_attack_modifier
	src.min_health_attack_modifier = min_health_attack_modifier
	src.max_health_slowdown = max_health_slowdown
	src.min_health_slowdown = min_health_slowdown
	src.additional_status_callback = additional_status_callback

	RegisterSignal(parent, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_changed))

/datum/component/health_scaling_effects/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_HEALTH_UPDATE)
	return ..()

/datum/component/health_scaling_effects/Destroy(force)
	additional_status_callback = null
	return ..()

/// Called when mob health changes, recalculates the ratio between maximum and minimum
/datum/component/health_scaling_effects/proc/on_health_changed(mob/living/source)
	SIGNAL_HANDLER
	var/current_health_percentage = source.health / source.maxHealth
	var/max_min_ratio = clamp(INVERSE_LERP(min_health_threshold, max_health_threshold, current_health_percentage), 0, 1)

	INVOKE_ASYNC(src, PROC_REF(update_stats), source, max_min_ratio)

/// Update statistics based on provided interpolator between maximum and minimum values
/datum/component/health_scaling_effects/proc/update_stats(mob/living/source, max_min_ratio)
	if (max_health_attack_modifier != 0 || min_health_attack_modifier != 0)
		var/attack_modifier = LERP(min_health_attack_modifier, max_health_attack_modifier, max_min_ratio)
		source.melee_damage = initial(source.melee_damage) + attack_modifier

	if (max_health_slowdown != 0 || min_health_slowdown != 0)
		source.add_or_update_variable_movespeed_modifier(
			/datum/movespeed_modifier/health_scaling_speed_buff,
			multiplicative_slowdown = LERP(min_health_slowdown, max_health_slowdown, max_min_ratio),
		)

	if (additional_status_callback)
		additional_status_callback.Invoke(max_min_ratio)
