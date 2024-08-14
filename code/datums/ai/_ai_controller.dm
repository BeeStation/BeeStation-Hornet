/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a atom. What this means is that these datums
have ways of interacting with a specific atom and control it. They posses a blackboard with the information the AI knows and has, and will plan behaviors it will try to execute through
multiple modular subtrees with behaviors
*/

/datum/ai_controller
	///The atom this controller is controlling
	var/atom/pawn
	///Bitfield of traits for this AI to handle extra behavior
	var/ai_traits
	///Current actions being performed by the AI.
	var/list/current_behaviors
	///Current actions and their respective last time ran as an assoc list.
	var/list/behavior_cooldowns = list()
	///Current status of AI (OFF/ON)
	var/ai_status
	///Current movement target of the AI, generally set by decision making.
	var/atom/current_movement_target
	///This is a list of variables the AI uses and can be mutated by actions. When an action is performed you pass this list and any relevant keys for the variables it can mutate.
	var/list/blackboard = list()
	///Stored arguments for behaviors given during their initial creation
	var/list/behavior_args = list()
	///Tracks recent pathing attempts, if we fail too many in a row we fail our current plans.
	var/consecutive_pathing_attempts
	///Can the AI remain in control if there is a client?
	var/continue_processing_when_client = FALSE
	///distance to give up on target
	var/max_target_distance = 14
	///Cooldown for new plans, to prevent AI from going nuts if it can't think of new plans and looping on end
	COOLDOWN_DECLARE(failed_planning_cooldown)
	///All subtrees this AI has available, will run them in order, so make sure they're in the order you want them to run. On initialization of this type, it will start as a typepath(s) and get converted to references of ai_subtrees found in SSai_controllers when init_subtrees() is called
	var/list/planning_subtrees

	///The idle behavior this AI preforms when it has no actions.
	var/datum/idle_behavior/idle_behavior = null

	// Movement related things here
	///Reference to the movement datum we use. Is a type on initialize but becomes a ref afterwards.
	var/datum/ai_movement/ai_movement = /datum/ai_movement/dumb
	///Cooldown until next movement
	COOLDOWN_DECLARE(movement_cooldown)
	///Delay between movements. This is on the controller so we can keep the movement datum singleton
	var/movement_delay = 0.1 SECONDS

	// The variables below are fucking stupid and should be put into the blackboard at some point.
	///AI paused time
	var/paused_until = 0

/datum/ai_controller/New(atom/new_pawn)
	change_ai_movement_type(ai_movement)
	init_subtrees()

	if(idle_behavior)
		idle_behavior = new idle_behavior()

	PossessPawn(new_pawn)

/datum/ai_controller/Destroy(force, ...)
	set_ai_status(AI_STATUS_OFF)
	UnpossessPawn(FALSE)
	return ..()

///Overrides the current ai_movement of this controller with a new one
/datum/ai_controller/proc/change_ai_movement_type(datum/ai_movement/new_movement)
	ai_movement = SSai_movement.movement_types[new_movement]

///Completely replaces the planning_subtrees with a new set based on argument provided, list provided must contain specifically typepaths
/datum/ai_controller/proc/replace_planning_subtrees(list/typepaths_of_new_subtrees)
	planning_subtrees = typepaths_of_new_subtrees
	init_subtrees()

///Loops over the subtrees in planning_subtrees and looks at the ai_controllers to grab a reference, ENSURE planning_subtrees ARE TYPEPATHS AND NOT INSTANCES/REFERENCES BEFORE EXECUTING THIS
/datum/ai_controller/proc/init_subtrees()
	if(!LAZYLEN(planning_subtrees))
		return
	var/list/temp_subtree_list = list()
	for(var/subtree in planning_subtrees)
		var/subtree_instance = SSai_controllers.ai_subtrees[subtree]
		temp_subtree_list += subtree_instance
	planning_subtrees = temp_subtree_list

