//Radiation storms occur when the station passes through an irradiated area, and irradiate anyone not standing in protected areas (maintenance, emergency storage, etc.)
/datum/weather/rad_storm
	name = "radiation storm"
	desc = "A cloud of intense radiation passes through the area dealing rad damage to those who are unprotected."

	telegraph_duration = 40 SECONDS
	telegraph_message = null

	weather_message = span_userdanger("<i>You feel waves of heat wash over you! Find shelter!</i>")
	weather_overlay = "ash_storm"
	weather_duration_lower = 60 SECONDS
	weather_duration_upper = 150 SECONDS
	weather_color = "green"
	weather_sound = 'sound/misc/bloblarm.ogg'

	end_duration = 10 SECONDS
	end_message = span_notice("The air seems to be cooling off again.")

	area_type = /area
	protected_areas = list(
		/area/maintenance,
		/area/ai_monitored/turret_protected/ai_upload,
		/area/ai_monitored/turret_protected/ai_upload_foyer,
		/area/ai_monitored/turret_protected/ai,
		/area/storage/emergency/starboard,
		/area/storage/emergency/port,
		/area/shuttle,
		/area/security/prison/asteroid/shielded,
		/area/security/prison/asteroid/service,
		/area/space/nearstation,
		/area/solar,
		/area/security/prison,
		/area/holodeck/prison,
		/area/holodeck/debug,
	)
	target_trait = ZTRAIT_STATION

	/// Chance we get a negative mutation, if we fail we get a positive one
	var/negative_mutation_chance = 90
	/// Chance we mutate
	var/mutate_chance = 40

/datum/weather/rad_storm/telegraph()
	..()
	status_alarm(TRUE)

/datum/weather/rad_storm/weather_act(mob/living/living)
	if(!prob(mutate_chance))
		return

	if(!ishuman(living))
		return

	var/mob/living/carbon/human/human = living
	if(!human.can_mutate())
		return

	if(HAS_TRAIT(human, TRAIT_RADIMMUNE))
		return

	if(SSradiation.wearing_rad_protected_clothing(human))
		return

	human.random_mutate_unique_identity()
	human.random_mutate_unique_features()

	if(prob(50))
		do_mutate(human)

/datum/weather/rad_storm/end()
	if(..())
		return
	priority_announce("The radiation threat has passed. Please return to your workplaces.", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
	status_alarm(FALSE)

/datum/weather/rad_storm/proc/do_mutate(mob/living/carbon/human/mutant)
	if(prob(negative_mutation_chance))
		mutant.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
	else
		mutant.easy_random_mutate(POSITIVE)
	mutant.domutcheck()

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
