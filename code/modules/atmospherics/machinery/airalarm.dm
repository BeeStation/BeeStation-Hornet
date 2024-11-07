/datum/tlv
	var/min2
	var/min1
	var/max1
	var/max2

/datum/tlv/New(min2 as num, min1 as num, max1 as num, max2 as num)
	if(min2) src.min2 = min2
	if(min1) src.min1 = min1
	if(max1) src.max1 = max1
	if(max2) src.max2 = max2

/datum/tlv/proc/get_danger_level(val as num)
	if(max2 != -1 && val >= max2)
		return 2
	if(min2 != -1 && val <= min2)
		return 2
	if(max1 != -1 && val >= max1)
		return 1
	if(min1 != -1 && val <= min1)
		return 1
	return 0

/datum/tlv/no_checks
	min2 = -1
	min1 = -1
	max1 = -1
	max2 = -1

/datum/tlv/dangerous
	min2 = -1
	min1 = -1
	max1 = 0.2
	max2 = 0.5

/obj/item/electronics/airalarm
	name = "air alarm electronics"
	custom_price = 5
	icon_state = "airalarm_electronics"

/obj/item/wallframe/airalarm
	name = "air alarm frame"
	desc = "Used for building Air Alarms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm_bitem"
	result_path = /obj/machinery/airalarm
	pixel_shift = 24

#define AIRALARM_WARNING_COOLDOWN (10 SECONDS)

/obj/machinery/airalarm
	name = "air alarm"
	desc = "A machine that monitors atmosphere levels and alerts if the area is dangerous."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarmp"
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 8
	power_channel = AREA_USAGE_ENVIRON
	req_access = list(ACCESS_ATMOSPHERICS)
	max_integrity = 250
	integrity_failure = 0.33
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 90, ACID = 30, STAMINA = 0, BLEED = 0)
	resistance_flags = FIRE_PROOF
	clicksound = 'sound/machines/terminal_select.ogg'
	layer = ABOVE_WINDOW_LAYER


	var/danger_level = 0
	var/mode = AALARM_MODE_SCRUBBING

	var/locked = TRUE
	var/aidisabled = 0
	var/shorted = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone

	///Represents a signel source of atmos alarms, complains to all the listeners if one of our thresholds is violated
	var/datum/alarm_handler/alarm_manager

	var/list/TLV = list( // Breathable air.
		"pressure"					= new/datum/tlv(ONE_ATMOSPHERE * 0.8, ONE_ATMOSPHERE*  0.9, ONE_ATMOSPHERE * 1.1, ONE_ATMOSPHERE * 1.2), // kPa. Values are min2, min1, max1, max2
		"temperature"				= new/datum/tlv(T0C, T0C+10, T0C+40, T0C+66),
		/datum/gas/oxygen			= new/datum/tlv(16, 19, 40, 50), // Partial pressure, kpa
		/datum/gas/nitrogen			= new/datum/tlv(-1, -1, 1000, 1000),
		/datum/gas/carbon_dioxide	= new/datum/tlv(-1, -1, 5, 10),
		/datum/gas/plasma			= new/datum/tlv/dangerous,
		/datum/gas/nitrous_oxide	= new/datum/tlv/dangerous,
		/datum/gas/bz				= new/datum/tlv/dangerous,
		/datum/gas/hypernoblium		= new/datum/tlv(-1, -1, 1000, 1000), // Hyper-Noblium is inert and nontoxic
		/datum/gas/water_vapor		= new/datum/tlv/dangerous,
		/datum/gas/tritium			= new/datum/tlv/dangerous,
		/datum/gas/stimulum			= new/datum/tlv/dangerous,
		/datum/gas/nitryl			= new/datum/tlv/dangerous,
		/datum/gas/pluoxium			= new/datum/tlv(-1, -1, 5, 6), // Unlike oxygen, pluoxium does not fuel plasma/tritium fires
	)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/airalarm, 24)
CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/airalarm)
GLOBAL_LIST_EMPTY_TYPED(air_alarms, /obj/machinery/airalarm)