///Proc to move from one pawn to another, this will destroy the target's existing controller.
/datum/ai_controller/proc/PossessPawn(atom/new_pawn)
	if(pawn) //Reset any old signals
		UnpossessPawn(FALSE)

	if(istype(new_pawn.ai_controller)) //Existing AI, kill it.
		QDEL_NULL(new_pawn.ai_controller)

	if(TryPossessPawn(new_pawn) & AI_CONTROLLER_INCOMPATIBLE)
		qdel(src)
		CRASH("[src] attached to [new_pawn] but these are not compatible!")

	pawn = new_pawn
	pawn.ai_controller = src

	if(!continue_processing_when_client && istype(new_pawn, /mob))
		var/mob/possible_client_holder = new_pawn
		if(possible_client_holder.client)
			set_ai_status(AI_STATUS_OFF)
		else
			set_ai_status(AI_STATUS_ON)
	else
		set_ai_status(AI_STATUS_ON)

	RegisterSignal(pawn, COMSIG_MOB_LOGIN, PROC_REF(on_sentience_gained))

///Abstract proc for initializing the pawn to the new controller
/datum/ai_controller/proc/TryPossessPawn(atom/new_pawn)
	return

///Proc for deinitializing the pawn to the old controller
/datum/ai_controller/proc/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT))
	if(ai_movement.moving_controllers[src])
		ai_movement.stop_moving_towards(src)
	pawn.ai_controller = null
	pawn = null
	if(destroy)
		qdel(src)
	return

///Returns TRUE if the ai controller can actually run at the moment.
/datum/ai_controller/proc/able_to_run()
	if(world.time < paused_until)
		return FALSE
	return TRUE


///Runs any actions that are currently running
/datum/ai_controller/process(delta_time)
	if(!able_to_run())
		SSmove_manager.stop_looping(pawn) //stop moving
		return //this should remove them from processing in the future through event-based stuff.

	if(!LAZYLEN(current_behaviors) && idle_behavior)
		idle_behavior.perform_idle_behavior(delta_time, src) //Do some stupid shit while we have nothing to do
		return

	if(current_movement_target && get_dist(pawn, current_movement_target) > max_target_distance) //The distance is out of range
		CancelActions()
		return

	for(var/i in current_behaviors)
		var/datum/ai_behavior/current_behavior = i


		// Convert the current behaviour action cooldown to realtime seconds from deciseconds.current_behavior
		// Then pick the max of this and the delta_time passed to ai_controller.process()
		// Action cooldowns cannot happen faster than delta_time, so delta_time should be the value used in this scenario.
		var/action_delta_time = max(current_behavior.action_cooldown * 0.1, delta_time)

		if(current_behavior.behavior_flags & AI_BEHAVIOR_REQUIRE_MOVEMENT) //Might need to move closer
			if(!current_movement_target)
				stack_trace("[pawn] wants to perform action type [current_behavior.type] which requires movement, but has no current movement target!")
				return //This can cause issues, so don't let these slide.
			if(current_behavior.required_distance >= get_dist(pawn, current_movement_target)) ///Are we close enough to engage?
				if(ai_movement.moving_controllers[src] == current_movement_target) //We are close enough, if we're moving stop.
					ai_movement.stop_moving_towards(src)

				if(behavior_cooldowns[current_behavior] > world.time) //Still on cooldown
					continue
				ProcessBehavior(action_delta_time, current_behavior)
				return

			else if(ai_movement.moving_controllers[src] != current_movement_target) //We're too far, if we're not already moving start doing it.
				ai_movement.start_moving_towards(src, current_movement_target, current_behavior.required_distance) //Then start moving

			if(current_behavior.behavior_flags & AI_BEHAVIOR_MOVE_AND_PERFORM) //If we can move and perform then do so.
				if(behavior_cooldowns[current_behavior] > world.time) //Still on cooldown
					continue
				ProcessBehavior(action_delta_time, current_behavior)
				return
		else //No movement required
			if(behavior_cooldowns[current_behavior] > world.time) //Still on cooldown
				continue
			ProcessBehavior(action_delta_time, current_behavior)
			return

///This is where you decide what actions are taken by the AI.
/datum/ai_controller/proc/SelectBehaviors(delta_time)
	SHOULD_NOT_SLEEP(TRUE) //Fuck you don't sleep in procs like this.
	if(!COOLDOWN_FINISHED(src, failed_planning_cooldown))
		return FALSE

	LAZYINITLIST(current_behaviors)

	if(LAZYLEN(planning_subtrees))
		for(var/datum/ai_planning_subtree/subtree as anything in planning_subtrees)
			if(subtree.SelectBehaviors(src, delta_time) == SUBTREE_RETURN_FINISH_PLANNING)
				break

