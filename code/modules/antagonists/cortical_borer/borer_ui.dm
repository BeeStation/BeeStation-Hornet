// Defines for UI element locations
#define ui_borer_health "EAST,CENTER-1:15"
#define ui_borer_navigate_menu "EAST-4:20,SOUTH:5"

// Hud
/datum/hud/borer
	ui_style = 'icons/cortical_borers/hud.dmi'

/datum/hud/borer/New(mob/owner)
	..()
	var/atom/movable/screen/using

	healths = new /atom/movable/screen/healths/borer(null, src)
	infodisplay += healths

	using = new /atom/movable/screen/navigate/borer(null, src)
	using.screen_loc = ui_borer_navigate_menu
	static_inventory += using

// Screen things
/atom/movable/screen/healths/borer
	icon = 'icons/cortical_borers/hud.dmi'
	screen_loc = ui_borer_health

/atom/movable/screen/navigate/borer
	icon = 'icons/cortical_borers/hud.dmi'
	icon_state = "navigate"
	screen_loc = ui_borer_navigate_menu
