//Component used for tamed carps, holds targets, friends, and enemies
/datum/component/carp_command
	///current directive
	var/command = null
	///type casted owner
	var/mob/living/simple_animal/hostile/carp/carp_parent
	///list of friends
	var/list/cares_about_ally = list()
	///list of enemies
	var/list/cares_about_enemy = list()
	///current target
	var/mob/target

/datum/component/carp_command/Initialize(...)
	..()
	carp_parent = parent
	
	RegisterSignal(carp_parent, COMSIG_CLICK_ALT, .proc/give_command)
	RegisterSignal(carp_parent, COMSIG_MOB_HAND_ATTACKED, .proc/append_enemy)
	RegisterSignal(carp_parent, COMSIG_PARENT_ATTACKBY, .proc/append_enemy_defend)
	RegisterSignal(carp_parent, COMSIG_MOB_ATTACK_HAND, .proc/append_enemy)

///Register signals to allies
/datum/component/carp_command/proc/update_ally()
	for(var/mob/living/M as() in cares_about_ally)
		RegisterSignal(M, COMSIG_PARENT_QDELETING, .proc/handle_hard_del, M)
		RegisterSignal(M, COMSIG_PARENT_ATTACKBY, .proc/append_enemy_defend)
		RegisterSignal(M, COMSIG_MOB_HAND_ATTACKED, .proc/append_enemy)
		RegisterSignal(M, COMSIG_MOB_ATTACK_HAND, .proc/append_enemy)
		RegisterSignal(M, COMSIG_MOB_POINTED, .proc/handle_point)
		RegisterSignal(M, COMSIG_MOB_SAY, .proc/handle_speech)

/datum/component/carp_command/proc/give_command(datum/source, mob/living/clicker, func_command, func_target)
	var/list/possible_commands = list(CARP_COMMAND_STOP = image(icon = 'icons/obj/carp_lasso.dmi', icon_state = "carp_stop"),
									CARP_COMMAND_WANDER = image(icon = 'icons/obj/carp_lasso.dmi', icon_state = "carp_wander"),
									CARP_COMMAND_FOLLOW = image(icon = 'icons/obj/carp_lasso.dmi', icon_state = "carp_follow"),
									CARP_COMMAND_ATTACK = image(icon = 'icons/obj/carp_lasso.dmi', icon_state = "carp_attack"),)
	command = (func_command ? func_command : show_radial_menu(clicker, carp_parent, possible_commands))
	switch(command)
		if(CARP_COMMAND_STOP)
			target = null
			carp_parent.toggle_ai(AI_OFF)
		if(CARP_COMMAND_WANDER)
			target = null
			carp_parent.toggle_ai(AI_ON)
		if(CARP_COMMAND_FOLLOW)
			target = (func_target ? func_target : target)
			carp_parent.toggle_ai(AI_OFF)
		if(CARP_COMMAND_ATTACK)
			if(!(target in cares_about_ally))
				cares_about_enemy |= target
			get_closest_enemy()
			target = (func_target ? func_target : target)
			carp_parent.toggle_ai(AI_OFF)
	to_chat(clicker, "[command]")

///Translates ATTACKBY
/datum/component/carp_command/proc/append_enemy_defend(datum/source, var/obj/item, var/mob/living/M, params)
	if(!(M in cares_about_ally))
		cares_about_enemy |= M
		target = M
		give_command(source, null, CARP_COMMAND_ATTACK, M)

///Translate ATTACKHAND
/datum/component/carp_command/proc/append_enemy(datum/source, var/mob/user, var/mob/attacker, params)
	if(attacker.a_intent == INTENT_HARM && !(attacker in cares_about_ally))
		cares_about_enemy |= attacker
		target = attacker
		give_command(source, user, CARP_COMMAND_ATTACK, attacker)

///Set target to closest entry in enemy list
/datum/component/carp_command/proc/get_closest_enemy()
	for(var/mob/living/M in cares_about_enemy)
		if(!M || get_dist(get_turf(M), get_turf(carp_parent)) < get_dist(get_turf(target), get_turf(carp_parent)))
			target = M

/datum/component/carp_command/proc/handle_point(datum/source, var/atom/A)
	target = A
	if(command == CARP_COMMAND_ATTACK && isliving(A))
		if((A in cares_about_ally))
			cares_about_ally -= A
		else
			cares_about_enemy |= A

/datum/component/carp_command/proc/handle_speech(mob/speaker, speech_args)
	var/spoken_text = speech_args[SPEECH_MESSAGE] // probably should check for full words
	if(findtext(spoken_text, "follow") || findtext(spoken_text, "come") || findtext(spoken_text, "here"))
		command = CARP_COMMAND_FOLLOW
	else if(findtext(spoken_text, "stop") || findtext(spoken_text, "stay") || findtext(spoken_text, "sit"))
		command = CARP_COMMAND_STOP
	else if(findtext(spoken_text, "attack") || findtext(spoken_text, "kill") || findtext(spoken_text, "destroy"))
		command = CARP_COMMAND_ATTACK
	else if(findtext(spoken_text, "go") || findtext(spoken_text, "wander") || findtext(spoken_text, "search"))
		command = CARP_COMMAND_WANDER
	var/mob/living/speech_target = (command == CARP_COMMAND_FOLLOW ? speaker : target)
	give_command(null, speaker, command, speech_target)

/datum/component/carp_command/proc/handle_hard_del(var/atom/M)
	UnregisterSignal(M, COMSIG_PARENT_QDELETING)
	UnregisterSignal(M, COMSIG_PARENT_ATTACKBY)
	UnregisterSignal(M, COMSIG_MOB_HAND_ATTACKED)
	UnregisterSignal(M, COMSIG_MOB_ATTACK_HAND)
	UnregisterSignal(M, COMSIG_MOB_POINTED)
	UnregisterSignal(M, COMSIG_MOB_SAY)

/datum/component/carp_command/Destroy(force, silent)
	UnregisterSignal(carp_parent, COMSIG_CLICK_ALT)
	UnregisterSignal(carp_parent, COMSIG_MOB_HAND_ATTACKED)
	UnregisterSignal(carp_parent, COMSIG_PARENT_ATTACKBY)
	UnregisterSignal(carp_parent, COMSIG_MOB_ATTACK_HAND)
	for(var/atom/M in cares_about_ally)
		handle_hard_del(M)
	cares_about_enemy = null
	target = null
	..()
