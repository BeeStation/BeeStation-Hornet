/obj/structure/lattice/catwalk
	name = "catwalk"
	desc = "A catwalk for easier EVA maneuvering and cable placement."
	icon = 'icons/obj/smooth_structures/catwalks/catwalk.dmi'
	icon_state = "catwalk-0"
	base_icon_state = "catwalk"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_OPEN_FLOOR, SMOOTH_GROUP_CATWALK, SMOOTH_GROUP_LATTICE)
	canSmoothWith = list(SMOOTH_GROUP_CATWALK)
	z_flags = Z_BLOCK_OUT_DOWN | Z_BLOCK_IN_UP
	number_of_rods = 2
	//Negates the effect of space and openspace.
	//Shouldn't be placed above anything else.
	FASTDMM_PROP(\
		pipe_astar_cost = -98.5\
	)

/obj/structure/lattice/catwalk/over
	layer = CATWALK_LATTICE
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
	var/turf/open/floor/plating/P = loc
	if(istype(P))
		return ..()
	for(var/obj/structure/cable/C in T)
		C.deconstruct()
	..()
