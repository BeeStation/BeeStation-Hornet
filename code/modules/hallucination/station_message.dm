#define ALERT_TITLE(text) ("<h1 class='alert'>" + text + "</h1>")
#define ALERT_BODY(text) ("<br><br>" + span_alert(text) + "<br><br>")

/datum/hallucination/station_message
	abstract_hallucination_parent = /datum/hallucination/station_message
	random_hallucination_weight = 1

/datum/hallucination/station_message/start()
	qdel(src) // To be implemented by subtypes, call parent for easy cleanup
	return TRUE

/datum/hallucination/station_message/blob_alert

/datum/hallucination/station_message/blob_alert/start()
	priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.",
		"Biohazard Alert", ANNOUNCER_OUTBREAK5, players = list(hallucinator))
	return ..()

/datum/hallucination/station_message/shuttle_dock

/datum/hallucination/station_message/shuttle_dock/start()
	priority_announce("[SSshuttle.emergency] has docked with the station. You have [DisplayTimeText(SSshuttle.emergency_dock_time)] to board the Emergency Shuttle.",
	null, ANNOUNCER_SHUTTLEDOCK, ANNOUNCEMENT_TYPE_PRIORITY, players = list(hallucinator))
	return ..()

/datum/hallucination/station_message/malf_ai

/datum/hallucination/station_message/malf_ai/start()
	if(!(locate(/mob/living/silicon/ai) in GLOB.silicon_mobs))
		return FALSE

	priority_announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.",
		"Anomaly Alert", ANNOUNCER_AIMALF, players = list(hallucinator))
	return ..()

/datum/hallucination/station_message/heretic
	// Assoc list of ascension text to ascension sound
	var/static/list/announcement_info = list()

/datum/hallucination/station_message/heretic/start()
	if(!length(announcement_info))
		for(var/ascension in subtypesof(/datum/heretic_knowledge/ultimate))
			var/datum/heretic_knowledge/ultimate/instance = new ascension()
			var/text = instance.announcement_text
			var/sound = instance.announcement_sound
			if(text && sound)
				announcement_info[text] = sound
			qdel(instance)

	// Unfortunately, this will not be synced if mass hallucinated
	var/mob/living/carbon/human/totally_real_heretic = random_non_sec_crewmember()
	if(!totally_real_heretic)
		return FALSE

	var/message = pick(announcement_info)
	var/message_with_name = replacetext(message, "%USER%", totally_real_heretic.real_name)

	priority_announce(
		text = "[generate_heretic_text()] [message_with_name] [generate_heretic_text()]",
		title = "[generate_heretic_text()]",
		sound = announcement_info[message],
		players = list(hallucinator)
	)
	return ..()

/datum/hallucination/station_message/cult_summon

/datum/hallucination/station_message/cult_summon/start()
	// Same, will not be synced if mass hallucinated
	var/mob/living/carbon/human/totally_real_cult_leader = random_non_sec_crewmember()
	if(!totally_real_cult_leader)
		return FALSE

	// Get a fake area that the summoning is happening in
	var/area/hallucinator_area = get_area(hallucinator)
	var/area/fake_summon_area_type = pick(GLOB.the_station_areas - hallucinator_area.type)
	var/area/fake_summon_area = GLOB.areas_by_type[fake_summon_area_type]

	priority_announce("Figments from an eldritch god are being summoned by [totally_real_cult_leader.real_name] into [fake_summon_area] from an unknown dimension. Disrupt the ritual at all costs!",
		"Central Command Higher Dimensional Affairs", 'sound/effects/antag/bloodcult/bloodcult_scribe.ogg',
		players = list(hallucinator))
	return ..()

/datum/hallucination/station_message/meteors
	random_hallucination_weight = 2

/datum/hallucination/station_message/meteors/start()
	priority_announce("Meteors have been detected on collision course with the station. Estimated time until impact: 10 MINUTES. Anti-meteor point defense is available for purchase via the station's cargo shuttle.",
		"Meteor Alert", ANNOUNCER_METEORS, players = list(hallucinator))
	return ..()

/datum/hallucination/station_message/supermatter_delam

/datum/hallucination/station_message/supermatter_delam/start()
	SEND_SOUND(hallucinator, 'sound/magic/charge.ogg')
	to_chat(hallucinator, span_bolddanger("You feel reality distort for a moment..."))
	return ..()

/datum/hallucination/station_message/clock_cult_ark
	random_hallucination_weight = 1

/datum/hallucination/station_message/clock_cult_ark/start()
	hallucinator.playsound_local(hallucinator, 'sound/machines/clockcult/ark_deathrattle.ogg', 50, FALSE, pressure_affected = FALSE)
	hallucinator.playsound_local(hallucinator, 'sound/effects/clockcult_gateway_disrupted.ogg', 50, FALSE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, PROC_REF(play_distant_explosion_sound)), 2.7 SECONDS)
	return TRUE // does not call parent to finish up the sound in a few seconds

/datum/hallucination/station_message/clock_cult_ark/proc/play_distant_explosion_sound()
	if(QDELETED(src))
		return

	hallucinator.playsound_local(get_turf(hallucinator), 'sound/effects/explosion_distant.ogg', 50, FALSE, pressure_affected = FALSE)
	qdel(src)

#undef ALERT_TITLE
#undef ALERT_BODY
