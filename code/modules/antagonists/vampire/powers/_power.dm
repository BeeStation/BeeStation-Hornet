/datum/action/vampire
	name = "Vampiric Gift"
	desc = "A vampiric gift."
	background_icon = 'icons/vampires/actions_vampire.dmi'
	background_icon_state = "vamp_power_off"
	button_icon = 'icons/vampires/actions_vampire.dmi'
	button_icon_state = "power_feed"
	buttontooltipstyle = "cult"
	transparent_when_unavailable = TRUE

	/// Cooldown you'll have to wait between each use, decreases depending on level.
	cooldown_time = 2 SECONDS

	var/background_icon_state_on = "vamp_power_on"
	var/background_icon_state_off = "vamp_power_off"

	/// A sort of tutorial text found in the Antagonist tab.
	var/power_explanation = "Use this power to do... something"
	/// The owner's vampire datum
	var/datum/antagonist/vampire/vampiredatum_power

	/// The effects on this Power (Toggled/Single Use/Static Cooldown)
	var/power_flags = BP_AM_TOGGLE | BP_AM_SINGLEUSE | BP_AM_STATIC_COOLDOWN | BP_AM_COSTLESS_UNCONSCIOUS
	/// Requirement flags for checks
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	/// Who can purchase the Power
	var/purchase_flags = NONE // VAMPIRE_CAN_BUY | VAMPIRE_DEFAULT_POWER | TREMERE_CAN_BUY | VASSAL_CAN_BUY

	/// If the Power is currently active, differs from action cooldown because of how powers are handled.
	var/currently_active = FALSE
	///Can increase to yield new abilities - Each Power ranks up each Rank
	var/level_current = 0
	///The cost to ACTIVATE this Power
	var/bloodcost = 0
	///The cost to MAINTAIN this Power Only used for constant powers
	var/constant_bloodcost = 0
	/// A multiplier for the bloodcost during sol.
	var/sol_multiplier = 1

// Modify description to add cost.
/datum/action/vampire/New(Target)
	. = ..()
	update_desc()

/datum/action/vampire/Destroy()
	vampiredatum_power = null
	. = ..()

/datum/action/vampire/Grant(mob/user)
	. = ..()
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(owner)
	var/datum/antagonist/vassal/favorite/favorite_vassal = IS_FAVORITE_VASSAL(owner)
	if(vampiredatum)
		vampiredatum_power = vampiredatum
		level_current = vampiredatum.vampire_level
	else if(favorite_vassal)
		level_current = favorite_vassal.vassal_level

//This is when we CLICK on the ability Icon, not USING.
/datum/action/vampire/on_activate(mob/user, atom/target)
	if(currently_active)
		deactivate_power()
		return FALSE
	if(!can_pay_cost() || !can_use())
		return FALSE
	pay_cost()
	activate_power()
	if(!(power_flags & BP_AM_TOGGLE) || !currently_active)
		start_cooldown()

	return TRUE

/datum/action/vampire/is_available(feedback = FALSE)
	return next_use_time <= world.time

/datum/action/vampire/proc/update_desc()
	desc = initial(desc)
	if(bloodcost > 0)
		desc += "<br><br><b>COST:</b> [bloodcost] Blood"
	if(constant_bloodcost > 0)
		desc += "<br><br><b>CONSTANT COST:</b><i> [constant_bloodcost] Blood.</i>"
	if(power_flags & BP_AM_SINGLEUSE)
		desc += "<br><br><b>SINGLE USE:</br><i> Can only be used once per night.</i>"

/// Called when the Power is upgraded.
/datum/action/vampire/proc/upgrade_power()
	level_current++
	// Decrease cooldown time
	if((power_flags & !BP_AM_STATIC_COOLDOWN) && (power_flags & !BP_AM_VERY_DYNAMIC_COOLDOWN))
		cooldown_time = max(initial(cooldown_time) / 2, initial(cooldown_time) - (initial(cooldown_time) / 16 * (level_current - 1)))

/datum/action/vampire/proc/can_pay_cost()
	if(QDELETED(owner))
		return FALSE

	// Check if we have enough blood for non-vampires
	if(!vampiredatum_power)
		var/mob/living/living_owner = owner
		if(!HAS_TRAIT(living_owner, TRAIT_NO_BLOOD) && living_owner.blood_volume < bloodcost)
			living_owner.balloon_alert(living_owner, "not enough blood.")
			return FALSE

		return TRUE

	// Have enough blood? Vampires in a Frenzy don't need to pay them
	if(vampiredatum_power.frenzied)
		return TRUE
	if(vampiredatum_power.vampire_blood_volume < bloodcost)
		owner.balloon_alert(owner, "not enough blood.")
		return FALSE

	return TRUE

