
/////////////////////////////////////////////////////////////
// GENERAL AIR CONTROL (a.k.a atmos computer)
/////////////////////////////////////////////////////////////
/obj/machinery/computer/atmos_control
	name = "atmospherics monitoring"
	desc = "Used to monitor the station's atmospherics sensors."
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/atmos_control
	light_color = LIGHT_COLOR_CYAN

	/// Which sensors do we want to listen to.
	/// Assoc of list[chamber_id] = readable_chamber_name
	var/list/atmos_chambers

	/// Whether we can actually adjust the chambers or not.
	var/control = TRUE
	/// Whether we are allowed to reconnect.
	var/reconnecting = TRUE

	/// Was this computer multitooled before. If so copy the list connected_sensors as it now maintain's its own sensors independent of the map loaded one's
	var/was_multi_tooled = FALSE

	/// list of all sensors[key is chamber id, value is id of air sensor linked to this chamber] monitered by this computer
	var/list/connected_sensors

/obj/machinery/computer/atmos_control/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/buffer)

/// Reconnect only works for station based chambers.
/obj/machinery/computer/atmos_control/proc/reconnect(mob/user)
	if(!reconnecting)
		return FALSE

	// We only prompt the user with the sensors that are actually available.
	var/available_devices = list()

	for (var/chamber_identifier in GLOB.station_gas_chambers)
		if (!("[chamber_identifier]_in" in GLOB.objects_by_id_tag) && !("[chamber_identifier]_out" in GLOB.objects_by_id_tag))
			continue

		available_devices[GLOB.station_gas_chambers[chamber_identifier]] = chamber_identifier

	// As long as we dont put any funny chars in the strings it should match.
	var/new_name = tgui_input_list(user, "Select the device set", "Reconnect", available_devices)
	var/new_id = available_devices[new_name]
	if(isnull(new_id))
		return FALSE

	atmos_chambers = list()
	atmos_chambers[new_id] = new_name
	name = new_name + (control ? " Control" : " Monitor")

	return TRUE

REGISTER_BUFFER_HANDLER(/obj/machinery/air_sensor)

DEFINE_BUFFER_HANDLER(/obj/machinery/air_sensor)
	if(istype(buffer, /obj/machinery/computer/atmos_control))
		to_chat(user, "<span class='notice'>You link [src] with [buffer].</span>")
		var/obj/machinery/computer/atmos_control/sensor = buffer
		if(!was_multi_tooled)
			connected_sensors = connected_sensors.Copy()
			was_multi_tooled = TRUE
			//register the sensor's unique ID with its assositated chamber
			connected_sensors[sensor.chamber_id] = sensor.id_tag
	else if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, "<span class='notice'>You link [src] with [buffer].</span>")
	else
		return NONE
	return COMPONENT_BUFFER_RECEIVED

/obj/machinery/computer/atmos_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosControlConsole")
		ui.open()
		ui.set_autoupdate(TRUE) // Gas sensors

/obj/machinery/computer/atmos_control/ui_static_data(mob/user)
	var/data = list()
	data["maxInput"] = MAX_TRANSFER_RATE
	data["maxOutput"] = MAX_OUTPUT_PRESSURE
	data["control"] = control
	data["reconnecting"] = reconnecting
	return data

/obj/machinery/computer/atmos_control/ui_data(mob/user)
	var/data = list()

	data["chambers"] = list()
	for(var/chamber_id in atmos_chambers)
		var/list/chamber_info = list()
		chamber_info["id"] = chamber_id
		chamber_info["name"] = atmos_chambers[chamber_id]

		var/obj/machinery/sensor = GLOB.objects_by_id_tag["[chamber_id]_sensor"]
		if(!QDELETED(sensor))
			chamber_info["gasmix"] = gas_mixture_parser(sensor.return_air())

		if(istype(sensor, /obj/machinery/air_sensor)) //distro & waste loop are not air sensors and don't have these functions

			var/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/input = GLOB.objects_by_id_tag["[chamber_id]_in"]
			if (!QDELETED(input))
				chamber_info["input_info"] = list(
					"active" = input.on,
					"amount" = input.volume_rate,
				)

			var/obj/machinery/atmospherics/components/unary/vent_pump/output = GLOB.objects_by_id_tag["[chamber_id]_out"]
			if (!QDELETED(output))
				chamber_info["output_info"] = list(
					"active" = output.on,
					"amount" = output.internal_pressure_bound,
				)

		data["chambers"] += list(chamber_info)
	return data
/obj/machinery/computer/atmos_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !(control || reconnecting))
		return

	var/chamber = params["chamber"]

	switch(action)
		if("toggle_input")
			if (!(chamber in atmos_chambers))
				return TRUE

			var/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/input = GLOB.objects_by_id_tag["[chamber]_in"]
			input?.on = !input.on
			input.update_icon()
		if("toggle_output")
			if (!(chamber in atmos_chambers))
				return TRUE

			var/obj/machinery/atmospherics/components/unary/vent_pump/output = GLOB.objects_by_id_tag["[chamber]_out"]
			output?.on = !output.on
			output.update_icon()
		if("adjust_input")
			if (!(chamber in atmos_chambers))
				return TRUE

			var/target = text2num(params["rate"])
			if(isnull(target))
				return TRUE
			target = clamp(target, 0, MAX_TRANSFER_RATE)
			var/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/input = GLOB.objects_by_id_tag["[chamber]_in"]
			input?.volume_rate = clamp(target, 0, min(input.airs[1].volume, MAX_TRANSFER_RATE))
		if("adjust_output")
			var/target = text2num(params["rate"])
			if(isnull(target))
				return TRUE

			var/obj/machinery/atmospherics/components/unary/vent_pump/output = GLOB.objects_by_id_tag["[chamber]_out"]
			output?.internal_pressure_bound = clamp(target, 0, ATMOS_PUMP_MAX_PRESSURE)
		if("reconnect")
			reconnect(usr)

	return TRUE

/////////////////////////////////////////////////////////////
// LARGE TANK CONTROL
/////////////////////////////////////////////////////////////

/obj/machinery/computer/atmos_control/nocontrol
	control = FALSE
	circuit = /obj/item/circuitboard/computer/atmos_control/nocontrol

/obj/machinery/computer/atmos_control/noreconnect
	reconnecting = FALSE
	circuit = /obj/item/circuitboard/computer/atmos_control/noreconnect

/// Vegetable
/obj/machinery/computer/atmos_control/fixed
	control = FALSE
	reconnecting = FALSE
	circuit = /obj/item/circuitboard/computer/atmos_control/fixed
