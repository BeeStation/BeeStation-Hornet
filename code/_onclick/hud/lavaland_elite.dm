/datum/hud/lavaland_elite
	ui_style = 'icons/hud/screen_slime.dmi'

/datum/hud/lavaland_elite/New(mob/living/simple_animal/hostile/asteroid/elite)
	..()
	healths = new /atom/movable/screen/healths/lavaland_elite()
	infodisplay += healths
