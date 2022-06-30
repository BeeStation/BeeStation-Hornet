#define HAL_LINES_FILE "hallucination.json"

/datum/hallucination/chat

/datum/hallucination/chat/New(mob/living/carbon/C, forced = TRUE, force_radio, specific_message)
	set waitfor = FALSE
	..()
	var/target_name = target.first_name()
	var/speak_messages = list("[pick_list_replacements(HAL_LINES_FILE, "suspicion")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "conversation")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "greetings")][target.first_name()]!",\
		"[pick_list_replacements(HAL_LINES_FILE, "getout")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "weird")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "didyouhearthat")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "doubt")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "aggressive")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "help")]!!",\
		"[pick_list_replacements(HAL_LINES_FILE, "escape")]",\
		"I'm infected, [pick_list_replacements(HAL_LINES_FILE, "infection_advice")]!")

	var/radio_messages = list("[pick_list_replacements(HAL_LINES_FILE, "people")] is [pick_list_replacements(HAL_LINES_FILE, "accusations")]!",\
		"Help!",\
		"[pick_list_replacements(HAL_LINES_FILE, "threat")] in [pick_list_replacements(HAL_LINES_FILE, "location")][prob(50)?"!":"!!"]",\
		"[pick("Where's [target.first_name()]?", "Set [target.first_name()] to arrest!")]",\
		"[pick("C","Ai, c","Someone c","Rec")]all the shuttle!",\
		"AI [pick("rogue", "is dead")]!!")

	var/mob/living/carbon/person = null
	var/datum/language/understood_language = target.get_random_understood_language()
	for(var/mob/living/carbon/H in view(target))
		if(H == target)
			continue
		if(!person)
			person = H
		else
			if(get_dist(target,H)<get_dist(target,person))
				person = H

	// Get person to affect if radio hallucination
	var/is_radio = !person || force_radio
	if (is_radio)
		var/list/humans = list()
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			humans += H
		person = pick(humans)

	// Generate message
	var/spans = list(person.speech_span)
	var/chosen = !specific_message ? capitalize(pick(is_radio ? speak_messages : radio_messages)) : specific_message
	chosen = replacetext(chosen, "%TARGETNAME%", target_name)
	var/message = target.compose_message(person, understood_language, chosen, is_radio ? "[FREQ_COMMON]" : null, spans, face_name = TRUE)
	feedback_details += "Type: [is_radio ? "Radio" : "Talk"], Source: [person.real_name], Message: [message]"

	// Display message
	if (!is_radio && !target.client?.prefs.chat_on_map)
		var/image/speech_overlay = image('icons/mob/talk.dmi', person, "default0", layer = ABOVE_MOB_LAYER)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/flick_overlay, speech_overlay, list(target.client), 30)
	if (target.client?.prefs.chat_on_map)
		create_chat_message(person, understood_language, list(target), chosen, spans)
	to_chat(target, message)
	qdel(src)

/datum/hallucination/message