/obj/machinery/airalarm/Initialize(mapload, ndir, nbuild)
	. = ..()
	set_wires(new /datum/wires/airalarm(src))
	if(ndir)
		setDir(ndir)

	if(nbuild)
		buildstage = AIR_ALARM_BUILD_NO_CIRCUIT
		set_panel_open(TRUE)

	if(name == initial(name))
		name = "[get_area_name(src)] Air Alarm"

	tlv_collection = list()
	tlv_collection["pressure"] = new /datum/tlv/pressure
	tlv_collection["temperature"] = new /datum/tlv/temperature

	var/list/cached_gas_info = GLOB.meta_gas_info
	for(var/datum/gas/gas_path as anything in cached_gas_info)
		if(ispath(gas_path, /datum/gas/oxygen))
			tlv_collection[gas_path] = new /datum/tlv/oxygen
		else if(ispath(gas_path, /datum/gas/carbon_dioxide))
			tlv_collection[gas_path] = new /datum/tlv/carbon_dioxide
		else if(cached_gas_info[gas_path][META_GAS_DANGER])
			tlv_collection[gas_path] = new /datum/tlv/dangerous
		else
			tlv_collection[gas_path] = new /datum/tlv/no_checks

	my_area = connected_sensor ? get_area(connected_sensor) : get_area(src)
	alarm_manager = new(src)
	select_mode(src, /datum/air_alarm_mode/filtering, should_apply = FALSE)

	AddElement(/datum/element/connect_loc, atmos_connections)
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/air_alarm_general,
		/obj/item/circuit_component/air_alarm,
		/obj/item/circuit_component/air_alarm_scrubbers,
		/obj/item/circuit_component/air_alarm_vents
	))

	GLOB.air_alarms += src
	find_and_hang_on_wall()
	register_context()
	check_enviroment()

/obj/machinery/airalarm/process()
	if(!COOLDOWN_FINISHED(src, warning_cooldown))
		return

	speak(warning_message)
	COOLDOWN_START(src, warning_cooldown, AIRALARM_WARNING_COOLDOWN)

/obj/machinery/airalarm/Destroy()
	if(my_area)
		my_area = null
	if(connected_sensor)
		UnregisterSignal(connected_sensor, COMSIG_QDELETING)
		UnregisterSignal(connected_sensor.loc, COMSIG_TURF_EXPOSE)
		connected_sensor.connected_airalarm = null
		connected_sensor = null

	QDEL_NULL(alarm_manager)
	GLOB.air_alarms -= src
	return ..()

/obj/machinery/airalarm/proc/check_enviroment()
	var/turf/our_turf = connected_sensor ? get_turf(connected_sensor) : get_turf(src)
	var/datum/gas_mixture/environment = our_turf.return_air()
	if(isnull(environment))
		return
	check_danger(our_turf, environment, environment.temperature)

/obj/machinery/airalarm/proc/get_enviroment()
	var/turf/our_turf = connected_sensor ? get_turf(connected_sensor) : get_turf(src)
	return our_turf.return_air()

/obj/machinery/airalarm/power_change()
	check_enviroment()
	return ..()

/obj/machinery/airalarm/on_enter_area(datum/source, area/area_to_register)
	//were already registered to an area. exit from here first before entering into an new area
	if(!isnull(my_area))
		return
	. = ..()

	my_area = connected_sensor ? get_area(connected_sensor) : area_to_register
	update_icon()

/obj/machinery/airalarm/update_name(updates)
	. = ..()
	name = "[get_area_name(my_area)] Air Alarm"

/obj/machinery/airalarm/on_enter_area(datum/source, area/area_to_register)
	//were already registered to an area. exit from here first before entering into an new area
	if(!isnull(my_area))
		return
	. = ..()

	my_area = connected_sensor ? get_area(connected_sensor) : area_to_register
	update_appearance()

/obj/machinery/airalarm/update_name(updates)
	. = ..()
	name = "[get_area_name(my_area)] Air Alarm"

/obj/machinery/airalarm/on_exit_area(datum/source, area/area_to_unregister)
	//we cannot unregister from an area we never registered to in the first place
	if(my_area != area_to_unregister)
		return
	. = ..()

	my_area = connected_sensor ? get_area(connected_sensor) : null

/obj/machinery/airalarm/examine(mob/user)
	. = ..()
	switch(buildstage)
		if(AIR_ALARM_BUILD_NO_CIRCUIT)
			. += "<span class='notice'>It is missing air alarm electronics.</span>"
		if(AIR_ALARM_BUILD_NO_WIRES)
			. += "<span class='notice'>It is missing wiring.</span>"
		if(AIR_ALARM_BUILD_COMPLETE)
			. += "<span class='notice'>Alt-click to [locked ? "unlock" : "lock"] the interface.</span>"

/obj/machinery/airalarm/ui_status(mob/user, datum/ui_state/state)
	if(HAS_SILICON_ACCESS(user) && aidisabled)
		to_chat(user, "AI control has been disabled.")
	else if(!shorted)
		return ..()
	return UI_CLOSE

