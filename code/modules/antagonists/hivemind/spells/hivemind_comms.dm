/obj/effect/proc_holder/spell/self/hive_comms
	name = "Telepathic Currents"
	desc = "We may communicate with our rivals for ceasefires, trickery or betrayal."
	panel = "Hivemind Abilities"
	charge_max = 100
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "comms"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_comms/cast(mob/living/user = usr)
	var/message = stripped_input(user, "What do you want to say?", "Hive Communication")
	var/datum/antagonist/hivemind/hivehost = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hivehost)
		return
	if(!message)
		return
	var/title = "Hive"
	var/my_message = "<span class='changeling'><b>[title] [hivehost.hiveID]:</b> [message]</span>"
	for(var/mob/M as() in GLOB.player_list)
		if(is_hivehost(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="hive")

/obj/effect/proc_holder/spell/self/hive_comms/cast(mob/living/user = usr)
	var/message = stripped_input(user, "What do you want to say?", "Hive Communication")
	var/datum/antagonist/hivemind/hivehost = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hivehost)
		return
	if(!message)
		return
	var/title = "Hive"
	var/my_message = "<span class='changeling'><b>[title] [hivehost.hiveID]:</b> [message]</span>"
	for(var/mob/M as() in GLOB.player_list)
		if(is_hivehost(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="hive")
