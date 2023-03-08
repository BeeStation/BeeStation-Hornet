///Template class of the movement datums, handles the timing portion of the loops
/datum/move_loop
	///The movement packet that owns us
	var/datum/movement_packet/owner
	///The subsystem we're processing on
	var/datum/controller/subsystem/movement/controller
	///An extra reference we pass around
	///It is on occasion useful to have a reference to some datum without storing it on the moving object
	///Mostly comes up in high performance senarios where we care about things being singletons
	///This feels horrible, but constantly making components seems worse
	var/datum/extra_info
	///The thing we're moving about
	var/atom/movable/moving
	///Defines how different move loops override each other. Higher numbers beat lower numbers
	var/priority = MOVEMENT_DEFAULT_PRIORITY
	///Bitfield of different things that affect how a loop operates
	var/flags
	///Time till we stop processing in deci-seconds, defaults to forever
	var/lifetime = INFINITY
	///Delay between each move in deci-seconds
	var/delay = 1
	///The next time we should process
	///Used primarially as a hint to be reasoned about by our [controller], and as the id of our bucket
	///Should not be modified directly outside of [start_loop]
	var/timer = 0

/datum/move_loop/New(datum/movement_packet/owner, datum/controller/subsystem/movement/controller, atom/moving, priority, flags, datum/extra_info)
	src.owner = owner
	src.controller = controller
	src.extra_info = extra_info
	if(extra_info)
		RegisterSignal(extra_info, COMSIG_PARENT_QDELETING, PROC_REF(info_deleted))
	src.moving = moving
	src.priority = priority
	src.flags = flags

/datum/move_loop/proc/setup(delay = 1, timeout = INFINITY)
	if(!ismovable(moving) || !owner)
		return FALSE

	src.delay = max(delay, world.tick_lag) //Please...
	src.lifetime = timeout
	return TRUE

///proc that exists so we can check if this exact moveloop datum already exists (in terms of vars) and so we can stop it from needlessly create a new one to overwrite the old one
/datum/move_loop/proc/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay = 1, timeout = INFINITY)
	SHOULD_CALL_PARENT(TRUE)
	if(loop_type == type && priority == src.priority && flags == src.flags && delay == src.delay && timeout == lifetime)
		return TRUE

/datum/move_loop/proc/start_loop()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_START)
	//If this is our first time starting to move with this loop
	//And we're meant to start instantly
	if(!timer && flags & MOVEMENT_LOOP_START_FAST)
		timer = world.time
		return
	timer = world.time + delay

/datum/move_loop/proc/stop_loop()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_STOP)

/datum/move_loop/proc/info_deleted(datum/source)
	SIGNAL_HANDLER
	extra_info = null

/datum/move_loop/Destroy()
	if(owner)
		owner.remove_loop(controller, src)
	owner = null
	moving = null
	controller = null
	extra_info = null
	return ..()

///Exists as a helper so outside code can modify delay in a sane way
/datum/move_loop/proc/set_delay(new_delay)
	delay =  max(new_delay, world.tick_lag)

/datum/move_loop/process()
	var/old_delay = delay //The signal can sometimes change delay

	if(SEND_SIGNAL(src, COMSIG_MOVELOOP_PREPROCESS_CHECK) & MOVELOOP_SKIP_STEP) //Chance for the object to react
		return

	lifetime -= old_delay //This needs to be based on work over time, not just time passed

	if(lifetime < 0) //Otherwise lag would make things look really weird
		qdel(src)
		return

	var/visual_delay = controller.visual_delay
	var/success = move()

	SEND_SIGNAL(src, COMSIG_MOVELOOP_POSTPROCESS, success, delay * visual_delay)

	if(QDELETED(src) || !success) //Can happen
		return

///Handles the actual move, overriden by children
///Returns FALSE if nothing happen, TRUE otherwise
/datum/move_loop/proc/move()
	return FALSE

///Removes the atom from some movement subsystem. Defaults to SSmovement
/datum/controller/subsystem/move_manager/proc/stop_looping(atom/movable/moving, datum/controller/subsystem/movement/subsystem = SSmovement)
	var/datum/movement_packet/our_info = moving.move_packet
	if(!our_info)
		return FALSE
	return our_info.remove_subsystem(subsystem)