/obj/machinery/airalarm/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	.= ..()

	if (!istype(multi_tool) || locked)
		return .

	if(istype(multi_tool.buffer, /obj/machinery/air_sensor))
		var/obj/machinery/air_sensor/sensor = multi_tool.buffer

		if(!allow_link_change)
			balloon_alert(user, "linking disabled")
			return TRUE
		if(connected_sensor || sensor.connected_airalarm)
			balloon_alert(user, "sensor already connected!")
			return TRUE

		connect_sensor(sensor)
		balloon_alert(user, "connected sensor")
		return TRUE

/obj/machinery/airalarm/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/airalarm/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirAlarm")
		ui.open()
		ui.set_autoupdate(TRUE) // Turf gas mixture

/obj/machinery/airalarm/ui_static_data(mob/user)
	var/list/data = list()
	data["thresholdTypeMap"] = list(
		"warning_min" = TLV_VAR_WARNING_MIN,
		"hazard_min" = TLV_VAR_HAZARD_MIN,
		"warning_max" = TLV_VAR_WARNING_MAX,
		"hazard_max" = TLV_VAR_HAZARD_MAX,
		"all" = TLV_VAR_ALL,
	)
	return data

/obj/machinery/airalarm/ui_data(mob/user)
	var/data = list()

	data["locked"] = locked
	data["siliconUser"] = HAS_SILICON_ACCESS(user)
	data["emagged"] = (obj_flags & EMAGGED ? 1 : 0)
	data["dangerLevel"] = danger_level
	data["atmosAlarm"] = !!my_area.active_alarms[ALARM_ATMOS]
	data["fireAlarm"] = my_area.fire
	data["faultStatus"] = my_area.fault_status
	data["faultLocation"] = my_area.fault_location
	data["sensor"] = !!connected_sensor
	data["allowLinkChange"] = allow_link_change

	var/datum/gas_mixture/environment = get_enviroment()
	var/total_moles = environment.total_moles()
	var/temp = environment.temperature
	var/pressure = environment.return_pressure()

	data["envData"] = list()
	if(connected_sensor)
		data["envData"] += list(list(
			"name" = "Linked area",
			"value" = my_area.name
		))
	data["envData"] += list(list(
		"name" = "Pressure",
		"value" = "[round(pressure, 0.01)] kPa",
		"danger" = tlv_collection["pressure"].check_value(pressure)
	))
	data["envData"] += list(list(
		"name" = "Temperature",
		"value" = "[round(temp, 0.01)] Kelvin / [round(temp, 0.01) - T0C] Celcius",
		"danger" = tlv_collection["temperature"].check_value(temp),
	))
	if(total_moles)
		for(var/gas_path in environment.gases)
			var/moles = environment.gases[gas_path][MOLES]
			var/portion = moles / total_moles
			data["envData"] += list(list(
				"name" = GLOB.meta_gas_info[gas_path][META_GAS_NAME],
				"value" = "[round(moles, 0.01)] moles / [round(100 * portion, 0.01)] % / [round(portion * pressure, 0.01)] kPa",
				"danger" = tlv_collection[gas_path].check_value(portion * pressure),
			))

	data["tlvSettings"] = list()
	for(var/threshold in tlv_collection)
		var/datum/tlv/tlv = tlv_collection[threshold]
		var/list/singular_tlv = list()
		if(threshold == "pressure")
			singular_tlv["name"] = "Pressure"
			singular_tlv["unit"] = "kPa"
		else if (threshold == "temperature")
			singular_tlv["name"] = "Temperature"
			singular_tlv["unit"] = "K"
		else
			singular_tlv["name"] = GLOB.meta_gas_info[threshold][META_GAS_NAME]
			singular_tlv["unit"] = "kPa"
		singular_tlv["id"] = threshold
		singular_tlv["warning_min"] = tlv.warning_min
		singular_tlv["hazard_min"] = tlv.hazard_min
		singular_tlv["warning_max"] = tlv.warning_max
		singular_tlv["hazard_max"] = tlv.hazard_max
		data["tlvSettings"] += list(singular_tlv)

	if(!locked || HAS_SILICON_ACCESS(user))
		data["vents"] = list()
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
			data["vents"] += list(list(
				"refID" = REF(vent),
				"long_name" = sanitize(vent.name),
				"power" = vent.on,
				"overclock" = vent.fan_overclocked,
				"integrity" = vent.get_integrity_percentage(),
				"checks" = vent.pressure_checks,
				"excheck" = vent.pressure_checks & ATMOS_EXTERNAL_BOUND,
				"incheck" = vent.pressure_checks & ATMOS_INTERNAL_BOUND,
				"direction" = vent.pump_direction,
				"external" = vent.external_pressure_bound,
				"internal" = vent.internal_pressure_bound,
				"extdefault" = (vent.external_pressure_bound == ONE_ATMOSPHERE),
				"intdefault" = (vent.internal_pressure_bound == 0)
			))
		data["scrubbers"] = list()
		for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
			var/list/filter_types = list()
			for (var/path in GLOB.meta_gas_info)
				var/list/gas = GLOB.meta_gas_info[path]
				filter_types += list(list("gas_id" = gas[META_GAS_ID], "gas_name" = gas[META_GAS_NAME], "enabled" = (path in scrubber.filter_types)))
			data["scrubbers"] += list(list(
				"refID" = REF(scrubber),
				"long_name" = sanitize(scrubber.name),
				"power" = scrubber.on,
				"scrubbing" = scrubber.scrubbing,
				"widenet" = scrubber.widenet,
				"filter_types" = filter_types,
			))

		data["selectedModePath"] = selected_mode.type
		data["modes"] = list()
		for(var/mode_path in GLOB.air_alarm_modes)
			var/datum/air_alarm_mode/mode = GLOB.air_alarm_modes[mode_path]
			if(!(obj_flags & EMAGGED) && mode.emag)
				continue
			data["modes"] += list(list(
				"name" = mode.name,
				"desc" = mode.desc,
				"danger" = mode.danger,
				"path" = mode.type
			))

		// forgive me holy father
		data["panicSiphonPath"] = /datum/air_alarm_mode/panic_siphon
		data["filteringPath"] = /datum/air_alarm_mode/filtering

	return data

