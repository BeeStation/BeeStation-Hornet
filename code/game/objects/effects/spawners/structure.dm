/*
Because mapping is already tedious enough this spawner let you spawn generic
"sets" of objects rather than having to make the same object stack again and
again.
*/

/obj/effect/spawner/structure
	name = "map structure spawner"
	density = TRUE
	var/list/spawn_list

/obj/effect/spawner/structure/Initialize(mapload)
	. = ..()
	if(spawn_list?.len)
		for(var/I in spawn_list)
			new I(get_turf(src))
	return INITIALIZE_HINT_QDEL


//normal windows

/obj/effect/spawner/structure/window
	icon = 'icons/obj/structures_spawners.dmi'
	icon_state = "window_spawner"
	name = "window spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/fulltile)
	dir = SOUTH
	FASTDMM_PROP(\
		pipe_astar_cost = 1\
	)

/obj/effect/spawner/structure/window/hollow
	name = "hollow window spawner"
	icon_state = "hwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/north, /obj/structure/window/spawner/east, /obj/structure/window/spawner/west)

/obj/effect/spawner/structure/window/hollow/end
	icon_state = "hwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/north, /obj/structure/window/spawner/east, /obj/structure/window/spawner/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/north, /obj/structure/window/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/east, /obj/structure/window/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/north, /obj/structure/window/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/middle
	icon_state = "hwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/east, /obj/structure/window/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/directional
	icon_state = "hwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/north, /obj/structure/window/spawner/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/north, /obj/structure/window/spawner/west)
	. = ..()

//shutter
/obj/effect/spawner/structure/window/shutter
	name = "shutter window spawner"
	icon_state = "shwindow_spawner"
	spawn_list = list(/obj/machinery/door/firedoor/window, /obj/structure/grille, /obj/structure/window/fulltile)

//reinforced

/obj/effect/spawner/structure/window/reinforced
	name = "reinforced window spawner"
	icon_state = "rwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/fulltile)
	FASTDMM_PROP(\
		pipe_astar_cost = 2\
	)

//reinforced shutter
/obj/effect/spawner/structure/window/reinforced/shutter
	name = "reinforced shutter window spawner"
	icon_state = "shrwindow_spawner"
	spawn_list = list(/obj/machinery/door/firedoor/window, /obj/structure/grille, /obj/structure/window/reinforced/fulltile)

/obj/effect/spawner/structure/window/hollow/reinforced
	name = "hollow reinforced window spawner"
	icon_state = "hrwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/east, /obj/structure/window/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/reinforced/end
	icon_state = "hrwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/reinforced/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/east, /obj/structure/window/reinforced/spawner/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/east, /obj/structure/window/reinforced/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/reinforced/middle
	icon_state = "hrwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/reinforced/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/east, /obj/structure/window/reinforced/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/reinforced/directional
	icon_state = "hrwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/reinforced/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/west)
	. = ..()

//tinted

/obj/effect/spawner/structure/window/reinforced/tinted
	name = "tinted reinforced window spawner"
	icon_state = "twindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/tinted/fulltile)

//tinted reinforced shutter
/obj/effect/spawner/structure/window/reinforced/tinted/shutter
	name = "tinted reinforced shutter window spawner"
	icon_state = "shtwindow_spawner"
	spawn_list = list(/obj/machinery/door/firedoor/window, /obj/structure/grille, /obj/structure/window/reinforced/tinted/fulltile)

//shuttle window

/obj/effect/spawner/structure/window/shuttle
	name = "shuttle window spawner"
	icon_state = "swindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle)


//plastitanium window

/obj/effect/spawner/structure/window/plastitanium
	name = "plastitanium window spawner"
	icon_state = "plastitaniumwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/plastitanium)


//ice window

/obj/effect/spawner/structure/window/ice
	name = "ice window spawner"
	icon_state = "icewindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/fulltile/ice)


//survival pod window

/obj/effect/spawner/structure/window/survival_pod
	name = "pod window spawner"
	icon_state = "podwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod)

/obj/effect/spawner/structure/window/hollow/survival_pod
	name = "hollow pod window spawner"
	icon_state = "podwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/north, /obj/structure/window/shuttle/survival_pod/spawner/east, /obj/structure/window/shuttle/survival_pod/spawner/west)