/**
 * Replacement for walk()
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * direction - The direction we want to move in
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/move(moving, direction, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/move, priority, flags, extra_info, delay, timeout, direction)

///Replacement for walk()
/datum/move_loop/move
	var/direction

/datum/move_loop/move/setup(delay, timeout, dir)
	. = ..()
	if(!.)
		return
	direction = dir

/datum/move_loop/move/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, dir)
	if(..() && direction == dir)
		return TRUE

/datum/move_loop/move/move()
	var/atom/old_loc = moving.loc
	moving.Move(get_step(moving, direction), direction)
	// We cannot rely on the return value of Move(), we care about teleports and it doesn't
	return old_loc != moving?.loc

/**
 * Like move(), but it uses byond's pathfinding on a step by step basis
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * direction - The direction we want to move in
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/move_to_dir(moving, direction, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/move/move_to, priority, flags, extra_info, delay, timeout, direction)

/datum/move_loop/move/move_to

/datum/move_loop/move/move_to/move()
	var/atom/old_loc = moving.loc
	step_to(moving, get_step(moving, direction))
	return old_loc != moving?.loc


/**
 * Like move(), but we don't care about collision at all
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * direction - The direction we want to move in
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/force_move_dir(moving, direction, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/move/force, priority, flags, extra_info, delay, timeout, direction)

/datum/move_loop/move/force

/datum/move_loop/move/force/move()
	var/atom/old_loc = moving.loc
	moving.forceMove(get_step(moving, direction))
	return old_loc != moving?.loc


/datum/move_loop/has_target
	///The thing we're moving in relation to, either at or away from
	var/atom/target

/datum/move_loop/has_target/setup(delay, timeout, atom/chasing)
	. = ..()
	if(!.)
		return
	if(!isatom(chasing))
		qdel(src)
		return FALSE

	target = chasing

	if(!isturf(target))
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(handle_no_target)) //Don't do this for turfs, because we don't care

/datum/move_loop/has_target/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing)
	if(..() && chasing == target)
		return TRUE

/datum/move_loop/has_target/Destroy()
	target = null
	return ..()

/datum/move_loop/has_target/proc/handle_no_target()
	SIGNAL_HANDLER
	qdel(src)


/**
 * Used for force-move loops, similar to move_towards_legacy() but not quite the same
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/force_move(moving, chasing, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/force_move, priority, flags, extra_info, delay, timeout, chasing)

///Used for force-move loops
/datum/move_loop/has_target/force_move

/datum/move_loop/has_target/force_move/move()
	var/atom/old_loc = moving.loc
	moving.forceMove(get_step(moving, get_dir(moving, target)))
	return old_loc != moving?.loc


/**
 * Used for following jps defined paths. The proc signature here's a bit long, I'm sorry
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * repath_delay - How often we're allowed to recalculate our path
 * max_path_length - The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * miminum_distance - Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example
 * id - An ID card representing what access we have and what doors we can open
 * simulated_only -  Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
 * avoid - If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * skip_first -  Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break things
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/jps_move(moving,
	chasing,
	delay,
	timeout,
	repath_delay,
	max_path_length,
	minimum_distance,
	obj/item/card/id/id,
	simulated_only,
	turf/avoid,
	skip_first,
	subsystem,
	priority,
	flags,
	datum/extra_info)
	return add_to_loop(moving,
		subsystem,
		/datum/move_loop/has_target/jps,
		priority,
		flags,
		extra_info,
		delay,
		timeout,
		chasing,
		repath_delay,
		max_path_length,
		minimum_distance,
		id,
		simulated_only,
		avoid,
		skip_first)

/datum/move_loop/has_target/jps
	///How often we're allowed to recalculate our path
	var/repath_delay
	///Max amount of steps to search
	var/max_path_length
	///Minimum distance to the target before path returns
	var/minimum_distance
	///An ID card representing what access we have and what doors we can open. Kill me
	var/obj/item/card/id/id
	///Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
	var/simulated_only
	///A perticular turf to avoid
	var/turf/avoid
	///Should we skip the first step? This is the tile we're currently on, which breaks some things
	var/skip_first
	///A list for the path we're currently following
	var/list/movement_path
	///TRUE if a repath proc is currently running to ensure that only one can be called and finishes at a time
	var/repath_active
	///Cooldown for repathing, prevents spam
	COOLDOWN_DECLARE(repath_cooldown)

/datum/move_loop/has_target/jps/setup(delay, timeout, atom/chasing, repath_delay, max_path_length, minimum_distance, obj/item/card/id/id, simulated_only, turf/avoid, skip_first)
	. = ..()
	if(!.)
		return
	src.repath_delay = repath_delay
	src.max_path_length = max_path_length
	src.minimum_distance = minimum_distance
	src.id = id
	src.simulated_only = simulated_only
	src.avoid = avoid
	src.skip_first = skip_first
	if(istype(id, /obj/item/card/id))
		RegisterSignal(id, COMSIG_PARENT_QDELETING, PROC_REF(handle_no_id)) //I prefer erroring to harddels. If this breaks anything consider making id info into a datum or something

/datum/move_loop/has_target/jps/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, repath_delay, max_path_length, minimum_distance, obj/item/card/id/id, simulated_only, turf/avoid, skip_first)
	if(..() && repath_delay == src.repath_delay && max_path_length == src.max_path_length && minimum_distance == src.minimum_distance && id == src.id && simulated_only == src.simulated_only && avoid == src.avoid)
		return TRUE

/datum/move_loop/has_target/jps/start_loop()
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(recalculate_path))

/datum/move_loop/has_target/jps/Destroy()
	id = null //Kill me
	avoid = null
	return ..()

/datum/move_loop/has_target/jps/proc/handle_no_id()
	SIGNAL_HANDLER
	id = null

//Returns FALSE if the recalculation failed, TRUE otherwise
/datum/move_loop/has_target/jps/proc/recalculate_path()
	if(!COOLDOWN_FINISHED(src, repath_cooldown) || repath_active)
		return
	repath_active = TRUE
	COOLDOWN_START(src, repath_cooldown, repath_delay)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_JPS_REPATH)
	movement_path = get_path_to(moving, target, max_path_length, minimum_distance, id, simulated_only, avoid, skip_first)
	repath_active = FALSE

/datum/move_loop/has_target/jps/move()
	var/atom/movable/atom = moving
	if(!length(movement_path))
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		if(!length(movement_path))
			return FALSE

	var/turf/next_step = movement_path[1]
	var/atom/old_loc = moving.loc
	moving.Move(next_step, get_dir(moving, next_step))
	. = (old_loc != moving?.loc)

	// this check if we're on exactly the next tile may be overly brittle for dense objects who may get bumped slightly
	// to the side while moving but could maybe still follow their path without needing a whole new path
	var/turf/current_loc = get_turf(atom) //if we need to use this twice might as well make it a local var
	if(current_loc == next_step)
		movement_path.Cut(1,2)
	else
		if(get_dist(current_loc, next_step) > 1) //we check here if we are further away than 1 tile before we recalculate the path cause else we might just be able to try to move again next time
			INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		return FALSE
/**
 * Used for following jps defined paths.
 * Unlike the previous one this one is designed to work for hostile mobs it includes some additional checks for the move proc and also
 * a fallback solution for pathing this fallback is mainly to allow the mob to go up to things like airlocks and glass and try to break those.
 * its not advised to set a repath delay bigger than 0 because our target is most likely a mob that might be running away
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * repath_delay - How often we're allowed to recalculate our path
 * max_path_length - The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * miminum_distance - Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example
 * id - An ID card representing what access we have and what doors we can open
 * simulated_only -  Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
 * avoid - If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * skip_first -  Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break things
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/hostile_jps_move(moving,
	chasing,
	delay,
	timeout,
	repath_delay,
	max_path_length,
	minimum_distance,
	obj/item/card/id/id,
	simulated_only,
	turf/avoid,
	skip_first,
	subsystem,
	priority,
	flags,
	datum/extra_info)
	return add_to_loop(moving,
		subsystem,
		/datum/move_loop/has_target/jps/hostile,
		priority,
		flags,
		extra_info,
		delay,
		timeout,
		chasing,
		repath_delay,
		max_path_length,
		minimum_distance,
		id,
		simulated_only,
		avoid,
		skip_first)

/datum/move_loop/has_target/jps/hostile
	var/target_turf

/datum/move_loop/has_target/jps/hostile/recalculate_path()
	if(!COOLDOWN_FINISHED(src, repath_cooldown) || repath_active || QDELETED(src))
		return
	repath_active = TRUE
	COOLDOWN_START(src, repath_cooldown, repath_delay)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_JPS_REPATH)
	movement_path = get_path_to(moving, target, max_path_length, minimum_distance, id, simulated_only, avoid, skip_first)
	// Implementing pathfinding fallback solution
	if(!length(movement_path) && !QDELETED(src))
		var/ln = get_dist(moving, target)
		var/turf/target_new = target
		var/found_blocker
		var/passflags_cache = moving.pass_flags
		while(!length(movement_path) && (ln > 0)) //will stop if we can find a valid path or if ln gets reduced to 0 or less
			find_target:
				for(var/i in 1 to ln) //calling get_path_to every time is quite taxing lets see if we can find whatever blocks us
					target_new = get_step(target_new,  get_dir(target_new, moving)) //step towards the origin until we find the blocker then 1 further
					ln--
					if(target_new.density && !(target_new.pass_flags_self & passflags_cache)) //we check for possible tiles that could block us
						found_blocker = TRUE
						continue find_target //in case there is like a double wall
					for(var/obj/o in target_new.contents)
						if(o.density && !(o.pass_flags_self & passflags_cache)) //We check for possible blockers on the tile
							found_blocker = TRUE
							continue find_target
					if(found_blocker) //cursed but after we found the blocker we end the loop on the next illiteration
						break find_target
			found_blocker = FALSE
			movement_path = get_path_to(moving, target_new, max_path_length, 0, id, simulated_only, avoid, skip_first) //here the min distance is always 0 because we need to stand beside the blocker
	target_turf = get_turf(target)
	repath_active = FALSE

/datum/move_loop/has_target/jps/hostile/move()
	var/atom/movable/atom = moving
	if(!length(movement_path) || target_turf != get_turf(target))
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		if(!length(movement_path))
			return FALSE
	var/turf/next_step = movement_path[1]
	var/atom/old_loc = moving.loc
	moving.Move(next_step, get_dir(moving, next_step))
	. = (old_loc != moving?.loc)

	// this check if we're on exactly the next tile may be overly brittle for dense objects who may get bumped slightly
	// to the side while moving but could maybe still follow their path without needing a whole new path
	var/turf/current_loc = get_turf(atom) //if we need to use this twice might as well make it a local var
	if(current_loc == next_step)
		movement_path.Cut(1,2)
	else
		if(get_dist(current_loc, next_step) > 1) //we check here if we are further away than 1 tile before we recalculate the path cause else we might just be able to try to move again next time
			INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		return FALSE

/datum/move_loop/has_target/jps/hostile/Destroy()
	target_turf = null
	return ..()

///Base class of move_to and move_away, deals with the distance and target aspect of things
/datum/move_loop/has_target/dist_bound
	var/distance = 0

/datum/move_loop/has_target/dist_bound/setup(delay, timeout, atom/chasing, dist = 0)
	. = ..()
	if(!.)
		return
	distance = dist

/datum/move_loop/has_target/dist_bound/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, dist = 0)
	if(..() && distance == dist)
		return TRUE

///Returns FALSE if the movement should pause, TRUE otherwise
/datum/move_loop/has_target/dist_bound/proc/check_dist()
	return FALSE

/datum/move_loop/has_target/dist_bound/move()
	if(!check_dist()) //If we're too close don't do the move
		return FALSE
	return TRUE


/**
 * Wrapper around walk_to()
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * min_dist - the closest we're allower to get to the target
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/move_to(moving, chasing, min_dist, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/dist_bound/move_to, priority, flags, extra_info, delay, timeout, chasing, min_dist)

///Wrapper around walk_to()
/datum/move_loop/has_target/dist_bound/move_to

/datum/move_loop/has_target/dist_bound/move_to/check_dist()
	return (get_dist(moving, target) > distance) //If you get too close, stop moving closer

/datum/move_loop/has_target/dist_bound/move_to/move()
	. = ..()
	if(!.)
		return
	var/atom/old_loc = moving.loc
	step_to(moving, target)
	return old_loc != moving?.loc

/**
 * Wrapper around walk_away()
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * max_dist - the furthest away from the target we're allowed to get
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/move_away(moving, chasing, max_dist, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/dist_bound/move_away, priority, flags, extra_info, delay, timeout, chasing, max_dist)

///Wrapper around walk_away()
/datum/move_loop/has_target/dist_bound/move_away

/datum/move_loop/has_target/dist_bound/move_away/check_dist()
	return (get_dist(moving, target) < distance) //If you get too far out, stop moving away

/datum/move_loop/has_target/dist_bound/move_away/move()
	. = ..()
	if(!.)
		return
	var/atom/old_loc = moving.loc
	step_away(moving, target)
	return old_loc != moving?.loc


/**
 * Helper proc for the move_towards datum
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * home - Should we move towards the object at all times? Or launch towards them, but allow walls and such to take us off track. Defaults to FALSE
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to INFINITY
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/move_towards(moving, chasing, delay, home, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/move_towards, priority, flags, extra_info, delay, timeout, chasing, home)

/**
 * Helper proc for homing onto something with move_towards
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * home - Should we move towards the object at all times? Or launch towards them, but allow walls and such to take us off track. Defaults to FALSE
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to INFINITY
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/home_onto(moving, chasing, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return move_towards(moving, chasing, delay, TRUE, timeout, subsystem, priority, flags, extra_info)

///Used as a alternative to walk_towards
/datum/move_loop/has_target/move_towards
	///The turf we want to move into, used for course correction
	var/turf/moving_towards
	///Should we try and stay on the path, or is deviation alright
	var/home = FALSE
	///When this gets larger then 1 we move a turf
	var/x_ticker = 0
	var/y_ticker = 0
	///The rate at which we move, between 0 and 1
	var/x_rate = 1
	var/y_rate = 1
	//We store the signs of x and y seperately, because byond will round negative numbers down
	//So doing all our operations with absolute values then multiplying them is easier
	var/x_sign = 0
	var/y_sign = 0

/datum/move_loop/has_target/move_towards/setup(delay, timeout, atom/chasing, home = FALSE)
	. = ..()
	if(!.)
		return FALSE
	src.home = home

	if(home)
		if(ismovable(target))
			RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(update_slope)) //If it can move, update your slope when it does
		RegisterSignal(moving, COMSIG_MOVABLE_MOVED, PROC_REF(handle_move))
	update_slope()

/datum/move_loop/has_target/move_towards/Destroy()
	if(home)
		if(ismovable(target))
			UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
		if(moving)
			UnregisterSignal(moving, COMSIG_MOVABLE_MOVED)
	return ..()

/datum/move_loop/has_target/move_towards/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, home = FALSE)
	if(..() && home == src.home)
		return TRUE

/datum/move_loop/has_target/move_towards/move()
	//Move our tickers forward a step, we're guaranteed at least one step forward because of how the code is written
	if(x_rate) //Did you know that rounding by 0 throws a divide by 0 error?
		x_ticker = FLOOR(x_ticker + x_rate, x_rate)
	if(y_rate)
		y_ticker = FLOOR(y_ticker + y_rate, y_rate)

	var/x = moving.x
	var/y = moving.y
	var/z = moving.z

	moving_towards = locate(x + round(x_ticker) * x_sign, y + round(y_ticker) * y_sign, z)
	//The tickers serve as good methods of tracking remainder
	if(x_ticker >= 1)
		x_ticker = MODULUS(x_ticker, 1) //I swear to god if you somehow go up by one then one in a tick I'm gonna go mad
	if(y_ticker >= 1)
		y_ticker = MODULUS(x_ticker, 1)
	var/atom/old_loc = moving.loc
	moving.Move(moving_towards, get_dir(moving, moving_towards))

	//YOU FOUND THEM! GOOD JOB
	if(home && get_turf(moving) == get_turf(target))
		x_rate = 0
		y_rate = 0
		return
	return old_loc != moving?.loc

/datum/move_loop/has_target/move_towards/proc/handle_move(source, atom/OldLoc, Dir, Forced = FALSE)
	SIGNAL_HANDLER
	if(moving.loc != moving_towards && home) //If we didn't go where we should have, update slope to account for the deviation
		update_slope()

/datum/move_loop/has_target/move_towards/handle_no_target()
	if(home)
		return ..()
	target = null

/**
 * Recalculates the slope between our object and the target, sets our rates to it
 *
 * The math below is reminiscent of something like y = mx + b
 * Except we don't need to care about axis, since we do all our movement in steps of 1
 * Because of that all that matters is we only move one tile at a time
 * So we take the smaller delta, divide it by the larger one, and get smaller step per large step
 * Then we set the large step to 1, and we're done. This way we're guaranteed to never move more then a tile at once
 * And we can have nice lines
**/
/datum/move_loop/has_target/move_towards/proc/update_slope()
	SIGNAL_HANDLER

	//You'll notice this is rise over run, except we flip the formula upside down depending on the larger number
	//This is so we never move more then one tile at once
	var/delta_y = target.y - moving.y
	var/delta_x = target.x - moving.x
	//It's more convienent to store delta x and y as absolute values
	//and modify them right at the end then it is to deal with rounding errors
	x_sign = (delta_x > 0) ? 1 : -1
	y_sign = (delta_y > 0) ? 1 : -1
	delta_x = abs(delta_x)
	delta_y = abs(delta_y)

	if(delta_x >= delta_y)
		if(delta_x == 0) //Just go up/down
			x_rate = 0
			y_rate = 1
			return
		x_rate = 1
		y_rate = delta_y / delta_x //rise over run, you know the deal
	else
		if(delta_y == 0) //Just go right/left
			x_rate = 1
			y_rate = 0
			return
		x_rate = delta_x / delta_y //Keep the larger step size at 1
		y_rate = 1