/obj/machinery/airalarm/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(. || buildstage != AIR_ALARM_BUILD_COMPLETE)
		return
	if((locked && !usr.has_unlimited_silicon_privilege) || (usr.has_unlimited_silicon_privilege && aidisabled))
		return
	var/area/area = connected_sensor ? get_area(connected_sensor) : get_area(src)

	ASSERT(!isnull(area))

	var/ref = params["ref"]
	var/obj/machinery/atmospherics/components/unary/vent_pump/vent
	var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber
	if(!isnull(ref))
		scrubber = locate(ref) in area.air_scrubbers
		vent = locate(ref) in area.air_vents
	switch (action)
		if ("power")
			var/obj/machinery/atmospherics/components/powering = vent || scrubber
			powering.on = !!params["val"]
			powering.atmos_conditions_changed()
			powering.update_icon()

		if("overclock")
			if(isnull(vent))
				return TRUE
			vent.toggle_overclock(source = key_name(user))
			vent.update_icon()
			return TRUE

		if ("direction")
			if (isnull(vent))
				return TRUE

			var/value = params["val"]

			if (value == ATMOS_DIRECTION_SIPHONING || value == ATMOS_DIRECTION_RELEASING)
				vent.pump_direction = value
				vent.update_icon()
		if ("incheck")
			if (isnull(vent))
				return TRUE

			var/new_checks = clamp((text2num(params["val"]) || 0) ^ ATMOS_INTERNAL_BOUND, NONE, ATMOS_BOUND_MAX)
			vent.pressure_checks = new_checks
			vent.update_icon()
		if ("excheck")
			if (isnull(vent))
				return TRUE

			var/new_checks = clamp((text2num(params["val"]) || 0) ^ ATMOS_EXTERNAL_BOUND, NONE, ATMOS_BOUND_MAX)
			vent.pressure_checks = new_checks
			vent.update_icon()
		if ("set_internal_pressure")
			if (isnull(vent))
				return TRUE

			var/old_pressure = vent.internal_pressure_bound
			var/new_pressure = clamp(text2num(params["value"]), 0, ATMOS_PUMP_MAX_PRESSURE)
			vent.internal_pressure_bound = new_pressure
			if (old_pressure != new_pressure)
				vent.investigate_log("internal pressure was set to [new_pressure] by [key_name(user)]", INVESTIGATE_ATMOS)
		if ("reset_internal_pressure")
			if (isnull(vent))
				return TRUE

			if (vent.internal_pressure_bound != 0)
				vent.internal_pressure_bound = 0
				vent.investigate_log("internal pressure was reset by [key_name(user)]", INVESTIGATE_ATMOS)
		if ("set_external_pressure")
			if (isnull(vent))
				return TRUE

			var/old_pressure = vent.external_pressure_bound
			var/new_pressure = clamp(text2num(params["value"]), 0, ATMOS_PUMP_MAX_PRESSURE)

			if (old_pressure == new_pressure)
				return TRUE

			vent.external_pressure_bound = new_pressure
			vent.investigate_log("external pressure was set to [new_pressure] by [key_name(user)]", INVESTIGATE_ATMOS)
			vent.update_icon()
		if ("reset_external_pressure")
			if (isnull(vent))
				return TRUE

			if (vent.external_pressure_bound == ATMOS_PUMP_MAX_PRESSURE)
				return TRUE

			vent.external_pressure_bound = ATMOS_PUMP_MAX_PRESSURE
			vent.investigate_log("internal pressure was reset by [key_name(user)]", INVESTIGATE_ATMOS)
			vent.update_icon()
		if ("scrubbing")
			if (isnull(scrubber))
				return TRUE

			scrubber.set_scrubbing(!!params["val"], user)
		if ("widenet")
			if (isnull(scrubber))
				return TRUE

			scrubber.set_widenet(!!params["val"])
		if ("toggle_filter")
			if (isnull(scrubber))
				return TRUE

			scrubber.toggle_filters(params["val"])
		if ("mode")
			select_mode(user, text2path(params["mode"]))
			investigate_log("was turned to [selected_mode.name] mode by [key_name(user)]", INVESTIGATE_ATMOS)

		if ("set_threshold")
			var/threshold = text2path(params["threshold"]) || params["threshold"]
			var/datum/tlv/tlv = tlv_collection[threshold]
			if(isnull(tlv))
				return
			var/threshold_type = params["threshold_type"]
			var/value = params["value"]
			tlv.set_value(threshold_type, value)
			investigate_log("threshold value for [threshold]:[threshold_type] was set to [value] by [key_name(user)]", INVESTIGATE_ATMOS)

			check_enviroment()

		if("reset_threshold")
			var/threshold = text2path(params["threshold"]) || params["threshold"]
			var/datum/tlv/tlv = tlv_collection[threshold]
			if(isnull(tlv))
				return
			var/threshold_type = params["threshold_type"]
			tlv.reset_value(threshold_type)
			investigate_log("threshold value for [threshold]:[threshold_type] was reset by [key_name(user)]", INVESTIGATE_ATMOS)

			check_enviroment()

		if ("alarm")
			if (alarm_manager.send_alarm(ALARM_ATMOS))
				danger_level = AIR_ALARM_ALERT_HAZARD

		if ("reset")
			if (alarm_manager.clear_alarm(ALARM_ATMOS))
				danger_level = AIR_ALARM_ALERT_NONE

		if ("disconnect_sensor")
			if(allow_link_change)
				disconnect_sensor()

		if ("lock")
			togglelock(user)
			return TRUE
	update_appearance()

