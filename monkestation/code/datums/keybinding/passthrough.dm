/datum/keybinding/mob/passthrough
		category = CATEGORY_HUMAN
		weight = WEIGHT_MOB


//I will outright admit, this is a hack. But functionality is the most important thing when things break.
//It's actually rather interesting how WASD itself is hacked in.
//The movement press itself sends WASD, but the down/up proc itself sends North, West, East, South instead
//Byond is hardcoded to use those for movement I suppose?
//Any better solution to this would be welcomed, but I'd simply like to see mechas and walking work again.
//Thanks for coming to my TED Talk.

//UP

/datum/keybinding/mob/passthrough/alt_north
	key = "Alt+W"
	name = "move_north_passthrough"
	full_name = "Move North(Alt)"
	description = ""
	keybind_signal = COMSIG_KB_MOB_MOVENORTH_PASSTHROUGH

/datum/keybinding/mob/passthrough/alt_north/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyDown("North")
	return TRUE

/datum/keybinding/mob/passthrough/alt_north/up(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyUp("North")
	return TRUE

//DOWN

/datum/keybinding/mob/passthrough/alt_south
	key = "Alt+S"
	name = "move_south_passthrough"
	full_name = "Move South(Alt)"
	description = ""
	keybind_signal = COMSIG_KB_MOB_MOVESOUTH_PASSTHROUGH

/datum/keybinding/mob/passthrough/alt_south/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyDown("South")
	return TRUE

/datum/keybinding/mob/passthrough/alt_south/up(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyUp("South")
	return TRUE

//RIGHT

/datum/keybinding/mob/passthrough/alt_east
	key = "Alt+D"
	name = "move_east_passthrough"
	full_name = "Move East(Alt)"
	description = ""
	keybind_signal = COMSIG_KB_MOB_MOVEEAST_PASSTHROUGH

/datum/keybinding/mob/passthrough/alt_east/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyDown("East")
	return TRUE

/datum/keybinding/mob/passthrough/alt_east/up(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyUp("East")
	return TRUE

//LEFT

/datum/keybinding/mob/passthrough/alt_west
	key = "Alt+A"
	name = "move_west_passthrough"
	full_name = "Move West(Alt)"
	description = ""
	keybind_signal = COMSIG_KB_MOB_MOVEWEST_PASSTHROUGH

/datum/keybinding/mob/passthrough/alt_west/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyDown("West")
	return TRUE

/datum/keybinding/mob/passthrough/alt_west/up(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	user.keyUp("West")
	return TRUE
