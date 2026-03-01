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
	var/list/aurora_colors = list("#A2FF80", "#A2FFB6", "#92FFD8", "#8AFFEA", "#72FCFF", "#C6A8FF", "#F89EFF", "#FFA0F1")
	var/aurora_progress = 0 //this cycles from 1 to 8, slowly changing colors from gentle green to gentle blue

/datum/round_event/aurora_caelus/announce()
	priority_announce("[station_name()]: A harmless cloud of ions is approaching your station, and will exhaust their energy battering the hull. Nanotrasen has approved a short break for all employees to relax and observe this very rare event. During this time, starlight will be bright but gentle, shifting between quiet green, blue and purple colors. Any staff who would like to view these lights for themselves may proceed to the area nearest to them with viewing ports to open space. We hope you enjoy the lights.",
	sound = 'sound/misc/notice2.ogg',
	sender_override = "Nanotrasen Meteorology Division")
	INVOKE_ASYNC(src, PROC_REF(play_sound_to_all_station_players))

/datum/round_event/aurora_caelus/start()
	set_starlight_colour(aurora_colors[1], 5 SECONDS)

/datum/round_event/aurora_caelus/tick()
	if(activeFor % 5 == 0)
		if(aurora_progress < 8)
			aurora_progress++
		var/aurora_color = aurora_colors[aurora_progress]
		set_starlight_colour(aurora_color, 5 SECONDS)

/datum/round_event/aurora_caelus/end()
	set_starlight_colour(color_lightness_max(SSparallax.random_parallax_color, 0.75), 30 SECONDS)
	priority_announce("The aurora caelus event is now ending. Starlight conditions will slowly return to normal. When this has concluded, please return to your workplace and continue work as normal. Have a pleasant shift, [station_name()], and thank you for watching with us.",
	sound = 'sound/misc/notice2.ogg',
	sender_override = "Nanotrasen Meteorology Division")

/datum/round_event/aurora_caelus/proc/play_sound_to_all_station_players()
	for(var/V in GLOB.player_list)
		var/mob/M = V
		if(is_station_level(M.z))
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "star_gazing", /datum/mood_event/witnessed_starlight)
			if(M.client.prefs.read_player_preference(/datum/preference/toggle/sound_midi))
				M.playsound_local(M, 'sound/ambience/aurora_caelus.ogg', 20, FALSE, pressure_affected = FALSE)
