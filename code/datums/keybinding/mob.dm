/datum/keybinding/mob
		category = CATEGORY_HUMAN
		weight = WEIGHT_MOB


/datum/keybinding/mob/face_north
	key = ""
	name = "face_north"
	full_name = "Face North"
	description = ""

/datum/keybinding/mob/face_north/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	M.northface()
	return TRUE


/datum/keybinding/mob/face_east
	key = ""
	name = "face_east"
	full_name = "Face East"
	description = ""

/datum/keybinding/mob/face_east/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	M.eastface()
	return TRUE


/datum/keybinding/mob/face_south
	key = ""
	name = "face_south"
	full_name = "Face South"
	description = ""

/datum/keybinding/mob/face_south/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	M.southface()
	return TRUE

/datum/keybinding/mob/face_west
	key = ""
	name = "face_west"
	full_name = "Face West"
	description = ""

/datum/keybinding/mob/face_west/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	M.westface()
	return TRUE

/datum/keybinding/mob/stop_pulling
	key = "H"
	name = "stop_pulling"
	full_name = "Stop pulling"
	description = ""

/datum/keybinding/mob/stop_pulling/down(client/user)
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

/datum/keybinding/mob/cycle_intent_right/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_RIGHT)
	return TRUE

/datum/keybinding/mob/cycle_intent_left
	key = "Insert"
	name = "cycle_intent_left"
	full_name = "Cycle Intent Left"
	description = ""

/datum/keybinding/mob/cycle_intent_left/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_LEFT)
	return TRUE

/datum/keybinding/mob/swap_hands
	key = "X"
	name = "swap_hands"
	full_name = "Swap hands"
	description = ""

/datum/keybinding/mob/swap_hands/down(client/user)
	if(!user.mob) return
	user.mob.swap_hand()
	return TRUE

/datum/keybinding/mob/activate_inhand
	key = "Z"
	name = "activate_inhand"
	full_name = "Activate in-hand"
	description = "Uses whatever item you have inhand"

/datum/keybinding/mob/activate_inhand/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	M.mode()
	return TRUE


/datum/keybinding/mob/activate_althand
	key = "Shift-Z"
	name = "activate_althand"
	full_name = "Activate alt-hand"
	description = "Uses whatever item you have in althand"

/datum/keybinding/mob/activate_althand/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	M.altmode()
	return TRUE


/datum/keybinding/mob/mainuse
	key = "C"
	name = "mainuse"
	full_name = "Main Use"
	description = "Will use item in your active hand on the item in your inactive hand"

/datum/keybinding/mob/mainuse/down(client/user)
	if (!ishuman(user.mob)) return
	var/mob/M = user.mob
	M.mainuse()
	return TRUE

/datum/keybinding/mob/inactiveuse
	key = "Shift-C"
	name = "inactiveuse"
	full_name = "Inactive Use"
	description = "Will use item in your inactive hand on the item in your active hand"

/datum/keybinding/mob/inactiveuse/down(client/user)
	if (!ishuman(user.mob)) return
	var/mob/M = user.mob
	M.inactiveuse()
	return TRUE






// NEW
/datum/keybinding/mob/quicklefthand
	key = "Ctrl-A"
	name = "quicklefthand"
	full_name = "Quick Left Hand"
	description = "Will use item in your active hand on the item in your inactive hand"

/datum/keybinding/mob/quicklefthand/down(client/user)
	if (!ishuman(user.mob)) return
	var/mob/M = user.mob
	M.lefthand()
	return TRUE

/datum/keybinding/mob/quickrighthand
	key = "Ctrl-D"
	name = "quickrighthand"
	full_name = "Quick Right Hand"
	description = "Will switch to your right hand"

/datum/keybinding/mob/quickrighthand/down(client/user)
	if (!ishuman(user.mob)) return
	var/mob/M = user.mob
	M.righthand()
	return TRUE


/datum/keybinding/mob/drop_item
	key = "Q"
	name = "drop_item"
	full_name = "Drop Item"
	description = ""

/datum/keybinding/mob/drop_item/down(client/user)
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

/datum/keybinding/mob/toggle_move_intent/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/mob/toggle_move_intent/up(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/mob/target_head_cycle
	key = "Numpad8"
	name = "target_head_cycle"
	full_name = "Target: Cycle head"
	description = ""

/datum/keybinding/mob/target_head_cycle/down(client/user)
	if(!user.mob) return
	user.body_toggle_head()
	return TRUE

/datum/keybinding/mob/target_r_arm
	key = "Numpad4"
	name = "target_r_arm"
	full_name = "Target: right arm"
	description = ""

/datum/keybinding/mob/target_r_arm/down(client/user)
	if(!user.mob) return
	user.body_r_arm()
	return TRUE

/datum/keybinding/mob/target_body_chest
	key = "Numpad5"
	name = "target_body_chest"
	full_name = "Target: Body"
	description = ""

/datum/keybinding/mob/target_body_chest/down(client/user)
	if(!user.mob) return
	user.body_chest()
	return TRUE

/datum/keybinding/mob/target_left_arm
	key = "Numpad6"
	name = "target_left_arm"
	full_name = "Target: left arm"
	description = ""

/datum/keybinding/mob/target_left_arm/down(client/user)
	if(!user.mob) return
	user.body_l_arm()
	return TRUE

/datum/keybinding/mob/target_right_leg
	key = "Numpad1"
	name = "target_right_leg"
	full_name = "Target: Right leg"
	description = ""

/datum/keybinding/mob/target_right_leg/down(client/user)
	if(!user.mob) return
	user.body_r_leg()
	return TRUE

/datum/keybinding/mob/target_body_groin
	key = "Numpad2"
	name = "target_body_groin"
	full_name = "Target: Groin"
	description = ""

/datum/keybinding/mob/target_body_groin/down(client/user)
	if(!user.mob) return
	user.body_groin()
	return TRUE

/datum/keybinding/mob/target_left_leg
	key = "Numpad3"
	name = "target_left_leg"
	full_name = "Target: left leg"
	description = ""

/datum/keybinding/mob/target_left_leg/down(client/user)
	if(!user.mob) return
	user.body_l_leg()
	return TRUE
