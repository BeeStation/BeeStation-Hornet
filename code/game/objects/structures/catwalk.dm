/obj/structure/lattice/catwalk
	name = "catwalk"
	desc = "A catwalk for easier EVA maneuvering and cable placement."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk"
	number_of_rods = 2
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP
	//Negates the effect of space and openspace.
	//Shouldn't be placed above anything else.
	FASTDMM_PROP(\
		pipe_astar_cost = -98.5\
	)

/obj/structure/lattice/catwalk/over
	layer = CATWALK_LAYER
	plane = GAME_PLANE

/obj/structure/lattice/catwalk/ratvar_act()
	new /obj/structure/lattice/catwalk/clockwork(loc)

/obj/structure/lattice/catwalk/Move()
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.deconstruct()
	..()

/obj/structure/lattice/catwalk/deconstruct()
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.deconstruct()
	..()

/obj/structure/lattice/catwalk/can_climb_through()
	return FALSE

/obj/structure/lattice/catwalk/can_climb_around()
	return TRUE