/datum/hallucination/message/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	var/list/mobpool = list()
	var/mob/living/carbon/human/other
	var/close_other = FALSE
	for(var/mob/living/carbon/human/H in oview(7, target))
		if(get_dist(H, target) <= 1)
			other = H
			close_other = TRUE
			break
		mobpool += H
	if(!other && mobpool.len)
		other = pick(mobpool)

	var/list/message_pool = list()
	if(other)
		if(close_other) //increase the odds
			for(var/i in 1 to 5)
				message_pool.Add("<span class='warning'>You feel a tiny prick!</span>")
		var/obj/item/storage/equipped_backpack = other.get_item_by_slot(ITEM_SLOT_BACK)
		if(istype(equipped_backpack))
			for(var/i in 1 to 5) //increase the odds
				message_pool.Add("<span class='notice'>[other] puts the [pick(\
					"revolver","energy sword","cryptographic sequencer","power sink","energy bow",\
					"hybrid taser","stun baton","flash","syringe gun","circular saw","tank transfer valve",\
					"ritual dagger","clockwork slab","spellbook",\
					"pulse rifle","captain's spare ID","hand teleporter","hypospray","antique laser gun","X-01 MultiPhase Energy Gun","station's blueprints"\
					)] into [equipped_backpack].</span>")

		message_pool.Add("<B>[other]</B> [pick("sneezes","coughs")].")

	message_pool.Add("<span class='notice'>You hear something squeezing through the ducts...</span>", \
		"<span class='notice'>Your [pick("arm", "leg", "back", "head")] itches.</span>",\
		"<span class='warning'>You feel [pick("hot","cold","dry","wet","woozy","faint")].</span>",
		"<span class='warning'>Your stomach rumbles.</span>",
		"<span class='warning'>Your head hurts.</span>",
		"<span class='warning'>You hear a faint buzz in your head.</span>",
		"<B>[target]</B> sneezes.")
	if(prob(10))
		message_pool.Add("<span class='warning'>Behind you.</span>",\
			"<span class='warning'>You hear a faint laughter.</span>",
			"<span class='warning'>You see something move.</span>",
			"<span class='warning'>You hear skittering on the ceiling.</span>",
			"<span class='warning'>You see an inhumanly tall silhouette moving in the distance.</span>")
	if(prob(10))
		message_pool.Add("[pick_list_replacements(HAL_LINES_FILE, "advice")]")
	var/chosen = pick(message_pool)
	feedback_details += "Message: [chosen]"
	to_chat(target, chosen)
	qdel(src)

/datum/hallucination/stationmessage

/datum/hallucination/stationmessage/New(mob/living/carbon/C, forced = TRUE, message)
	set waitfor = FALSE
	..()
	if(!message)
		message = pick("ratvar","shuttle dock","blob alert","malf ai","meteors","supermatter")
	feedback_details += "Type: [message]"
	switch(message)
		if("blob alert")
			to_chat(target, "<h1 class='alert'>Biohazard Alert</h1>")
			to_chat(target, "<br><br><span class='alert'>Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.</span><br><br>")
			SEND_SOUND(target,  SSstation.announcer.event_sounds[ANNOUNCER_OUTBREAK5])
		if("ratvar")
			target.playsound_local(target, 'sound/machines/clockcult/ark_deathrattle.ogg', 50, FALSE, pressure_affected = FALSE)
			target.playsound_local(target, 'sound/effects/clockcult_gateway_disrupted.ogg', 50, FALSE, pressure_affected = FALSE)
			sleep(27)
			target.playsound_local(target, 'sound/effects/explosion_distant.ogg', 50, FALSE, pressure_affected = FALSE)
		if("shuttle dock")
			to_chat(target, "<h1 class='alert'>Priority Announcement</h1>")
			to_chat(target, "<br><br><span class='alert'>The Emergency Shuttle has docked with the station. You have 3 minutes to board the Emergency Shuttle.</span><br><br>")
			SEND_SOUND(target, SSstation.announcer.event_sounds[ANNOUNCER_SHUTTLEDOCK])
		if("malf ai") //AI is doomsdaying!
			to_chat(target, "<h1 class='alert'>Anomaly Alert</h1>")
			to_chat(target, "<br><br><span class='alert'>Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.</span><br><br>")
			SEND_SOUND(target, SSstation.announcer.event_sounds[ANNOUNCER_AIMALF])
		if("meteors") //Meteors inbound!
			to_chat(target, "<h1 class='alert'>Meteor Alert</h1>")
			to_chat(target, "<br><br><span class='alert'>Meteors have been detected on collision course with the station.</span><br><br>")
			SEND_SOUND(target, SSstation.announcer.event_sounds[ANNOUNCER_METEORS])
		if("supermatter")
			SEND_SOUND(target, 'sound/magic/charge.ogg')
			to_chat(target, "<span class='boldannounce'>You feel reality distort for a moment...</span>")
