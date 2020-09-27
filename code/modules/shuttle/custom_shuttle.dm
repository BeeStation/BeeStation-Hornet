#define Z_DIST 500
#define CUSTOM_ENGINES_START_TIME 65
#define CALCULATE_STATS_COOLDOWN 2

/obj/machinery/computer/system_map/custom_shuttle
	name = "nanotrasen shuttle flight controller"
	desc = "A terminal used to fly shuttles defined by the Shuttle Zoning Designator"
	circuit = /obj/item/circuitboard/computer/shuttle/flight_control
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list( )
	var/possible_destinations = "whiteship_home"
	var/admin_controlled
	var/no_destination_swap = 0
	var/calculated_mass = 0
	var/calculated_dforce = 0
	var/calculated_speed = 0
	var/calculated_engine_count = 0
	var/calculated_consumption = 0
	var/calculated_cooldown = 0
	var/calculated_non_operational_thrusters = 0
	var/calculated_fuel_less_thrusters = 0
	var/target_fuel_cost = 0

	var/stat_calc_cooldown = 0

	var/distance_multiplier

/obj/machinery/computer/system_map/custom_shuttle/examine(mob/user)
	. = ..()
	. += distance_multiplier < 1 ? "Bluespace shortcut module installed. Route is [distance_multiplier]x the original length." : ""

/obj/machinery/computer/system_map/custom_shuttle/ui_data(mob/user)
	var/list/data = ..()
	data["extra_data"] = list()
	data["extra_data"] += list(list("Shuttle Mass", "[calculated_mass/10] tons"))
	data["extra_data"] += list(list("Engine Force", "[calculated_dforce]kN ([calculated_engine_count] engines)"))
	data["extra_data"] += list(list("Sublight Speed", "[calculated_speed] m/s"))
	data["extra_data"] += list(list("Fuel Consumption", "[calculated_consumption] units per distance"))
	data["extra_data"] += list(list("Engine Cooldown", "[calculated_cooldown] s"))
	if(calculated_non_operational_thrusters > 0)
		data["extra_data"] += list(list("Offline Thrusters", "[calculated_non_operational_thrusters]"))
	if(calculated_speed < 1)
		data["extra_data"] += list(list("Notices", "ENGINE POWER INSUFFICIENT."))
	return data

/obj/machinery/computer/system_map/custom_shuttle/ui_static_data(mob/user)
	var/list/data = ..()
	data["custom_shuttle"] = TRUE
	return data

/obj/machinery/computer/system_map/custom_shuttle/ui_act(action, params)
	var/obj/docking_port/mobile/linkedShuttle = SSshuttle.getShuttle(shuttle_id)
	if(action == "calculate_custom_shuttle")
		calculateStats()
		return
	return ..()

/obj/machinery/computer/system_map/custom_shuttle/calculate_distance_to_stationary_port(obj/docking_port/stationary/port)
	var/obj/docking_port/mobile/linkedShuttle = SSshuttle.getShuttle(shuttle_id)
	var/deltaX = port.x - linkedShuttle.x
	var/deltaY = port.y - linkedShuttle.y
	var/deltaZ = (port.z - linkedShuttle.z) * Z_DIST
	return sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ) * distance_multiplier

/obj/machinery/computer/system_map/custom_shuttle/proc/linkShuttle(var/new_id)
	shuttle_id = new_id
	possible_destinations = "whiteship_home;shuttle[new_id]_custom"
	//Split the possible destination ports
	standard_port_locations = splittext(possible_destinations, ";")

