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
	startWhen = 6
	endWhen = 50
	var/list/aurora_colors = list("#A2FF80", "#A2FFB6", "#92FFD8", "#8AFFEA", "#72FCFF", "#C6A8FF", "#F89EFF", "#FFA0F1")
	var/aurora_progress = 0 //this cycles from 1 to 8, slowly changing colors from gentle green to gentle blue
	var/list/affected_turfs = list()

/datum/round_event/aurora_caelus/announce()
	priority_announce("[station_name()]: A harmless cloud of ions is approaching your station, and will exhaust their energy battering the hull. Nanotrasen has approved a short break for all employees to relax and observe this very rare event. During this time, starlight will be bright but gentle, shifting between quiet green, blue and purple colors. Any staff who would like to view these lights for themselves may proceed to the area nearest to them with viewing ports to open space. We hope you enjoy the lights.",
	sound = 'sound/misc/notice2.ogg',
	sender_override = "Nanotrasen Meteorology Division")
	INVOKE_ASYNC(src, PROC_REF(play_sound_to_all_station_players))
	INVOKE_ASYNC(src, PROC_REF(create_starlights), 1.5, 0.1, aurora_colors[7])
	create_starlights()

/datum/round_event/aurora_caelus/start()
	if(!length(affected_turfs))
		return
	INVOKE_ASYNC(src, PROC_REF(update_starlights), 2, 0.2, aurora_colors[8])
	INVOKE_ASYNC(src, PROC_REF(create_starlights), 2, 0.2, aurora_colors[8])

/datum/round_event/aurora_caelus/tick()
	if(activeFor % 5 == 0)
		if(aurora_progress < 8)
			aurora_progress++
		if(!length(affected_turfs))
			return
		var/aurora_color = aurora_colors[aurora_progress]
		var/light_modifier = 0
		if(aurora_progress < 5)
			light_modifier = aurora_progress / 10
		else
			light_modifier = 1 - aurora_progress / 10
		INVOKE_ASYNC(src, PROC_REF(update_starlights), 2 + light_modifier * 4, 0.3, aurora_color)
		INVOKE_ASYNC(src, PROC_REF(create_starlights), 2 + light_modifier * 4, 0.3, aurora_color)

/datum/round_event/aurora_caelus/end()
	if(length(affected_turfs))
		for(var/turf/floor in affected_turfs)
			if(floor.starlit)
				INVOKE_ASYNC(src, PROC_REF(fade_to_black), floor)
	priority_announce("The aurora caelus event is now ending. Starlight conditions will slowly return to normal. When this has concluded, please return to your workplace and continue work as normal. Have a pleasant shift, [station_name()], and thank you for watching with us.",
	sound = 'sound/misc/notice2.ogg',
	sender_override = "Nanotrasen Meteorology Division")

/datum/round_event/aurora_caelus/proc/play_sound_to_all_station_players()
	for(var/V in GLOB.player_list)
		var/mob/M = V
		if(is_station_level(M.z))
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "star_gazing", /datum/mood_event/witnessed_starlight)
			if(M.client.prefs.toggles & PREFTOGGLE_SOUND_MIDI)
				M.playsound_local(M, 'sound/ambience/aurora_caelus.ogg', 20, FALSE, pressure_affected = FALSE)

/datum/round_event/aurora_caelus/proc/create_starlights(light_range, light_power, light_color)
	if(!length(GLOB.aurora_targets))
		return
	for(var/turf/floor in GLOB.aurora_targets)
		if(floor.starlit)
			GLOB.aurora_targets.Remove(floor)
			continue
		if(isspaceturf(floor))
			for(var/atom/found_thing as() in RANGE_TURFS(1, floor))
				if(!isspaceturf(found_thing) && !istype(found_thing, /mob))
					floor.set_light(light_range, light_power, light_color)
					floor.starlit = TRUE
					affected_turfs += floor
					GLOB.aurora_targets.Remove(floor)
					continue
		if(istype(floor, /turf/open/floor/fakespace))
			floor.set_light(light_range, light_power, light_color)
			floor.starlit = TRUE
			affected_turfs += floor
			GLOB.aurora_targets.Remove(floor)

/datum/round_event/aurora_caelus/proc/update_starlights(light_range, light_power, light_color)
	for(var/turf/floor in affected_turfs)
		if(floor.starlit)
			floor.set_light(light_range, light_power, light_color)

/datum/round_event/aurora_caelus/proc/fade_to_black(turf/open/space/S)
	set waitfor = FALSE
	var/new_light = initial(S.light_range)
	var/current_light_range = S.light_range
	while(current_light_range > new_light)
		S.set_light(current_light_range)
		current_light_range -= 0.2
		sleep(30)
	S.set_light(new_light, initial(S.light_power), initial(S.light_color))
	S.starlit = FALSE
