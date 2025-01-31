/datum/hud/slime
	ui_style = 'icons/hud/screen_slime.dmi'

/datum/hud/slime/New(mob/living/simple_animal/slime/owner)
	..()
	healths = new /atom/movable/screen/healths/slime()
	healths.hud = src
	infodisplay += healths
