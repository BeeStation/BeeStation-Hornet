/*
Because mapping is already tedious enough this spawner let you spawn generic
"sets" of objects rather than having to make the same object stack again and
again.
*/

/obj/effect/spawner/structure
	name = "map structure spawner"
	var/list/spawn_list

/obj/effect/spawner/structure/Initialize(mapload)
	. = ..()
	// When spawner is created at a holodeck template
	var/area/holodeck/holodeck_area = get_area(src)
	if(istype(holodeck_area, /area/holodeck))
		var/obj/machinery/computer/holodeck/holocomputer = holodeck_area.linked
		for(var/spawn_type as anything in spawn_list)
			holocomputer.from_spawner += new spawn_type(loc)
		return
	// standard init
	for(var/spawn_type in spawn_list)
		new spawn_type(loc)

//normal windows

/obj/effect/spawner/structure/window
	icon = 'icons/obj/structures_spawners.dmi'
	icon_state = "window_spawner"
	name = "window spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/fulltile)
	dir = SOUTH

/obj/effect/spawner/structure/window/Initialize(mapload)
	. = ..()

	if (is_station_level(z))
		var/turf/current_turf = get_turf(src)
		current_turf.rcd_memory = RCD_MEMORY_WINDOWGRILLE

/obj/effect/spawner/structure/window/hollow
	name = "hollow window spawner"
	icon_state = "hwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/directional/north, /obj/structure/window/spawner/directional/east, /obj/structure/window/spawner/directional/west)

/obj/effect/spawner/structure/window/hollow/end
	icon_state = "hwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/directional/north, /obj/structure/window/spawner/directional/east, /obj/structure/window/spawner/directional/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/directional/north, /obj/structure/window/spawner/directional/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/directional/east, /obj/structure/window/spawner/directional/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/directional/north, /obj/structure/window/spawner/directional/west)
	return ..()

/obj/effect/spawner/structure/window/hollow/middle
	icon_state = "hwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/directional/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/directional/east, /obj/structure/window/spawner/directional/west)
	return ..()

/obj/effect/spawner/structure/window/hollow/directional
	icon_state = "hwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/directional/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/directional/north, /obj/structure/window/spawner/directional/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/directional/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/directional/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/directional/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/directional/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/directional/north, /obj/structure/window/spawner/directional/west)
	return ..()

//reinforced

/obj/effect/spawner/structure/window/reinforced
	name = "reinforced window spawner"
	icon_state = "rwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/fulltile)

//Alarm grilles for prison wing
/obj/effect/spawner/structure/window/reinforced/prison
	name = "prison window spawner"
	spawn_list = list(/obj/structure/grille/prison, /obj/structure/window/reinforced/fulltile)

/obj/effect/spawner/structure/window/hollow/reinforced
	name = "hollow reinforced window spawner"
	icon_state = "hrwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/directional/north, /obj/structure/window/reinforced/spawner/directional/east, /obj/structure/window/reinforced/spawner/directional/west)

/obj/effect/spawner/structure/window/hollow/reinforced/end
	icon_state = "hrwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/reinforced/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/directional/north, /obj/structure/window/reinforced/spawner/directional/east, /obj/structure/window/reinforced/spawner/directional/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/directional/north, /obj/structure/window/reinforced/spawner/directional/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/directional/east, /obj/structure/window/reinforced/spawner/directional/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/directional/north, /obj/structure/window/reinforced/spawner/directional/west)
	return ..()

/obj/effect/spawner/structure/window/hollow/reinforced/middle
	icon_state = "hrwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/reinforced/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/directional/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/directional/east, /obj/structure/window/reinforced/spawner/directional/west)
	return ..()

/obj/effect/spawner/structure/window/hollow/reinforced/directional
	icon_state = "hrwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/reinforced/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/directional/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/directional/north, /obj/structure/window/reinforced/spawner/directional/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/directional/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/directional/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/directional/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/directional/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/directional/north, /obj/structure/window/reinforced/spawner/directional/west)
	return ..()

//tinted

/obj/effect/spawner/structure/window/reinforced/tinted
	name = "tinted reinforced window spawner"
	icon_state = "twindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/tinted/fulltile)

//tinted nightclub

/obj/effect/spawner/structure/window/reinforced/tinted/nightclub
	name = "tinted nightclub reinforced window spawner"
	icon_state = "twindow_spawner"
	color ="#9b1d70"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/tinted/fulltile/nightclub)

//bronze

/obj/effect/spawner/structure/window/bronze
	name = "bronze window spawner"
	icon_state = "bronzewindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/bronze/fulltile)


//shuttle window

/obj/effect/spawner/structure/window/reinforced/shuttle
	name = "shuttle window spawner"
	icon_state = "swindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/shuttle)


