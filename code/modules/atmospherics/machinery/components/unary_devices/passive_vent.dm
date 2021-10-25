/obj/machinery/atmospherics/components/unary/passive_vent
	icon_state = "passive_vent_map-2"

	name = "passive vent"
	desc = "It is an open vent."
	can_unwrench = TRUE

	level = 1
	interacts_with_air = TRUE
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

	var/active = FALSE
	var/datum/gas_mixture/external = loc.return_air()
	var/datum/gas_mixture/internal = airs[1]
	var/external_pressure = external.return_pressure()
	var/internal_pressure = internal.return_pressure()
	var/pressure_delta = abs(external_pressure - internal_pressure)

	if(pressure_delta > 0.5)
		equalize_all_gases_in_list(list(internal,external))
		active = TRUE

	active = internal.temperature_share(external, OPEN_HEAT_TRANSFER_COEFFICIENT) || active

	if(active)
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
