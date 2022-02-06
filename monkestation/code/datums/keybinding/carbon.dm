/datum/keybinding/carbon/hold_throw_mode
	key = "Space"
	name = "hold_throw_mode"
	full_name = "Hold throw mode"
	description = "Hold to throw the current item."
	category = CATEGORY_CARBON
	keybind_signal = COMSIG_KB_CARBON_HOLDTHROWMODE_DOWN

/datum/keybinding/carbon/hold_throw_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/C = user.mob
	C.throw_mode_on()
	return TRUE

/datum/keybinding/carbon/hold_throw_mode/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/C = user.mob
	C.throw_mode_off()
	return TRUE
