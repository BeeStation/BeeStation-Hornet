/proc/trigger_clockcult_victory(hostile)
	addtimer(CALLBACK(GLOBAL_PROC, /proc/clockcult_gg), 700)
	sleep(50)
	set_security_level("delta")
	priority_announce("Huge gravitational-energy spike detected emminating from a neutron star near your sector. Event has been determined to be survivable by 0% of life. ESTIMATED TIME UNTIL ENERGY PULSE REACHES [GLOB.station_name]: 56 SECONDS. Godspeed crew, glory to Nanotrasen. -Admiral Telvig.", "Central Command Anomolous Materials Division", 'sound/misc/bloblarm.ogg')
	for(var/client/C in GLOB.clients)
		SEND_SOUND(C, sound('sound/misc/airraid.ogg', 1))
	sleep(500)
	priority_announce("Station [GLOB.station_name] is in the wa#e %o[text2ratvar("YOU WILL SEE THE LIGHT")] action imminent. Glory[text2ratvar(" TO ENG'INE")].","Central Command Anomolous Materials Division", 'sound/machines/alarm.ogg')
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			M.client.color = COLOR_WHITE
			animate(M.client, color=LIGHT_COLOR_CLOCKWORK, time=135)
	sleep(135)
	SSshuttle.registerHostileEnvironment(hostile)
	SSshuttle.lockdown = TRUE
	for(var/mob/M in GLOB.mob_list)
		if(M.client)
			M.client.color = LIGHT_COLOR_CLOCKWORK
			animate(M.client, color=COLOR_WHITE, time=5)
			SEND_SOUND(M, sound(null))
			SEND_SOUND(M, sound('sound/magic/fireball.ogg'))
		if(!is_servant_of_ratvar(M) && isliving(M))
			var/mob/living/L = M
			L.fire_stacks = INFINITY
			L.IgniteMob()
			L.emote("scream")

/proc/clockcult_gg()
	SSticker.force_ending = TRUE
