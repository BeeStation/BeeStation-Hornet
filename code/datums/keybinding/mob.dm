/datum/keybinding/mob
		category = CATEGORY_HUMAN
		weight = WEIGHT_MOB


/datum/keybinding/mob/move_north
	keys = list("W")
	name = "move_north"
	full_name = "Move North"
	description = ""
	keybind_signal = COMSIG_KB_MOB_MOVENORTH_DOWN
	any_modifier = TRUE

/datum/keybinding/mob/move_north/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyDown("North")
	return TRUE

/datum/keybinding/mob/move_north/up(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyUp("North")
	return TRUE


/datum/keybinding/mob/move_east
	keys = list("D")
	name = "move_east"
	full_name = "Move East"
	description = ""
	keybind_signal = COMSIG_KB_MOB_MOVEEAST_DOWN
	any_modifier = TRUE

/datum/keybinding/mob/move_east/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyDown("East")
	return TRUE

/datum/keybinding/mob/move_east/up(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyUp("East")
	return TRUE


/datum/keybinding/mob/move_south
	keys = list("S")
	name = "move_south"
	full_name = "Move South"
	description = ""
	keybind_signal = COMSIG_KB_MOB_MOVESOUTH_DOWN
	any_modifier = TRUE

/datum/keybinding/mob/move_south/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyDown("South")
	return TRUE

/datum/keybinding/mob/move_south/up(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyUp("South")
	return TRUE


/datum/keybinding/mob/move_west
	keys = list("A")
	name = "move_west"
	full_name = "Move West"
	description = ""
	keybind_signal = COMSIG_KB_MOB_MOVEWEST_DOWN
	any_modifier = TRUE

/datum/keybinding/mob/move_west/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyDown("West")
	return TRUE

/datum/keybinding/mob/move_west/up(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyUp("West")
	return TRUE

/datum/keybinding/mob/move_up
	keys = list()
	name = "move up"
	full_name = "Move Up"
	description = "Attempts to move upwards."
	keybind_signal = COMSIG_KB_MOB_MOVEUP_DOWN

/datum/keybinding/mob/move_up/down(client/user)
	. = ..()
	if(.)
		return
	if(isliving(user.mob))
		var/mob/living/L = user.mob
		L.zMove(UP, TRUE)
	else if(isobserver(user.mob))
		var/turf/original = get_turf(user.mob)
		if(!istype(original))
			return
		var/turf/new_turf = get_step_multiz(original, UP)
		if(!istype(new_turf))
			to_chat(user.mob, span_warning("There is nothing above you!"))
			return
		user.mob.Move(new_turf, UP)
	return TRUE

/datum/keybinding/mob/move_down
	keys = list()
	name = "move down"
	full_name = "Move Down"
	description = "Attempts to move downards."
	keybind_signal = COMSIG_KB_MOB_MOVEDOWN_DOWN

/datum/keybinding/mob/move_down/down(client/user)
	. = ..()
	if(.)
		return
	if(isliving(user.mob))
		var/mob/living/L = user.mob
		L.zMove(DOWN, TRUE)
	else if(isobserver(user.mob))
		var/turf/original = get_turf(user.mob)
		if(!istype(original))
			return
		var/turf/new_turf = get_step_multiz(original, DOWN)
		if(!istype(new_turf))
			to_chat(user.mob, span_warning("There is nothing below you!"))
			return
		user.mob.Move(new_turf, DOWN)
	return TRUE

/datum/keybinding/mob/move_look_up
	keys = list("CtrlF", "Northeast") // Northeast: Page-up
	name = "move or look up"
	full_name = "Move/Look Up"
	description = "Move upwards if you are capable, otherwise looks up instead."
	keybind_signal = COMSIG_KB_MOB_MOVEUP_DOWN

/datum/keybinding/mob/move_look_up/down(client/user)
	. = ..()
	if(.)
		return
	if(isliving(user.mob))
		var/mob/living/L = user.mob
		if (!L.zMove(UP, FALSE))
			L.look_up()
	else if(isobserver(user.mob))
		var/turf/original = get_turf(user.mob)
		if(!istype(original))
			return
		var/turf/new_turf = get_step_multiz(original, UP)
		if(!istype(new_turf))
			to_chat(user.mob, span_warning("There is nothing above you!"))
			return
		user.mob.Move(new_turf, UP)
	return TRUE

/datum/keybinding/mob/move_look_down
	keys = list("CtrlC", "Southeast") // Southeast: Page-down
	name = "move or look down"
	full_name = "Move/Look Down"
	description = "Move downwards if you are capable, otherwise looks down instead."
	keybind_signal = COMSIG_KB_MOB_MOVEDOWN_DOWN

/datum/keybinding/mob/move_look_down/down(client/user)
	. = ..()
	if(.)
		return
	if(isliving(user.mob))
		var/mob/living/L = user.mob
		if (!L.zMove(DOWN, FALSE))
			L.look_down()
	else if(isobserver(user.mob))
		var/turf/original = get_turf(user.mob)
		if(!istype(original))
			return
		var/turf/new_turf = get_step_multiz(original, DOWN)
		if(!istype(new_turf))
			to_chat(user.mob, span_warning("There is nothing below you!"))
			return
		user.mob.Move(new_turf, DOWN)
	return TRUE

/datum/keybinding/mob/stop_pulling
	keys = list("H")
	name = "stop_pulling"
	full_name = "Stop pulling"
	description = ""
	keybind_signal = COMSIG_KB_MOB_STOPPULLING_DOWN

/datum/keybinding/mob/stop_pulling/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	if (!M.pulling)
		to_chat(user, span_notice("You are not pulling anything."))
	else
		M.stop_pulling()
	return TRUE

/datum/keybinding/mob/swap_hands
	keys = list("X")
	name = "swap_hands"
	full_name = "Swap hands"
	description = ""
	keybind_signal = COMSIG_KB_MOB_SWAPHANDS_DOWN

/datum/keybinding/mob/swap_hands/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.mob.swap_hand()
	return TRUE

/datum/keybinding/mob/activate_inhand
	keys = list("Z")
	name = "activate_inhand"
	full_name = "Activate in-hand"
	description = "Uses whatever item you have inhand"
	keybind_signal = COMSIG_KB_MOB_ACTIVATEINHAND_DOWN

/datum/keybinding/mob/activate_inhand/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	M.mode()
	return TRUE

/datum/keybinding/mob/drop_item
	keys = list("Q")
	name = "drop_item"
	full_name = "Drop Item"
	description = ""
	keybind_signal = COMSIG_KB_MOB_DROPITEM_DOWN

/datum/keybinding/mob/drop_item/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob)
		return
	var/mob/M = user.mob
	var/obj/item/I = M.get_active_held_item()
	if(!I)
		to_chat(user, span_warning("You have nothing to drop in your hand!"))
	else
		user.mob.dropItemToGround(I)
	return TRUE

/datum/keybinding/mob/toggle_move_intent
	keys = list("Alt")
	name = "toggle_move_intent"
	full_name = "Hold to toggle move intent"
	description = "Held down to cycle to the other move intent, release to cycle back"
	keybind_signal = COMSIG_KB_MOB_TOGGLEMOVEINTENT_DOWN

/datum/keybinding/mob/toggle_move_intent/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/mob/toggle_move_intent/up(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/mob/toggle_move_intent_alternative
	keys = list("Unbound")
	name = "toggle_move_intent_alt"
	full_name = "press to cycle move intent"
	description = "Pressing this cycle to the opposite move intent, does not cycle back"
	keybind_signal = COMSIG_KB_MOB_TOGGLEMOVEINTENTALT_DOWN

/datum/keybinding/mob/toggle_move_intent_alternative/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/mob/prevent_movement
	keys = list("Ctrl")
	name = "block_movement"
	full_name = "Hold to change facing"
	description = "While pressed, prevents movement when pressing directional keys; instead just changes your facing direction"
	keybind_signal = COMSIG_KB_MOB_PREVENTMOVEMENT_DOWN

/datum/keybinding/mob/prevent_movement/down(client/user)
	. = ..()
	if(.)
		return
	user.movement_locked = TRUE

/datum/keybinding/mob/prevent_movement/up(client/user)
	. = ..()
	if(.)
		return
	user.movement_locked = FALSE

/datum/keybinding/mob/show_extended_screentips
	keys = list("Shift")
	name = "show_extended_screentips"
	full_name = "Show Extended Screentips"
	description = "While held, screentip information about construction and deconstruction will be shown on the screen."
	keybind_signal = COMSIG_KB_MOB_EXTENDEDSCREENTIPS_DOWN

/datum/keybinding/mob/show_extended_screentips/down(client/user)
	. = ..()
	if (.)
		return
	user.show_extended_screentips = TRUE
	user.mob.refresh_self_screentips()

/datum/keybinding/mob/show_extended_screentips/up(client/user)
	. = ..()
	if (.)
		return
	user.show_extended_screentips = FALSE
	user.mob.refresh_self_screentips()

/**
 * ===========================
 * Bodyzone targeting section
 * ===========================
 *
 * Precise hotkeys
 *
 */

/datum/keybinding/mob/target_head_cycle
	keys = list("Numpad8")
	name = "target_head_cycle"
	full_name = "Target: Cycle head"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLEHEAD_DOWN
	required_pref_type = /datum/preference/choiced/zone_select
	required_pref_value = PREFERENCE_BODYZONE_INTENT

/datum/keybinding/mob/target_head_cycle/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_toggle_head()
	return TRUE

/datum/keybinding/mob/target_r_arm
	keys = list("Numpad4")
	name = "target_r_arm"
	full_name = "Target: right arm"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTARM_DOWN
	required_pref_type = /datum/preference/choiced/zone_select
	required_pref_value = PREFERENCE_BODYZONE_INTENT

/datum/keybinding/mob/target_r_arm/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_r_arm()
	return TRUE

/datum/keybinding/mob/target_body_chest
	keys = list("Numpad5")
	name = "target_body_chest"
	full_name = "Target: Body"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETBODYCHEST_DOWN
	required_pref_type = /datum/preference/choiced/zone_select
	required_pref_value = PREFERENCE_BODYZONE_INTENT

/datum/keybinding/mob/target_body_chest/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_chest()
	return TRUE

/datum/keybinding/mob/target_left_arm
	keys = list("Numpad6")
	name = "target_left_arm"
	full_name = "Target: left arm"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTARM_DOWN
	required_pref_type = /datum/preference/choiced/zone_select
	required_pref_value = PREFERENCE_BODYZONE_INTENT

/datum/keybinding/mob/target_left_arm/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_l_arm()
	return TRUE

/datum/keybinding/mob/target_right_leg
	keys = list("Numpad1")
	name = "target_right_leg"
	full_name = "Target: Right leg"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTLEG_DOWN
	required_pref_type = /datum/preference/choiced/zone_select
	required_pref_value = PREFERENCE_BODYZONE_INTENT

/datum/keybinding/mob/target_right_leg/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_r_leg()
	return TRUE

/datum/keybinding/mob/target_body_groin
	keys = list("Numpad2")
	name = "target_body_groin"
	full_name = "Target: Groin"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETBODYGROIN_DOWN
	required_pref_type = /datum/preference/choiced/zone_select
	required_pref_value = PREFERENCE_BODYZONE_INTENT

/datum/keybinding/mob/target_body_groin/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_groin()
	return TRUE

/datum/keybinding/mob/target_left_leg
	keys = list("Numpad3")
	name = "target_left_leg"
	full_name = "Target: left leg"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTLEG_DOWN
	required_pref_type = /datum/preference/choiced/zone_select
	required_pref_value = PREFERENCE_BODYZONE_INTENT

/datum/keybinding/mob/target_left_leg/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_l_leg()
	return TRUE

/**
 * ===========================
 * Bodyzone targeting section
 * ===========================
 *
 * Simplified hotkeys
 *
 */

/datum/keybinding/mob/target_higher_zone
	keys = list("ScrollUp")
	name = "target_higher_zone"
	full_name = "Target: Cycle zone up"
	description = "Cycles the targeted bodyzone upwards. Leg targeting will become arm targeting, and arm targeting will become body/head targeting."
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLEUP_DOWN
	required_pref_type = /datum/preference/choiced/zone_select
	required_pref_value = PREFERENCE_BODYZONE_SIMPLIFIED

/datum/keybinding/mob/target_higher_zone/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob)
		return
	user.body_up()
	return TRUE


/datum/keybinding/mob/target_lower_zone
	keys = list("ScrollDown")
	name = "target_lower_zone"
	full_name = "Target: Cycle zone down"
	description = "Cycles the targeted bodyzone downwards. Head/body targeting will become arm targeting and arm targeting will become leg targeting.."
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLEDOWN_DOWN
	required_pref_type = /datum/preference/choiced/zone_select
	required_pref_value = PREFERENCE_BODYZONE_SIMPLIFIED

/datum/keybinding/mob/target_lower_zone/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob)
		return
	user.body_down()
	return TRUE

