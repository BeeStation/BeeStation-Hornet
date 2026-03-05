/datum/weather/void_storm
	name = "void storm"
	desc = "A rare and highly anomalous event often accompanied by unknown entities shredding spacetime continouum. We'd advise you to start running."

	telegraph_duration = 2 SECONDS
	telegraph_overlay = "light_snow"

	weather_message = span_danger("<i>You feel air around you getting colder... and void's sweet embrace...</i>")
	weather_overlay = "snow_storm"
	weather_color = COLOR_BLACK
	weather_duration_lower = 60 SECONDS
	weather_duration_upper = 120 SECONDS


	end_duration = 10 SECONDS

	area_type = /area
	target_trait = ZTRAIT_VOIDSTORM

	barometer_predictable = FALSE
	perpetual = TRUE

/datum/weather/void_storm/can_weather_act(mob/living/mob_to_check)
	. = ..()
	if(IS_HERETIC_OR_MONSTER(mob_to_check))
		return FALSE

/datum/weather/void_storm/weather_act(mob/living/victim)
	var/need_mob_update = FALSE
	victim.adjustFireLoss(1, updating_health = FALSE)
	victim.adjustOxyLoss(rand(1, 3), updating_health = FALSE)
	if(need_mob_update)
		victim.updatehealth()
	victim.adjust_eye_blur(rand(0 SECONDS, 2 SECONDS))
	victim.adjust_bodytemperature(-30 * TEMPERATURE_DAMAGE_COEFFICIENT)
