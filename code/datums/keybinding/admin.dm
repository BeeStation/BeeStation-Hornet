/datum/keybinding/admin
	category = CATEGORY_ADMIN
	weight = WEIGHT_ADMIN


/datum/keybinding/admin/admin_say
	key = "F3"
	name = "admin_say"
	full_name = "Admin say"
	description = "Talk with other admins."

/datum/keybinding/admin/admin_say/down(client/user)
	if (!user.holder) return
	user.get_admin_say()
	return TRUE


/datum/keybinding/admin/mentor_say
	key = "F4"
	name = "mentor_say"
	full_name = "Mentor say"
	description = "Speak with other mentors."

/datum/keybinding/admin/mentor_say/down(client/user)
	if (!user.holder) return
	user.get_mentor_say()
	return TRUE


/datum/keybinding/admin/admin_ghost
	key = "F5"
	name = "admin_ghost"
	full_name = "Admin Ghost"
	description = "Toggle your admin ghost status."

/datum/keybinding/admin/admin_ghost/down(client/user)
	if (!user.holder) return
	user.admin_ghost()
	return TRUE


/datum/keybinding/admin/player_panel
	key = "F6"
	name = "player_panel"
	full_name = "Player Panel"
	description = "View the player panel list."

/datum/keybinding/admin/player_panel/down(client/user)
	if (!user.holder) return
	user.holder.player_panel_new()
	return TRUE


/datum/keybinding/admin/build_mode
	key = "F7"
	name = "toggle_build_mode"
	full_name = "Toggle Build Mode"
	description = "Toggle admin build mode on or off."

/datum/keybinding/admin/build_mode/down(client/user)
	if (!user.holder) return
	user.togglebuildmodeself()
	return TRUE


/datum/keybinding/admin/invismin
	key = "F8"
	name = "invismin"
	full_name = "Toggle Invismin"
	description = "Toggle your admin invisibility."

/datum/keybinding/admin/invismin/down(client/user)
	if (!user.holder) return
	user.invisimin()
	return TRUE


/datum/keybinding/admin/dead_say
	key = "F10"
	name = "dead_say"
	full_name = "Dead Say"
	description = "Speak in deadchat as an admin."

/datum/keybinding/admin/dead_say/down(client/user)
	user.get_dead_say()
	return TRUE
