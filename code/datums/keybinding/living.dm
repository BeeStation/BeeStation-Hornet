/datum/keybinding/living
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)


/datum/keybinding/living/resist
	keys = list("B")
	name = "resist"
	full_name = "Resist"
	description = "Break free of your current state. Handcuffs, on fire, being trapped in an alien nest? Resist!"
	keybind_signal = COMSIG_KB_LIVING_RESIST_DOWN

/datum/keybinding/living/resist/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.resist()
	return TRUE


/datum/keybinding/living/rest
	keys = list("V")
	name = "rest"
	full_name = "Rest"
	description = "Lay down, or get up."
	keybind_signal = COMSIG_KB_LIVING_REST_DOWN

/datum/keybinding/living/rest/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.lay_down()
	return TRUE

/datum/keybinding/living/look_up
	keys = list("L")
	name = "look up"
	full_name = "Look Up"
	description = "Look up at the next z-level. Only works if below any nearby open space within a 3x3 square."
	keybind_signal = COMSIG_KB_LIVING_LOOKUP_DOWN

/datum/keybinding/living/look_up/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_up(lock = TRUE)
	return TRUE

/datum/keybinding/living/look_up/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_reset()
	return TRUE

/datum/keybinding/living/look_down
	keys = list(";")
	name = "look down"
	full_name = "Look Down"
	description = "Look down at the previous z-level. Only works if above any nearby open space within a 3x3 square."
	keybind_signal = COMSIG_KB_LIVING_LOOKDOWN_DOWN

/datum/keybinding/living/look_down/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_down(lock = TRUE)
	return TRUE

/datum/keybinding/living/look_down/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_reset()
	return TRUE


/datum/keybinding/living/select_intent
	/// The intent this keybinding will switch to.
	var/intent

/datum/keybinding/living/select_intent/can_use(client/user)
	. = ..()
	var/mob/living/user_mob = user.mob
	if(!. || !istype(user_mob))
		return
	return !iscyborg(user_mob) && (intent in user_mob.possible_a_intents) && (locate(/atom/movable/screen/act_intent) in user_mob.hud_used?.static_inventory) // The cyborg check is because cyborgs have their own swap intent hotkey, and we don't want to mess that up.

/datum/keybinding/living/select_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob?.a_intent_change(intent)
	return TRUE


/datum/keybinding/living/select_intent/help
	keys = list("1")
	name = "select_help_intent"
	full_name = "Select help intent"
	description = ""
	keybind_signal = COMSIG_KB_LIVING_SELECTHELPINTENT_DOWN
	intent = INTENT_HELP


/datum/keybinding/living/select_intent/disarm
	keys = list("2")
	name = "select_disarm_intent"
	full_name = "Select disarm intent"
	description = ""
	keybind_signal = COMSIG_KB_LIVING_SELECTDISARMINTENT_DOWN
	intent = INTENT_DISARM


/datum/keybinding/living/select_intent/grab
	keys = list("3")
	name = "select_grab_intent"
	full_name = "Select grab intent"
	description = ""
	keybind_signal = COMSIG_KB_LIVING_SELECTGRABINTENT_DOWN
	intent = INTENT_GRAB


/datum/keybinding/living/select_intent/harm
	keys = list("4")
	name = "select_harm_intent"
	full_name = "Select harm intent"
	description = ""
	keybind_signal = COMSIG_KB_LIVING_SELECTHARMINTENT_DOWN
	intent = INTENT_HARM
