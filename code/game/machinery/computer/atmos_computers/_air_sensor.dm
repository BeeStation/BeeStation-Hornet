/// Gas tank air sensor.
/// These always hook to monitors, be mindful of them
/obj/machinery/air_sensor
	name = "gas sensor"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	resistance_flags = FIRE_PROOF
	power_channel = AREA_USAGE_ENVIRON
	active_power_usage = 1
	var/on = TRUE

	/// The unique string that represents which atmos chamber to associate with.
	var/chamber_id
	/// The inlet[injector] controlled by this sensor
	var/inlet_id
	/// The outlet[vent pump] controlled by this sensor
	var/outlet_id
	/// The air alarm connected to this sensor
	var/obj/machinery/airalarm/connected_airalarm

/obj/machinery/air_sensor/Initialize(mapload)
	id_tag = assign_random_name()

	//this global list of air sensors is available to all station monitering consoles round start and to new consoles made during the round
	if(mapload)
		GLOB.map_loaded_sensors[chamber_id] = id_tag
		inlet_id = CHAMBER_INPUT_FROM_ID(chamber_id)
		outlet_id = CHAMBER_OUTPUT_FROM_ID(chamber_id)

	return ..()

/obj/machinery/air_sensor/Destroy()
	reset()
	return ..()

/obj/machinery/air_sensor/return_air()
	if(!on)
		return
	. = ..()
	use_power = active_power_usage

/obj/machinery/air_sensor/process()
	//update appearance according to power state
	if(machine_stat & NOPOWER)
		if(on)
			on = FALSE
			update_icon()
	else if(!on)
		on = TRUE
		update_icon()

/obj/machinery/air_sensor/examine(mob/user)
	. = ..()
	. += span_notice("Use a multitool to link it to an injector, vent, or air alarm.")
	. += span_notice("You can use a screwdriver to reset its ports.")
	. += span_notice("Click with hand to turn it off.")

/obj/machinery/air_sensor/attack_hand(mob/living/user, list/modifiers)
	. = ..()

	//switched off version of this air sensor but still anchored to the ground
	var/obj/item/air_sensor/sensor = new(drop_location(), inlet_id, outlet_id)
	sensor.set_anchored(TRUE)
	sensor.balloon_alert(user, "sensor turned off")

	//delete self
	qdel(src)

/obj/machinery/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"
	return ..()

/obj/machinery/air_sensor/proc/reset()
	inlet_id = null
	outlet_id = null
	if(connected_airalarm)
		connected_airalarm.disconnect_sensor()
		// if air alarm and sensor were linked at roundstart we allow them to link to new devices
		connected_airalarm.allow_link_change = TRUE
		connected_airalarm = null

///click with multi tool to disconnect everything
/obj/machinery/air_sensor/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	balloon_alert(user, "reset ports")
	reset()
	return TRUE

REGISTER_BUFFER_HANDLER(/obj/machinery/air_sensor)

DEFINE_BUFFER_HANDLER(/obj/machinery/air_sensor)
	if(istype(buffer, /obj/machinery/atmospherics/components/unary/outlet_injector))
		var/obj/machinery/atmospherics/components/unary/outlet_injector/input = buffer
		inlet_id = input.id_tag
		FLUSH_BUFFER(buffer)
		balloon_alert(user, "connected to input")
	else if(istype(buffer, /obj/machinery/atmospherics/components/unary/vent_pump))
		var/obj/machinery/atmospherics/components/unary/vent_pump/output = buffer
		output.disconnect_from_area()
		output.pump_direction = ATMOS_DIRECTION_SIPHONING
		output.pressure_checks = ATMOS_INTERNAL_BOUND
		output.internal_pressure_bound = 4000
		output.external_pressure_bound = 0
		//finally assign it to this sensor
		outlet_id = output.id_tag
		FLUSH_BUFFER(buffer)
		balloon_alert(user, "connected to output")
	else if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, span_notice("You register [src] in [buffer_parent]'s buffer."))
		balloon_alert(user, "added to multitool buffer")
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/**
 * A portable version of the /obj/machinery/air_sensor
 * Wrenching it & turning it on will convert it back to /obj/machinery/air_sensor
 * Unwelding /obj/machinery/air_sensor will turn it back to /obj/item/air_sensor
 * The logic is same as meters
 */
/obj/item/air_sensor
	name = "Air Sensor"
	desc = "A device designed to detect gases and their concentration in an area."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor0"
	custom_materials = list(/datum/material/iron = 100, /datum/material/glass = 100)
	/// The injector linked with this sensor
	var/input_id
	/// The vent pump linked with this sensor
	var/output_id

/obj/item/air_sensor/Initialize(mapload, inlet, outlet)
	. = ..()
	input_id = inlet
	output_id = outlet

/obj/item/air_sensor/examine(mob/user)
	. = ..()
	if(anchored)
		. += span_notice("It's <b>wrenched</b> in place")
	else
		. += span_notice("It should be <b>wrenched</b> in place to turn it on.")
	. +=  span_notice("It could be <b>welded</b> apart.")
	. +=  span_notice("Click with hand to turn it on.")

/obj/item/air_sensor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!anchored)
		return

	//List of air sensor's by name
	var/list/available_sensors = list()
	for(var/chamber_id in GLOB.station_gas_chambers)
		//don't let it conflict with existing distro & waste moniter meter's
		if(chamber_id == ATMOS_GAS_MONITOR_DISTRO)
			continue
		if(chamber_id == ATMOS_GAS_MONITOR_WASTE)
			continue
		available_sensors += GLOB.station_gas_chambers[chamber_id]

	//make the choice
	var/chamber_name = tgui_input_list(user, "Select Sensor Purpose", "Select Sensor ID", available_sensors)
	if(isnull(chamber_name))
		return

	//map chamber name back to id
	var/target_chamber
	for(var/chamber_id in GLOB.station_gas_chambers)
		if(GLOB.station_gas_chambers[chamber_id] != chamber_name)
			continue
		target_chamber = chamber_id
		break

	//build the sensor from the subtypes of sensor's available
	var/static/list/chamber_subtypes = null
	if(isnull(chamber_subtypes))
		chamber_subtypes = subtypesof(/obj/machinery/air_sensor)
	for(var/obj/machinery/air_sensor/sensor as anything in chamber_subtypes)
		if(initial(sensor.chamber_id) != target_chamber)
			continue

		//make real air sensor in its place
		var/obj/machinery/air_sensor/new_sensor = new sensor(get_turf(src))
		new_sensor.inlet_id = input_id
		new_sensor.outlet_id = output_id
		new_sensor.balloon_alert(user, "sensor turned on")
		qdel(src)

		break

/obj/item/air_sensor/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		return TRUE

/obj/item/air_sensor/welder_act(mob/living/user, obj/item/tool)
	if(!tool.tool_start_check(user, amount = 1))
		return TRUE

	loc.balloon_alert(user, "dismantling sensor")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 30, amount = 1))
		return TRUE
	loc.balloon_alert(user, "sensor dismanteled")

	deconstruct(TRUE)
	return TRUE

/obj/item/air_sensor/deconstruct(disassembled)
	. = ..()
	new /obj/item/analyzer(loc)
	new /obj/item/stack/sheet/iron(loc, 1)
