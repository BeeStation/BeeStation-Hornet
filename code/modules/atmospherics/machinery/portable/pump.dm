/obj/machinery/portable_atmospherics/pump
	name = "portable air pump"
	desc = "It's a small portable air pump, capable of siphoning or pumping gasses into its surroundings. It has a decent internal gas storage, and a slot for external tanks. It can be wrenched to a connection port to join it into the pipe net."
	icon_state = "psiphon:0"
	density = TRUE


	///Is the machine on?
	var/on = FALSE
	///What direction is the machine pumping (into pump/port or out to the tank/area)?
	var/direction = PUMP_OUT
	///Player configurable, sets what's the release pressure
	var/target_pressure = ONE_ATMOSPHERE

	volume = 1000

/obj/machinery/portable_atmospherics/pump/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/portable_pump))

/obj/machinery/portable_atmospherics/pump/on_deconstruction(disassembled)
	var/turf/local_turf = get_turf(src)
	local_turf.assume_air(air_contents)
	return ..()

/obj/machinery/portable_atmospherics/pump/update_icon()
	icon_state = "psiphon:[on]"

	cut_overlays()
	if(holding)
		add_overlay("siphon-open")
	if(connected_port)
		add_overlay("siphon-connector")

/obj/machinery/portable_atmospherics/pump/process_atmos()
	if(take_atmos_damage())
		excited = TRUE
		return ..()

	if(!on)
		return ..()

	excited = TRUE

	var/turf/local_turf = get_turf(src)

	var/datum/gas_mixture/sending
	var/datum/gas_mixture/receiving

	if (holding) //Work with tank when inserted, otherwise - with area
		sending = (direction == PUMP_IN ? holding.return_air() : air_contents)
		receiving = (direction == PUMP_IN ? air_contents : holding.return_air())
	else
		sending = (direction == PUMP_IN ? local_turf.return_air() : air_contents)
		receiving = (direction == PUMP_IN ? air_contents : local_turf.return_air())

	if(sending.pump_gas_to(receiving, target_pressure) && !holding)
		air_update_turf(FALSE, FALSE) // Update the environment if needed.

	return ..()


/obj/machinery/portable_atmospherics/pump/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!is_operational)
		return
	if(prob(50 / severity))
		on = !on
		if(on)
			SSair.start_processing_machine(src)
	if(prob(100 / severity))
		direction = PUMP_OUT
	target_pressure = rand(0, 100 * ONE_ATMOSPHERE)
	update_icon()

/obj/machinery/portable_atmospherics/pump/replace_tank(mob/living/user, close_valve)
	. = ..()
	if(!.)
		return
	if(close_valve)
		if(on)
			on = FALSE
			update_appearance()
	else if(on && holding && direction == PUMP_OUT)
		user.investigate_log("started a transfer into [holding].", INVESTIGATE_ATMOS)

/obj/machinery/portable_atmospherics/pump/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/portable_atmospherics/pump/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortablePump")
		ui.open()
		ui.set_autoupdate(TRUE) // Air pressure, tank pressure