/obj/machinery/airalarm/update_appearance(updates)
	. = ..()

	if(panel_open || (machine_stat & (NOPOWER|BROKEN)) || shorted)
		set_light(0)
		return

	var/color
	if(danger_level == AIR_ALARM_ALERT_HAZARD)
		color = "#FF0022" // red
	else if(danger_level == AIR_ALARM_ALERT_WARNING || my_area.active_alarms[ALARM_ATMOS])
		color = "#FFAA00" // yellow
	else
		color = "#00FFCC" // teal

	set_light(1.4, 1, color)

/obj/machinery/airalarm/update_icon_state()
	if(panel_open)
		switch(buildstage)
			if(AIR_ALARM_BUILD_COMPLETE)
				icon_state = "alarmx"
			if(AIR_ALARM_BUILD_NO_WIRES)
				icon_state = "alarm_b2"
			if(AIR_ALARM_BUILD_NO_CIRCUIT)
				icon_state = "alarm_b1"
		return ..()

	icon_state = isnull(connected_sensor) ? "alarmp" : "alarmp_remote"
	return ..()

/obj/machinery/airalarm/update_overlays()
	. = ..()

	if(panel_open || (machine_stat & (NOPOWER|BROKEN)) || shorted)
		return

	var/state
	if(danger_level == AIR_ALARM_ALERT_HAZARD)
		state = "alarm1"
	else if(danger_level == AIR_ALARM_ALERT_WARNING || my_area.active_alarms[ALARM_ATMOS])
		state = "alarm2"
	else
		state = "alarm0"

	. += mutable_appearance(icon, state)
	. += emissive_appearance(icon, state, src, alpha = src.alpha)


