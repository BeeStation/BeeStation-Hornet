/datum/station_alert
	/// Holder of the datum
	var/holder
	/// List of all alarm types we are listening to
	var/list/alarm_types
	/// Listens for alarms, provides the alarms list for our UI
	var/datum/alarm_listener/listener
	/// Title of our UI
	var/title
	/// If UI will also show and allow jumping to cameras connected to each alert area
	var/camera_view

/datum/station_alert/ui_host(mob/user)
	return holder

/datum/station_alert/New(holder, list/alarm_types, list/listener_z_level, list/listener_areas, title = "Station Alerts", camera_view = FALSE)
	src.holder = holder
	src.alarm_types = alarm_types
	src.title = title
	src.camera_view = camera_view
	listener = new(alarm_types, listener_z_level, listener_areas)

/datum/station_alert/Destroy()
	QDEL_NULL(listener)
	return ..()

/datum/station_alert/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StationAlertConsole", title)
		ui.open()
		ui.set_autoupdate(TRUE)

/// The z-level the map renders. Consoles are bound to one z level and silicons will use the primary one.
/datum/station_alert/proc/get_map_z()
	if(length(listener.allowed_z_levels))
		return listener.allowed_z_levels[1]
	var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	return length(station_levels) ? station_levels[1] : null

/// TGUI sends assets before it asks for payload, so prefer ui_assets as opposed to static :)
/datum/station_alert/ui_assets(mob/user)
	var/map_z = get_map_z()
	if(!isnull(map_z))
		get_minimap_for_z(map_z)
	return list(get_asset_datum(/datum/asset/minimap))

/datum/station_alert/ui_static_data(mob/user)
	var/list/data = list()
	data["map"] = null

	var/map_z = get_map_z()
	if(isnull(map_z))
		return data
	var/datum/minimap/minimap = GLOB.minimaps[map_z]
	if(!minimap)
		return data

	data["map"] = list(
		"url" = SSassets.transport.get_asset_url(minimap.asset_name),
		"width" = minimap.width,
		"height" = minimap.height,
		"areas" = minimap.areas,
	)
	// Static because we derived it entirely from area vars fixed at compile time
	var/list/not_applicable = list()
	for(var/list/map_area as anything in minimap.areas)
		var/area/checked_area = locate(map_area["ref"])
		if(!istype(checked_area))
			continue
		var/list/na = list()
		if(!checked_area.reports_atmosphere())
			na += ALARM_ATMOS
			na += ALARM_FIRE
		if(!checked_area.reports_power())
			na += ALARM_POWER
			na += ALERT_LAYER_GRID
		if(length(na))
			not_applicable[map_area["ref"]] = na
	data["areaNotApplicable"] = not_applicable
	return data

/**
 * Returns an assoc of "status" and "orders".
 *
 * Only areas with something to report get caught in status, so anything missing is fine
 */
/datum/station_alert/proc/get_area_state(datum/minimap/minimap)
	var/list/air_coverage = SSwork_orders.get_air_alarm_coverage()
	var/list/has_working_air_alarm = air_coverage["working"]
	var/list/air_sensors = air_coverage["sensors"]

	var/list/status = list()

	for(var/list/map_area as anything in minimap.areas)
		var/area/checked_area = locate(map_area["ref"])
		if(!istype(checked_area))
			continue

		var/list/entry = null
		for(var/alarm_type in alarm_types)
			if(!checked_area.active_alarms[alarm_type])
				continue
			LAZYINITLIST(entry)
			LAZYADD(entry["alarms"], alarm_type)

		var/power_state = get_apc_state(checked_area.apc)
		if(power_state)
			LAZYINITLIST(entry)
			entry["power"] = power_state

		// Only the dynamic half goes out each tick
		var/list/blind = checked_area.get_coverage_gaps(has_working_air_alarm)
		if(length(blind))
			LAZYINITLIST(entry)
			entry["blind"] = blind

		// Read the air rather than alarm state because alarmcode sucks
		var/pressure = get_area_pressure(air_sensors[checked_area])
		if(!isnull(pressure))
			LAZYINITLIST(entry)
			entry["pressure"] = pressure

		// Undamaged areas just have no integrity field
		var/integrity = SSwork_orders.integrity_current[map_area["ref"]]
		if(!isnull(integrity) && integrity < 100)
			LAZYINITLIST(entry)
			entry["integrity"] = integrity

		if(entry)
			status[map_area["ref"]] = entry

	// KEEP THIS SHIT CENTRAL!!11!! I do not want other consoles having different payloads of what the station looks like.
	return list("status" = status, "orders" = SSwork_orders.get_orders())

