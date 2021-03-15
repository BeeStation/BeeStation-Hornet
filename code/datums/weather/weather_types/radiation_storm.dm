//Radiation storms occur when the station passes through an irradiated area, and irradiate anyone not standing in protected areas (maintenance, emergency storage, etc.)
/datum/weather/rad_storm
	name = "radiation storm"
	desc = "A cloud of intense radiation passes through the area dealing rad damage to those who are unprotected."

	telegraph_duration = 400
	telegraph_message = "<span class='danger'>The air begins to grow warm.</span>"

	weather_message = "<span class='userdanger'><i>You feel waves of heat wash over you! Find shelter!</i></span>"
	weather_overlay = "ash_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_color = "green"
	weather_sound = 'sound/misc/bloblarm.ogg'

	end_duration = 100
	end_message = "<span class='notice'>The air seems to be cooling off again.</span>"

	area_type = /area
	protected_areas = list(/area/maintenance, /area/ai_monitored/turret_protected/ai_upload, /area/ai_monitored/turret_protected/ai_upload_foyer,
	/area/ai_monitored/turret_protected/ai, /area/storage/emergency/starboard, /area/storage/emergency/port, /area/shuttle)
	target_trait = ZTRAIT_STATION

	immunity_type = "rad"

/datum/weather/rad_storm/telegraph()
	..()
	status_alarm(TRUE)


/datum/weather/rad_storm/weather_act(mob/living/L)
	var/resist = L.getarmor(null, "rad")
	if(prob(40))
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.dna && !(HAS_TRAIT(H, TRAIT_RADIMMUNE) || HAS_TRAIT(H, TRAIT_MUTATEIMMUNE))) // don't add mutations to species that are immune, IPCs
				if(prob(max(0,100-resist)))
					H.randmuti()
					if(prob(50))
						if(prob(90))
							H.easy_randmut(NEGATIVE+MINOR_NEGATIVE)
						else
							H.easy_randmut(POSITIVE)
						H.domutcheck()
				if(HAS_TRAIT(H, TRAIT_IPCRADBRAINDAMAGE)) // instead, give IPCs brain damage
					if(prob(max(0,100-resist)))
						if(prob(50))
							var/trauma_type = pickweight(list(
								BRAIN_TRAUMA_MILD = 65,
								BRAIN_TRAUMA_SEVERE = 30,
								BRAIN_TRAUMA_SPECIAL = 5
							))
							var/resistance = pick(
								50;TRAUMA_RESILIENCE_BASIC,
								30;TRAUMA_RESILIENCE_SURGERY,
								15;TRAUMA_RESILIENCE_LOBOTOMY,
								5;TRAUMA_RESILIENCE_MAGIC
							)
							H.gain_trauma_type(trauma_type,resistance)

							var/emote_type = pickweight(list(
								"beep" = 34,
								"buzz" = 34,
								"buzz2" = 34,
							))
							H.emote(emote_type)
		L.rad_act(20)

/datum/weather/rad_storm/end()
	if(..())
		return
	priority_announce("The radiation threat has passed. Please return to your workplaces.", "Anomaly Alert")
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