/// Check the current air and update our danger level.
/// [/obj/machinery/airalarm/var/danger_level]
/obj/machinery/airalarm/proc/check_danger(turf/location, datum/gas_mixture/environment, exposed_temperature)
	SIGNAL_HANDLER
	if((machine_stat & (NOPOWER|BROKEN)) || shorted)
		return

	if(!environment)
		return

	var/old_danger = danger_level
	danger_level = AIR_ALARM_ALERT_NONE

	var/total_moles = environment.total_moles()
	var/pressure = environment.return_pressure()
	var/temp = environment.return_temperature()

	danger_level = max(danger_level, tlv_collection["pressure"].check_value(pressure))
	danger_level = max(danger_level, tlv_collection["temperature"].check_value(temp))
	if(total_moles)
		var/list/cached_gas_info = GLOB.meta_gas_info
		for(var/datum/gas/gas_path as anything in cached_gas_info)
			var/moles = environment.gases[gas_path] ? environment.gases[gas_path][MOLES] : 0
			danger_level = max(danger_level, tlv_collection[gas_path].check_value(pressure * moles / total_moles))

	if(danger_level)
		alarm_manager.send_alarm(ALARM_ATMOS)
		var/is_high_pressure = tlv_collection["pressure"].hazard_max != TLV_VALUE_IGNORE && pressure >= tlv_collection["pressure"].hazard_max
		var/is_high_temp = tlv_collection["temperature"].hazard_max != TLV_VALUE_IGNORE && temp >= tlv_collection["temperature"].hazard_max
		var/is_low_pressure = tlv_collection["pressure"].hazard_min != TLV_VALUE_IGNORE && pressure <= tlv_collection["pressure"].hazard_min
		var/is_low_temp = tlv_collection["temperature"].hazard_min != TLV_VALUE_IGNORE && temp <= tlv_collection["temperature"].hazard_min

		if(is_low_pressure && is_low_temp)
			warning_message = "Danger! Low pressure and temperature detected."
			return
		if(is_low_pressure && is_high_temp)
			warning_message = "Danger! Low pressure and high temperature detected."
			return
		if(is_high_pressure && is_high_temp)
			warning_message = "Danger! High pressure and temperature detected."
			return
		if(is_high_pressure && is_low_temp)
			warning_message = "Danger! High pressure and low temperature detected."
			return
		if(is_low_pressure)
			warning_message = "Danger! Low pressure detected."
			return
		if(is_high_pressure)
			warning_message = "Danger! High pressure detected."
			return
		if(is_low_temp)
			warning_message = "Danger! Low temperature detected."
			return
		if(is_high_temp)
			warning_message = "Danger! High temperature detected."
			return
		else
			warning_message = null

	else
		alarm_manager.clear_alarm(ALARM_ATMOS)
		warning_message = null

	if(old_danger != danger_level)
		update_appearance()

	selected_mode.replace(my_area, pressure)

/obj/machinery/airalarm/proc/select_mode(atom/source, datum/air_alarm_mode/mode_path, should_apply = TRUE)
	var/datum/air_alarm_mode/new_mode = GLOB.air_alarm_modes[mode_path]
	if(!new_mode)
		return
	if(new_mode.emag && !(obj_flags & EMAGGED))
		return
	selected_mode = new_mode
	if(should_apply)
		selected_mode.apply(my_area)
	SEND_SIGNAL(src, COMSIG_AIRALARM_UPDATE_MODE, source)

/obj/machinery/airalarm/proc/speak(warning_message)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(!speaker_enabled)
		return
	if(!warning_message)
		return

	say(warning_message)

/// Used for unlocked air alarm helper, which unlocks the air alarm.
/obj/machinery/airalarm/proc/unlock()
	locked = FALSE

/// Used for syndicate_access air alarm helper, which sets air alarm's required access to syndicate_access.
/obj/machinery/airalarm/proc/give_syndicate_access()
	req_access = list(ACCESS_SYNDICATE)

///Used for away_general_access air alarm helper, which set air alarm's required access to away_general_access.
/obj/machinery/airalarm/proc/give_away_general_access()
	req_access = list(ACCESS_AWAY_GENERAL)

///Used for engine_access air alarm helper, which set air alarm's required access to away_general_access.
/obj/machinery/airalarm/proc/give_engine_access()
	name = "engine air alarm"
	locked = FALSE
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_ENGINEERING)

///Used for mixingchamber_access air alarm helper, which set air alarm's required access to away_general_access.
/obj/machinery/airalarm/proc/give_mixingchamber_access()
	name = "chamber air alarm"
	locked = FALSE
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_ORDNANCE)

///Used for all_access air alarm helper, which set air alarm's required access to null.
/obj/machinery/airalarm/proc/give_all_access()
	name = "all-access air alarm"
	desc = "This particular atmos control unit appears to have no access restrictions."
	locked = FALSE
	req_access = null
	req_one_access = null

///Used for air alarm cold room tlv helper, which sets cold room temperature and pressure alarm thresholds
/obj/machinery/airalarm/proc/set_tlv_cold_room()
	tlv_collection["temperature"] = new /datum/tlv/cold_room_temperature
	tlv_collection["pressure"] = new /datum/tlv/cold_room_pressure

