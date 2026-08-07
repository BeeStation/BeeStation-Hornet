
/datum/hud/blobbernaut/New(mob/owner)
	..()
	blobpwrdisplay = new /atom/movable/screen/healths/blob/naut/core(null, src)
	infodisplay += blobpwrdisplay

	healths = new /atom/movable/screen/healths/blob/naut(null, src)
	infodisplay += healths
