/datum/hud/slime
	ui_style = 'icons/mob/screen_slime.dmi'

/datum/hud/slime/New(mob/living/simple_animal/slime/owner)
	..()
	healths = new /atom/movable/screen/healths/slime()
	healths.hud = src
	infodisplay += healths