/// Pressure at an area's air alarm in kPa, or null while it's inside the safe band
/datum/station_alert/proc/get_area_pressure(obj/machinery/airalarm/sensor)
	if(isnull(sensor))
		return null
	var/datum/gas_mixture/environment = sensor.get_enviroment()
	if(isnull(environment))
		return null
	var/pressure = round(environment.return_pressure())
	if(pressure >= WARNING_LOW_PRESSURE && pressure <= WARNING_HIGH_PRESSURE)
		return null
	return pressure

/// Coarse power bucket for an area's APC. Null when there's nothing worth reporting.
/datum/station_alert/proc/get_apc_state(obj/machinery/power/apc/area_apc)
	// Missing, broken and cell-less APCs are coverage gaps
	if(isnull(area_apc) || (area_apc.machine_stat & BROKEN) || isnull(area_apc.cell))
		return null
	var/charge = area_apc.cell.percent()
	if(charge <= 0)
		return "dead"
	if(charge < 15)
		return "critical"
	if(charge < 50)
		return "low"
	return null

/datum/station_alert/ui_data(mob/user)
	var/list/data = list()
	data["cameraView"] = camera_view

	var/map_z = get_map_z()
	// Deliberately not generating here
	var/datum/minimap/minimap = isnull(map_z) ? null : GLOB.minimaps[map_z]
	var/list/area_state = minimap ? get_area_state(minimap) : null
	data["areaStatus"] = area_state?["status"]
	var/board = !issilicon(user)
	data["workOrders"] = board ? area_state?["orders"] : null
	data["canAssign"] = board && can_assign_work(user)
	var/list/assignable = list()
	if(board)
		for(var/list/member in SSwork_orders.get_department_crew())
			if(member["ckey"] != user?.ckey)
				assignable += list(member)
	data["crew"] = board ? assignable : null
	data["alarms"] = list()
	var/list/nominal_types = alarm_types.Copy()
	var/list/alarms = listener.alarms
	for(var/alarm_type in alarms)
		var/list/alarm_category = list(
			"name" = alarm_type,
			"alerts" = list(),
		)
		var/list/alerts = alarms[alarm_type]
		for(var/alert in alerts)
			var/list/alert_details = alerts[alert]
			alarm_category["alerts"] += list(list(
				"name" = get_area_name(alert_details[1], TRUE),
				// Join key with the schematic
				"areaRef" = REF(alert_details[1]),
				"cameras" = camera_view ? length(alert_details[2]) : null,
				"sources" = camera_view ? length(alert_details[3]) : null,
				"ref" = camera_view ? REF(alert) : null,
			))
		data["alarms"] += list(alarm_category)
		nominal_types -= alarm_type
	if(length(nominal_types))
		for(var/nominal_type in nominal_types)
			var/list/nominal_category = list(
				"name" = nominal_type,
				"alerts" = list(),
			)
			data["alarms"] += list(nominal_category)
	return data

