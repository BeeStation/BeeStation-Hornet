// Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.
//
// node1, air1, network1 correspond to input
// node2, air2, network2 correspond to output
//
// Thus, the two variables affect pump operation are set in New():
//   air1.volume
//     This is the volume of gas available to the pump that may be transfered to the output
//   air2.volume
//     Higher quantities of this cause more air to be perfected later
//     but overall network volume is also increased as this increases...

/obj/machinery/atmospherics/components/binary/pump
	icon_state = "pump_map-3"
	name = "gas pump"
	desc = "A pump that moves gas by pressure."

	can_unwrench = TRUE
	shift_underlay_only = FALSE

	var/target_pressure = ONE_ATMOSPHERE

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

	construction_type = /obj/item/pipe/directional
	pipe_state = "pump"

/obj/machinery/atmospherics/components/binary/pump/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/atmos_pump,
	))

/obj/machinery/atmospherics/components/binary/pump/CtrlClick(mob/user)
	if(can_interact(user))
		set_on(!on)
		update_icon()
		ui_update()
	return ..()

/obj/machinery/atmospherics/components/binary/pump/AltClick(mob/user)
	if(can_interact(user))
		target_pressure = MAX_OUTPUT_PRESSURE
		balloon_alert(user, "You set the target pressure to [target_pressure] kPa.")
		update_icon()
		ui_update()
	return


/obj/machinery/atmospherics/components/binary/pump/Destroy()
	SSradio.remove_object(src,frequency)
	if(radio_connection)
		radio_connection = null
	return ..()

/obj/machinery/atmospherics/components/binary/pump/update_icon_nopipes()
	icon_state = "pump_[on && is_operational ? "on" : "off"]-[set_overlay_offset(piping_layer)]"

/obj/machinery/atmospherics/components/binary/pump/process_atmos()
//	..()
	if(!on || !is_operational)
		return
	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]
	var/output_starting_pressure = air2.return_pressure()
	if((target_pressure - output_starting_pressure) < 0.01)
		//No need to pump gas if target is already reached!
		return
	//Calculate necessary moles to transfer using PV=nRT
	if((air1.total_moles() > 0) && (air1.return_temperature()>0))
		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles = pressure_delta*air2.return_volume()/(air1.return_temperature() * R_IDEAL_GAS_EQUATION)

		air1.transfer_to(air2,transfer_moles)

		update_parents()

/obj/machinery/atmospherics/components/binary/pump/proc/set_on(active)
	on = active
	SEND_SIGNAL(src, COMSIG_PUMP_SET_ON, on)

//Radio remote control
/obj/machinery/atmospherics/components/binary/pump/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/binary/pump/proc/broadcast_status()
	if(!radio_connection)
		return

	var/datum/signal/signal = new(list(
		"tag" = id,
		"device" = "AGP",
		"power" = on,
		"target_output" = target_pressure,
		"sigtype" = "status"
	))
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)


/obj/machinery/atmospherics/components/binary/pump/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/atmospherics/components/binary/pump/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump")
		ui.open()

/obj/machinery/atmospherics/components/binary/pump/ui_data()
	var/data = list()
	data["on"] = on
	data["pressure"] = round(target_pressure)
	data["max_pressure"] = round(MAX_OUTPUT_PRESSURE)
	return data

/obj/machinery/atmospherics/components/binary/pump/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			set_on(!on)
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "max")
				pressure = MAX_OUTPUT_PRESSURE
				. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				target_pressure = clamp(pressure, 0, MAX_OUTPUT_PRESSURE)
				investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", INVESTIGATE_ATMOS)
	if(.)
		update_icon()

/obj/machinery/atmospherics/components/binary/pump/atmosinit()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/components/binary/pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return

	var/old_on = on //for logging

	if("power" in signal.data)
		set_on(text2num(signal.data["power"]))

	if("power_toggle" in signal.data)
		set_on(!on)

	if("set_output_pressure" in signal.data)
		target_pressure = clamp(text2num(signal.data["set_output_pressure"]),0,ONE_ATMOSPHERE*50)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", INVESTIGATE_ATMOS)

	if("status" in signal.data)
		broadcast_status()
		return

	broadcast_status()
	update_icon()
	ui_update()

/obj/machinery/atmospherics/components/binary/pump/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/components/binary/pump/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational)
		to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		return FALSE


/obj/machinery/atmospherics/components/binary/pump/layer2
	piping_layer = 2
	icon_state= "pump_map-2"

