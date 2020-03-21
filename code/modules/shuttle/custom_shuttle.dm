#define Z_DIST 1000

/obj/machinery/computer/custom_shuttle
	name = "nanotrasen shuttle flight controller"
	desc = "A terminal used to fly shuttles defined by the Shuttle Zoning Designator"
	circuit = /obj/item/circuitboard/computer/syndicate_shuttle
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list( )
	var/shuttleId
	var/possible_destinations = ""
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
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
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
	return sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)

/obj/machinery/computer/custom_shuttle/proc/linkShuttle(var/new_id)
	shuttleId = new_id
	possible_destinations = "shuttle[new_id]_custom"

/obj/machinery/computer/custom_shuttle/proc/calculateStats(var/useFuel = FALSE, var/dist = 0)
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
		for(var/each in shuttleArea)
			var/atom/atom = each
			if(!atom)
				continue
			calculated_mass ++
			if(!istype(atom, /obj/machinery/shuttle/engine))
				continue
			var/obj/machinery/shuttle/engine/E = atom
			E.check_setup(FALSE)
			if(!E.thruster_active)	//Skipover thrusters with no valid heater
				calculated_non_operational_thrusters ++
				continue
			if(!E.attached_heater.hasFuel(dist * E.fuel_use) && useFuel)
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
	var/list/areas = M.shuttle_areas
	//fix this shitcode plox
	for(var/shuttleArea in areas)
		for(var/each in shuttleArea)
			var/atom/atom = each
			if(!atom)
				continue
			if(!istype(atom, /obj/machinery/shuttle/engine))
				continue
			var/obj/machinery/shuttle/engine/E = atom
			E.check_setup(FALSE)
			if(!E.thruster_active)	//Skipover thrusters with no valid heater
				continue
			if(!E.attached_heater.hasFuel(dist * E.fuel_use))
				continue
			E.attached_heater.consumeFuel(dist * E.fuel_use)

/obj/machinery/computer/custom_shuttle/proc/SetTargetLocation(var/newTarget)
	if(!(newTarget in params2list(possible_destinations)))
		log_admin("[usr] attempted to href dock exploit on [src] with target location \"[newTarget]\"")
		message_admins("[usr] just attempted to href dock exploit on [src] with target location \"[newTarget]\"")
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
	if(!calculateStats(TRUE))
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
	jumpto_ports = list("whiteship_home" = 1)
	view_range = 12
	designate_time = 100

/obj/machinery/computer/camera_advanced/shuttle_docker/custom/attack_hand(mob/user)
	if(!shuttleId)
		to_chat(user, "<span class='warning'>You must link the console to a shuttle first.</span>")
		return
	return ..()

/obj/machinery/computer/camera_advanced/shuttle_docker/custom/proc/linkShuttle(var/new_id)
	shuttleId = new_id
	shuttlePortId = "shuttle[new_id]_custom"
