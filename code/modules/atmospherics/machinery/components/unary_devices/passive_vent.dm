/obj/machinery/atmospherics/components/unary/passive_vent
	icon_state = "passive_vent_map-2"

	name = "passive vent"
	desc = "It is an open vent."
	can_unwrench = TRUE

	level = 1
	layer = GAS_SCRUBBER_LAYER

	pipe_state = "pvent"

/obj/machinery/atmospherics/components/unary/passive_vent/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		var/image/cap = getpipeimage(icon, "vent_cap", initialize_directions, piping_layer = piping_layer)
		add_overlay(cap)
	icon_state = "passive_vent"

/obj/machinery/atmospherics/components/unary/passive_vent/process_atmos()
	..()
	if(isclosedturf(loc))
		return

	var/datum/gas_mixture/internal = airs[1]
	var/datum/gas_mixture/external = loc.return_air()
	if(internal.equalize(external))
		air_update_turf()
		update_parents()

/obj/machinery/atmospherics/components/unary/passive_vent/can_crawl_through()
	return TRUE

/obj/machinery/atmospherics/components/unary/passive_vent/layer1
	piping_layer = 1
	icon_state = "passive_vent_map-1"

/obj/machinery/atmospherics/components/unary/passive_vent/layer3
	piping_layer = 3
	icon_state = "passive_vent_map-3"
