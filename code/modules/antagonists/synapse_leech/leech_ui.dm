// Defines for UI element locations
#define ui_leech_health "EAST,CENTER-1:15"
#define ui_leech_navigate_menu "EAST-4:20,SOUTH:5"

// Hud
/datum/hud/leech
	ui_style = 'icons/synapse_leech/hud.dmi'

/datum/hud/leech/New(mob/owner)
	..()
	var/atom/movable/screen/using

	healths = new /atom/movable/screen/healths/leech(null, src)
	infodisplay += healths

	using = new /atom/movable/screen/navigate/leech(null, src)
	using.screen_loc = ui_leech_navigate_menu
	static_inventory += using

// Screen things
/atom/movable/screen/healths/leech
	icon = 'icons/synapse_leech/hud.dmi'
	screen_loc = ui_leech_health

/atom/movable/screen/navigate/leech
	icon = 'icons/synapse_leech/hud.dmi'
	icon_state = "navigate"
	screen_loc = ui_leech_navigate_menu