/obj/machinery/portable_atmospherics/pump/ui_data()
	var/data = list()
	data["on"] = on
	data["direction"] = direction
	data["connected"] = !!connected_port
	data["pressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["target_pressure"] = round(target_pressure ? target_pressure : 0)
	data["default_pressure"] = round(PUMP_DEFAULT_PRESSURE)
	data["min_pressure"] = round(PUMP_MIN_PRESSURE)
	data["max_pressure"] = round(PUMP_MAX_PRESSURE)

	if(holding)
		data["holding"] = list()
		data["holding"]["name"] = holding.name
		var/datum/gas_mixture/holding_mix = holding.return_air()
		data["holding"]["pressure"] = round(holding_mix.return_pressure())
	else
		data["holding"] = null
	return data

/obj/machinery/portable_atmospherics/pump/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			if(on)
				SSair.start_processing_machine(src)
			if(on && !holding)
				var/plasma = GET_MOLES(/datum/gas/plasma, air_contents)
				var/n2o = GET_MOLES(/datum/gas/nitrous_oxide, air_contents)
				if(n2o || plasma)
					message_admins("[ADMIN_LOOKUPFLW(usr)] turned on a pump that contains [n2o ? "N2O" : ""][n2o && plasma ? " & " : ""][plasma ? "Plasma" : ""] at [ADMIN_VERBOSEJMP(src)]")
					log_admin("[key_name(usr)] turned on a pump that contains [n2o ? "N2O" : ""][n2o && plasma ? " & " : ""][plasma ? "Plasma" : ""] at [AREACOORD(src)]")
			else if(on && direction == PUMP_OUT)
				usr.investigate_log(" started a transfer into [holding].", INVESTIGATE_ATMOS)
			. = TRUE
		if("direction")
			if(direction == PUMP_OUT)
				direction = PUMP_IN
			else
				if(on && holding)
					usr.investigate_log(" started a transfer into [holding].", INVESTIGATE_ATMOS)
				direction = PUMP_OUT
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = PUMP_DEFAULT_PRESSURE
				. = TRUE
			else if(pressure == "min")
				pressure = PUMP_MIN_PRESSURE
				. = TRUE
			else if(pressure == "max")
				pressure = PUMP_MAX_PRESSURE
				. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				target_pressure = clamp(pressure, PUMP_MIN_PRESSURE, PUMP_MAX_PRESSURE)
				investigate_log("was set to [target_pressure] kPa by [key_name(usr)].", INVESTIGATE_ATMOS)
		if("eject")
			if(holding)
				replace_tank(usr, FALSE)
				. = TRUE
	update_icon()

/obj/machinery/portable_atmospherics/pump/unregister_holding()
	on = FALSE
	return ..()

//////////////////////////////////////// CIRCUIT STUFFS ///////////////////////////////

/obj/item/circuit_component/portable_pump
	display_name = "Pump Controller"
	desc = "The interface for communicating with a portable pump."

	var/obj/machinery/portable_atmospherics/pump/attached_pump

	var/datum/port/input/turn_on

	var/datum/port/input/turn_off

	var/datum/port/input/pump_in

	var/datum/port/input/pump_out

	var/datum/port/input/target_pressure

/obj/item/circuit_component/portable_pump/populate_ports()
	turn_on = add_input_port("Turn On", PORT_TYPE_SIGNAL)
	turn_off = add_input_port("Turn Off", PORT_TYPE_SIGNAL)

	pump_in = add_input_port("Set pump IN", PORT_TYPE_SIGNAL)
	pump_out = add_input_port("Set pump OUT", PORT_TYPE_SIGNAL)

	target_pressure = add_input_port("Target Pressure", PORT_TYPE_NUMBER)

/obj/item/circuit_component/portable_pump/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/portable_atmospherics/pump))
		attached_pump = shell

/obj/item/circuit_component/portable_pump/unregister_usb_parent(atom/movable/shell)
	attached_pump = null
	return ..()

/obj/item/circuit_component/portable_pump/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!attached_pump)
		return

	if(COMPONENT_TRIGGERED_BY(turn_on, port))
		attached_pump.on = TRUE
		if(attached_pump.holding && (attached_pump.direction == PUMP_IN))
			investigate_log("[parent.get_creator()] started a transfer into [attached_pump.holding].", INVESTIGATE_ATMOS)
	if(COMPONENT_TRIGGERED_BY(turn_off, port))
		attached_pump.on = FALSE
	if(COMPONENT_TRIGGERED_BY(pump_in, port))
		attached_pump.direction = PUMP_IN
	if(COMPONENT_TRIGGERED_BY(pump_out, port))
		attached_pump.direction = PUMP_OUT
	if(COMPONENT_TRIGGERED_BY(target_pressure, port))
		attached_pump.target_pressure = clamp(round(target_pressure), PUMP_MIN_PRESSURE, PUMP_MAX_PRESSURE)
		investigate_log("a portable pump was set to [attached_pump.target_pressure] kPa by [parent.get_creator()].", INVESTIGATE_ATMOS)
