/*

Passive gate is similar to the regular pump except:
* It doesn't require power
* Can not transfer low pressure to higher pressure (so it's more like a valve where you can control the flow)
* Passes gas when output pressure lower than target pressure

*/

/obj/machinery/atmospherics/components/binary/passive_gate
	icon_state = "passgate_map-3"

	name = "passive gate"
	desc = "A one-way air valve that does not require power. Passes gas when the output pressure is lower than the target pressure."

	can_unwrench = TRUE
	shift_underlay_only = FALSE

	interaction_flags_machine = INTERACT_MACHINE_OFFLINE | INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_SET_MACHINE

	var/target_pressure = ONE_ATMOSPHERE

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

	construction_type = /obj/item/pipe/directional
	pipe_state = "passivegate"




/obj/machinery/atmospherics/components/binary/passive_gate/CtrlClick(mob/user)
	if(can_interact(user))
		on = !on
		update_icon()
		ui_update()
	return ..()

/obj/machinery/atmospherics/components/binary/passive_gate/AltClick(mob/user)
	if(can_interact(user))
		target_pressure = ONE_ATMOSPHERE*100
		balloon_alert(user, "Set to [target_pressure] kPa")
		update_icon()
		ui_update()
	return

/obj/machinery/atmospherics/components/binary/passive_gate/Destroy()
	SSradio.remove_object(src,frequency)
	return ..()

/obj/machinery/atmospherics/components/binary/passive_gate/update_icon_nopipes()
	cut_overlays()
	icon_state = "passgate_off-[set_overlay_offset(piping_layer)]"
	if(on)
		add_overlay(getpipeimage(icon, "passgate_on-[set_overlay_offset(piping_layer)]"))

/obj/machinery/atmospherics/components/binary/passive_gate/process_atmos()
	..()
	if(!on)
		return

	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]
	if(air1.release_gas_to(air2, target_pressure))
		update_parents()

//Radio remote control

/obj/machinery/atmospherics/components/binary/passive_gate/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/binary/passive_gate/proc/broadcast_status()
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


/obj/machinery/atmospherics/components/binary/passive_gate/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/atmospherics/components/binary/passive_gate/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump")
		ui.open()

/obj/machinery/atmospherics/components/binary/passive_gate/ui_data()
	var/data = list()
	data["on"] = on
	data["pressure"] = round(target_pressure)
	data["max_pressure"] = round(ONE_ATMOSPHERE*100)
	return data

/obj/machinery/atmospherics/components/binary/passive_gate/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "max")
				pressure = ONE_ATMOSPHERE*100
				. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				target_pressure = clamp(pressure, 0, ONE_ATMOSPHERE*100)
				investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", INVESTIGATE_ATMOS)
	if(.)
		update_icon()

/obj/machinery/atmospherics/components/binary/passive_gate/atmosinit()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/components/binary/passive_gate/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return

	var/old_on = on //for logging

	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("set_output_pressure" in signal.data)
		target_pressure = clamp(text2num(signal.data["set_output_pressure"]),0,ONE_ATMOSPHERE*100)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", INVESTIGATE_ATMOS)

	if("status" in signal.data)
		broadcast_status()
		return

	broadcast_status()
	update_icon()
	ui_update()

/obj/machinery/atmospherics/components/binary/passive_gate/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/components/binary/passive_gate/can_unwrench(mob/user)
	. = ..()
	if(. && on)
		to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		return FALSE


/obj/machinery/atmospherics/components/binary/passive_gate/layer2
	piping_layer = 2
	icon_state = "passgate_map-2"

/obj/machinery/atmospherics/components/binary/passive_gate/layer4
	piping_layer = 4
	icon_state = "passgate_map-4"
