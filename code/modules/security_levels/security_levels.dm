GLOBAL_VAR_INIT(security_level, SEC_LEVEL_GREEN)
//SEC_LEVEL_GREEN = code green
//SEC_LEVEL_BLUE = code blue
//SEC_LEVEL_RED = code red
//SEC_LEVEL_DELTA = code delta

//config.alert_desc_blue_downto

/proc/set_security_level(level)
	switch(level)
		if("green")
			level = SEC_LEVEL_GREEN
		if("blue")
			level = SEC_LEVEL_BLUE
		if("red")
			level = SEC_LEVEL_RED
		if("delta")
			level = SEC_LEVEL_DELTA
	stop_alert_siren()
	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != GLOB.security_level)
		switch(level)
			if(SEC_LEVEL_GREEN)
				minor_announce(CONFIG_GET(string/alert_green), "Attention! Security level lowered to green:")
				if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
					if(GLOB.security_level >= SEC_LEVEL_RED)
						SSshuttle.emergency.modTimer(4)
					else
						SSshuttle.emergency.modTimer(2)
				GLOB.security_level = SEC_LEVEL_GREEN
				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_level(FA.z))
						FA.update_icon()
			if(SEC_LEVEL_BLUE)
				if(GLOB.security_level < SEC_LEVEL_BLUE)
					minor_announce(CONFIG_GET(string/alert_blue_upto), "Attention! Security level elevated to blue:",1)
					if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
						SSshuttle.emergency.modTimer(0.5)
				else
					minor_announce(CONFIG_GET(string/alert_blue_downto), "Attention! Security level lowered to blue:")
					if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
						SSshuttle.emergency.modTimer(2)
				GLOB.security_level = SEC_LEVEL_BLUE
				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_level(FA.z))
						FA.update_icon()
			if(SEC_LEVEL_RED)
				if(GLOB.security_level < SEC_LEVEL_RED)
					minor_announce(CONFIG_GET(string/alert_red_upto), "Attention! Code red!",1)
					spawn(0)
					start_alert_siren(SEC_LEVEL_RED)
					if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
						if(GLOB.security_level == SEC_LEVEL_GREEN)
							SSshuttle.emergency.modTimer(0.25)
						else
							SSshuttle.emergency.modTimer(0.5)
				else
					minor_announce(CONFIG_GET(string/alert_red_downto), "Attention! Code red!")
				GLOB.security_level = SEC_LEVEL_RED

				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_level(FA.z))
						FA.update_icon()
				for(var/obj/machinery/computer/shuttle_flight/pod/pod in GLOB.machines)
					pod.admin_controlled = 0
			if(SEC_LEVEL_DELTA)
				minor_announce(CONFIG_GET(string/alert_delta), "Attention! Delta security level reached!",1)
				spawn(0)
					start_alert_siren(SEC_LEVEL_DELTA)
				if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
					if(GLOB.security_level == SEC_LEVEL_GREEN)
						SSshuttle.emergency.modTimer(0.25)
					else if(GLOB.security_level == SEC_LEVEL_BLUE)
						SSshuttle.emergency.modTimer(0.5)
				GLOB.security_level = SEC_LEVEL_DELTA
				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_level(FA.z))
						FA.update_icon()
				for(var/obj/machinery/computer/shuttle_flight/pod/pod in GLOB.machines)
					pod.admin_controlled = 0
		if(level >= SEC_LEVEL_RED)
			for(var/obj/machinery/door/D in GLOB.machines)
				if(D.red_alert_access)
					D.visible_message("<span class='notice'>[D] whirs as it automatically lifts access requirements!</span>")
					playsound(D, 'sound/machines/boltsup.ogg', 50, TRUE)
		SSblackbox.record_feedback("tally", "security_level_changes", 1, get_security_level())
		SSnightshift.check_nightshift()
		for(var/obj/machinery/light/light in GLOB.machines)
			if(is_station_level(light.z))
				light.update()
	else
		return

// play a siren sound on red/delta alert with volume depending on the severity
// can be muted by players by setting "play admin midis" to false
// must  be called via spawn since it's blocking
/proc/start_alert_siren(level)
	var/filename
	var/volume
	var/interval

	switch(GLOB.security_level)
		if(SEC_LEVEL_RED)
			filename = 'sound/misc/red_alert.ogg'
			volume = 20
			interval = 20 SECONDS
		if(SEC_LEVEL_DELTA)
			filename = 'sound/misc/delta_alert.ogg'
			volume = 50
			interval = 10 SECONDS
		else
			return	// not happening for non-red or non-delta

	stop_alert_siren() //stop any sirens playing right now

	var/sound/alert_siren_sound = new()
	alert_siren_sound.file = filename
	alert_siren_sound.priority = 250
	alert_siren_sound.channel = CHANNEL_STATION_ALERT_SIREN
	alert_siren_sound.frequency = 1
	alert_siren_sound.wait = TRUE
	alert_siren_sound.repeat = FALSE
	alert_siren_sound.status = SOUND_STREAM
	alert_siren_sound.volume = volume

	do	// play the alert sound as long as the security level is the same as on proc invoke
		for(var/mob/M in GLOB.player_list)
			if(M.client.prefs.toggles & SOUND_MIDI && is_station_level(M.z)) // play only on station and if you have admin midis on
				SEND_SOUND(M, alert_siren_sound)
		sleep(interval)
	while(GLOB.security_level == level)


// stop the siren sounds right now
/proc/stop_alert_siren()
	for(var/mob/M in GLOB.player_list)
		if(!M.client)
			continue
		M.stop_sound_channel(CHANNEL_STATION_ALERT_SIREN)

/proc/get_security_level()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/num2seclevel(num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(seclevel)
	switch( lowertext(seclevel) )
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("delta")
			return SEC_LEVEL_DELTA
