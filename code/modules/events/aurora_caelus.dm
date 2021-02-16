/datum/round_event_control/aurora_caelus
	name = "Aurora Caelus"
	typepath = /datum/round_event/aurora_caelus
	max_occurrences = 1
	weight = 1
	earliest_start = 5 MINUTES

/datum/round_event/aurora_caelus
	announceWhen = 1
	startWhen = 9
	endWhen = 50
	var/list/aurora_colors = list("#76ff44", "#44ff44", "#44ff92", "#44ffb7", "#44ffef", "#44e9ff", "#44c4ff", "#4476ff")
	var/aurora_progress = 0 //this cycles from 1 to 8, slowly changing colors from gentle green to gentle blue

/datum/round_event/aurora_caelus/announce()
	priority_announce("[station_name()]: A harmless cloud of ions is approaching your station, and will exhaust their energy battering the hull. Nanotrasen has approved a short break for all employees to relax and observe this very rare event. During this time, starlight will be bright but gentle, shifting between quiet green and blue colors. Any staff who would like to view these lights for themselves may proceed to the area nearest to them with viewing ports to open space. We hope you enjoy the lights.",
	sound = 'sound/misc/notice2.ogg',
	sender_override = "Nanotrasen Meteorology Division")
	for(var/V in GLOB.player_list)
		var/mob/M = V
		if((M.client.prefs.toggles & SOUND_MIDI) && is_station_level(M.z))
			M.playsound_local(M, 'sound/ambience/aurora_caelus.ogg', 20, FALSE, pressure_affected = FALSE)

/datum/round_event/aurora_caelus/start()
	for(var/area/space/nearstation/area in GLOB.sortedAreas)
		var/area/A = area
		for(var/turf/open/space/S in A)
			S.set_light(5, S.light_power * 0.5, aurora_colors[1])
			CHECK_TICK

/datum/round_event/aurora_caelus/tick()
	if(activeFor % 5 == 0)
		aurora_progress++
		var/aurora_color = aurora_colors[aurora_progress]
		for(var/area/space/nearstation/area in GLOB.sortedAreas)
			var/area/A = area
			for(var/turf/open/space/S in A)
				S.fade_light(aurora_color, 50)

/datum/round_event/aurora_caelus/end()
	for(var/area/space/nearstation/A in GLOB.sortedAreas)
		for(var/turf/open/space/S in A)
			fade_to_black(S)
	priority_announce("The aurora caelus event is now ending. Starlight conditions will slowly return to normal. When this has concluded, please return to your workplace and continue work as normal. Have a pleasant shift, [station_name()], and thank you for watching with us.",
	sound = 'sound/misc/notice2.ogg',
	sender_override = "Nanotrasen Meteorology Division")

/datum/round_event/aurora_caelus/proc/fade_to_black(turf/open/space/S)
	set waitfor = FALSE
	var/new_light = initial(S.light_range)
	S.flash_lighting_fx(S.light_range, S.light_power, S.light_color, 100)
	S.set_light(new_light, initial(S.light_power), initial(S.light_color))