/**
 * Wrapper for walk_towards, not reccomended, as it's movement ends up being a bit stilted
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/move_towards_legacy(moving, chasing, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/move_towards_budget, priority, flags, extra_info, delay, timeout, chasing)

///The actual implementation of walk_towards()
/datum/move_loop/has_target/move_towards_budget

/datum/move_loop/has_target/move_towards_budget/move()
	var/turf/target_turf = get_step_towards(moving, target)
	var/atom/old_loc = moving.loc
	moving.Move(target_turf, get_dir(moving, target_turf))
	return old_loc != moving?.loc


/**
 * Helper proc for the move_rand datum
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * directions - A list of acceptable directions to try and move in. Defaults to GLOB.alldirs
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/move_rand(moving, directions, delay, timeout, subsystem, priority, flags, datum/extra_info)
	if(!directions)
		directions = GLOB.alldirs
	return add_to_loop(moving, subsystem, /datum/move_loop/move_rand, priority, flags, extra_info, delay, timeout, directions)

/**
 * This isn't actually the same as walk_rand
 * Because walk_rand is really more like walk_to_rand
 * It appears to pick a spot outside of range, and move towards it, then pick a new spot, etc.
 * I can't actually replicate this on our side, because of how bad our pathfinding is, and cause I'm not totally sure I know what it's doing.
 * I can just implement a random-walk though
**/
/datum/move_loop/move_rand
	var/list/potential_directions

