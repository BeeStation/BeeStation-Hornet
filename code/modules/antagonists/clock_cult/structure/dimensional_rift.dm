/obj/effect/portal/wormhole/clockcult
	name = "dimensional anomaly"
	desc = "A dimensional anomaly. It feels warm to the touch, and has a gentle puff of steam emanating from it."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	mech_sized = TRUE
	density = TRUE

/obj/effect/portal/wormhole/clockcult/Bumped(atom/movable/AM)
	. = ..()
	teleport(AM)

/obj/effect/portal/wormhole/clockcult/teleport(atom/movable/M)
	CRASH("Not implemented exception")
