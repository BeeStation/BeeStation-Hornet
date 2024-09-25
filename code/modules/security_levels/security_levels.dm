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

	//Will not be announced if you try to set to the same level as it already is
	if(level < SEC_LEVEL_GREEN || level > SEC_LEVEL_DELTA || level == GLOB.security_level)
		return
	switch(level)
		if(SEC_LEVEL_GREEN)
			minor_announce(CONFIG_GET(string/alert_green), "Attention! Security level lowered to green:")
			if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
				if(GLOB.security_level >= SEC_LEVEL_RED)
					SSshuttle.emergency.modTimer(4)
				else
					SSshuttle.emergency.modTimer(2)

		if(SEC_LEVEL_BLUE)
			if(GLOB.security_level < SEC_LEVEL_BLUE)
				minor_announce(CONFIG_GET(string/alert_blue_upto), "Attention! Security level elevated to blue:",1)
				if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
					SSshuttle.emergency.modTimer(0.5)
			else
				minor_announce(CONFIG_GET(string/alert_blue_downto), "Attention! Security level lowered to blue:")
				if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
					SSshuttle.emergency.modTimer(2)

		if(SEC_LEVEL_RED)
			if(GLOB.security_level < SEC_LEVEL_RED)
				minor_announce(CONFIG_GET(string/alert_red_upto), "Attention! Code red!",1)
				if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
					if(GLOB.security_level == SEC_LEVEL_GREEN)
						SSshuttle.emergency.modTimer(0.25)
					else
						SSshuttle.emergency.modTimer(0.5)
			else
				minor_announce(CONFIG_GET(string/alert_red_downto), "Attention! Code red!")

		if(SEC_LEVEL_DELTA)
			minor_announce(CONFIG_GET(string/alert_delta), "Attention! Delta security level reached!",1)
			if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
				if(GLOB.security_level == SEC_LEVEL_GREEN)
					SSshuttle.emergency.modTimer(0.25)
				else if(GLOB.security_level == SEC_LEVEL_BLUE)
					SSshuttle.emergency.modTimer(0.5)

	GLOB.security_level = level
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_SECURITY_ALERT_CHANGE, level)
	SSblackbox.record_feedback("tally", "security_level_changes", 1, get_security_level())
	SSnightshift.check_nightshift()

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
