//Radiation storms occur when the station passes through an irradiated area, and irradiate anyone not standing in protected areas (maintenance, emergency storage, etc.)
/datum/weather/rad_storm
	name = "radiation storm"
	desc = "A cloud of intense radiation passes through the area dealing rad damage to those who are unprotected."

	telegraph_duration = 40 SECONDS
	telegraph_message = null

	weather_message = span_userdanger("<i>You feel waves of heat wash over you! Find shelter!</i>")
	weather_overlay = "rad_storm"
	weather_duration_lower = 60 SECONDS
	weather_duration_upper = 150 SECONDS

	weather_color = "#00ff0dff"

	end_duration = 10 SECONDS
	end_message = span_notice("The air seems to be cooling off again.")

	area_type = /area
	protected_areas = list(
		/area/station/maintenance,
		/area/station/ai_monitored/turret_protected/ai_upload,
		/area/station/ai_monitored/turret_protected/ai_upload_foyer,
		/area/station/ai_monitored/turret_protected/ai,
		/area/station/commons/storage/emergency/starboard,
		/area/station/commons/storage/emergency/port,
		/area/shuttle,
		/area/station/security/prison/asteroid/shielded,
		/area/station/security/prison/asteroid/service,
		/area/misc/space/nearstation,
		/area/station/solars,
		/area/station/security/prison,
		/area/station/holodeck/prison,
		/area/station/holodeck/debug,
	)
	target_trait = ZTRAIT_STATION

	var/list/playlist = list()

/datum/weather/rad_storm/telegraph()
	status_alarm(TRUE)

	var/list/eligible_areas = list()
	for (var/z in impacted_z_levels)
		eligible_areas += SSmapping.areas_in_z["[z]"]
	for(var/i in 1 to eligible_areas.len)
		var/area/place = eligible_areas[i]
		if(istype(place, /area/station/maintenance))
			playlist[place] = /datum/looping_sound/rad_alert_inside
		else
			playlist[place] = /datum/looping_sound/rad_alert_outside
		CHECK_TICK

	GLOB.rad_storm_sounds += playlist
	return ..()

/datum/weather/floor_is_lava/can_weather_act_mob(mob/living/mob_to_check)
	if(!ishuman(mob_to_check))
		return FALSE
	if(HAS_TRAIT(mob_to_check, TRAIT_RADIMMUNE))
		return FALSE
	if(SSradiation.wearing_rad_protected_clothing(mob_to_check))
		return FALSE
	return ..()

/datum/weather/rad_storm/weather_act_mob(mob/living/victim)
	SSradiation.irradiate(victim, intensity = rand(1, 5))

/datum/weather/rad_storm/end()
	GLOB.rad_storm_sounds -= playlist
	if(..())
		return
	priority_announce("The radiation threat has passed. Please return to your workplaces.", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
	status_alarm(FALSE)

/datum/weather/rad_storm/proc/status_alarm(active)	//Makes the status displays show the radiation warning for those who missed the announcement.
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(!frequency)
		return

	var/datum/signal/signal = new
	if (active)
		signal.data["command"] = "alert"
		signal.data["picture_state"] = "radiation"
	else
		signal.data["command"] = "shuttle"

	var/atom/movable/virtualspeaker/virt = new(null)
	frequency.post_signal(virt, signal)
