/obj/machinery/computer/shuttle_flight/custom_shuttle
	name = "nanotrasen shuttle flight controller"
	desc = "A terminal used to fly shuttles defined by the Shuttle Zoning Designator"
	circuit = /obj/item/circuitboard/computer/shuttle/flight_control
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list( )
	possible_destinations = "whiteship_home"

	var/list/obj/machinery/shuttle/engine/shuttle_engines = list()
	var/calculated_mass = 0
	var/calculated_dforce = 0
	var/calculated_acceleration = 0
	var/calculated_engine_count = 0
	var/calculated_consumption = 0
	var/calculated_cooldown = 0
	var/calculated_non_operational_thrusters = 0
	var/calculated_fuel_less_thrusters = 0

/obj/machinery/computer/shuttle_flight/custom_shuttle/ui_static_data(mob/user)
	var/list/data = ..()
	calculateStats()
	data["display_fuel"] = TRUE
	return data

/obj/machinery/computer/shuttle_flight/custom_shuttle/ui_data(mob/user)
	var/list/data = ..()
	data["fuel"] = get_fuel()
	data["display_stats"] = list(
		"Shuttle Mass" = "[calculated_mass/10] Tons",
		"Engine Force" = "[calculated_dforce]kN ([calculated_engine_count] engines)",
		"Supercruise Acceleration" = "[calculated_acceleration] ms^-2",
		"Fuel Consumption" = "[calculated_consumption] moles per second",
		"Engine Cooldown" = "[calculated_cooldown] seconds"
	)
	if(calculated_acceleration < 1)
		data["thrust_alert"] = "Insufficient engine power at last callibration. Launch shuttle to recalculate thrust."
	else
		data["thrust_alert"] = 0
	if(calculated_non_operational_thrusters > 0)
		data["damage_alert"] = "[calculated_non_operational_thrusters] thrusters offline."
	else
		data["thrust_alert"] = 0
	return data

/obj/machinery/computer/shuttle_flight/custom_shuttle/launch_shuttle()
	calculateStats()
	if(calculated_acceleration < 1)
		say("Insufficient engine power to engage supercruise.")
		return
	var/datum/orbital_object/shuttle/custom_shuttle/shuttle = ..()
	if(shuttle)
		shuttle.attached_console = src
	return shuttle

//Consumes fuel and reduces thrust of engines that run out of fuel
/obj/machinery/computer/shuttle_flight/custom_shuttle/proc/consume_fuel(var/multiplier = 1)
	//Reset stats
	calculated_dforce = 0
	calculated_acceleration = 0
	calculated_engine_count = 0
	calculated_consumption = 0
	//Consume fuel
	for(var/obj/machinery/shuttle/engine/E as() in shuttle_engines)
		var/valid_thruster = FALSE
		//Void thrusters don't need heaters
		if(E.needs_heater)
			//Check for inop engines
			if(!E.attached_heater)
				continue
			var/obj/machinery/atmospherics/components/unary/shuttle/heater/shuttle_heater = E.attached_heater.resolve()
			if(!shuttle_heater)
				continue
			if(shuttle_heater.dir != E.dir)
				continue
			if(shuttle_heater.panel_open)
				continue
			if(!shuttle_heater.anchored)
				continue
			//Setup correct, check fuel.
			if(shuttle_heater.hasFuel(E.fuel_use * multiplier / shuttle_heater.efficiency_multiplier))
				shuttle_heater.consumeFuel(E.fuel_use * multiplier / shuttle_heater.efficiency_multiplier)
				valid_thruster = TRUE
		else
			valid_thruster = TRUE
		if(valid_thruster)
			calculated_consumption += E.fuel_use
			calculated_dforce += E.thrust
			calculated_engine_count ++
	calculated_acceleration = (calculated_dforce*1000) / (calculated_mass*100)

/obj/machinery/computer/shuttle_flight/custom_shuttle/proc/check_stranded()
	if(!calculated_engine_count && shuttleObject)
		say("Fuel reserves depleted, dropping out of supercruise.")
		if(!shuttleObject.docking_target)
			if(shuttleObject.can_dock_with)
				shuttleObject.commence_docking(shuttleObject.can_dock_with, TRUE)
			else
				//Send shuttle object to random location
				var/datum/orbital_object/z_linked/beacon/z_linked = new /datum/orbital_object/z_linked/beacon/ruin/stranded_shuttle(new /datum/orbital_vector(shuttleObject.position.x, shuttleObject.position.y))
				z_linked.name = "Stranded [shuttleObject]"
				if(!z_linked)
					say("Failed to dethrottle shuttle, please contact a Nanotrasen supervisor.")
					return
				shuttleObject.commence_docking(z_linked, TRUE)
		shuttleObject.docking_frozen = TRUE
		//Dock
		if(!random_drop())
			say("Failed to drop at a random location. Please select a location.")
			shuttleObject.docking_frozen = FALSE
		return TRUE
	return FALSE

/obj/machinery/computer/shuttle_flight/custom_shuttle/proc/get_fuel()
	var/amount = 0
	for(var/obj/machinery/shuttle/engine/E as() in shuttle_engines)
		var/obj/machinery/atmospherics/components/unary/shuttle/heater/shuttle_heater = E.attached_heater?.resolve()
		if(!shuttle_heater)
			continue
		var/datum/gas_mixture/air_contents = shuttle_heater.airs[1]
		var/moles = air_contents.total_moles()
		amount += moles
	return amount

/obj/machinery/computer/shuttle_flight/custom_shuttle/proc/linkShuttle(var/new_id)
	shuttleId = new_id
	shuttlePortId = "[shuttleId]_custom_dock"

/obj/machinery/computer/shuttle_flight/custom_shuttle/proc/calculateStats(var/useFuel = FALSE)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	if(!M)
		return FALSE
	//Reset data
	calculated_mass = 0
	calculated_dforce = 0
	calculated_acceleration = 0
	calculated_engine_count = 0
	calculated_consumption = 0
	calculated_cooldown = 0
	calculated_fuel_less_thrusters = 0
	calculated_non_operational_thrusters = 0
	shuttle_engines = list()
	//Calculate all the data
	var/list/areas = M.shuttle_areas
	for(var/shuttleArea in areas)
		calculated_mass += length(get_area_turfs(shuttleArea))
	for(var/obj/machinery/shuttle/engine/E in GLOB.custom_shuttle_machines)
		if(!(get_area(E) in areas))
			continue
		E.check_setup()
		if(!E.thruster_active)	//Skipover thrusters with no valid heater
			calculated_non_operational_thrusters ++
			continue
		calculated_engine_count++
		calculated_dforce += E.thrust
		calculated_consumption += E.fuel_use
		calculated_cooldown = max(calculated_cooldown, E.cooldown)
		shuttle_engines += E
	//This should really be accelleration, but its a 2d spessman game so who cares
	if(calculated_mass == 0)
		return FALSE
	calculated_acceleration = (calculated_dforce*1000) / (calculated_mass*100)
	return TRUE

/obj/machinery/computer/shuttle_flight/custom_shuttle/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(port && (shuttleId == initial(shuttleId) || override))
		linkShuttle(port.id)
