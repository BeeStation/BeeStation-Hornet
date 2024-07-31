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
		var/image/cap = getpipeimage(icon, "vent_cap", initialize_directions)
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
	return TRUE // we don't care about power or being broken

/obj/machinery/atmospherics/components/unary/passive_vent/layer2
	piping_layer = 2
	icon_state = "passive_vent_map-2"

/obj/machinery/atmospherics/components/unary/passive_vent/layer4
	piping_layer = 4
	icon_state = "passive_vent_map-4"
