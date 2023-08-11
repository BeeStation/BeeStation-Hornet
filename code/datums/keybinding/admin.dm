/datum/keybinding/admin
	category = CATEGORY_ADMIN
	weight = WEIGHT_ADMIN

/datum/keybinding/admin/can_use(client/user)
	return user.holder ? TRUE : FALSE

/datum/keybinding/admin/admin_say
	keys = list("F3")
	name = "admin_say"
	full_name = "Admin say"
	description = "Talk with other admins."
	keybind_signal = COMSIG_KB_ADMIN_ASAY_DOWN

/datum/keybinding/admin/admin_say/down(client/user)
	. = ..()
	if(.)
		return
	user.get_admin_say()
	return TRUE


/datum/keybinding/admin/mentor_say
	keys = list("F4")
	name = "mentor_say"
	full_name = "Mentor say"
	description = "Speak with other mentors."
	keybind_signal = COMSIG_KB_ADMIN_MSAY_DOWN

/datum/keybinding/admin/mentor_say/down(client/user)
	. = ..()
	if(.)
		return
	user.get_mentor_say()
	return TRUE

//Snowflakey fix for mentors not being able to use the hotkey, without moving the hotkey to a new category
/datum/keybinding/admin/mentor_say/can_use(client/user)
	return user.mentor_datum ? TRUE : FALSE


/datum/keybinding/admin/admin_ghost
	keys = list("F5")
	name = "admin_ghost"
	full_name = "Admin Ghost"
	description = "Toggle your admin ghost status."
	keybind_signal = COMSIG_KB_ADMIN_AGHOST_DOWN

/datum/keybinding/admin/admin_ghost/down(client/user)
	. = ..()
	if(.)
		return
	user.admin_ghost()
	return TRUE


/datum/keybinding/admin/player_panel
	keys = list("F6")
	name = "player_panel"
	full_name = "Player Panel"
	description = "View the player panel list."
	keybind_signal = COMSIG_KB_ADMIN_PLAYERPANEL_DOWN

/datum/keybinding/admin/player_panel/down(client/user)
	. = ..()
	if(.)
		return
	user.holder.open_player_panel()
	return TRUE


/datum/keybinding/admin/build_mode
	keys = list("F7")
	name = "toggle_build_mode"
	full_name = "Toggle Build Mode"
	description = "Toggle admin build mode on or off."
	keybind_signal = COMSIG_KB_ADMIN_TOGGLEBUILDMODE_DOWN

/datum/keybinding/admin/build_mode/down(client/user)
	. = ..()
	if(.)
		return
	user.togglebuildmodeself()
	return TRUE


/datum/keybinding/admin/invismin
	keys = list("F8")
	name = "invismin"
	full_name = "Toggle Invismin"
	description = "Toggle your admin invisibility."
	keybind_signal = COMSIG_KB_ADMIN_INVISIMINTOGGLE_DOWN

/datum/keybinding/admin/invismin/down(client/user)
	. = ..()
	if(.)
		return
	user.invisimin()
	return TRUE


/datum/keybinding/admin/dead_say
	keys = list("F10")
	name = "dead_say"
	full_name = "Dead Say"
	description = "Speak in deadchat as an admin."
	keybind_signal = COMSIG_KB_ADMIN_DSAY_DOWN

/datum/keybinding/admin/dead_say/down(client/user)
	. = ..()
	if(.)
		return
	user.get_dead_say()
	return TRUE