/obj/machinery/computer/system_map/custom_shuttle/proc/calculateStats(var/useFuel = FALSE, var/dist = 0, var/ignore_cooldown = FALSE)
	if(!ignore_cooldown && stat_calc_cooldown >= world.time)
		to_chat(usr, "<span>You are using this too fast, please slow down.</span>")
		return
	stat_calc_cooldown = world.time + CALCULATE_STATS_COOLDOWN
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttle_id)
	if(!M)
		return FALSE
	//Reset data
	calculated_mass = 0
	calculated_dforce = 0
	calculated_speed = 0
	calculated_engine_count = 0
	calculated_consumption = 0
	calculated_cooldown = 0
	calculated_fuel_less_thrusters = 0
	calculated_non_operational_thrusters = 0
	//Calculate all the data
	var/list/areas = M.shuttle_areas
	for(var/shuttleArea in areas)
		calculated_mass += length(get_area_turfs(shuttleArea))
		for(var/obj/machinery/shuttle/engine/E in shuttleArea)
			E.check_setup()
			if(!E.thruster_active)	//Skipover thrusters with no valid heater
				calculated_non_operational_thrusters ++
				continue
			if(E.attached_heater)
				var/obj/machinery/atmospherics/components/unary/shuttle/heater/resolvedHeater = E.attached_heater.resolve()
				if(resolvedHeater && !resolvedHeater.hasFuel(dist * E.fuel_use) && useFuel)
					calculated_fuel_less_thrusters ++
					continue
			calculated_engine_count++
			calculated_dforce += E.thrust
			calculated_consumption += E.fuel_use
			calculated_cooldown = max(calculated_cooldown, E.cooldown)
	//This should really be accelleration, but its a 2d spessman game so who cares
	if(calculated_mass == 0)
		return FALSE
	calculated_speed = (calculated_dforce*1000) / (calculated_mass*100)
	return TRUE

/obj/machinery/computer/system_map/custom_shuttle/proc/consumeFuel(var/dist)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttle_id)
	if(!M)
		return FALSE
	//Calculate all the data
	for(var/obj/machinery/shuttle/engine/shuttle_machine in GLOB.custom_shuttle_machines)
		shuttle_machine.check_setup()
		if(!shuttle_machine.thruster_active)
			continue
		if(get_area(M) != get_area(shuttle_machine))
			continue
		if(shuttle_machine.attached_heater)
			var/obj/machinery/atmospherics/components/unary/shuttle/heater/resolvedHeater = shuttle_machine.attached_heater.resolve()
			if(resolvedHeater && !resolvedHeater.hasFuel(dist * shuttle_machine.fuel_use))
				continue
			resolvedHeater?.consumeFuel(dist * shuttle_machine.fuel_use)
		shuttle_machine.fireEngine()

//=======
//Handles jumping to a random star system (bluespace!)
//=======
/obj/machinery/computer/system_map/custom_shuttle/handle_space_jump(star)
	var/datum/star_system/SS = star
	var/distance = SS.distance_from_center * 500
	if(!can_jump(distance))
		return
	var/time = min(max(round(distance / calculated_speed), 10), 90)
	var/obj/docking_port/mobile/linkedShuttle = SSshuttle.getShuttle(shuttle_id)
	linkedShuttle.callTime = time * 10
	linkedShuttle.rechargeTime = calculated_cooldown
	//We need to find the direction of this console to the port
	linkedShuttle.port_direction = angle2dir(dir2angle(dir) - (dir2angle(linkedShuttle.dir)) + 180)
	linkedShuttle.preferred_direction = NORTH
	linkedShuttle.ignitionTime = CUSTOM_ENGINES_START_TIME
	var/throwForce = CLAMP((calculated_speed / 2) - 5, 0, 10)
	linkedShuttle.movement_force = list("KNOCKDOWN" = calculated_speed > 5 ? 3 : 0, "THROW" = throwForce)
	say("Calculating hyperlane, estimated departure in [LAZYLEN(SSbluespace_exploration.ship_traffic_queue) * 90] seconds.")
	SSbluespace_exploration.request_ship_transit_to(shuttle_id, star)

