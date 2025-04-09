/obj/machinery/computer/robotics
	name = "robotics control console"
	desc = "Used to remotely lockdown or detonate linked Cyborgs and Drones."
	icon_screen = "robot"
	icon_keyboard = "rd_key"
	req_access = list(ACCESS_RD)
	circuit = /obj/item/circuitboard/computer/robotics
	light_color = LIGHT_COLOR_PINK
	var/extracting = FALSE
	var/obj/item/radio/radio
	var/timerid

/obj/machinery/computer/robotics/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()

/obj/machinery/computer/robotics/Destroy()
	QDEL_NULL(radio)
	if(timerid)
		deltimer(timerid)
	return ..()

/obj/machinery/computer/robotics/proc/extraction(mob/user)
	var/obj/item/paper/paper = new /obj/item/paper(loc)
	paper.name = "Silicon Upload key"
	paper.add_raw_text("Current Upload key is: [GLOB.upload_code]")
	extracting = FALSE
	ui_update()

/obj/machinery/computer/robotics/proc/can_control(mob/user, mob/living/silicon/robot/robot)
	. = FALSE
	if(!istype(robot))
		return
	if(isAI(user))
		if(robot.connected_ai != user)
			return
	if(iscyborg(user))
		if(robot != user)
			return
	if(robot.scrambledcodes)
		return
	return TRUE

/obj/machinery/computer/robotics/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/robotics/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RoboticsControlConsole")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/robotics/ui_data(mob/user)
	var/list/data = list()

	data["can_hack"] = FALSE
	data["is_silicon"] = FALSE
	data["extracting"] = extracting
	if(issilicon(user))
		var/mob/living/silicon/silicon = user
		if(silicon.hack_software)
			data["can_hack"] = TRUE
		data["is_silicon"] = TRUE
	else if(IsAdminGhost(user))
		data["can_hack"] = TRUE

	data["cyborgs"] = list()
	for(var/mob/living/silicon/robot/robot as anything in GLOB.cyborg_list)
		if(!can_control(user, robot))
			continue
		if(get_virtual_z_level() != (get_turf(robot)).get_virtual_z_level())
			continue
		var/list/cyborg_data = list(
			name = robot.name,
			locked_down = robot.lockcharge,
			status = robot.stat,
			charge = robot.cell ? round(robot.cell.percent()) : null,
			module = robot.model ? "[robot.model.name] Model" : "No Model Detected",
			synchronization = robot.connected_ai,
			emagged =  robot.emagged,
			ref = REF(robot)
		)
		data["cyborgs"] += list(cyborg_data)

	data["drones"] = list()
	for(var/mob/living/simple_animal/drone/drone in GLOB.drones_list)
		if(drone.hacked)
			continue
		if(get_virtual_z_level() != (get_turf(drone)).get_virtual_z_level())
			continue
		var/list/drone_data = list(
			name = drone.name,
			status = drone.stat,
			ref = REF(drone)
		)
		data["drones"] += list(drone_data)


	data["uploads"] = list()
	for(var/obj/machinery/computer/upload/upload as() in GLOB.uploads_list)
		if(machine_stat & (NOPOWER|BROKEN))
			continue
		if(!(is_station_level(src.z) && is_station_level(upload.z)))
			continue
		var/turf/loc = get_turf(upload)
		var/list/upload_data = list(
			name = upload.name,
			area = "[get_area_name(loc, TRUE)]",
			coords = "[loc.x], [loc.y], [loc.get_virtual_z_level()]",
			ref = REF(upload)
		)
		data["uploads"] += list(upload_data)

	return data

