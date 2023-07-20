/datum/round_event_control/aurora_caelus
	name = "Aurora Caelus"
	typepath = /datum/round_event/aurora_caelus
	max_occurrences = 1
	weight = 1
	earliest_start = 5 MINUTES

/datum/round_event_control/aurora_caelus/canSpawnEvent(players, gamemode)
	if(!CONFIG_GET(flag/starlight))
		return FALSE
	return ..()

/datum/round_event/aurora_caelus
	announceWhen = 1
	startWhen = 9
	endWhen = 50
	var/list/aurora_colors = list("#A2FF80", "#A2FFB6", "#92FFD8", "#8AFFEA", "#72FCFF", "#C6A8FF", "#F89EFF", "#FFA0F1")
	var/aurora_progress = 0 //this cycles from 1 to 8, slowly changing colors from gentle green to gentle blue
	var/list/affected_turfs = list()
	var/starttime

/datum/round_event/aurora_caelus/announce()
	priority_announce("[station_name()]: A harmless cloud of ions is approaching your station, and will exhaust their energy battering the hull. Nanotrasen has approved a short break for all employees to relax and observe this very rare event. During this time, starlight will be bright but gentle, shifting between quiet green and blue colors. Any staff who would like to view these lights for themselves may proceed to the area nearest to them with viewing ports to open space. We hope you enjoy the lights.",
	sound = 'sound/misc/notice2.ogg',
	sender_override = "Nanotrasen Meteorology Division")
	starttime = world.timeofday
	for(var/V in GLOB.player_list)
		var/mob/M = V
		if((M.client.prefs.toggles & PREFTOGGLE_SOUND_MIDI) && is_station_level(M.z))
			M.playsound_local(M, 'sound/ambience/aurora_caelus.ogg', 20, FALSE, pressure_affected = FALSE)
	for(var/atom/window in GLOB.station_windows)
		for(var/turf/T as() in RANGE_TURFS(1, window))
			if(isspaceturf(T) && !(T.starlit))
				T.set_light(1, 1, aurora_colors[7])
				T.starlit = TRUE
				affected_turfs += T

/datum/round_event/aurora_caelus/start()
	if(!length(affected_turfs))
		return
	for(var/atom/A in affected_turfs)
		A.set_light(1.5, 1.5, l_color = aurora_colors[8])
	/*
	for(var/area in GLOB.sortedAreas)
		var/area/A = area
		if(initial(A.dynamic_lighting) == DYNAMIC_LIGHTING_IFSTARLIGHT)
			for(var/turf/open/space/S in A)
				S.set_light(2.5, S.light_power * 2, aurora_colors[1])
				affected_turfs += S
				*/
				//message_admins("Light created at [AREACOORD(S)], telepor -> [ADMIN_VERBOSEJMP(S)]")

/datum/round_event/aurora_caelus/tick()
	if(activeFor % 5 == 0)
		if(aurora_progress < 8)
			aurora_progress++
		if(!length(affected_turfs))
			return
		var/aurora_color = aurora_colors[aurora_progress]
		/*
		for(var/area in GLOB.sortedAreas)
			var/area/A = area
			if(initial(A.dynamic_lighting) == DYNAMIC_LIGHTING_IFSTARLIGHT)
				for(var/turf/open/space/S in A)
					S.set_light(l_color = aurora_color)
		*/
		for(var/atom/A in affected_turfs)
			var/light_modifier = 0
			if(aurora_progress < 5)
				light_modifier = aurora_progress / 10
			else
				light_modifier = 0.5 - aurora_progress / 10
			A.set_light(2 + light_modifier, 2 + light_modifier, l_color = aurora_color)


/datum/round_event/aurora_caelus/end()
	/*
	for(var/area in GLOB.sortedAreas)
		var/area/A = area
		if(initial(A.dynamic_lighting) == DYNAMIC_LIGHTING_IFSTARLIGHT)
			for(var/turf/open/space/S in A)
				fade_to_black(S)
	*/
	if(length(affected_turfs))
		for(var/atom/A in affected_turfs)
			fade_to_black(A)
	priority_announce("The aurora caelus event is now ending. Starlight conditions will slowly return to normal. When this has concluded, please return to your workplace and continue work as normal. Have a pleasant shift, [station_name()], and thank you for watching with us.",
	sound = 'sound/misc/notice2.ogg',
	sender_override = "Nanotrasen Meteorology Division")
	message_admins("Aurora caelus is ending. Start time - [time2text(starttime,"YYYY-MM-DD hh:mm:ss")], end time - [time2text(world.timeofday,"YYYY-MM-DD hh:mm:ss")]")

/datum/round_event/aurora_caelus/proc/fade_to_black(turf/open/space/S)
	set waitfor = FALSE
	var/new_light = initial(S.light_range)
	while(S.light_range > new_light)
		S.set_light(S.light_range - 0.2)
		sleep(30)
	S.set_light(new_light, initial(S.light_power), initial(S.light_color))
	S.starlit = FALSE