///Checks if the Power is available to use.
/datum/action/vampire/proc/can_use()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner

	// Torpor?
	if((check_flags & BP_CANT_USE_IN_TORPOR) && HAS_TRAIT(carbon_owner, TRAIT_TORPOR))
		to_chat(carbon_owner, span_warning("Not while you're in Torpor."))
		return FALSE
	// Frenzy?
	if((check_flags & BP_CANT_USE_IN_FRENZY) && vampiredatum_power?.frenzied)
		to_chat(carbon_owner, span_warning("You cannot use powers while in a Frenzy!"))
		return FALSE
	// Stake?
	if((check_flags & BP_CANT_USE_WHILE_STAKED) && vampiredatum_power?.check_if_staked())
		to_chat(carbon_owner, span_warning("You have a stake in your chest! Your powers are useless."))
		return FALSE
	// Conscious? -- We use our own (AB_CHECK_CONSCIOUS) here so we can control it more, like the error message.
	if((check_flags & BP_CANT_USE_WHILE_UNCONSCIOUS) && carbon_owner.stat != CONSCIOUS)
		to_chat(carbon_owner, span_warning("You can't do this while you are unconcious!"))
		return FALSE
	// Incapacitated?
	if((check_flags & BP_CANT_USE_WHILE_INCAPACITATED) && INCAPACITATED_IGNORING(carbon_owner, INCAPABLE_RESTRAINTS|INCAPABLE_GRAB))
		to_chat(carbon_owner, span_warning("Not while you're incapacitated!"))
		return FALSE
	// Constant Cost (out of blood)
	if(constant_bloodcost > 0 && vampiredatum_power?.vampire_blood_volume <= 0)
		to_chat(carbon_owner, span_warning("You don't have the blood to upkeep [src]."))
		return FALSE
	// Sol check
	if((check_flags & BP_CANT_USE_DURING_SOL) && carbon_owner.has_status_effect(/datum/status_effect/vampire_sol))
		to_chat(carbon_owner, span_warning("You can't use [src] during Sol!"))
		return FALSE
	return TRUE

/datum/action/vampire/update_buttons(force = FALSE)
	background_icon_state = currently_active ? background_icon_state_on : background_icon_state_off
	. = ..()

/datum/action/vampire/proc/pay_cost()
	// Vassals get powers too!
	if(!vampiredatum_power)
		var/mob/living/living_owner = owner
		if(!HAS_TRAIT(living_owner, TRAIT_NO_BLOOD))
			living_owner.blood_volume -= bloodcost
		return

	// Vampires in a Frenzy don't have enough Blood to pay it, so just don't.
	if(!vampiredatum_power.frenzied)
		vampiredatum_power.vampire_blood_volume -= bloodcost
		vampiredatum_power.update_hud()

/datum/action/vampire/proc/activate_power()
	currently_active = TRUE
	if(power_flags & BP_AM_TOGGLE)
		RegisterSignal(owner, COMSIG_LIVING_LIFE, PROC_REF(UsePower))

	owner.log_message("used [src][bloodcost != 0 ? " at the cost of [bloodcost]" : ""].", LOG_ATTACK, color="red")
	update_buttons()

/datum/action/vampire/proc/deactivate_power()
	if(!currently_active) //Already inactive? Return
		return

	if(power_flags & BP_AM_TOGGLE)
		UnregisterSignal(owner, COMSIG_LIVING_LIFE)
	if(power_flags & BP_AM_SINGLEUSE)
		remove_after_use()
		return

	currently_active = FALSE
	start_cooldown()
	update_buttons()

/// Used by powers that are continuously active (That have BP_AM_TOGGLE flag)
/datum/action/vampire/proc/UsePower()
	if(!continue_active()) // We can't afford the Power? Deactivate it.
		deactivate_power()
		return FALSE
	// We can keep this up (For now), so Pay Cost!
	if(!(power_flags & BP_AM_COSTLESS_UNCONSCIOUS) && owner.stat != CONSCIOUS)
		if(vampiredatum_power)
			vampiredatum_power.AddBloodVolume(-constant_bloodcost)
		else
			var/mob/living/living_owner = owner
			if(!HAS_TRAIT(living_owner, TRAIT_NO_BLOOD))
				living_owner.blood_volume -= constant_bloodcost

	return TRUE

/// Checks to make sure this power can stay active
/datum/action/vampire/proc/continue_active()
	if(!owner)
		return FALSE
	if(vampiredatum_power && vampiredatum_power.vampire_blood_volume < constant_bloodcost)
		return FALSE

	return TRUE

/// Used to unlearn Single-Use Powers
/datum/action/vampire/proc/remove_after_use()
	vampiredatum_power?.powers -= src
	Remove(owner)
