/mob/living/proc/alien_talk(message, shown_name = real_name)
	message = trim(message)
	if(!message)
		return
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, span_warning("Your message contains forbidden words."))
		return
	message = treat_message_min(message)
	log_talk(message, LOG_SAY)
	var/message_a = say_quote(message)
	var/rendered = "<i>[span_srtradioalien("Hivemind, [span_name(shown_name)] [span_message(message_a)]")]</i>"
	for(var/mob/S in GLOB.player_list)
		if(!S.stat && S.hivecheck())
			to_chat(S, rendered)
		if(S in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(S, src)
			to_chat(S, "[link] [rendered]")

/mob/living/carbon/alien/humanoid/royal/queen/alien_talk(message, shown_name = name)
	shown_name = "<FONT size = 3>[shown_name]</FONT>"
	return ..(message, shown_name)

/mob/living/carbon/hivecheck()
	var/obj/item/organ/alien/hivenode/N = get_organ_by_type(/obj/item/organ/alien/hivenode)
	if(N && !N.recent_queen_death) //Mob has alien hive node and is not under the dead queen special effect.
		return TRUE
