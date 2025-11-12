// NOTE: All Targeted spells are Toggles! We just don't bother checking here.
/datum/action/vampire/targeted
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
/datum/action/vampire/targeted/update_desc()
	. = ..()
	desc += "<br><br><i>Targeted Power</i>"

/datum/action/vampire/targeted/on_activate(mob/user, atom/target)
	if(currently_active)
		deactivate_power()
		return FALSE
	if(owner.click_intercept)
		owner.balloon_alert(owner, "already using a targeted power!")
		return FALSE
	if(!can_pay_cost(owner) || !can_use())
		return FALSE

	if(prefire_message)
		to_chat(owner, span_announce(prefire_message))

	activate_power()

	if(currently_active)
		set_click_ability(owner)

/datum/action/vampire/targeted/activate_power()
	currently_active = TRUE

	owner.log_message("used [src][bloodcost != 0 ? " at the cost of [bloodcost]" : ""].", LOG_ATTACK, color="red")
	update_buttons()

/datum/action/vampire/targeted/deactivate_power()
	if(power_flags & BP_AM_TOGGLE)
		UnregisterSignal(owner, COMSIG_LIVING_LIFE)

	currently_active = FALSE
	update_buttons()
	unset_click_ability(owner)

/// Check if target is VALID (wall, turf, or character?)
/datum/action/vampire/targeted/proc/check_valid_target(atom/target_atom)
	// No targeting yourself
	if(target_atom == owner)
		return FALSE
	// Check if in range
	if(target_range && !(target_atom in view(target_range, owner)))
		if(target_range > 1)
			owner.balloon_alert(owner, "out of range.")
		return FALSE

	return TRUE

/datum/action/vampire/targeted/InterceptClickOn(mob/living/clicker, params, atom/target)
	INVOKE_ASYNC(src, PROC_REF(click_with_power), target)

/// Click Target
/datum/action/vampire/targeted/proc/click_with_power(atom/target_atom)
	// Already using?
	if(power_in_use)
		return
	// Can use?
	if(!can_use())
		return
	// Valid target?
	if(!check_valid_target(target_atom))
		return
	// Enough blood?
	if(!can_pay_cost())
		return

	power_in_use = TRUE
	FireTargetedPower(target_atom)
	if(power_flags & BP_AM_TOGGLE)
		RegisterSignal(owner, COMSIG_LIVING_LIFE, PROC_REF(UsePower))
	// Skip this part so we can return TRUE right away.
	if(power_activates_immediately)
		power_activated_sucessfully() // Mesmerize pays only after success.
	power_in_use = FALSE

/datum/action/vampire/targeted/proc/FireTargetedPower(atom/target_atom)
	unset_click_ability(owner)
	log_combat(owner, target_atom, "used [name] on")

/// The power went off! We now pay the cost of the power.
/datum/action/vampire/targeted/proc/power_activated_sucessfully()
	pay_cost()
	start_cooldown()
	deactivate_power()
