/obj/machinery/atmospherics/components/unary/passive_vent
	icon_state = "passive_vent_map-3"

	name = "passive vent"
	desc = "It is an open vent."

	can_unwrench = TRUE
	hide = TRUE
	interacts_with_air = TRUE
	layer = GAS_SCRUBBER_LAYER
	shift_underlay_only = FALSE

	pipe_state = "pvent"

/obj/machinery/atmospherics/components/unary/passive_vent/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		var/image/cap = get_pipe_image(icon, "vent_cap", initialize_directions, pipe_color)
		add_overlay(cap)
	icon_state = "passive_vent"

/obj/machinery/atmospherics/components/unary/passive_vent/process_atmos()
	var/turf/location = get_turf(loc)
	if(isclosedturf(location))
		return

	var/datum/gas_mixture/external = location.return_air()
	var/datum/gas_mixture/internal = airs[1]

	if(internal.equalize(external))
		air_update_turf(FALSE, FALSE)
		update_parents()

/obj/machinery/atmospherics/components/unary/passive_vent/can_crawl_through()
	return TRUE // we don't care about power or being broken

/obj/machinery/atmospherics/components/unary/passive_vent/layer2
	piping_layer = 2
	icon_state = "passive_vent_map-2"

/obj/machinery/atmospherics/components/unary/passive_vent/layer4
	piping_layer = 4
	icon_state = "passive_vent_map-4"
