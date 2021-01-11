
/datum/hud/revenant/New(mob/owner)
	..()

	healths = new /atom/movable/screen/healths/revenant()
	healths.hud = src
	infodisplay += healths
