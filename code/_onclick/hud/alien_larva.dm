/datum/hud/larva
	ui_style = 'icons/hud/screen_alien.dmi'

/datum/hud/larva/New(mob/owner)
	..()
	var/atom/movable/screen/using

	action_intent = new /atom/movable/screen/combattoggle/flashy(null, src)
	action_intent.icon = ui_style
	action_intent.screen_loc = ui_combat_toggle
	static_inventory += action_intent

	healths = new /atom/movable/screen/healths/alien(null, src)
	infodisplay += healths

	alien_queen_finder = new /atom/movable/screen/alien/alien_queen_finder(null, src)
	infodisplay += alien_queen_finder

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = 'icons/hud/screen_alien.dmi'
	pull_icon.update_icon()
	pull_icon.screen_loc = ui_above_movement
	hotkeybuttons += pull_icon

	using = new/atom/movable/screen/language_menu(null, src)
	using.screen_loc = ui_alien_language_menu
	static_inventory += using

	using = new /atom/movable/screen/navigate(null, src)
	using.screen_loc = ui_alien_navigate_menu
	static_inventory += using

	zone_select = new /atom/movable/screen/zone_sel/alien(null, src)
	zone_select.update_icon()
	static_inventory += zone_select
