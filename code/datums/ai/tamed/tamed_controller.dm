#define TAMED_COMMAND_FOLLOW "Follow"
#define TAMED_COMMAND_STOP "Stop"
#define TAMED_COMMAND_WANDER "Wander"
#define TAMED_COMMAND_ATTACK "Attack"

#define ANGER_THRESHOLD_ATTACK 3 // How many attacks it takes to anger a tamed mob
#define ANGER_RESET_TIME 5 MINUTES // How long it takes for a tamed mob's anger to expire (resets after every attack)

///default jps fails pathfinding too often, this work better
/datum/ai_movement/jps/expensive
	max_pathing_attempts = 12

//Frakensteins some dog code
/datum/ai_controller/tamed
	blackboard = list(\
		BB_DOG_FRIENDS = list(),\
		BB_DOG_ORDER_MODE = DOG_COMMAND_NONE)
	ai_movement = /datum/ai_movement/jps/expensive
	COOLDOWN_DECLARE(command_cooldown)
	//Icons for radial menu
	///Icon for follow
	var/icon/follow_icon
	var/icon/stop_icon
	var/icon/wander_icon
	var/icon/attack_icon
	var/anger = 0

/datum/ai_controller/tamed/process(delta_time)
	if(ismob(pawn))
		var/mob/living/living_pawn = pawn
		movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..()

/datum/ai_controller/tamed/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(new_pawn, COMSIG_MOB_ITEM_ATTACKBY, PROC_REF(on_item_attack))
	RegisterSignal(new_pawn, COMSIG_CLICK_ALT, PROC_REF(check_altclicked))
	return ..()

/datum/ai_controller/tamed/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_PARENT_EXAMINE, COMSIG_CLICK_ALT, COMSIG_MOB_DEATH, COMSIG_GLOB_CARBON_THROW_THING, COMSIG_PARENT_QDELETING))
	return ..()

/datum/ai_controller/tamed/able_to_run()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/datum/ai_controller/tamed/get_access()
	var/mob/living/simple_animal/simple_pawn = pawn
	if(!istype(simple_pawn))
		return

	return simple_pawn.access_card

/// === Command Stuff ===
/// Someone alt clicked us, see if they're someone we should show the radial command menu to
/datum/ai_controller/tamed/proc/check_altclicked(datum/source, mob/living/clicker)
	SIGNAL_HANDLER

	if(!istype(clicker) || !blackboard[BB_DOG_FRIENDS][WEAKREF(clicker)])
		return
	INVOKE_ASYNC(src, PROC_REF(command_radial), clicker)

/// Show the command radial menu
/datum/ai_controller/tamed/proc/command_radial(mob/living/clicker)
	var/list/commands = list(
		TAMED_COMMAND_FOLLOW = follow_icon,
		TAMED_COMMAND_ATTACK = attack_icon,
		TAMED_COMMAND_STOP = stop_icon,
		TAMED_COMMAND_WANDER = wander_icon
		)

	var/choice = show_radial_menu(clicker, pawn, commands, custom_check = CALLBACK(src, PROC_REF(check_menu), clicker), tooltips = TRUE)
	if(!choice || !check_menu(clicker))
		return
	set_command_mode(clicker, choice)

/datum/ai_controller/tamed/proc/check_menu(mob/user)
	if(!istype(user))
		CRASH("A non-mob is trying to issue an order to [pawn].")
	if(user.incapacitated() || !can_see(user, pawn))
		return FALSE
	return TRUE

/datum/ai_controller/tamed/proc/set_command_mode(mob/commander, command)
	COOLDOWN_START(src, command_cooldown, AI_DOG_COMMAND_COOLDOWN)
	//typecast to stop the nerd from walking away
	var/mob/living/simple_animal/living_pawn = pawn
	living_pawn.wander = FALSE

	switch(command)
		if(TAMED_COMMAND_STOP)
			blackboard[BB_DOG_ORDER_MODE] = TAMED_COMMAND_STOP
			CancelActions()
			queue_behavior(/datum/ai_behavior/tamed_sit)

		if(TAMED_COMMAND_FOLLOW)
			blackboard[BB_DOG_ORDER_MODE] = TAMED_COMMAND_FOLLOW
			CancelActions()
			if(!blackboard[BB_FOLLOW_TARGET])
				if(blackboard[BB_DOG_FRIENDS][1])
					var/datum/weakref/follow_ref = blackboard[BB_DOG_FRIENDS][1]
					blackboard[BB_FOLLOW_TARGET] = follow_ref?.resolve()
					if(!can_see(pawn, blackboard[BB_FOLLOW_TARGET], AI_DOG_VISION_RANGE))
						pawn.visible_message("[pawn] can't see [blackboard[BB_FOLLOW_TARGET]]!")
						return
				else
					pawn.visible_message("[pawn] doesn't see anything to follow!")
					return
			pawn.visible_message("[pawn] starts to follow [blackboard[BB_FOLLOW_TARGET]]!")
			current_movement_target = blackboard[BB_FOLLOW_TARGET]
			queue_behavior(/datum/ai_behavior/tamed_follow)

		if(TAMED_COMMAND_ATTACK)
			blackboard[BB_DOG_ORDER_MODE] = TAMED_COMMAND_ATTACK
			CancelActions()
			if(!blackboard[BB_ATTACK_TARGET])
				pawn.visible_message("[pawn] doesn't see anything to attack!")
				return
			if(!can_see(pawn, blackboard[BB_ATTACK_TARGET], AI_DOG_VISION_RANGE))
				pawn.visible_message("[pawn] can't see [blackboard[BB_ATTACK_TARGET]]!")
				return
			if(commander && ismob(blackboard[BB_ATTACK_TARGET]))
				log_combat(commander, blackboard[BB_ATTACK_TARGET], "ordered [pawn] to attack")
			current_movement_target = blackboard[BB_ATTACK_TARGET]
			queue_behavior(/datum/ai_behavior/tamed_follow/attack)

		if(TAMED_COMMAND_WANDER)
			blackboard[BB_DOG_ORDER_MODE] = null
			living_pawn.wander = TRUE
			CancelActions()

