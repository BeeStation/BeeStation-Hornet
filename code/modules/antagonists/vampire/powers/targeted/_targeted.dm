// NOTE: All Targeted spells are Toggles! We just don't bother checking here.
/datum/action/cooldown/vampire/targeted
	power_flags = BP_AM_TOGGLE

	///If set, how far the target has to be for the power to work.
	var/target_range
	///Message sent to chat when clicking on the power, before you use it.
	var/prefire_message
	///Most powers happen the moment you click. Some, like Mesmerize, require time and shouldn't cost you if they fail.
	var/power_activates_immediately = TRUE
	///Is this power LOCKED due to being used?
	var/power_in_use = FALSE

/// Modify description to add notice that this is aimed.
/datum/action/cooldown/vampire/targeted/New(Target)
	desc += "<br>\[<i>Targeted Power</i>\]"
	return ..()

/datum/action/cooldown/vampire/targeted/on_activate(mob/user, atom/target)
	if(currently_active)
		DeactivatePower()
		return FALSE
	if(!can_pay_cost(owner) || !can_use(owner))
		return FALSE

	if(prefire_message)
		to_chat(owner, span_announce(prefire_message))

	ActivatePower()

	return set_click_ability(owner)

/datum/action/cooldown/vampire/targeted/DeactivatePower()
	if(power_flags & BP_AM_TOGGLE)
		UnregisterSignal(owner, COMSIG_LIVING_LIFE)
	currently_active = FALSE
	update_buttons()
	unset_click_ability(owner)

/// Check if target is VALID (wall, turf, or character?)
/datum/action/cooldown/vampire/targeted/proc/CheckValidTarget(atom/target_atom)
	return !(target_atom == owner)

/// Check if valid target meets conditions
/datum/action/cooldown/vampire/targeted/proc/CheckCanTarget(atom/target_atom)
	if(target_range && !(target_atom in view(target_range, owner)))
		if(target_range > 1) // Only warn for range if it's greater than 1. Brawn doesn't need to announce itself.
			owner.balloon_alert(owner, "out of range.")
		return FALSE
	return istype(target_atom)

/datum/action/cooldown/vampire/targeted/InterceptClickOn(mob/living/caller, params, atom/target)
	click_with_power(target)

/// Click Target
/datum/action/cooldown/vampire/targeted/proc/click_with_power(atom/target_atom)
	// CANCEL RANGED TARGET check
	if(power_in_use || !CheckValidTarget(target_atom))
		return FALSE
	// Valid? (return true means DON'T cancel power!)
	if(!can_pay_cost() || !can_use(owner) || !CheckCanTarget(target_atom))
		return TRUE
	power_in_use = TRUE // Lock us into this ability until it successfully fires off. Otherwise, we pay the blood even if we fail.
	FireTargetedPower(target_atom)
	// Skip this part so we can return TRUE right away.
	if(power_activates_immediately)
		power_activated_sucessfully() // Mesmerize pays only after success.
	power_in_use = FALSE
	return TRUE

/datum/action/cooldown/vampire/targeted/proc/FireTargetedPower(atom/target_atom)
	log_combat(owner, target_atom, "used [name] on")

/// The power went off! We now pay the cost of the power.
/datum/action/cooldown/vampire/targeted/proc/power_activated_sucessfully()
	unset_click_ability(owner)
	pay_cost()
	start_cooldown()
	DeactivatePower()