/datum/station_alert/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_claim")
			if(!usr.get_idcard(FALSE))
				return
			var/key = params["key"]
			if(!key)
				return
			var/description = SSwork_orders.known_orders[key]
			if(!description)
				return
			var/claimant = usr.get_work_claimant_name()
			var/datum/work_claim/existing = SSwork_orders.claims[key]
			// Claim it, drop your own, or take over someone else's. Ungated on purpose
			if(existing?.claimant_ckey == usr?.ckey)
				SSwork_orders.resolve_claim(key, WORK_OUTCOME_DROPPED)
				to_chat(usr, span_notice("You take your name off: [description]."))
				// Tell whoever assigned it, so they aren't left thinking it's handled.
				var/mob/assigner = existing.get_assigner_mob()
				if(assigner && assigner != usr)
					to_chat(assigner, span_warning("[existing.claimant] has dropped the work order you assigned: [description]."))
			else
				if(existing)
					var/mob/displaced = existing.get_claimant_mob()
					if(displaced && displaced != usr)
						to_chat(displaced, span_warning("[claimant] has taken over your work order: [description]."))
				SSwork_orders.resolve_claim(key, WORK_OUTCOME_REASSIGNED)
				SSwork_orders.claims[key] = new /datum/work_claim(claimant, usr?.ckey)
				SSblackbox.record_feedback("tally", "work_orders_claimed", 1, "self")
				to_chat(usr, span_notice("You put your name to: [description]."))
			playsound(ui_host(), 'sound/machines/terminal_prompt_confirm.ogg', 40, FALSE)
			return TRUE

		if("assign_order")
			if(!can_assign_work(usr))
				to_chat(usr, span_warning("You are not authorised to direct engineering staff."))
				playsound(ui_host(), 'sound/machines/terminal_prompt_deny.ogg', 40, FALSE)
				return
			var/key = params["key"]
			var/target_ckey = params["ckey"]
			var/description = SSwork_orders.known_orders[key]
			if(!key || !target_ckey || !description)
				return
			var/mob/target = get_mob_by_ckey(target_ckey)
			if(!target)
				to_chat(usr, span_warning("That crewmember is no longer reachable."))
				return

			var/assigner = usr.get_work_claimant_name()
			var/target_name = target.get_work_claimant_name()
			var/datum/work_claim/existing = SSwork_orders.claims[key]
			if(existing?.claimant_ckey == target_ckey)
				to_chat(usr, span_warning("[existing.claimant] already has that job."))
				return
			if(existing)
				var/mob/displaced = existing.get_claimant_mob()
				if(displaced && displaced != target)
					to_chat(displaced, span_warning("[assigner] has reassigned your work order to [target_name]: [description]."))
				SSwork_orders.resolve_claim(key, WORK_OUTCOME_REASSIGNED)

			SSwork_orders.claims[key] = new /datum/work_claim(target_name, target_ckey, assigner, usr?.ckey)
			SSblackbox.record_feedback("tally", "work_orders_claimed", 1, "assigned")
			notify_work_assignment(target, assigner, description)
			to_chat(usr, span_notice("You assign [target_name] to: [description]."))
			playsound(ui_host(), 'sound/machines/terminal_prompt_confirm.ogg', 40, FALSE)
			return TRUE

		if("select_camera")
			var/mob/living/silicon/ai/ai = usr
			if(!istype(ai))
				return

			var/list/alarms = listener.alarms
			var/list/alerts = list()
			for(var/alarm_type in alarms)
				alerts += alarms[alarm_type]

			var/list/our_alert = locate(params["alert"]) in alerts
			if(!length(our_alert))
				return
			var/chosen_alert = alerts[our_alert]
			var/list/cameras = chosen_alert[2]
			if(!length(cameras))
				return
			var/list/named_cameras = list()
			for(var/obj/machinery/camera/camera in cameras)
				named_cameras[camera.c_tag] = camera

			var/chosen_camera
			if(length(named_cameras) == 1)
				chosen_camera = named_cameras[1]
			else
				chosen_camera = tgui_input_list(ai, "Choose a camera to jump to", "Camera Selection", named_cameras)
				if(isnull(chosen_camera))
					return
			var/obj/machinery/camera/selected_camera = named_cameras[chosen_camera]
			if(!selected_camera.can_use())
				to_chat(ai, span_warning("Camera is unavailable!"))
				return
			ai.switchCamera(selected_camera)
			return TRUE