/obj/machinery/atmospherics/components/binary/pump/layer4
	piping_layer = 4
	icon_state= "pump_map-4"

/obj/machinery/atmospherics/components/binary/pump/on
	on = TRUE
	icon_state = "pump_on_map-3"

/obj/machinery/atmospherics/components/binary/pump/on/layer2
	piping_layer = 2
	icon_state= "pump_on_map-2"

/obj/machinery/atmospherics/components/binary/pump/on/layer4
	piping_layer = 4
	icon_state= "pump_on_map-4"



/obj/item/circuit_component/atmos_pump
	display_name = "Atmospheric Binary Pump"
	desc = "The interface for communicating with a pump."

	///Set the target pressure of the pump
	var/datum/port/input/pressure_value
	///Activate the pump
	var/datum/port/input/on
	///Deactivate the pump
	var/datum/port/input/off
	///Signals the circuit to retrieve the pump's current pressure and temperature
	var/datum/port/input/request_data

	///Pressure of the input port
	var/datum/port/output/input_pressure
	///Pressure of the output port
	var/datum/port/output/output_pressure
	///Temperature of the input port
	var/datum/port/output/input_temperature
	///Temperature of the output port
	var/datum/port/output/output_temperature

	///Whether the pump is currently active
	var/datum/port/output/is_active
	///Send a signal when the pump is turned on
	var/datum/port/output/turned_on
	///Send a signal when the pump is turned off
	var/datum/port/output/turned_off

	///The component parent object
	var/obj/machinery/atmospherics/components/binary/pump/connected_pump

/obj/item/circuit_component/atmos_pump/populate_ports()
	pressure_value = add_input_port("New Pressure", PORT_TYPE_NUMBER, trigger = PROC_REF(set_pump_pressure))
	on = add_input_port("Turn On", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_on))
	off = add_input_port("Turn Off", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_off))
	request_data = add_input_port("Request Port Data", PORT_TYPE_SIGNAL, trigger = PROC_REF(request_pump_data))

	input_pressure = add_output_port("Input Pressure", PORT_TYPE_NUMBER)
	output_pressure = add_output_port("Output Pressure", PORT_TYPE_NUMBER)
	input_temperature = add_output_port("Input Temperature", PORT_TYPE_NUMBER)
	output_temperature = add_output_port("Output Temperature", PORT_TYPE_NUMBER)

	is_active = add_output_port("Active", PORT_TYPE_NUMBER)
	turned_on = add_output_port("Turned On", PORT_TYPE_SIGNAL)
	turned_off = add_output_port("Turned Off", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/atmos_pump/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/atmospherics/components/binary/pump))
		connected_pump = shell
		RegisterSignal(connected_pump, COMSIG_PUMP_SET_ON, PROC_REF(handle_pump_activation))

/obj/item/circuit_component/atmos_pump/unregister_usb_parent(atom/movable/shell)
	UnregisterSignal(connected_pump, COMSIG_PUMP_SET_ON)
	connected_pump = null
	return ..()

/obj/item/circuit_component/atmos_pump/pre_input_received(datum/port/input/port)
	pressure_value.set_value(clamp(pressure_value.value, 0, MAX_OUTPUT_PRESSURE))

/obj/item/circuit_component/atmos_pump/proc/handle_pump_activation(datum/source, active)
	SIGNAL_HANDLER
	is_active.set_output(active)
	if(active)
		turned_on.set_output(COMPONENT_SIGNAL)
	else
		turned_off.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/atmos_pump/proc/set_pump_pressure()
	if(!connected_pump)
		return
	connected_pump.target_pressure = pressure_value.value

/obj/item/circuit_component/atmos_pump/proc/set_pump_on()
	if(!connected_pump)
		return
	connected_pump.set_on(TRUE)

/obj/item/circuit_component/atmos_pump/proc/set_pump_off()
	if(!connected_pump)
		return
	connected_pump.set_on(FALSE)

/obj/item/circuit_component/atmos_pump/proc/request_pump_data()
	if(!connected_pump)
		return
	var/datum/gas_mixture/air_input = connected_pump.airs[1]
	var/datum/gas_mixture/air_output = connected_pump.airs[2]
	input_pressure.set_output(air_input.return_pressure())
	output_pressure.set_output(air_output.return_pressure())
	input_temperature.set_output(air_input.return_temperature())
	output_temperature.set_output(air_output.return_temperature())