/datum/move_loop/move_rand/setup(delay, timeout, list/directions)
	. = ..()
	if(!.)
		return
	potential_directions = directions

/datum/move_loop/move_rand/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, list/directions)
	if(..() && (length(potential_directions | directions) == length(potential_directions))) //i guess this could be usefull if actually it really has yet to move
		return TRUE

/datum/move_loop/move_rand/move()
	var/list/potential_dirs = potential_directions.Copy()
	while(potential_dirs.len)
		var/testdir = pick(potential_dirs)
		var/turf/moving_towards = get_step(moving, testdir)
		var/atom/old_loc = moving.loc
		moving.Move(moving_towards, testdir)
		if(old_loc != moving?.loc)  //If it worked, we're done
			return TRUE
		potential_dirs -= testdir
	return FALSE

/**
 * Wrapper around walk_rand(), doesn't actually result in a random walk, it's more like moving to random places in viewish
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/move_to_rand(moving, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/move_to_rand, priority, flags, extra_info, delay, timeout)

///Wrapper around step_rand
/datum/move_loop/move_to_rand

/datum/move_loop/move_to_rand/move()
	var/atom/old_loc = moving.loc
	step_rand(moving)
	return old_loc != moving?.loc

/**
 * Snowflake disposal movement. Moves a disposal holder along a chain of disposal pipes
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/move_disposals(moving, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/disposal_holder, priority, flags, extra_info, delay, timeout)

/// Disposal holders need to move through a chain of pipes
/// Rather then through the world. This supports this
/// If this ever changes, get rid of this, add drift component like logic to the holder
/// And move them to move()
/datum/move_loop/disposal_holder

/datum/move_loop/disposal_holder/setup(delay = 1, timeout = INFINITY)
	// This is a horrible pattern.
	// Move loops should almost never need to be one offs. Please don't do this if you can help it
	if(!istype(moving, /obj/structure/disposalholder))
		stack_trace("You tried to make a [moving.type] object move like a disposals holder, stop that!")
		return FALSE
	return ..()

/datum/move_loop/disposal_holder/move()
	var/obj/structure/disposalholder/holder = moving
	if(!holder.current_pipe)
		return FALSE
	var/atom/old_loc = moving.loc
	holder.current_pipe = holder.current_pipe.transfer(holder)
	return old_loc != moving?.loc