/// === Enemy / Ally stuff ===
/// Someone's interacting with us by hand, see if they're being nice or mean
/datum/ai_controller/tamed/proc/on_attack_hand(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(user.a_intent == INTENT_HELP)
		if(prob(25))
			user.visible_message("[source] nuzzles [user]!", "<span class='notice'>[source] nuzzles you!</span>")
		return
	if(blackboard[BB_DOG_FRIENDS][WEAKREF(user)])
		anger++
		if(anger >= ANGER_THRESHOLD_ATTACK)
			unfriend(user)
		else
			addtimer(VARSET_CALLBACK(src, anger, 0), ANGER_RESET_TIME, TIMER_UNIQUE|TIMER_OVERRIDE)
			return
	blackboard[BB_ATTACK_TARGET] = user
	set_command_mode(null, TAMED_COMMAND_ATTACK)

/datum/ai_controller/tamed/proc/on_item_attack(datum/source, mob/living/user, obj/item/I)
	SIGNAL_HANDLER
	if(!I.force)
		return
	if(blackboard[BB_DOG_FRIENDS][WEAKREF(user)])
		anger++
		if(anger >= ANGER_THRESHOLD_ATTACK)
			unfriend(user)
		else
			addtimer(VARSET_CALLBACK(src, anger, 0), ANGER_RESET_TIME, TIMER_UNIQUE|TIMER_OVERRIDE)
			return
	blackboard[BB_ATTACK_TARGET] = user
	set_command_mode(null, TAMED_COMMAND_ATTACK)

/// Someone is being nice to us, let's make them a friend!
/datum/ai_controller/tamed/proc/befriend(mob/living/new_friend)
	var/list/friends = blackboard[BB_DOG_FRIENDS]
	var/datum/weakref/friend_ref = WEAKREF(new_friend)
	if(friends[friend_ref])
		return
	friends[friend_ref] = TRUE
	RegisterSignal(new_friend, COMSIG_MOB_POINTED, PROC_REF(check_point))
	RegisterSignal(new_friend, COMSIG_MOB_SAY, PROC_REF(check_verbal_command))
	RegisterSignal(new_friend, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))

/// Someone is being mean to us, take them off our friends (add actual enemies behavior later)
/datum/ai_controller/tamed/proc/unfriend(mob/living/ex_friend)
	var/list/friends = blackboard[BB_DOG_FRIENDS]
	friends -= WEAKREF(ex_friend)
	UnregisterSignal(ex_friend, list(COMSIG_MOB_POINTED, COMSIG_MOB_SAY))

/// Someone we like is pointing at something, see if it's something we might want to interact with (like if they might want us to fetch something for them)
/datum/ai_controller/tamed/proc/check_point(mob/pointing_friend, atom/movable/pointed_movable)
	SIGNAL_HANDLER

	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return

	if(!can_see(pawn, pointing_friend, length=AI_DOG_VISION_RANGE) || !can_see(pawn, pointed_movable, length=AI_DOG_VISION_RANGE))
		return

	COOLDOWN_START(src, command_cooldown, AI_DOG_COMMAND_COOLDOWN)

	blackboard[BB_FOLLOW_TARGET] = pointed_movable
	if(!blackboard[BB_DOG_FRIENDS][WEAKREF(pointed_movable)])
		blackboard[BB_ATTACK_TARGET] = pointed_movable

/// One of our friends said something, see if it's a valid command, and if so, take action
/datum/ai_controller/tamed/proc/check_verbal_command(mob/speaker, speech_args)
	SIGNAL_HANDLER
	if(!blackboard[BB_DOG_FRIENDS][WEAKREF(speaker)])
		return

	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return

	var/spoken_text = speech_args[SPEECH_MESSAGE] // probably should check for full words
	var/command
	if(findtext(spoken_text, "follow") || findtext(spoken_text, "come"))
		command = TAMED_COMMAND_FOLLOW
	else if(findtext(spoken_text, "stop") || findtext(spoken_text, "sit") || findtext(spoken_text, "stay"))
		command = TAMED_COMMAND_STOP
	else if(findtext(spoken_text, "attack") || findtext(spoken_text, "sic"))
		command = TAMED_COMMAND_ATTACK
	else if(findtext(spoken_text, "wander") || findtext(spoken_text, "explore"))
		command = TAMED_COMMAND_WANDER
	else
		return

	if(!can_see(pawn, speaker, length=AI_DOG_VISION_RANGE))
		return
	set_command_mode(speaker, command)

