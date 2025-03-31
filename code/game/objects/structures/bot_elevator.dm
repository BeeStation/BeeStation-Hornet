/obj/structure/bot_elevator
	name = "bot elevator"
	desc = "A basic service elevator built specifically for the various bots onboard the vessel."
	icon = 'icons/obj/structures/bot_elevator.dmi'
	icon_state = "elevator1"
	anchored = TRUE
	var/obj/structure/bot_elevator/down
	var/obj/structure/bot_elevator/up
	max_integrity = 100

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/bot_elevator)

/obj/structure/bot_elevator/Initialize(mapload, obj/structure/bot_elevator/up, obj/structure/bot_elevator/down)
	..()
	GLOB.bot_elevator += src
	if (up)
		src.up = up
		up.down = src
	if (down)
		src.down = down
		down.up = src
	return INITIALIZE_HINT_LATELOAD

/obj/structure/bot_elevator/Destroy(force)
	if ((resistance_flags & INDESTRUCTIBLE) && !force)
		return QDEL_HINT_LETMELIVE
	GLOB.bot_elevator -= src
	disconnect()
	return ..()

/obj/structure/bot_elevator/proc/disconnect()
	if(up && up.down == src)
		up.down = null
	if(down && down.up == src)
		down.up = null
	up = down = null

/obj/structure/bot_elevator/LateInitialize()
	// By default, discover bot elevators above and below us vertically
	var/turf/T = get_turf(src)
	var/obj/structure/bot_elevator/Elevator

	if (!down)
		Elevator = locate() in GET_TURF_BELOW(T)
		if (Elevator)
			down = Elevator
			Elevator.up = src  // Don't waste effort looping the other way
	if (!up)
		Elevator = locate() in GET_TURF_ABOVE(T)
		if (Elevator)
			up = Elevator
			Elevator.down = src  // Don't waste effort looping the other way



/obj/structure/bot_elevator/proc/travel(going_up, mob/user, is_ghost, obj/structure/bot_elevator/elevator, needs_do_after=TRUE)
	var/turf/T = get_turf(elevator)
	if(!is_ghost && isbot(user))
		user.say("Weeeeeee!")
		if(needs_do_after)
			if(!do_after(user, 1 SECONDS, target=src))
				return FALSE
	user.forceMove(T)

