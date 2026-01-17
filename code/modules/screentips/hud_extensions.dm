/// Screentip to be displayed on the HUD
/datum/hud/var/atom/movable/screen/screentip/screentip

/datum/hud/New(mob/owner)
	. = ..()
	screentip = new(null, src)
	infodisplay += screentip