///This proc handles changing ai status, and starts/stops processing if required.
/datum/ai_controller/proc/set_ai_status(new_ai_status)
	if(ai_status == new_ai_status)
		return FALSE //no change

	ai_status = new_ai_status
	switch(ai_status)
		if(AI_STATUS_ON)
			SSai_controllers.active_ai_controllers += src
			START_PROCESSING(SSai_behaviors, src)
		if(AI_STATUS_OFF)
			STOP_PROCESSING(SSai_behaviors, src)
			SSai_controllers.active_ai_controllers -= src
			CancelActions()

/datum/ai_controller/proc/PauseAi(time)
	paused_until = world.time + time

///Call this to add a behavior to the stack.
/datum/ai_controller/proc/queue_behavior(behavior_type, ...)
	var/datum/ai_behavior/behavior = GET_AI_BEHAVIOR(behavior_type)
	if(!behavior)
		CRASH("Behavior [behavior_type] not found.")
	var/list/arguments = args.Copy()
	arguments[1] = src
	if(!behavior.setup(arglist(arguments)))
		return
	LAZYADD(current_behaviors, behavior)
	arguments.Cut(1, 2)
	if(length(arguments))
		behavior_args[behavior_type] = arguments
	else
		behavior_args -= behavior_type

/datum/ai_controller/proc/ProcessBehavior(delta_time, datum/ai_behavior/behavior)
	var/list/arguments = list(delta_time, src)
	var/list/stored_arguments = behavior_args[behavior.type]
	if(stored_arguments)
		arguments += stored_arguments
	behavior.perform(arglist(arguments))

/datum/ai_controller/proc/CancelActions()
	if(!LAZYLEN(current_behaviors))
		return
	for(var/i in current_behaviors)
		var/datum/ai_behavior/current_behavior = i
		var/list/arguments = list(src, FALSE)
		var/list/stored_arguments = behavior_args[current_behavior.type]
		if(stored_arguments)
			arguments += stored_arguments
		current_behavior.finish_action(arglist(arguments))

/datum/ai_controller/proc/on_sentience_gained()
	SIGNAL_HANDLER
	UnregisterSignal(pawn, COMSIG_MOB_LOGIN)
	if(!continue_processing_when_client)
		set_ai_status(AI_STATUS_OFF) //Can't do anything while player is connected
	RegisterSignal(pawn, COMSIG_MOB_LOGOUT, PROC_REF(on_sentience_lost))

/datum/ai_controller/proc/on_sentience_lost()
	SIGNAL_HANDLER
	UnregisterSignal(pawn, COMSIG_MOB_LOGOUT)
	set_ai_status(AI_STATUS_ON) //Can't do anything while player is connected
	RegisterSignal(pawn, COMSIG_MOB_LOGIN, PROC_REF(on_sentience_gained))

/// Use this proc to define how your controller defines what access the pawn has for the sake of pathfinding, likely pointing to whatever ID slot is relevant
/datum/ai_controller/proc/get_access()
	return

///Returns the minimum required distance to preform one of our current behaviors. Honestly this should just be cached or something but fuck you
/datum/ai_controller/proc/get_minimum_distance()
	var/minimum_distance = max_target_distance
	// right now I'm just taking the shortest minimum distance of our current behaviors, at some point in the future
	// we should let whatever sets the current_movement_target also set the min distance and max path length
	// (or at least cache it on the controller)
	for(var/datum/ai_behavior/iter_behavior as anything in current_behaviors)
		if(iter_behavior.required_distance < minimum_distance)
			minimum_distance = iter_behavior.required_distance
	return minimum_distance


/// Used for above to track all the keys that have registered a signal
#define TRAIT_AI_TRACKING "tracked_by_ai"


/**
 * Used to manage references to datum by AI controllers
 *
 * * tracked_datum - something being added to an ai blackboard
 * * key - the associated key
 */