//plastitanium window

/obj/effect/spawner/structure/window/reinforced/plasma/plastitanium
	name = "plastitanium window spawner"
	icon_state = "plastitaniumwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma/plastitanium)


//ice window

/obj/effect/spawner/structure/window/ice
	name = "ice window spawner"
	icon_state = "icewindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/fulltile/ice)


//survival pod window

/obj/effect/spawner/structure/window/survival_pod
	name = "pod window spawner"
	icon_state = "podwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/shuttle/survival_pod)

/obj/effect/spawner/structure/window/hollow/survival_pod
	name = "hollow pod window spawner"
	icon_state = "podwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod, /obj/structure/window/reinforced/survival_pod/spawner/directional/north, /obj/structure/window/reinforced/survival_pod/spawner/directional/east, /obj/structure/window/reinforced/survival_pod/spawner/directional/west)

/obj/effect/spawner/structure/window/hollow/survival_pod/end
	icon_state = "podwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/survival_pod/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod/spawner/directional/north, /obj/structure/window/reinforced/survival_pod/spawner/directional/east, /obj/structure/window/reinforced/survival_pod/spawner/directional/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod, /obj/structure/window/reinforced/survival_pod/spawner/directional/north, /obj/structure/window/reinforced/survival_pod/spawner/directional/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod, /obj/structure/window/reinforced/survival_pod/spawner/directional/east, /obj/structure/window/reinforced/survival_pod/spawner/directional/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod, /obj/structure/window/reinforced/survival_pod/spawner/directional/north, /obj/structure/window/reinforced/survival_pod/spawner/directional/west)
	return ..()

/obj/effect/spawner/structure/window/hollow/survival_pod/middle
	icon_state = "podwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/survival_pod/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod, /obj/structure/window/reinforced/survival_pod/spawner/directional/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod/spawner/directional/east, /obj/structure/window/reinforced/survival_pod/spawner/directional/west)
	return ..()

/obj/effect/spawner/structure/window/hollow/survival_pod/directional
	icon_state = "podwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/survival_pod/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod/spawner/directional/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod/spawner/directional/north, /obj/structure/window/reinforced/survival_pod/spawner/directional/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod/spawner/directional/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod, /obj/structure/window/reinforced/survival_pod/spawner/directional/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod, /obj/structure/window/reinforced/survival_pod/spawner/directional/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod/spawner/directional/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod/spawner/directional/north, /obj/structure/window/reinforced/survival_pod/spawner/directional/west)
	return ..()


//plasma windows

/obj/effect/spawner/structure/window/plasma
	name = "plasma window spawner"
	icon_state = "pwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/fulltile)

/obj/effect/spawner/structure/window/hollow/plasma
	name = "hollow plasma window spawner"
	icon_state = "phwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/directional/north, /obj/structure/window/plasma/spawner/directional/east, /obj/structure/window/plasma/spawner/directional/west)

/obj/effect/spawner/structure/window/hollow/plasma/end
	icon_state = "phwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/plasma/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/directional/north, /obj/structure/window/plasma/spawner/directional/east, /obj/structure/window/plasma/spawner/directional/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/directional/north, /obj/structure/window/plasma/spawner/directional/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/directional/east, /obj/structure/window/plasma/spawner/directional/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/directional/north, /obj/structure/window/plasma/spawner/directional/west)
	return ..()

/obj/effect/spawner/structure/window/hollow/plasma/middle
	icon_state = "phwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/plasma/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/directional/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/directional/east, /obj/structure/window/plasma/spawner/directional/west)
	return ..()

/obj/effect/spawner/structure/window/hollow/plasma/directional
	icon_state = "phwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/plasma/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/directional/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/directional/north, /obj/structure/window/plasma/spawner/directional/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/directional/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/directional/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/directional/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/directional/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/directional/north, /obj/structure/window/plasma/spawner/directional/west)
	return ..()

//reinforced plasma

/obj/effect/spawner/structure/window/reinforced/plasma
	name = "reinforced plasma window spawner"
	icon_state = "prwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma/fulltile)

/obj/effect/spawner/structure/window/hollow/reinforced/plasma
	name = "hollow reinforced plasma window spawner"
	icon_state = "phrwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma, /obj/structure/window/reinforced/plasma/spawner/directional/north, /obj/structure/window/reinforced/plasma/spawner/directional/east, /obj/structure/window/reinforced/plasma/spawner/directional/west)

