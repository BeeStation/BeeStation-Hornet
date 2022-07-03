#define CARP_COMMAND_STOP "carp_command_stop"
#define CARP_COMMAND_WANDER "carp_command_wander"
#define CARP_COMMAND_FOLLOW "carp_command_follow"
#define CARP_COMMAND_ATTACK "carp_command_attack"

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
	if(istype(carp_parent)) //setup signals & listens
		RegisterSignal(carp_parent, COMSIG_CLICK_ALT, .proc/give_command)

///Register signals to allies
/datum/component/carp_command/proc/update_ally()
	for(var/mob/living/M in cares_about_ally)
		RegisterSignal(M, COMSIG_PARENT_ATTACKBY, .proc/append_enemy_defend)
		RegisterSignal(M, COMSIG_MOB_HAND_ATTACKED, .proc/append_enemy)

/datum/component/carp_command/proc/give_command(var/mob/clicker, func_command, func_target)
	if(!(locate(clicker) in cares_about_ally) && !func_command)
		return
	target = null
	var/list/possible_commands = list(CARP_COMMAND_STOP = image(icon = 'icons/obj/carp_lasso.dmi', icon_state = "carp_stop"),
									CARP_COMMAND_WANDER = image(icon = 'icons/obj/carp_lasso.dmi', icon_state = "carp_wander"),
									CARP_COMMAND_FOLLOW = image(icon = 'icons/obj/carp_lasso.dmi', icon_state = "carp_follow"),
									CARP_COMMAND_ATTACK = image(icon = 'icons/obj/carp_lasso.dmi', icon_state = "carp_attack"),)
	command = (func_command ? func_command : show_radial_menu(clicker, carp_parent, possible_commands))
	switch(command)
		if(CARP_COMMAND_STOP)
			carp_parent.toggle_ai(AI_OFF)
		if(CARP_COMMAND_WANDER)
			carp_parent.toggle_ai(AI_ON)
		if(CARP_COMMAND_FOLLOW)
			target = (func_target ? func_target : (isliving(clicker.pulling) ? clicker.pulling : clicker))
			carp_parent.toggle_ai(AI_OFF)
		if(CARP_COMMAND_ATTACK)
			get_closest_enemy()
			target = (func_target ? func_target : target)
			carp_parent.toggle_ai(AI_OFF)

///Translates ATTACKBY
/datum/component/carp_command/proc/append_enemy_defend(var/obj/item, var/mob/living/M, params)
	cares_about_enemy += M
	give_command(null, CARP_COMMAND_ATTACK, M)

///Translate ATTACKHAND
/datum/component/carp_command/proc/append_enemy(var/mob/M, var/mob/user)
	cares_about_enemy += M
	give_command(user, CARP_COMMAND_ATTACK, M)

///Set target to closest entry in enemy list
/datum/component/carp_command/proc/get_closest_enemy()
	for(var/mob/living/M in cares_about_enemy)
		if(!M || get_dist(get_turf(M), get_turf(carp_parent)) < get_dist(get_turf(target), get_turf(carp_parent)))
			target = M

/datum/component/carp_command/Destroy(force, silent)
	UnregisterSignal(carp_parent, )
	..()
