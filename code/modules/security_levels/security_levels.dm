GLOBAL_VAR_INIT(security_level, SEC_LEVEL_GREEN)
//SEC_LEVEL_GREEN = code green
//SEC_LEVEL_BLUE = code blue
//SEC_LEVEL_RED = code red
//SEC_LEVEL_OMEGA = code omega
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
		if("omega")
			level = SEC_LEVEL_OMEGA
		if("delta")
			level = SEC_LEVEL_DELTA

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != GLOB.security_level)
		var/modTimer
		switch(level)
			if(SEC_LEVEL_GREEN)
				minor_announce(CONFIG_GET(string/alert_green), "Attention! Security level lowered to green:")
				if(GLOB.security_level >= SEC_LEVEL_RED)
					modTimer = 4
				else
					modTimer = 2

			if(SEC_LEVEL_BLUE)
				if(GLOB.security_level < SEC_LEVEL_BLUE)
					minor_announce(CONFIG_GET(string/alert_blue_upto), "Attention! Security level elevated to blue:", TRUE)
					modTimer = 0.5
				else
					minor_announce(CONFIG_GET(string/alert_blue_downto), "Attention! Security level lowered to blue:")
					modTimer = 2

			if(SEC_LEVEL_RED)
				if(GLOB.security_level < SEC_LEVEL_RED)
					minor_announce(CONFIG_GET(string/alert_red_upto), "Attention! Code red!", TRUE)
					if(GLOB.security_level == SEC_LEVEL_GREEN)
						modTimer = 0.25
					else
						modTimer = 0.5
				else
					minor_announce(CONFIG_GET(string/alert_red_downto), "Attention! Code red!")
					if(GLOB.security_level == SEC_LEVEL_DELTA)
						modTimer = 2

			if(SEC_LEVEL_OMEGA)
				minor_announce(CONFIG_GET(string/alert_omega), "Attention! Omega security level reached!", TRUE)
				SEND_SOUND(world, 'sound/misc/omega_alert.ogg')
				if(GLOB.security_level < SEC_LEVEL_OMEGA)
					modTimer = 1

			if(SEC_LEVEL_DELTA)
				minor_announce(CONFIG_GET(string/alert_delta), "Attention! Delta security level reached!", TRUE)
				if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
					if(GLOB.security_level == SEC_LEVEL_GREEN)
						modTimer = 0.25
					else if(GLOB.security_level == SEC_LEVEL_BLUE)
						modTimer = 0.5

		GLOB.security_level = level
		for(var/obj/machinery/firealarm/FA in GLOB.machines)
			if(is_station_level(FA.z))
				FA.update_icon()

		if(level >= SEC_LEVEL_RED)
			for(var/obj/machinery/computer/shuttle_flight/pod/pod in GLOB.machines)
				pod.admin_controlled = FALSE
			for(var/obj/machinery/door/D in GLOB.machines)
				if(D.red_alert_access)
					D.visible_message("<span class='notice'>[D] whirrs as it automatically lifts access requirements!</span>")
					playsound(D, 'sound/machines/boltsup.ogg', 50, TRUE)

		if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
			SSshuttle.emergency.modTimer(modTimer)

		SSblackbox.record_feedback("tally", "security_level_changes", 1, get_security_level())
		SSnightshift.check_nightshift()
	else
		return

/proc/get_security_level()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_OMEGA)
			return "omega"
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
		if(SEC_LEVEL_OMEGA)
			return "omega"
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
		if("omega")
			return SEC_LEVEL_OMEGA
		if("delta")
			return SEC_LEVEL_DELTA
