/obj/machinery/atmospherics/components/unary/portables_connector
	icon_state = "connector_map-3"

	name = "connector port"
	desc = "For connecting portables devices related to atmospherics control."

	can_unwrench = TRUE

	use_power = NO_POWER_USE
	layer = GAS_FILTER_LAYER
	shift_underlay_only = FALSE
	hide = TRUE

	pipe_flags = PIPING_ONE_PER_TURF
	pipe_state = "connector"
	custom_reconcilation = TRUE

	///Reference to the connected device
	var/obj/machinery/portable_atmospherics/connected_device

/obj/machinery/atmospherics/components/unary/portables_connector/New()
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.volume = 0
	if(connected_device)
		var/datum/pipenet/parent = parents[1]
		if(parent)
			airs[1] = connected_device.air_contents
			parent.reconcile_air()
		else
			CRASH("Portable canister without parent pipenet at [COORD(src)]")

/obj/machinery/atmospherics/components/unary/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()
	return ..()

/obj/machinery/atmospherics/components/unary/portables_connector/update_icon_nopipes()
	cut_overlays()
	icon_state = "connector"
	if(showpipe)
		var/image/cap = get_pipe_image(icon, "connector_cap", initialize_directions, pipe_color)
		add_overlay(cap)

/obj/machinery/atmospherics/components/unary/portables_connector/process_atmos()
	if(!connected_device)
		return
	update_parents()

/obj/machinery/atmospherics/components/unary/portables_connector/return_airs_for_reconcilation(datum/pipenet/requester)
	. = ..()
	if(!connected_device)
		return
	. += connected_device.return_air()

/obj/machinery/atmospherics/components/unary/portables_connector/can_unwrench(mob/user)
	. = ..()
	if(. && connected_device)
		to_chat(user, span_warning("You cannot unwrench [src], detach [connected_device] first!"))
		return FALSE

/obj/machinery/atmospherics/components/unary/portables_connector/layer2
	piping_layer = 2
	icon_state = "connector_map-2"

/obj/machinery/atmospherics/components/unary/portables_connector/layer4
	piping_layer = 4
	icon_state = "connector_map-4"

/obj/machinery/atmospherics/components/unary/portables_connector/visible
	hide = FALSE

/obj/machinery/atmospherics/components/unary/portables_connector/visible/layer2
	piping_layer = 2
	icon_state = "connector_map-2"

/obj/machinery/atmospherics/components/unary/portables_connector/visible/layer4
	piping_layer = 4
	icon_state = "connector_map-4"