/obj/effect/spawner/structure/window/hollow/survival_pod/end
	icon_state = "podwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/survival_pod/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/north, /obj/structure/window/shuttle/survival_pod/spawner/east, /obj/structure/window/shuttle/survival_pod/spawner/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/north, /obj/structure/window/shuttle/survival_pod/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/east, /obj/structure/window/shuttle/survival_pod/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/north, /obj/structure/window/shuttle/survival_pod/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/survival_pod/middle
	icon_state = "podwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/survival_pod/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/east, /obj/structure/window/shuttle/survival_pod/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/survival_pod/directional
	icon_state = "podwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/survival_pod/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/north, /obj/structure/window/shuttle/survival_pod/spawner/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/north, /obj/structure/window/shuttle/survival_pod/spawner/west)
	. = ..()


//lean windows

/obj/effect/spawner/structure/window/lean
	name = "lean window spawner"
	icon_state = "pwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/fulltile)

/obj/effect/spawner/structure/window/hollow/lean
	name = "hollow lean window spawner"
	icon_state = "phwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/lean, /obj/structure/window/lean/spawner/north, /obj/structure/window/lean/spawner/east, /obj/structure/window/lean/spawner/west)

/obj/effect/spawner/structure/window/hollow/lean/end
	icon_state = "phwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/lean/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/spawner/north, /obj/structure/window/lean/spawner/east, /obj/structure/window/lean/spawner/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean, /obj/structure/window/lean/spawner/north, /obj/structure/window/lean/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean, /obj/structure/window/lean/spawner/east, /obj/structure/window/lean/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean, /obj/structure/window/lean/spawner/north, /obj/structure/window/lean/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/lean/middle
	icon_state = "phwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/lean/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean, /obj/structure/window/lean/spawner/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/spawner/east, /obj/structure/window/lean/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/lean/directional
	icon_state = "phwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/lean/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/spawner/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/spawner/north, /obj/structure/window/lean/spawner/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/spawner/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean, /obj/structure/window/lean/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean, /obj/structure/window/lean/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/spawner/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/spawner/north, /obj/structure/window/lean/spawner/west)
	. = ..()

//lean reinforced

/obj/effect/spawner/structure/window/lean/reinforced
	name = "reinforced lean window spawner"
	icon_state = "prwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced/fulltile)

/obj/effect/spawner/structure/window/hollow/lean/reinforced
	name = "hollow reinforced lean window spawner"
	icon_state = "phrwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced, /obj/structure/window/lean/reinforced/spawner/north, /obj/structure/window/lean/reinforced/spawner/east, /obj/structure/window/lean/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/lean/reinforced/end
	icon_state = "phrwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/lean/reinforced/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced/spawner/north, /obj/structure/window/lean/reinforced/spawner/east, /obj/structure/window/lean/reinforced/spawner/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced, /obj/structure/window/lean/reinforced/spawner/north, /obj/structure/window/lean/reinforced/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced, /obj/structure/window/lean/reinforced/spawner/east, /obj/structure/window/lean/reinforced/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced, /obj/structure/window/lean/reinforced/spawner/north, /obj/structure/window/lean/reinforced/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/lean/reinforced/middle
	icon_state = "phrwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/lean/reinforced/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced, /obj/structure/window/lean/reinforced/spawner/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced/spawner/east, /obj/structure/window/lean/reinforced/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/lean/reinforced/directional
	icon_state = "phrwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/lean/reinforced/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced/spawner/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced/spawner/north, /obj/structure/window/lean/reinforced/spawner/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced/spawner/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced, /obj/structure/window/lean/reinforced/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced, /obj/structure/window/lean/reinforced/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced/spawner/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/lean/reinforced/spawner/north, /obj/structure/window/lean/reinforced/spawner/west)
	. = ..()

//reinforced lean shutter

/obj/effect/spawner/structure/window/lean/reinforced/shutter
	name = "reinforced lean shutter window spawner"
	icon_state = "shprwindow_spawner"
	spawn_list = list(/obj/machinery/door/firedoor/window, /obj/structure/grille, /obj/structure/window/lean/reinforced/fulltile)
