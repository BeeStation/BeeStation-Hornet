/datum/hud/nymph
	ui_style = 'icons/hud/screen_gen.dmi'

/datum/hud/nymph/New(mob/living/simple_animal/hostile/retaliate/nymph/owner)
	..()
	healths = new /atom/movable/screen/healths()
	healths.hud = src
	infodisplay += healths
