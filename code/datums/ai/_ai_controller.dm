/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a atom. What this means is that these datums
have ways of interacting with a specific atom and control it. They posses a blackboard with the information the AI knows and has, and will plan behaviors it will try to execute.
*/

/datum/ai_controller
	///The atom this controller is controlling
	var/atom/pawn
	///Bitfield of traits for this AI to handle extra behavior
	var/ai_traits
	///Current actions being performed by the AI.
	var/list/current_behaviors = list()
	///Current status of AI (OFF/ON/IDLE)
	var/ai_status
	///Current movement target of the AI, generally set by decision making.
	var/atom/current_movement_target
	///Delay between atom movements, if this is not a multiplication of the delay in
	var/move_delay
	///This is a list of variables the AI uses and can be mutated by actions. When an action is performed you pass this list and any relevant keys for the variables it can mutate.
	var/list/blackboard = list()
	///Tracks recent pathing attempts, if we fail too many in a row we fail our current plans.
	var/pathing_attempts

/datum/ai_controller/New(atom/new_pawn)
	PossessPawn(new_pawn)

/datum/ai_controller/Destroy(force, ...)
	set_ai_status(AI_STATUS_OFF)
	UnpossessPawn()
	return ..()

///Proc to move from one pawn to another, this will destroy the target's existing controller.
/datum/ai_controller/proc/PossessPawn(atom/new_pawn)
	if(pawn) //Reset any old signals
		UnpossessPawn()

	if(istype(new_pawn.ai_controller)) //Existing AI, kill it.
		QDEL_NULL(new_pawn.ai_controller)

	if(TryPossessPawn(new_pawn) & AI_CONTROLLER_INCOMPATIBLE)
		qdel(src)
		CRASH("[src] attached to [new_pawn] but these are not compatible!")

	pawn = new_pawn
	pawn.ai_controller = src

	set_ai_status(AI_STATUS_ON)

	RegisterSignal(pawn, COMSIG_MOB_LOGIN, .proc/on_sentience_gained)

///Abstract proc for initializing the pawn to the new controller
/datum/ai_controller/proc/TryPossessPawn(atom/new_pawn)
	return

///Proc for deinitializing the pawn to the old controller
/datum/ai_controller/proc/UnpossessPawn()
	UnregisterSignal(pawn, COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT)
	pawn.ai_controller = null
	pawn = null
	return

///Returns TRUE if the ai controller can actually run at the moment.
/datum/ai_controller/proc/able_to_run()
	return TRUE

/// Generates a plan and see if our existing one is still valid.
/datum/ai_controller/process(delta_time)
	if(!able_to_run())
		return //this should remove them from processing in the future through event-based stuff.
	if(!current_behaviors?.len)
		SelectBehaviors(delta_time)
		if(!current_behaviors?.len)
			PerformIdleBehavior(delta_time) //Do some stupid shit while we have nothing to do
			return

	var/want_to_move = FALSE
	for(var/i in current_behaviors)
		var/datum/ai_behavior/current_behavior = i
		if(current_behavior.behavior_flags & AI_BEHAVIOR_REQUIRE_MOVEMENT && current_movement_target && current_behavior.required_distance < get_dist(pawn, current_movement_target)) //Move closer
			want_to_move = TRUE
			if(current_behavior.behavior_flags & AI_BEHAVIOR_MOVE_AND_PERFORM) //Move and perform the action
				current_behavior.perform(delta_time, src)
		else //Perform the action
			current_behavior.perform(delta_time, src)

	if(want_to_move)
		MoveTo(delta_time) //Need to add some code to check if we can perform the actions now without too much overhead


///Move somewhere using dumb movement (byond base)
/datum/ai_controller/proc/MoveTo(delta_time)
	var/current_loc = get_turf(pawn)

	if(!is_type_in_typecache(get_step(pawn, get_dir(pawn, current_movement_target)), GLOB.dangerous_turfs))
		step_towards(pawn, current_movement_target)
	if(current_loc == get_turf(pawn))
		if(++pathing_attempts >= MAX_PATHING_ATTEMPTS)
			CancelActions()
			pathing_attempts = 0


///Perform some dumb idle behavior.
/datum/ai_controller/proc/PerformIdleBehavior(delta_time)
	return

///This is where you decide what actions are taken by the AI.
/datum/ai_controller/proc/SelectBehaviors(delta_time)
	SHOULD_NOT_SLEEP(TRUE) //Fuck you don't sleep in procs like this.
	return

///This proc handles changing ai status, and starts/stops processing if required.
/datum/ai_controller/proc/set_ai_status(new_ai_status)
	if(ai_status == new_ai_status)
		return FALSE //no change

	ai_status = new_ai_status
	switch(ai_status)
		if(AI_STATUS_ON)
			START_PROCESSING(SSai_controllers, src)
		if(AI_STATUS_OFF)
			STOP_PROCESSING(SSai_controllers, src)
			CancelActions()

/datum/ai_controller/proc/CancelActions()
	for(var/i in current_behaviors)
		var/datum/ai_behavior/current_behavior = i
		current_behavior.finish_action(src, FALSE)

/datum/ai_controller/proc/on_sentience_gained()
	UnregisterSignal(pawn, COMSIG_MOB_LOGIN)
	set_ai_status(AI_STATUS_OFF) //Can't do anything while player is connected
	RegisterSignal(pawn, COMSIG_MOB_LOGOUT, .proc/on_sentience_lost)

/datum/ai_controller/proc/on_sentience_lost()
	UnregisterSignal(pawn, COMSIG_MOB_LOGOUT)
	set_ai_status(AI_STATUS_ON) //Can't do anything while player is connected
	RegisterSignal(pawn, COMSIG_MOB_LOGIN, .proc/on_sentience_gained)