///Used for air alarm no tlv helper, which removes alarm thresholds
/obj/machinery/airalarm/proc/set_tlv_no_checks()
	tlv_collection["temperature"] = new /datum/tlv/no_checks
	tlv_collection["pressure"] = new /datum/tlv/no_checks

	for(var/gas_path in GLOB.meta_gas_info)
		tlv_collection[gas_path] = new /datum/tlv/no_checks

///Used for air alarm link helper, which connects air alarm to a sensor with corresponding chamber_id
/obj/machinery/airalarm/proc/setup_chamber_link()
	var/obj/machinery/air_sensor/sensor = GLOB.objects_by_id_tag[GLOB.map_loaded_sensors[air_sensor_chamber_id]]
	if(isnull(sensor))
		log_mapping("[src] at [AREACOORD(src)] tried to connect to a sensor, but no sensor with chamber_id:[air_sensor_chamber_id] found!")
		return
	if(connected_sensor)
		log_mapping("[src] at [AREACOORD(src)] tried to connect to more than one sensor!")
		return
	connect_sensor(sensor)

///Used to connect air alarm with a sensor
/obj/machinery/airalarm/proc/connect_sensor(obj/machinery/air_sensor/sensor)
	sensor.connected_airalarm = src
	connected_sensor = sensor

	RegisterSignal(connected_sensor, COMSIG_QDELETING, PROC_REF(disconnect_sensor))

	// Transfer signal from air alarm to sensor
	UnregisterSignal(loc, COMSIG_TURF_EXPOSE)
	RegisterSignal(connected_sensor.loc, COMSIG_TURF_EXPOSE, PROC_REF(check_danger), override=TRUE)

	my_area = get_area(connected_sensor)

	check_enviroment()

	update_appearance()
	update_name()

///Used to reset the air alarm to default configuration after disconnecting from air sensor
/obj/machinery/airalarm/proc/disconnect_sensor()
	UnregisterSignal(connected_sensor, COMSIG_QDELETING)

	// Transfer signal from sensor to air alarm
	UnregisterSignal(connected_sensor.loc, COMSIG_TURF_EXPOSE)
	RegisterSignal(loc, COMSIG_TURF_EXPOSE, PROC_REF(check_danger), override=TRUE)

	connected_sensor.connected_airalarm = null
	connected_sensor = null
	my_area = get_area(src)

	check_enviroment()

	update_appearance()
	update_name()

/obj/machinery/airalarm/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if((buildstage == AIR_ALARM_BUILD_NO_CIRCUIT) && (the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
	return FALSE

/obj/machinery/airalarm/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			user.visible_message("<span class='notice'>[user] fabricates a circuit and places it into [src].</span>", \
			"<span class='notice'>You adapt an air alarm circuit and slot it into the assembly.</span>")
			buildstage = AIR_ALARM_BUILD_NO_WIRES
			update_icon()
			return TRUE
	return FALSE

/obj/machinery/airalarm/server // No checks here.
	TLV = list(
		"pressure"					= new/datum/tlv/no_checks,
		"temperature"				= new/datum/tlv/no_checks,
		/datum/gas/oxygen			= new/datum/tlv/no_checks,
		/datum/gas/nitrogen			= new/datum/tlv/no_checks,
		/datum/gas/carbon_dioxide	= new/datum/tlv/no_checks,
		/datum/gas/plasma			= new/datum/tlv/no_checks,
		/datum/gas/nitrous_oxide	= new/datum/tlv/no_checks,
		/datum/gas/bz				= new/datum/tlv/no_checks,
		/datum/gas/hypernoblium		= new/datum/tlv/no_checks,
		/datum/gas/water_vapor		= new/datum/tlv/no_checks,
		/datum/gas/tritium			= new/datum/tlv/no_checks,
		/datum/gas/stimulum			= new/datum/tlv/no_checks,
		/datum/gas/nitryl			= new/datum/tlv/no_checks,
		/datum/gas/pluoxium			= new/datum/tlv/no_checks
	)

/obj/machinery/airalarm/kitchen_cold_room // Kitchen cold rooms start off at -20°C or 253.15 K.
	TLV = list(
		"pressure"					= new/datum/tlv(ONE_ATMOSPHERE * 0.8, ONE_ATMOSPHERE*  0.9, ONE_ATMOSPHERE * 1.1, ONE_ATMOSPHERE * 1.2), // kPa
		"temperature"				= new/datum/tlv(T0C-273.15, T0C-80, T0C-10, T0C+10),
		/datum/gas/oxygen			= new/datum/tlv(16, 19, 135, 140), // Partial pressure, kpa
		/datum/gas/nitrogen			= new/datum/tlv(-1, -1, 1000, 1000),
		/datum/gas/carbon_dioxide	= new/datum/tlv(-1, -1, 5, 10),
		/datum/gas/plasma			= new/datum/tlv/dangerous,
		/datum/gas/nitrous_oxide	= new/datum/tlv/dangerous,
		/datum/gas/bz				= new/datum/tlv/dangerous,
		/datum/gas/hypernoblium		= new/datum/tlv(-1, -1, 1000, 1000), // Hyper-Noblium is inert and nontoxic
		/datum/gas/water_vapor		= new/datum/tlv/dangerous,
		/datum/gas/tritium			= new/datum/tlv/dangerous,
		/datum/gas/stimulum			= new/datum/tlv/dangerous,
		/datum/gas/nitryl			= new/datum/tlv/dangerous,
		/datum/gas/pluoxium			= new/datum/tlv(-1, -1, 1000, 1000) // Unlike oxygen, pluoxium does not fuel plasma/tritium fires
	)

/obj/machinery/airalarm/unlocked
	locked = FALSE

/obj/machinery/airalarm/engine
	name = "engine air alarm"
	locked = FALSE
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_ENGINE)

/obj/machinery/airalarm/mixingchamber
	name = "chamber air alarm"
	locked = FALSE
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_TOX, ACCESS_TOX_STORAGE)

