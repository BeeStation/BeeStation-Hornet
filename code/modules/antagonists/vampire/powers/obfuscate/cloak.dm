/datum/action/vampire/cloak
	name = "Cloak of Darkness"
	desc = "Blend into the shadows and become invisible to the artificial eye."
	button_icon_state = "power_cloak"
	power_explanation = "Activate this Power while unseen and you will turn nearly invisible, scaling with your rank.\n\
		Additionally, while Cloak is active, you are completely invisible to silicons."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 50
	constant_vitaecost = 1
	sol_multiplier = 2.5
	cooldown_time = 5 SECONDS
	var/cloaklevel = 20

/datum/action/vampire/cloak/two
	vitaecost = 40
	constant_vitaecost = 2
	cloaklevel = 15

/datum/action/vampire/cloak/three
	vitaecost = 30
	constant_vitaecost = 3
	cloaklevel = 10

/datum/action/vampire/cloak/four
	vitaecost = 20
	constant_vitaecost = 4
	cloaklevel = 5

/// Must have nobody around to see the cloak
/datum/action/vampire/cloak/can_use()
	. = ..()
	if(!.)
		return FALSE

	return TRUE

/datum/action/vampire/cloak/activate_power()
	. = ..()
	check_witnesses()
	var/mob/living/user = owner
	owner.add_movespeed_modifier(/datum/movespeed_modifier/cloak)
	user.AddElement(/datum/element/digital_camo)
	user.balloon_alert(user, "cloak turned on.")
	animate(owner, alpha = cloaklevel, time = 1 SECONDS)

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