/obj/effect/spawner/structure/window/hollow/reinforced/plasma/end
	icon_state = "phrwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/reinforced/plasma/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma/spawner/directional/north, /obj/structure/window/reinforced/plasma/spawner/directional/east, /obj/structure/window/reinforced/plasma/spawner/directional/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma, /obj/structure/window/reinforced/plasma/spawner/directional/north, /obj/structure/window/reinforced/plasma/spawner/directional/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma, /obj/structure/window/reinforced/plasma/spawner/directional/east, /obj/structure/window/reinforced/plasma/spawner/directional/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma, /obj/structure/window/reinforced/plasma/spawner/directional/north, /obj/structure/window/reinforced/plasma/spawner/directional/west)
	return ..()

/obj/effect/spawner/structure/window/hollow/reinforced/plasma/middle
	icon_state = "phrwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/reinforced/plasma/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma, /obj/structure/window/reinforced/plasma/spawner/directional/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma/spawner/directional/east, /obj/structure/window/reinforced/plasma/spawner/directional/west)
	return ..()

/obj/effect/spawner/structure/window/hollow/reinforced/plasma/directional
	icon_state = "phrwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/reinforced/plasma/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma/spawner/directional/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma/spawner/directional/north, /obj/structure/window/reinforced/plasma/spawner/directional/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma/spawner/directional/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma, /obj/structure/window/reinforced/plasma/spawner/directional/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma, /obj/structure/window/reinforced/plasma/spawner/directional/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma/spawner/directional/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/plasma/spawner/directional/north, /obj/structure/window/reinforced/plasma/spawner/directional/west)
	return ..()

//Depleted Uranium Windows

/obj/effect/spawner/structure/window/depleteduranium
	name = "reinforced depleted uranium window spawner"
	icon_state = "duwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/fulltile)

/obj/effect/spawner/structure/window/hollow/depleteduranium
	name = "hollow depleted uranium window spawner"
	icon_state = "duhwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/directional/north, /obj/structure/window/depleteduranium/spawner/directional/east, /obj/structure/window/depleteduranium/spawner/directional/west)

/obj/effect/spawner/structure/window/hollow/depleteduranium/end
	icon_state = "duhwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/depleteduranium/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/directional/north, /obj/structure/window/depleteduranium/spawner/directional/east, /obj/structure/window/depleteduranium/spawner/directional/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/directional/north, /obj/structure/window/depleteduranium/spawner/directional/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/directional/east, /obj/structure/window/depleteduranium/spawner/directional/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/directional/north, /obj/structure/window/depleteduranium/spawner/directional/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/depleteduranium/middle
	icon_state = "duhwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/depleteduranium/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/directional/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/directional/east, /obj/structure/window/depleteduranium/spawner/directional/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/depleteduranium/directional
	icon_state = "duhwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/depleteduranium/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/directional/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/directional/north, /obj/structure/window/depleteduranium/spawner/directional/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/directional/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/directional/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/directional/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/directional/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/directional/north, /obj/structure/window/depleteduranium/spawner/directional/west)
	. = ..()

/obj/effect/spawner/structure/shipping_container
	name = "shipping container spawner"
	icon = 'icons/obj/containers.dmi'
	icon_state = "random_container"
	spawn_list = list(/obj/structure/shipping_container/conarex = 3,/obj/structure/shipping_container/deforest = 3,/obj/structure/shipping_container/kahraman = 3,/obj/structure/shipping_container/kahraman/alt = 3,/obj/structure/shipping_container/kosmologistika = 3,/obj/structure/shipping_container/interdyne = 3,/obj/structure/shipping_container/nakamura = 3,/obj/structure/shipping_container/nanotrasen = 3,/obj/structure/shipping_container/nthi = 3,/obj/structure/shipping_container/vitezstvi = 3,/obj/structure/shipping_container/cybersun = 2,/obj/structure/shipping_container/donk_co = 2,/obj/structure/shipping_container/gorlex = 1,/obj/structure/shipping_container/gorlex/red = 1)

/obj/effect/spawner/structure/random_piano
	name = "random piano spawner"
	icon = 'icons/effects/landmarks_spawners.dmi'
	icon_state = "piano"

/// This is stupid, I hate it, I'm already working on a pr to overhaul this entire stupid ass cocksucking bitch of a system
/// Also, the spawner above has the same issue and spawns every single shipping container
/obj/effect/spawner/structure/random_piano/Initialize(mapload)
	. = ..()
	var/obj/structure/musician/piano/chosen_piano = prob(50) ? /obj/structure/musician/piano : /obj/structure/musician/piano/minimoog

	// When spawner is created at a holodeck template
	var/area/holodeck/holodeck_area = get_area(src)
	if(istype(holodeck_area, /area/holodeck))
		var/obj/machinery/computer/holodeck/holocomputer = holodeck_area.linked
		holocomputer.from_spawner += new chosen_piano(loc)
		return

	new chosen_piano(loc)
