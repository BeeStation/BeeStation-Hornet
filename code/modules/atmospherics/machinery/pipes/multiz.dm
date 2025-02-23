/// This is an atmospherics pipe which can relay air up/down a deck.
/obj/machinery/atmospherics/pipe/multiz
	name = "multi deck pipe adapter"
	desc = "An adapter which allows pipes to connect to other pipenets on different decks."
	icon_state = "adapter-3"
	icon = 'icons/obj/atmospherics/pipes/multiz.dmi'

	dir = SOUTH
	initialize_directions = SOUTH

	hide = FALSE
	layer = HIGH_OBJ_LAYER
	device_type = TRINARY
	paintable = FALSE

	construction_type = /obj/item/pipe/directional
	pipe_state = "multiz"

	has_gas_visuals = FALSE

	///Our central icon
	var/mutable_appearance/center = null
	///The pipe icon
	var/mutable_appearance/pipe = null
	var/obj/machinery/atmospherics/front_node = null



/* We use New() instead of Initialize() because these values are used in update_icon()
 * in the mapping subsystem init before Initialize() is called in the atoms subsystem init.
 * This is true for the other manifolds (the 4 ways and the heat exchanges) too.
 */
/obj/machinery/atmospherics/pipe/multiz/New()
	icon_state = ""
	center = mutable_appearance(icon, "adapter_center", layer = HIGH_OBJ_LAYER)
	pipe = mutable_appearance(icon, "pipe-[piping_layer]")
	return ..()

/obj/machinery/atmospherics/pipe/multiz/set_init_directions()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/multiz/update_icon()
	cut_overlays()
	pipe.color = front_node ? front_node.pipe_color : rgb(255, 255, 255)
	pipe.icon_state = "pipe-[piping_layer]"
	center.pixel_x = PIPING_LAYER_P_X * (piping_layer - PIPING_LAYER_DEFAULT)
	add_overlay(pipe)
	add_overlay(center)

/// Attempts to locate a multiz pipe that's above us, if it finds one it merges us into its pipenet
/obj/machinery/atmospherics/pipe/multiz/pipenet_expansion()
	var/turf/T = get_turf(src)
	for(var/obj/machinery/atmospherics/pipe/multiz/above in GET_TURF_ABOVE(T))
		if(is_connectable(above, piping_layer))
			nodes[2] = above
			above.nodes[3] = src //Two way travel :)
	for(var/obj/machinery/atmospherics/pipe/multiz/below in GET_TURF_BELOW(T))
		if(is_connectable(below, piping_layer))
			below.pipenet_expansion() // If we've got one below us, force it to add us on facebook
	return ..()

// MAPPING
/obj/machinery/atmospherics/pipe/multiz/layer1
	piping_layer = 1
	icon_state = "adapter-1"

/obj/machinery/atmospherics/pipe/multiz/layer2
	piping_layer = 2
	icon_state = "adapter-2"

/obj/machinery/atmospherics/pipe/multiz/layer4
	piping_layer = 4
	icon_state = "adapter-4"

/obj/machinery/atmospherics/pipe/multiz/layer5
	piping_layer = 5
	icon_state = "adapter-5"