/obj/machinery/computer/robotics/ui_act(action, params)
	if(..())
		return
	if(extracting)
		say("The machine is busy!")
		return

	switch(action)
		if("killbot")
			if(allowed(usr))
				var/mob/living/silicon/robot/robot = locate(params["ref"]) in GLOB.cyborg_list
				if(can_control(usr, robot) && !..())
					robot.self_destruct(usr)
			else
				to_chat(usr, span_danger("Access Denied."))
		if("stopbot")
			if(allowed(usr))
				var/mob/living/silicon/robot/robot = locate(params["ref"]) in GLOB.cyborg_list
				if(can_control(usr, robot) && !..())
					message_admins(span_notice("[ADMIN_LOOKUPFLW(usr)] [!robot.lockcharge ? "locked down" : "released"] [ADMIN_LOOKUPFLW(robot)]!"))
					log_game("[key_name(usr)] [!robot.lockcharge ? "locked down" : "released"] [key_name(robot)]!")
					log_combat(usr, robot, "[!robot.lockcharge ? "locked down" : "released"] cyborg", important = FALSE)
					robot.SetLockdown(!robot.lockcharge)
					to_chat(robot, "[!robot.lockcharge ? span_notice("Your lockdown has been lifted!") : span_alert("You have been locked down!")]")
					if(robot.connected_ai)
						to_chat(robot.connected_ai, "[!robot.lockcharge ? span_notice("NOTICE - Cyborg lockdown lifted") : span_alert("ALERT - Cyborg lockdown detected")]: <a href='byond://?src=[REF(robot.connected_ai)];track=[html_encode(robot.name)]'>[robot.name]</a><br>")
			else
				to_chat(usr, span_danger("Access Denied."))
		if("magbot")
			var/mob/living/silicon/silicon = usr
			if((istype(silicon) && silicon.hack_software) || IsAdminGhost(usr))
				var/mob/living/silicon/robot/robot = locate(params["ref"]) in GLOB.cyborg_list
				if(istype(robot) && !robot.emagged && (robot.connected_ai == usr || IsAdminGhost(usr)) && !robot.scrambledcodes && can_control(usr, robot))
					log_game("[key_name(usr)] emagged [key_name(robot)] using robotic console!")
					message_admins("[ADMIN_LOOKUPFLW(usr)] emagged cyborg [key_name_admin(robot)] using robotic console!")
					robot.SetEmagged(TRUE)
					robot.logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error
		if("killdrone")
			if(allowed(usr))
				var/mob/living/simple_animal/drone/robot = locate(params["ref"]) in GLOB.mob_list
				if(robot.hacked)
					to_chat(usr, span_danger("ERROR: [robot] is not responding to external commands."))
				else
					var/turf/turf = get_turf(robot)
					message_admins("[ADMIN_LOOKUPFLW(usr)] detonated [key_name_admin(robot)] at [ADMIN_VERBOSEJMP(turf)]!")
					log_game("[key_name(usr)] detonated [key_name(robot)]!")
					var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
					sparks.set_up(3, TRUE, robot)
					sparks.start()
					robot.visible_message(span_danger("\the [robot] self-destructs!"))
					robot.investigate_log("has been gibbed by a robotics console.", INVESTIGATE_DEATHS)
					robot.gib()
		if("extract")
			var/area/current_area = get_area(src)
			if(!GLOB.the_station_areas.Find(current_area.type))
				say("Unable to establish a connection to station.")
				return

			if(!GLOB.upload_code)
				GLOB.upload_code = random_code(4)

			message_admins("[ADMIN_LOOKUPFLW(usr)] is extracting the upload key!")
			extracting = TRUE
			ui_update()

			var/time = 60 SECONDS
			if(allowed(usr))
				say("Credentials successfully verified, commencing extraction.")
				time = 30 SECONDS
			else
				radio.talk_into(src, "ALERT: UNAUTHORIZED UPLOAD KEY EXTRACTION AT [get_area_name(loc, TRUE)]")

			timerid = addtimer(CALLBACK(src, PROC_REF(extraction),usr), time, TIMER_STOPPABLE)

			// Alert silicons
			for(var/mob/player in GLOB.player_list)
				if(player.binarycheck())
					var/message = span_srtradiobinarysay("Robotic Talk, \the [span_name(name)] states, \
						An upload key is being extracted at [get_area_name(loc, TRUE)] \
						and will be finished in [time / (1 SECONDS)] seconds.")
					to_chat(player, message)
