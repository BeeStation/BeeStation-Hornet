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
		balloon_alert(user, "You set the target pressure to [target_pressure] kPa.")
		update_icon()
		ui_update()
	return

/obj/machinery/atmospherics/components/binary/passive_gate/update_icon_nopipes()
	cut_overlays()
	icon_state = "passgate_off-[set_overlay_offset(piping_layer)]"
	if(on)
		add_overlay(get_pipe_image(icon, "passgate_on-[set_overlay_offset(piping_layer)]"))

/obj/machinery/atmospherics/components/binary/passive_gate/process_atmos()
	..()
	if(!on)
		return

	var/datum/gas_mixture/input_air = airs[1]
	var/datum/gas_mixture/output_air = airs[2]
	var/datum/gas_mixture/output_pipenet_air = parents[2].air

	if(input_air.release_gas_to(output_air, target_pressure, output_pipenet_air = output_pipenet_air))
		update_parents()

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

/obj/machinery/atmospherics/components/binary/passive_gate/can_unwrench(mob/user)
	. = ..()
	if(. && on)
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE


/obj/machinery/atmospherics/components/binary/passive_gate/layer2
	piping_layer = 2
	icon_state = "passgate_map-2"

/obj/machinery/atmospherics/components/binary/passive_gate/layer4
	piping_layer = 4
	icon_state = "passgate_map-4"
