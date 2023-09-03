/obj/machinery/door/unpowered

/obj/machinery/door/unpowered/Bumped(atom/movable/AM)
	if(src.locked)
		return
	..()
	return

/obj/machinery/door/unpowered/item_interact(obj/item/I, mob/user, params)
	return FALSE

/obj/machinery/door/unpowered/shuttle
	icon = 'icons/turf/shuttle.dmi'
	name = "door"
	icon_state = "door1"
	opacity = TRUE
	density = TRUE
	explosion_block = 1