//=======
//Handles jumping to a specific port (or custom location port)
//=======
/obj/machinery/computer/system_map/custom_shuttle/handle_jump_to_port(static_port_id)
	if(!static_port_id)
		return
	var/obj/docking_port/stationary/targetPort = SSshuttle.getDock(static_port_id)
	if(!targetPort)
		return
	var/dist = calculate_distance_to_stationary_port(targetPort)
	if(!can_jump(dist))
		return
	var/time = min(max(round(dist / calculated_speed), 10), 90)
	var/obj/docking_port/mobile/linkedShuttle = SSshuttle.getShuttle(shuttle_id)
	linkedShuttle.callTime = time * 10
	linkedShuttle.rechargeTime = calculated_cooldown
	linkedShuttle.ignitionTime = CUSTOM_ENGINES_START_TIME
	linkedShuttle.count_engines()
	linkedShuttle.hyperspace_sound(HYPERSPACE_WARMUP)
	var/throwForce = CLAMP((calculated_speed / 2) - 5, 0, 10)
	linkedShuttle.movement_force = list("KNOCKDOWN" = calculated_speed > 5 ? 3 : 0, "THROW" = throwForce)
	if(!(static_port_id in params2list(possible_destinations)))
		log_admin("[usr] attempted to launch a shuttle that has been affected by href dock exploit on [src] with target location \"[static_port_id]\"")
		message_admins("[usr] attempted to launch a shuttle that has been affected by href dock exploit on [src] with target location \"[static_port_id]\"")
		return
	switch(SSshuttle.moveShuttle(shuttle_id, static_port_id, 1))
		if(0)
			consumeFuel(dist)
			say("Shuttle departing. Please stand away from the doors.")
		if(1)
			to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
		else
			to_chat(usr, "<span class='notice'>Unable to comply.</span>")
	return

/obj/machinery/computer/system_map/custom_shuttle/proc/can_jump(distance)
	var/obj/docking_port/mobile/linkedShuttle = SSshuttle.getShuttle(shuttle_id)
	if(!linkedShuttle)
		return FALSE
	if(linkedShuttle.mode != SHUTTLE_IDLE)
		return FALSE
	//Calculate our speed
	if(!calculateStats(FALSE, 0, TRUE))
		return FALSE
	if(calculated_fuel_less_thrusters > 0)
		say("Warning, [calculated_fuel_less_thrusters] do not have enough fuel for this journey, engine output may be limitted.")
	if(calculated_speed < 1)
		say("Insufficient engine power, shuttle requires [calculated_mass / 10]kN of thrust.")
		return FALSE
	//The stuff done here is for fuel consumption
	if(!calculateStats(TRUE, distance, TRUE))
		return FALSE
	return TRUE

/obj/machinery/computer/system_map/custom_shuttle/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(port && (shuttle_id == initial(shuttle_id) || override))
		linkShuttle(port.id)

//Requires manual linking
/obj/machinery/computer/system_map/custom_shuttle/get_attached_shuttle()
	return

//Custom shuttle docker locations
/obj/machinery/computer/camera_advanced/shuttle_docker/custom
	name = "Shuttle Navigation Computer"
	desc = "Used to designate a precise transit location for private ships."
	lock_override = NONE
	whitelist_turfs = list(/turf/open/space,
		/turf/open/lava,
		/turf/open/floor/plating/beach,
		/turf/open/floor/plating/ashplanet,
		/turf/open/floor/plating/asteroid,
		/turf/open/floor/plating/lavaland_baseturf)
	jumpto_ports = list("whiteship_home" = 1)
	view_range = 12
	designate_time = 100
	circuit = /obj/item/circuitboard/computer/shuttle/docker

/obj/machinery/computer/camera_advanced/shuttle_docker/custom/Initialize()
	. = ..()
	GLOB.jam_on_wardec += src

/obj/machinery/computer/camera_advanced/shuttle_docker/custom/Destroy()
	GLOB.jam_on_wardec -= src
	return ..()

/obj/machinery/computer/camera_advanced/shuttle_docker/custom/placeLandingSpot()
	if(!shuttleId)
		return	//Only way this would happen is if someone else delinks the console while in use somehow
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	if(M?.mode != SHUTTLE_IDLE)
		to_chat(usr, "<span class='warning'>You cannot target locations while in transit.</span>")
		return
	..()

/obj/machinery/computer/camera_advanced/shuttle_docker/custom/attack_hand(mob/user)
	if(!shuttleId)
		to_chat(user, "<span class='warning'>You must link the console to a shuttle first.</span>")
		return
	return ..()

/obj/machinery/computer/camera_advanced/shuttle_docker/custom/proc/linkShuttle(new_id)
	shuttleId = new_id
	shuttlePortId = "shuttle[new_id]_custom"

	//Take info from connected port and calculate amendments
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(new_id)
	var/list/shuttlebounds = M.return_coords()
	view_range = min(round(max(M.width, M.height)*0.5), 15)
	x_offset = round((shuttlebounds[1] + shuttlebounds[3])*0.5) - M.x
	y_offset = round((shuttlebounds[2] + shuttlebounds[4])*0.5) - M.y
