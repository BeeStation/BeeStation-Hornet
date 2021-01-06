/datum/keybinding/carbon
	category = CATEGORY_CARBON
	weight = WEIGHT_MOB


/datum/keybinding/carbon/toggle_throw_mode
	key = "R"
	name = "toggle_throw_mode"
	full_name = "Toggle throw mode"
	description = "Toggle throwing the current item or not."
	category = CATEGORY_CARBON

/datum/keybinding/carbon/toggle_throw_mode/down(client/user)
	if (!iscarbon(user.mob)) return
	var/mob/living/carbon/C = user.mob
	C.toggle_throw_mode()
	return EF_TRUE


/datum/keybinding/carbon/select_help_intent
	key = "1"
	name = "select_help_intent"
	full_name = "Select help intent"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/select_help_intent/down(client/user)
	if (!iscarbon(user.mob)) return
	var/mob/living/carbon/C = user.mob
	C.a_intent_change(INTENT_HELP)
	return EF_TRUE


/datum/keybinding/carbon/select_disarm_intent
	key = "2"
	name = "select_disarm_intent"
	full_name = "Select disarm intent"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/select_disarm_intent/down(client/user)
	if (!iscarbon(user.mob)) return
	var/mob/living/carbon/C = user.mob
	C.a_intent_change(INTENT_DISARM)
	return EF_TRUE


/datum/keybinding/carbon/select_grab_intent
	key = "3"
	name = "select_grab_intent"
	full_name = "Select grab intent"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/select_grab_intent/down(client/user)
	if (!iscarbon(user.mob)) return
	var/mob/living/carbon/C = user.mob
	C.a_intent_change(INTENT_GRAB)
	return EF_TRUE


/datum/keybinding/carbon/select_harm_intent
	key = "4"
	name = "select_harm_intent"
	full_name = "Select harm intent"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/select_harm_intent/down(client/user)
	if (!iscarbon(user.mob)) return
	var/mob/living/carbon/C = user.mob
	C.a_intent_change(INTENT_HARM)
	return EF_TRUE
