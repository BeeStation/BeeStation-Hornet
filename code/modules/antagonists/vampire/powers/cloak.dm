/datum/action/cooldown/vampire/cloak
	name = "Cloak of Darkness"
	desc = "Blend into the shadows and become invisible to the untrained and Artificial eye."
	button_icon_state = "power_cloak"
	power_explanation = list(
		"Activate this Power in the shadows and you will turn nearly invisible, scaling with your rank.",
		"Additionally, while Cloak is active, you are completely invisible to the AI.")
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = VAMPIRE_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 5
	constant_bloodcost = 0.2
	cooldown_time = 5 SECONDS

/// Must have nobody around to see the cloak
/datum/action/cooldown/vampire/cloak/can_use(mob/living/carbon/user, trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	for(var/mob/living/watchers in view(9, owner) - owner)
		owner.balloon_alert(owner, "you can only vanish unseen.")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/cloak/ActivatePower(trigger_flags)
	. = ..()
	var/mob/living/user = owner
	owner.add_movespeed_modifier(/datum/movespeed_modifier/obesity)
	user.AddElement(/datum/element/digital_camo)
	user.balloon_alert(user, "cloak turned on.")

/datum/action/cooldown/vampire/cloak/UsePower(seconds_per_tick)
	. = ..()
	if(!.)
		return

	animate(owner, alpha = max(25, owner.alpha - min(75, 10 + 5 * level_current)), time = 1.5 SECONDS)

/datum/action/cooldown/vampire/cloak/ContinueActive(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user.stat != CONSCIOUS)
		to_chat(owner, span_warning("Your cloak failed because you fell unconcious!"))
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/cloak/DeactivatePower()
	var/mob/living/user = owner

	animate(user, alpha = 255, time = 1 SECONDS)
	user.RemoveElement(/datum/element/digital_camo)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/obesity)
	user.balloon_alert(user, "cloak turned off.")
	return ..()
