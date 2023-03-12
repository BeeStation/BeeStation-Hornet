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
	var/radio_channel = RADIO_CHANNEL_COMMAND
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
	var/obj/item/paper/P = new /obj/item/paper(loc)
	P.name = "Silicon Upload key"
	P.info = "Current Upload key is: [GLOB.upload_code]"
	extracting = FALSE
	ui_update()

/obj/machinery/computer/robotics/proc/can_control(mob/user, mob/living/silicon/robot/R)
	. = FALSE
	if(!istype(R))
		return
	if(isAI(user))
		if(R.connected_ai != user)
			return
	if(iscyborg(user))
		if(R != user)
			return
	if(R.scrambledcodes)
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
		var/mob/living/silicon/S = user
		if(S.hack_software)
			data["can_hack"] = TRUE
		data["is_silicon"] = TRUE
	else if(IsAdminGhost(user))
		data["can_hack"] = TRUE

	data["cyborgs"] = list()
	for(var/mob/living/silicon/robot/R in GLOB.silicon_mobs)
		if(!can_control(user, R))
			continue
		if(get_virtual_z_level() != (get_turf(R)).get_virtual_z_level())
			continue
		var/list/cyborg_data = list(
			name = R.name,
			locked_down = R.lockcharge,
			status = R.stat,
			charge = R.cell ? round(R.cell.percent()) : null,
			module = R.module ? "[R.module.name] Module" : "No Module Detected",
			synchronization = R.connected_ai,
			emagged =  R.emagged,
			ref = REF(R)
		)
		data["cyborgs"] += list(cyborg_data)

	data["drones"] = list()
	for(var/mob/living/simple_animal/drone/D in GLOB.drones_list)
		if(D.hacked)
			continue
		if(get_virtual_z_level() != (get_turf(D)).get_virtual_z_level())
			continue
		var/list/drone_data = list(
			name = D.name,
			status = D.stat,
			ref = REF(D)
		)
		data["drones"] += list(drone_data)


	data["uploads"] = list()
	for(var/obj/machinery/computer/upload/U as() in GLOB.uploads_list)
		if(machine_stat & (NOPOWER|BROKEN))
			continue
		if(!(is_station_level(src.z) && is_station_level(U.z)))
			continue
		var/turf/loc = get_turf(U)
		var/list/upload_data = list(
			name = U.name,
			area = "[get_area_name(loc, TRUE)]",
			coords = "[loc.x], [loc.y], [loc.get_virtual_z_level()]",
			ref = REF(U)
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
				var/mob/living/silicon/robot/R = locate(params["ref"]) in GLOB.silicon_mobs
				if(can_control(usr, R) && !..())
					R.self_destruct(usr)
			else
				to_chat(usr, "<span class='danger'>Access Denied.</span>")
		if("stopbot")
			if(allowed(usr))
				var/mob/living/silicon/robot/R = locate(params["ref"]) in GLOB.silicon_mobs
				if(can_control(usr, R) && !..())
					message_admins("<span class='notice'>[ADMIN_LOOKUPFLW(usr)] [!R.lockcharge ? "locked down" : "released"] [ADMIN_LOOKUPFLW(R)]!</span>")
					log_game("[key_name(usr)] [!R.lockcharge ? "locked down" : "released"] [key_name(R)]!")
					log_combat(usr, R, "[!R.lockcharge ? "locked down" : "released"] cyborg")
					R.SetLockdown(!R.lockcharge)
					to_chat(R, "[!R.lockcharge ? "<span class='notice'>Your lockdown has been lifted!" : "<span class='alert'>You have been locked down!"]</span>")
					if(R.connected_ai)
						to_chat(R.connected_ai, "[!R.lockcharge ? "<span class='notice'>NOTICE - Cyborg lockdown lifted" : "<span class='alert'>ALERT - Cyborg lockdown detected"]: <a href='?src=[REF(R.connected_ai)];track=[html_encode(R.name)]'>[R.name]</a></span><br>")
			else
				to_chat(usr, "<span class='danger'>Access Denied.</span>")
		if("magbot")
			var/mob/living/silicon/S = usr
			if((istype(S) && S.hack_software) || IsAdminGhost(usr))
				var/mob/living/silicon/robot/R = locate(params["ref"]) in GLOB.silicon_mobs
				if(istype(R) && !R.emagged && (R.connected_ai == usr || IsAdminGhost(usr)) && !R.scrambledcodes && can_control(usr, R))
					log_game("[key_name(usr)] emagged [key_name(R)] using robotic console!")
					message_admins("[ADMIN_LOOKUPFLW(usr)] emagged cyborg [key_name_admin(R)] using robotic console!")
					R.SetEmagged(TRUE)
					R.logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error
		if("killdrone")
			if(allowed(usr))
				var/mob/living/simple_animal/drone/D = locate(params["ref"]) in GLOB.mob_list
				if(D.hacked)
					to_chat(usr, "<span class='danger'>ERROR: [D] is not responding to external commands.</span>")
				else
					var/turf/T = get_turf(D)
					message_admins("[ADMIN_LOOKUPFLW(usr)] detonated [key_name_admin(D)] at [ADMIN_VERBOSEJMP(T)]!")
					log_game("[key_name(usr)] detonated [key_name(D)]!")
					var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
					s.set_up(3, TRUE, D)
					s.start()
					D.visible_message("<span class='danger'>\the [D] self-destructs!</span>")
					D.gib()
		if("extract")
			if(!GLOB.upload_code)
				GLOB.upload_code = random_code(4)

			message_admins("[ADMIN_LOOKUPFLW(usr)] is extracting the upload key!")
			extracting = TRUE
			ui_update()
			if(allowed(usr))
				say("Credentials successfully verified, commencing extraction.")
				src.timerid = addtimer(CALLBACK(src, PROC_REF(extraction),usr), 300, TIMER_STOPPABLE)
			else
				var/message = "ALERT: UNAUTHORIZED UPLOAD KEY EXTRACTION AT [get_area_name(loc, TRUE)]"
				radio.talk_into(src, message, radio_channel)
				src.timerid = addtimer(CALLBACK(src, PROC_REF(extraction),usr), 600, TIMER_STOPPABLE)




