#define Z_DIST 500
#define CUSTOM_ENGINES_START_TIME 65
#define CALCULATE_STATS_COOLDOWN 2

/obj/machinery/computer/custom_shuttle
	name = "nanotrasen shuttle flight controller"
	desc = "A terminal used to fly shuttles defined by the Shuttle Zoning Designator"
	circuit = /obj/item/circuitboard/computer/shuttle/flight_control
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list( )
	var/shuttleId
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
	var/targetLocation
	var/datum/browser/popup

	var/stat_calc_cooldown = 0

	//Upgrades
	var/distance_multiplier = 1

/obj/machinery/computer/custom_shuttle/examine(mob/user)
	. = ..()
	. += distance_multiplier < 1 ? "Bluespace shortcut module installed. Route is [distance_multiplier]x the original length." : ""

/obj/machinery/computer/custom_shuttle/ui_interact(mob/user)
	var/list/options = params2list(possible_destinations)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "[M ? "Current Location : [M.getStatusText()]" : "Shuttle link required."]<br><br>"
	if(M)
		dat += "<A href='?src=[REF(src)];calculate=1'>Run Flight Calculations</A><br>"
		dat += "<b>Shuttle Data</b><hr>"
		dat += "Shuttle Mass: [calculated_mass/10]tons<br>"
		dat += "Engine Force: [calculated_dforce]kN ([calculated_engine_count] engines)<br>"
		dat += "Sublight Speed: [calculated_speed]ms<sup>-1</sup><br>"
		dat += calculated_speed < 1 ? "<b>INSUFFICIENT ENGINE POWER</b><br>" : ""
		dat += calculated_non_operational_thrusters > 0 ? "<b>Warning: [calculated_non_operational_thrusters] thrusters offline.</b><br>" : ""
		dat += "Fuel Consumption: [calculated_consumption]units per distance<br>"
		dat += "Engine Cooldown: [calculated_cooldown]s<hr>"
		var/destination_found
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!options.Find(S.id))
				continue
			if(!M.check_dock(S, silent=TRUE))
				continue
			if(calculated_speed == 0)
				break
			destination_found = TRUE
			var/dist = round(calculateDistance(S))
			dat += "<A href='?src=[REF(src)];setloc=[S.id]'>Target [S.name] (Dist: [dist] | Fuel Cost: [round(dist * calculated_consumption)] | Time: [round(dist / calculated_speed)])</A><br>"
		if(!destination_found)
			dat += "<B>No valid destinations</B><br>"
		dat += "<hr>[targetLocation ? "Target Location : [targetLocation]" : "No Target Location"]"
		dat += "<hr><A href='?src=[REF(src)];fly=1'>Initate Flight</A><br>"
	dat += "<A href='?src=[REF(user)];mach_close=computer'>Close</a>"

	popup = new(user, "computer", M ? M.name : "shuttle", 350, 450)
	popup.set_content("<center>[dat]</center>")
	popup.open()

/obj/machinery/computer/custom_shuttle/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(!allowed(usr))
		to_chat(usr, "<span class='danger'>Access denied.</span>")
		return

	if(href_list["calculate"])
		calculateStats()
		ui_interact(usr)
		return
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	if(!M)
		return
	if(M.launch_status == ENDGAME_LAUNCHED)
		return
	if(href_list["setloc"])
		SetTargetLocation(href_list["setloc"])
		ui_interact(usr)
		return
	else if(href_list["fly"])
		Fly()
		ui_interact(usr)
		return

/obj/machinery/computer/custom_shuttle/proc/calculateDistance(var/obj/docking_port/stationary/port)
	var/deltaX = port.x - x
	var/deltaY = port.y - y
	var/deltaZ = (port.z - z) * Z_DIST
	return sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ) * distance_multiplier

/obj/machinery/computer/custom_shuttle/proc/linkShuttle(var/new_id)
	shuttleId = new_id
	possible_destinations = "whiteship_home;shuttle[new_id]_custom"

/obj/machinery/computer/custom_shuttle/proc/calculateStats(var/useFuel = FALSE, var/dist = 0, var/ignore_cooldown = FALSE)
	if(!ignore_cooldown && stat_calc_cooldown >= world.time)
		to_chat(usr, "<span>You are using this too fast, please slow down.</span>")
		return
	stat_calc_cooldown = world.time + CALCULATE_STATS_COOLDOWN
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
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

/obj/machinery/computer/custom_shuttle/proc/consumeFuel(var/dist)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
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

/obj/machinery/computer/custom_shuttle/proc/SetTargetLocation(var/newTarget)
	if(!(newTarget in params2list(possible_destinations)))
		log_admin("[usr] attempted to forge a target location through a href exploit on [src]")
		message_admins("[ADMIN_FULLMONTY(usr)] attempted to forge a target location through a href exploit on [src]")
		return
	targetLocation = newTarget
	say("Shuttle route calculated.")
	return

/obj/machinery/computer/custom_shuttle/proc/Fly()
	if(!targetLocation)
		return
	var/obj/docking_port/mobile/linkedShuttle = SSshuttle.getShuttle(shuttleId)
	if(!linkedShuttle)
		return
	if(linkedShuttle.mode != SHUTTLE_IDLE)
		return
	if(!calculateStats(TRUE, 0, TRUE))
		return
	if(calculated_fuel_less_thrusters > 0)
		say("Warning, [calculated_fuel_less_thrusters] do not have enough fuel for this journey, engine output may be limitted.")
	if(calculated_speed < 1)
		say("Insufficient engine power, shuttle requires [calculated_mass / 10]kN of thrust.")
		return
	var/obj/docking_port/stationary/targetPort = SSshuttle.getDock(targetLocation)
	if(!targetPort)
		return
	var/dist = calculateDistance(targetPort)
	var/time = min(max(round(dist / calculated_speed), 10), 90)
	linkedShuttle.callTime = time * 10
	linkedShuttle.rechargeTime = calculated_cooldown
	linkedShuttle.ignitionTime = CUSTOM_ENGINES_START_TIME
	linkedShuttle.count_engines()
	linkedShuttle.hyperspace_sound(HYPERSPACE_WARMUP)
	var/throwForce = CLAMP((calculated_speed / 2) - 5, 0, 10)
	linkedShuttle.movement_force = list("KNOCKDOWN" = calculated_speed > 5 ? 3 : 0, "THROW" = throwForce)
	if(!(targetLocation in params2list(possible_destinations)))
		log_admin("[usr] attempted to launch a shuttle that has been affected by href dock exploit on [src] with target location \"[targetLocation]\"")
		message_admins("[usr] attempted to launch a shuttle that has been affected by href dock exploit on [src] with target location \"[targetLocation]\"")
		return
	switch(SSshuttle.moveShuttle(shuttleId, targetLocation, 1))
		if(0)
			consumeFuel(dist)
			say("Shuttle departing. Please stand away from the doors.")
		if(1)
			to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
		else
			to_chat(usr, "<span class='notice'>Unable to comply.</span>")
	return

/obj/machinery/computer/custom_shuttle/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(port && (shuttleId == initial(shuttleId) || override))
		linkShuttle(port.id)

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