/obj/machinery/airalarm/all_access
	name = "all-access air alarm"
	desc = "This particular atmospherics control unit appears to have no access restrictions."
	locked = FALSE
	req_access = null
	req_one_access = null

/obj/machinery/airalarm/syndicate //general syndicate access
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/airalarm/away //general away mission access
	req_access = list(ACCESS_AWAY_GENERAL)

///////////////////////////// CIRCUIT COMPONENTS ///////////////////////////////////////

/obj/item/circuit_component/air_alarm
	display_name = "Air Alarm"
	desc = "Controls levels of gases and their temperature as well as all vents and scrubbers in the room."

	var/datum/port/input/option/air_alarm_options

	var/datum/port/input/min_2
	var/datum/port/input/min_1
	var/datum/port/input/max_1
	var/datum/port/input/max_2

	var/datum/port/input/request_data

	var/datum/port/output/pressure
	var/datum/port/output/temperature
	var/datum/port/output/gas_amount

	var/obj/machinery/airalarm/connected_alarm
	var/list/options_map

/obj/item/circuit_component/air_alarm/populate_ports()
	min_2 = add_input_port("Min 2", PORT_TYPE_NUMBER)
	min_1 = add_input_port("Min 1", PORT_TYPE_NUMBER)
	max_1 = add_input_port("Max 1", PORT_TYPE_NUMBER)
	max_2 = add_input_port("Max 2", PORT_TYPE_NUMBER)
	request_data = add_input_port("Request Atmosphere Data", PORT_TYPE_SIGNAL)

	pressure = add_output_port("Pressure", PORT_TYPE_NUMBER)
	temperature = add_output_port("Temperature", PORT_TYPE_NUMBER)
	gas_amount = add_output_port("Chosen Gas Amount", PORT_TYPE_NUMBER)

/obj/item/circuit_component/air_alarm/populate_options()
	var/static/list/component_options

	if(!component_options)
		component_options = list(
			"Pressure" = "pressure",
			"Temperature" = "temperature"
		)

		for(var/gas in subtypesof(/datum/gas))
			component_options[GLOB.meta_gas_info[gas][META_GAS_NAME]] = GLOB.meta_gas_info[gas][META_GAS_ID]

	air_alarm_options = add_option_port("Air Alarm Options", component_options)
	options_map = component_options

/obj/item/circuit_component/air_alarm/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/airalarm))
		connected_alarm = parent

/obj/item/circuit_component/air_alarm/unregister_usb_parent(atom/movable/parent)
	connected_alarm = null
	return ..()

/obj/item/circuit_component/air_alarm/input_received(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	var/current_option = air_alarm_options.value

	if(COMPONENT_TRIGGERED_BY(request_data, port))
		var/turf/alarm_turf = get_turf(connected_alarm)
		var/datum/gas_mixture/environment = alarm_turf.return_air()
		pressure.set_output(round(environment.return_pressure()))
		temperature.set_output(round(environment.return_temperature()))
		if(ispath(options_map[current_option]))
			gas_amount.set_output(round(GET_MOLES(current_option, environment)))
		return

	var/datum/tlv/settings = connected_alarm.TLV[options_map[current_option]]
	settings.min2 = min_2
	settings.min1 = min_1
	settings.max1 = max_1
	settings.max2 = max_2

#undef AIRALARM_WARNING_COOLDOWN
