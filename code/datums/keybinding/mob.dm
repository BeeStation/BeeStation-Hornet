/datum/keybinding/mob
		category = CATEGORY_HUMAN
		weight = WEIGHT_MOB


/datum/keybinding/mob/move_north
	key = "W"
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
	key = "D"
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
	key = "S"
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
	key = "A"
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
	key = "F"
	name = "move up"
	full_name = "Move Up"
	description = "Try moving upwards."
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
			to_chat(user.mob, "<span class='warning'>There is nothing above you!</span>")
			return
		user.mob.Move(new_turf, UP)
	return TRUE

/datum/keybinding/mob/move_down
	key = "C"
	name = "move down"
	full_name = "Move Down"
	description = "Try moving downwards."
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
			to_chat(user.mob, "<span class='warning'>There is nothing below you!</span>")
			return
		user.mob.Move(new_turf, DOWN)
	return TRUE

/datum/keybinding/mob/stop_pulling
	key = "H"
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
		to_chat(user, "<span class='notice'>You are not pulling anything.</span>")
	else
		M.stop_pulling()
	return TRUE

/datum/keybinding/mob/cycle_intent_right
	key = "Home"
	name = "cycle_intent_right"
	full_name = "Cycle Intent Right"
	description = ""
	keybind_signal = COMSIG_KB_MOB_CYCLEINTENTRIGHT_DOWN

/datum/keybinding/mob/cycle_intent_right/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_RIGHT)
	return TRUE

/datum/keybinding/mob/cycle_intent_left
	key = "Insert"
	name = "cycle_intent_left"
	full_name = "Cycle Intent Left"
	description = ""
	keybind_signal = COMSIG_KB_MOB_CYCLEINTENTLEFT_DOWN

/datum/keybinding/mob/cycle_intent_left/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_LEFT)
	return TRUE

/datum/keybinding/mob/swap_hands
	key = "X"
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
	key = "Z"
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
	key = "Q"
	name = "drop_item"
	full_name = "Drop Item"
	description = ""
	keybind_signal = COMSIG_KB_MOB_DROPITEM_DOWN

/datum/keybinding/mob/drop_item/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/item/I = M.get_active_held_item()
	if(!I)
		to_chat(user, "<span class='warning'>You have nothing to drop in your hand!</span>")
	else
		user.mob.dropItemToGround(I)
	return TRUE

/datum/keybinding/mob/toggle_move_intent
	key = "Alt"
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
	key = "Unbound"
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

/datum/keybinding/mob/target_head_cycle
	key = "Numpad8"
	name = "target_head_cycle"
	full_name = "Target: Cycle head"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLEHEAD_DOWN

/datum/keybinding/mob/target_head_cycle/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_toggle_head()
	return TRUE

/datum/keybinding/mob/target_r_arm
	key = "Numpad4"
	name = "target_r_arm"
	full_name = "Target: right arm"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTARM_DOWN

/datum/keybinding/mob/target_r_arm/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_r_arm()
	return TRUE

/datum/keybinding/mob/target_body_chest
	key = "Numpad5"
	name = "target_body_chest"
	full_name = "Target: Body"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETBODYCHEST_DOWN

/datum/keybinding/mob/target_body_chest/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_chest()
	return TRUE

/datum/keybinding/mob/target_left_arm
	key = "Numpad6"
	name = "target_left_arm"
	full_name = "Target: left arm"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTARM_DOWN

/datum/keybinding/mob/target_left_arm/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_l_arm()
	return TRUE

/datum/keybinding/mob/target_right_leg
	key = "Numpad1"
	name = "target_right_leg"
	full_name = "Target: Right leg"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTLEG_DOWN

/datum/keybinding/mob/target_right_leg/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_r_leg()
	return TRUE

/datum/keybinding/mob/target_body_groin
	key = "Numpad2"
	name = "target_body_groin"
	full_name = "Target: Groin"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETBODYGROIN_DOWN

/datum/keybinding/mob/target_body_groin/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_groin()
	return TRUE

/datum/keybinding/mob/target_left_leg
	key = "Numpad3"
	name = "target_left_leg"
	full_name = "Target: left leg"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTLEG_DOWN

/datum/keybinding/mob/target_left_leg/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.body_l_leg()
	return TRUE

/datum/keybinding/mob/prevent_movement
	key = "Ctrl"
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

