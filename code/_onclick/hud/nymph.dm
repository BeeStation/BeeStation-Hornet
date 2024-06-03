/datum/hud/nymph
	ui_style = 'icons/mob/screen_gen.dmi'

/datum/hud/nymph/New(mob/living/simple_animal/nymph/owner)
	..()
	healths = new /atom/movable/screen/healths()
	healths.hud = src
	infodisplay += healths
