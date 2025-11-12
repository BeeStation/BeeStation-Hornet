/datum/action/vampire/cloak
	name = "Cloak of Darkness"
	desc = "Blend into the shadows and become invisible to the artificial eye."
	button_icon_state = "power_cloak"
	power_explanation = "Activate this Power while unseen and you will turn nearly invisible, scaling with your rank.\n\
		Additionally, while Cloak is active, you are completely invisible to silicons."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_UNCONSCIOUS
	bloodcost = 30
	constant_bloodcost = 0.1
	sol_multiplier = 2.5
	cooldown_time = 5 SECONDS
	level_current = 1

/datum/action/vampire/cloak/two
	bloodcost = 45
	constant_bloodcost = 0.2
	level_current = 2

/datum/action/vampire/cloak/three
	bloodcost = 60
	constant_bloodcost = 0.3
	level_current = 3

/datum/action/vampire/cloak/four
	bloodcost = 75
	constant_bloodcost = 0.4
	level_current = 4

/datum/action/vampire/cloak/five	// We have no nosferatu but if we had...
	bloodcost = 90
	constant_bloodcost = 0.5
	level_current = 5

/// Must have nobody around to see the cloak
/datum/action/vampire/cloak/can_use()
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/watcher in view(9, owner) - owner)
		if(watcher.stat == DEAD || QDELETED(watcher.client) || watcher.client?.is_afk())
			continue
		if(IS_VAMPIRE(watcher) || IS_VASSAL(watcher))
			continue
		if(watcher.is_blind())
			continue
		owner.balloon_alert(owner, "you can only vanish unseen.")
		return FALSE
	return TRUE

/datum/action/vampire/cloak/activate_power()
	. = ..()
	var/mob/living/user = owner
	owner.add_movespeed_modifier(/datum/movespeed_modifier/cloak)
	user.AddElement(/datum/element/digital_camo)
	user.balloon_alert(user, "cloak turned on.")
	animate(owner, alpha = max(0, 255 - min(255, 60 * level_current)), time = 1 SECONDS)

/datum/action/vampire/cloak/continue_active()
	. = ..()
	if(!.)
		return FALSE

	if(owner.stat != CONSCIOUS)
		to_chat(owner, span_warning("Your cloak failed because you fell unconcious!"))
		return FALSE
	return TRUE

/datum/action/vampire/cloak/deactivate_power()
	var/mob/living/user = owner

	animate(user, alpha = 255, time = 1 SECONDS)
	user.RemoveElement(/datum/element/digital_camo)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/cloak)
	user.balloon_alert(user, "cloak turned off.")
	return ..()

/datum/movespeed_modifier/cloak
	multiplicative_slowdown = 1.5