#define TRACK_AI_DATUM_TARGET(tracked_datum, key) do { \
	if(isweakref(tracked_datum)) { \
		var/datum/weakref/_bad_weakref = tracked_datum; \
		stack_trace("Weakref (Actual datum: [_bad_weakref.resolve()]) found in ai datum blackboard! \
			This is an outdated method of ai reference handling, please remove it."); \
	}; \
	else if(isdatum(tracked_datum)) { \
		var/datum/_tracked_datum = tracked_datum; \
		if(!HAS_TRAIT_FROM(_tracked_datum, TRAIT_AI_TRACKING, "[REF(src)]_[key]")) { \
			RegisterSignal(_tracked_datum, COMSIG_PARENT_QDELETING, PROC_REF(sig_remove_from_blackboard), override = TRUE); \
			ADD_TRAIT(_tracked_datum, TRAIT_AI_TRACKING, "[REF(src)]_[key]"); \
		}; \
	}; \
} while(FALSE)

/**
 * Used to clear previously set reference handing by AI controllers
 *
 * * tracked_datum - something being removed from an ai blackboard
 * * key - the associated key
 */
#define CLEAR_AI_DATUM_TARGET(tracked_datum, key) do { \
	if(isdatum(tracked_datum)) { \
		var/datum/_tracked_datum = tracked_datum; \
		REMOVE_TRAIT(_tracked_datum, TRAIT_AI_TRACKING, "[REF(src)]_[key]"); \
		if(!HAS_TRAIT(_tracked_datum, TRAIT_AI_TRACKING)) { \
			UnregisterSignal(_tracked_datum, COMSIG_PARENT_QDELETING); \
		}; \
	}; \
} while(FALSE)

/**
 * Sets the key to the passed "thing".
 *
 * * key - A blackboard key
 * * thing - a value to set the blackboard key to.
 */
/datum/ai_controller/proc/set_blackboard_key(key, thing)
	// Assume it is an error when trying to set a value overtop a list
	if(islist(blackboard[key]))
		CRASH("set_blackboard_key attempting to set a blackboard value to key [key] when it's a list!")
	// Don't do anything if it's already got this value
	if (blackboard[key] == thing)
		return

	// Clear existing values
	if(!isnull(blackboard[key]))
		clear_blackboard_key(key)

	TRACK_AI_DATUM_TARGET(thing, key)
	blackboard[key] = thing
	post_blackboard_key_set(key)


/**
 * Clears the passed key, resetting it to null
 *
 * Not intended for use with list keys - use [proc/remove_thing_from_blackboard_key] if you are removing a value from a list at a key
 *
 * * key - A blackboard key
 */
/datum/ai_controller/proc/clear_blackboard_key(key)
	if(isnull(blackboard[key]))
		return
	CLEAR_AI_DATUM_TARGET(blackboard[key], key)
	blackboard[key] = null
	if(isnull(pawn))
		return
	SEND_SIGNAL(pawn, COMSIG_AI_BLACKBOARD_KEY_CLEARED(key))

/**
 * Called after we set a blackboard key, forwards signal information.
 */
/datum/ai_controller/proc/post_blackboard_key_set(key)
	if (isnull(pawn))
		return
	SEND_SIGNAL(pawn, COMSIG_AI_BLACKBOARD_KEY_SET(key))

/// Signal proc to go through every key and remove the datum from all keys it finds
/datum/ai_controller/proc/sig_remove_from_blackboard(datum/source)
	SIGNAL_HANDLER

	var/list/list/remove_queue = list(blackboard)
	var/index = 1
	while(index <= length(remove_queue))
		var/list/next_to_clear = remove_queue[index]
		for(var/inner_value in next_to_clear)
			var/associated_value = next_to_clear[inner_value]
			// We are a lists of lists, add the next value to the queue so we can handle references in there
			// (But we only need to bother checking the list if it's not empty.)
			if(islist(inner_value) && length(inner_value))
				UNTYPED_LIST_ADD(remove_queue, inner_value)

			// We found the value that's been deleted. Clear it out from this list
			else if(inner_value == source)
				next_to_clear -= inner_value

			// We are an assoc lists of lists, the list at the next value so we can handle references in there
			// (But again, we only need to bother checking the list if it's not empty.)
			if(islist(associated_value) && length(associated_value))
				UNTYPED_LIST_ADD(remove_queue, associated_value)

			// We found the value that's been deleted, it was an assoc value. Clear it out entirely
			else if(associated_value == source)
				next_to_clear -= inner_value
				SEND_SIGNAL(pawn, COMSIG_AI_BLACKBOARD_KEY_CLEARED(inner_value))

		index += 1


#undef TRAIT_AI_TRACKING
