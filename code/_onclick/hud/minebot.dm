/datum/hud/minebot
	ui_style = 'icons/hud/screen_cyborg.dmi'

/datum/hud/minebot/New(mob/living/simple_animal/hostile/mining_drone)
	..()
	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_icon()
	pull_icon.screen_loc = ui_healthdoll
	static_inventory += pull_icon

	healths = new /atom/movable/screen/healths/minebot(null, src)
	infodisplay += healths
