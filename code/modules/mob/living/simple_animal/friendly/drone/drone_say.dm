//Base proc for anything to call
/proc/_alert_drones(msg, dead_can_hear = 0, atom/source, mob/living/faction_checked_mob, exact_faction_match)
	if(dead_can_hear && source)
		for(var/mob/dead_mob in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(dead_mob, source)
			to_chat(dead_mob, "[link] [msg]")
	for(var/global_drone in GLOB.drones_list)
		var/mob/living/simple_animal/drone/drone = global_drone
		if(!istype(drone))
			continue
		if(drone.stat == DEAD)
			continue
		if(faction_checked_mob && !drone.faction_check_mob(faction_checked_mob, exact_faction_match))
			continue
		to_chat(
			drone,
			msg,
			type = MESSAGE_TYPE_RADIO,
			avoid_highlighting = (drone == source),
		)

//Wrapper for drones to handle factions
/mob/living/simple_animal/drone/proc/alert_drones(msg, dead_can_hear = FALSE)
	_alert_drones(msg, dead_can_hear, src, src, TRUE)


/mob/living/simple_animal/drone/proc/drone_chat(message, list/spans = list(), list/message_mods = list())
	log_sayverb_talk(message, message_mods, tag = "drone chat")
	var/message_part = generate_messagepart(message, spans, message_mods)
	alert_drones(span_srtradio("<i>Drone Chat: [span_name(name)] [span_message("[message_part]")]</i>"), TRUE)

/mob/living/simple_animal/drone/binarycheck()
	return TRUE
