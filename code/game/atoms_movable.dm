/atom/movable
	layer = OBJ_LAYER
	glide_size = 8
	appearance_flags = TILE_BOUND|PIXEL_SCALE|LONG_GLIDE

	var/move_stacks = 0 //how many times a this movable had movement procs called on it since Moved() was last called
	var/last_move = null
	var/last_move_time = 0
	var/anchored = FALSE
	var/move_resist = MOVE_RESIST_DEFAULT
	var/move_force = MOVE_FORCE_DEFAULT
	var/pull_force = PULL_FORCE_DEFAULT
	var/datum/thrownthing/throwing = null
	var/throw_speed = 2 //How many tiles to move per ds when being thrown. Float values are fully supported
	var/throw_range = 7
	var/mob/pulledby = null
	/// What language holder type to init as
	var/initial_language_holder = /datum/language_holder/atom_basic
	/// Holds all languages this mob can speak and understand
	VAR_PRIVATE/datum/language_holder/language_holder

	var/verb_say = "says"
	var/verb_ask = "asks"
	var/verb_exclaim = "exclaims"
	var/verb_whisper = "whispers"
	var/verb_sing = "sings"
	var/verb_yell = "yells"
	var/speech_span
	///Are we moving with inertia? Mostly used as an optimization
	var/inertia_moving = FALSE
	///Delay in deciseconds between inertia based movement
	var/inertia_move_delay = 5
	/// Things we can pass through while moving. If any of this matches the thing we're trying to pass's [pass_flags_self], then we can pass through.
	var/pass_flags = NONE
	/// If false makes CanPass call CanPassThrough on this type instead of using default behaviour
	var/generic_canpass = TRUE
	var/moving_diagonally = 0 //0: not doing a diagonal move. 1 and 2: doing the first/second step of the diagonal move
	var/atom/movable/moving_from_pull		//attempt to resume grab after moving instead of before.
	///Holds information about any movement loops currently running/waiting to run on the movable. Lazy, will be null if nothing's going on
	var/datum/movement_packet/move_packet
	var/list/acted_explosions	//for explosion dodging
	var/datum/forced_movement/force_moving = null	//handled soley by forced_movement.dm
	/**
	  * In case you have multiple types, you automatically use the most useful one.
	  * IE: Skating on ice, flippers on water, flying over chasm/space, etc.
	  * I reccomend you use the movetype_handler system and not modify this directly, especially for living mobs.
	  */
	var/movement_type = GROUND

	var/atom/movable/pulling
	var/grab_state = 0
	/// The strongest grab we can acomplish
	var/max_grab = GRAB_KILL
	var/throwforce = 0
	var/datum/component/orbiter/orbiting
	var/can_be_z_moved = TRUE

	/// Either [EMISSIVE_BLOCK_NONE], [EMISSIVE_BLOCK_GENERIC], or [EMISSIVE_BLOCK_UNIQUE]
	var/blocks_emissive = EMISSIVE_BLOCK_NONE
	///Internal holder for emissive blocker object, do not use directly use blocks_emissive
	var/atom/movable/emissive_blocker/em_block
	/**
	 * an associative lazylist of relevant nested contents by "channel", the list is of the form: list(channel = list(important nested contents of that type))
	 * each channel has a specific purpose and is meant to replace potentially expensive nested contents iteration
	 * do NOT add channels to this for little reason as it can add considerable memory usage.
	 */
	var/list/important_recursive_contents
	///contains every client mob corresponding to every client eye in this container. lazily updated by SSparallax and is sparse:
	///only the last container of a client eye has this list assuming no movement since SSparallax's last fire
	var/list/client_mobs_in_contents
	///Lazylist to keep track on the sources of illumination.
	var/list/affected_dynamic_lights
	///Highest-intensity light affecting us, which determines our visibility.
	var/affecting_dynamic_lumi = 0

	/// Whether this atom should have its dir automatically changed when it moves. Setting this to FALSE allows for things such as directional windows to retain dir on moving without snowflake code all of the place.
	var/set_dir_on_move = TRUE

/mutable_appearance/emissive_blocker

/mutable_appearance/emissive_blocker/New()
	. = ..()
	// Need to do this here because it's overridden by the parent call
	// This is a microop which is the sole reason why this child exists, because its static this is a really cheap way to set color without setting or checking it every time we create an atom
	color = EM_BLOCKER_MATRIX

/atom/movable/Initialize(mapload, ...)
	. = ..()

#if EMISSIVE_BLOCK_GENERIC != 0
	#error EMISSIVE_BLOCK_GENERIC is expected to be 0 to facilitate a weird optimization hack where we rely on it being the most common.
	#error Read the comment in code/game/atoms_movable.dm for details.
#endif

	// This one is incredible.
	// `if (x) else { /* code */ }` is surprisingly fast, and it's faster than a switch, which is seemingly not a jump table.
	// From what I can tell, a switch case checks every single branch individually, although sane, is slow in a hot proc like this.
	// So, we make the most common `blocks_emissive` value, EMISSIVE_BLOCK_GENERIC, 0, getting to the fast else branch quickly.
	// If it fails, then we can check over every value it can be (here, EMISSIVE_BLOCK_UNIQUE is the only one that matters).
	// This saves several hundred milliseconds of init time.
	if (blocks_emissive)
		if (blocks_emissive == EMISSIVE_BLOCK_UNIQUE)
			render_target = ref(src)
			em_block = new(src, src)
			overlays += em_block
			if(managed_overlays)
				if(islist(managed_overlays))
					managed_overlays += em_block
				else
					managed_overlays = list(managed_overlays, em_block)
			else
				managed_overlays = em_block
	else
		var/static/mutable_appearance/blocker = new()
		blocker.icon = icon
		blocker.icon_state = icon_state
		blocker.dir = dir
		blocker.appearance_flags = EMISSIVE_APPEARANCE_FLAGS
		// Ok so this is really cursed, but I want to set with this blocker cheaply while
		// Still allowing it to be removed from the overlays list later
		// So I'm gonna flatten it, then insert the flattened overlay into overlays AND the managed overlays list, directly
		// I'm sorry
		var/mutable_appearance/flat = blocker.appearance
		overlays += flat
		if(managed_overlays)
			if(islist(managed_overlays))
				managed_overlays += flat
			else
				managed_overlays = list(managed_overlays, flat)
		else
			managed_overlays = flat

	if(opacity)
		AddElement(/datum/element/light_blocking)
	switch(light_system)
		if(MOVABLE_LIGHT)
			AddComponent(/datum/component/overlay_lighting)
		if(MOVABLE_LIGHT_DIRECTIONAL)
			AddComponent(/datum/component/overlay_lighting, is_directional = TRUE)

	if(isturf(loc))
		var/turf/T = loc
		T.update_above() // Z-Mimic

/atom/movable/Destroy(force)
	QDEL_NULL(language_holder)
	QDEL_NULL(em_block)
	if(bound_overlay)
		QDEL_NULL(bound_overlay)

	unbuckle_all_mobs(force = TRUE)

	if(loc)
		//Restore air flow if we were blocking it (movables with ATMOS_PASS_PROC will need to do this manually if necessary)
		if(((can_atmos_pass == ATMOS_PASS_DENSITY && density) || can_atmos_pass == ATMOS_PASS_NO) && isturf(loc))
			can_atmos_pass = ATMOS_PASS_YES
			air_update_turf(TRUE, FALSE)
		loc.handle_atom_del(src)

	if(opacity)
		RemoveElement(/datum/element/light_blocking)

	invisibility = INVISIBILITY_ABSTRACT

	if(pulledby)
		pulledby.stop_pulling()
	if(pulling)
		stop_pulling()

	if(orbiting)
		orbiting.end_orbit(src)
		orbiting = null

	if(move_packet)
		if(!QDELETED(move_packet))
			qdel(move_packet)
		move_packet = null

	if(important_recursive_contents && (important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS] || important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
		SSspatial_grid.force_remove_from_cell(src)

	LAZYCLEARLIST(client_mobs_in_contents)

	. = ..()

	for(var/movable_content in contents)
		qdel(movable_content)

	moveToNullspace()

	//This absolutely must be after moveToNullspace()
	//We rely on Entered and Exited to manage this list, and the copy of this list that is on any /atom/movable "Containers"
	//If we clear this before the nullspace move, a ref to this object will be hung in any of its movable containers
	LAZYCLEARLIST(important_recursive_contents)


	vis_locs = null //clears this atom out of all viscontents

	// Checking length(vis_contents) before cutting has significant speed benefits
	if (length(vis_contents))
		vis_contents.Cut()

/atom/movable/proc/update_emissive_block()
	if(!blocks_emissive)
		return
	else if (blocks_emissive == EMISSIVE_BLOCK_GENERIC)
		var/mutable_appearance/gen_emissive_blocker = mutable_appearance(icon, icon_state, layer, EMISSIVE_PLANE)
		gen_emissive_blocker.dir = dir
		gen_emissive_blocker.appearance_flags = EMISSIVE_APPEARANCE_FLAGS
		gen_emissive_blocker.color = GLOB.em_blocker_matrix
		return gen_emissive_blocker
	else if(blocks_emissive == EMISSIVE_BLOCK_UNIQUE)
		if(!em_block && !QDELETED(src))
			render_target = ref(src)
			em_block = new(src, render_target)
		return em_block

/atom/movable/update_overlays()
	var/list/overlays = ..()
	var/emissive_block = update_emissive_block()
	if(emissive_block)
		// Emissive block should always go at the beginning of the list
		overlays.Insert(1, emissive_block)
	return overlays

/atom/movable/vv_edit_var(var_name, var_value)
	var/static/list/banned_edits = list("step_x", "step_y", "step_size", "bounds")
	var/static/list/careful_edits = list("bound_x", "bound_y", "bound_width", "bound_height")
	if(var_name in banned_edits)
		return FALSE	//PLEASE no.
	if((var_name in careful_edits) && (var_value % world.icon_size) != 0)
		return FALSE

	switch(var_name)
		if(NAMEOF(src, anchored))
			set_anchored(var_value)
			return TRUE
		if(NAMEOF(src, x))
			var/turf/T = locate(var_value, y, z)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, y))
			var/turf/T = locate(x, var_value, z)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, z))
			var/turf/T = locate(x, y, var_value)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, loc))
			if(istype(var_value, /atom))
				forceMove(var_value)
				return TRUE
			else if(isnull(var_value))
				moveToNullspace()
				return TRUE
			return FALSE
	return ..()

/atom/movable/proc/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	if(QDELETED(AM))
		return FALSE
	if(!(AM.can_be_pulled(src, state, force)))
		return FALSE

	// If we're pulling something then drop what we're currently pulling and pull this instead.
	if(pulling)
		if(state == 0)
			stop_pulling()
			return FALSE
		// Are we trying to pull something we are already pulling? Then enter grab cycle and end.
		if(AM == pulling)
			setGrabState(state)
			if(istype(AM,/mob/living))
				var/mob/living/AMob = AM
				AMob.grabbedby(src)
			return TRUE
		stop_pulling()

	if(AM.pulledby)
		log_combat(AM, AM.pulledby, "pulled from", src, important = FALSE)
		AM.pulledby.stop_pulling() //an object can't be pulled by two mobs at once.
	pulling = AM
	AM.set_pulledby(src)
	setGrabState(state)
	if(ismob(AM))
		var/mob/M = AM
		log_combat(src, M, "grabbed", addition="passive grab", important = FALSE)
		if(!supress_message)
			M.visible_message(span_warning("[src] grabs [M] passively."), \
				span_danger("[src] grabs you passively."))
	SEND_SIGNAL(pulling, COMSIG_MOVABLE_PULLED)
	return TRUE

/atom/movable/proc/stop_pulling()
	if(!pulling)
		return
	if(ismob(pulling?.pulledby))
		pulling.pulledby.log_message("has stopped pulling [key_name(pulling)]", LOG_ATTACK)
	if(ismob(pulling))
		pulling.log_message("has stopped being pulled by [key_name(pulling.pulledby)]", LOG_ATTACK)
	pulling.set_pulledby(null)
	setGrabState(GRAB_PASSIVE)
	var/mob/living/old_pulling = pulling
	pulling = null
	SEND_SIGNAL(old_pulling, COMSIG_ATOM_NO_LONGER_PULLED, src)
	//SEND_SIGNAL(src, COMSIG_ATOM_NO_LONGER_PULLING, old_pulling)

///Reports the event of the change in value of the pulledby variable.
/atom/movable/proc/set_pulledby(new_pulledby)
	if(new_pulledby == pulledby)
		return FALSE //null signals there was a change, be sure to return FALSE if none happened here.
	. = pulledby
	pulledby = new_pulledby

/atom/movable/proc/Move_Pulled(atom/A)
	if(!pulling)
		return FALSE
	if(pulling.anchored || pulling.move_resist > move_force || !pulling.Adjacent(src, src, pulling))
		stop_pulling()
		return FALSE
	if (HAS_TRAIT(pulling, TRAIT_NO_MOVE_PULL))
		stop_pulling()
		return FALSE
	if(isliving(pulling))
		var/mob/living/L = pulling
		if(L.buckled?.buckle_prevents_pull) //if they're buckled to something that disallows pulling, prevent it
			stop_pulling()
			return FALSE
	if(A == loc && pulling.density)
		return FALSE
	var/move_dir = get_dir(pulling.loc, A)
	if(!Process_Spacemove(move_dir))
		return FALSE
	pulling.Move(get_step(pulling.loc, move_dir), move_dir, glide_size)

/mob/living/Move_Pulled(atom/A)
	. = ..()
	if(!. || !isliving(A))
		return
	var/mob/living/L = A
	set_pull_offsets(L, grab_state)

/atom/movable/proc/check_pulling()
	if(pulling)
		var/atom/movable/pullee = pulling
		if(pullee && get_dist(src, pullee) > 1)
			stop_pulling()
			return
		if(!isturf(loc))
			stop_pulling()
			return
		if(pullee && !isturf(pullee.loc) && pullee.loc != loc) //to be removed once all code that changes an object's loc uses forceMove().
			log_game("DEBUG:[src]'s pull on [pullee] wasn't broken despite [pullee] being in [pullee.loc]. Pull stopped manually.")
			stop_pulling()
			return
		if(pulling.anchored || pulling.move_resist > move_force)
			stop_pulling()
			return
		if (HAS_TRAIT(pulling, TRAIT_NO_MOVE_PULL))
			stop_pulling()
			return
	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1)		//separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()

/atom/movable/proc/set_glide_size(target = 8)
	if (HAS_TRAIT(src, TRAIT_NO_GLIDE))
		return
	SEND_SIGNAL(src, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, target)
	glide_size = target

	for(var/mob/buckled_mob as anything in buckled_mobs)
		buckled_mob.set_glide_size(target)

/**
 * meant for movement with zero side effects. only use for objects that are supposed to move "invisibly" (like camera mobs or ghosts)
 * if you want something to move onto a tile with a beartrap or recycler or tripmine or mouse without that object knowing about it at all, use this
 * most of the time you want forceMove()
 */
/atom/movable/proc/abstract_move(atom/new_loc)
	var/atom/old_loc = loc
	move_stacks++
	loc = new_loc
	Moved(old_loc)

////////////////////////////////////////
// Here's where we rewrite how byond handles movement except slightly different
// To be removed on step_ conversion
// All this work to prevent a second bump
/atom/movable/Move(atom/newloc, direction, glide_size_override = 0, update_dir = TRUE)
	. = FALSE
	if(!newloc || newloc == loc)
		return

	if(!direction)
		direction = get_dir(src, newloc)

	if(set_dir_on_move && dir != direction && update_dir)
		setDir(direction)

	var/is_multi_tile_object = bound_width > 32 || bound_height > 32

	var/list/old_locs
	if(is_multi_tile_object && isturf(loc))
		old_locs = locs // locs is a special list, this is effectively the same as .Copy() but with less steps
		for(var/atom/exiting_loc as anything in old_locs)
			if(!exiting_loc.Exit(src, direction))
				return
	else
		if(!loc.Exit(src, direction))
			return

	var/list/new_locs
	if(is_multi_tile_object && isturf(newloc))
		new_locs = block(
			newloc,
			locate(
				min(world.maxx, newloc.x + CEILING(bound_width / 32, 1)),
				min(world.maxy, newloc.y + CEILING(bound_height / 32, 1)),
				newloc.z
				)
		) // If this is a multi-tile object then we need to predict the new locs and check if they allow our entrance.
		for(var/atom/entering_loc as anything in new_locs)
			if(!entering_loc.Enter(src))
				return
			if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, entering_loc) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
				return
	else // Else just try to enter the single destination.
		if(!newloc.Enter(src))
			return
		if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, newloc) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
			return

	// Past this is the point of no return
	var/atom/oldloc = loc
	var/area/oldarea = get_area(oldloc)
	var/area/newarea = get_area(newloc)
	move_stacks++

	loc = newloc

	. = TRUE

	if(old_locs) // This condition will only be true if it is a multi-tile object.
		for(var/atom/exited_loc as anything in (old_locs - new_locs))
			exited_loc.Exited(src, direction)
	else // Else there's just one loc to be exited.
		oldloc.Exited(src, direction)
	if(oldarea != newarea)
		oldarea.Exited(src, direction)

	if(new_locs) // Same here, only if multi-tile.
		for(var/atom/entered_loc as anything in (new_locs - old_locs))
			entered_loc.Entered(src, oldloc, old_locs)
	else
		newloc.Entered(src, oldloc, old_locs)
	if(oldarea != newarea)
		newarea.Entered(src, oldarea)

	Moved(oldloc, direction, FALSE, old_locs)

////////////////////////////////////////

/atom/movable/Move(atom/newloc, direct, glide_size_override = 0, update_dir = TRUE)
	var/atom/movable/pullee = pulling
	var/turf/T = loc
	if(!moving_from_pull)
		check_pulling()
	if(!loc || !newloc)
		return FALSE
	var/atom/oldloc = loc
	//Early override for some cases like diagonal movement
	if(glide_size_override)
		set_glide_size(glide_size_override)

	var/flat_direct = direct & ~(UP|DOWN)
	if(loc != newloc)
		if (!(flat_direct & (flat_direct - 1))) //Cardinal move
			. = ..()
		else //Diagonal move, split it into cardinal moves
			moving_diagonally = FIRST_DIAG_STEP
			var/first_step_dir
			// The `&& moving_diagonally` checks are so that a forceMove taking
			// place due to a Crossed, Bumped, etc. call will interrupt
			// the second half of the diagonal movement, or the second attempt
			// at a first half if step() fails because we hit something.
			if (direct & NORTH)
				if (direct & EAST)
					if (step(src, NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, EAST)
					else if (moving_diagonally && step(src, EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, NORTH)
				else if (direct & WEST)
					if (step(src, NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, WEST)
					else if (moving_diagonally && step(src, WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, NORTH)
			else if (direct & SOUTH)
				if (direct & EAST)
					if (step(src, SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, EAST)
					else if (moving_diagonally && step(src, EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, SOUTH)
				else if (direct & WEST)
					if (step(src, SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, WEST)
					else if (moving_diagonally && step(src, WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, SOUTH)
			if(moving_diagonally == SECOND_DIAG_STEP)
				if(!. && set_dir_on_move && update_dir)
					setDir(first_step_dir)
				else if (!inertia_moving)
					newtonian_move(direct)
			moving_diagonally = 0
			return

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = null
		return

	if(. && pulling && pulling == pullee && pulling != moving_from_pull) //we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored || HAS_TRAIT(pulling, TRAIT_NO_MOVE_PULL))
			stop_pulling()
		else
			var/pull_dir = get_dir(src, pulling)
			//puller and pullee more than one tile away or in diagonal position and whatever the pullee is pulling isn't already moving from a pull as it'll most likely result in an infinite loop a la ouroborus.
			if(!pulling.pulling?.moving_from_pull && (get_dist(src, pulling) > 1 || (moving_diagonally != SECOND_DIAG_STEP && ((pull_dir - 1) & pull_dir))))
				pulling.moving_from_pull = src
				pulling.Move(T, get_dir(pulling, T), glide_size) //the pullee tries to reach our previous position
				pulling.moving_from_pull = null
			check_pulling()


	//glide_size strangely enough can change mid movement animation and update correctly while the animation is playing
	//This means that if you don't override it late like this, it will just be set back by the movement update that's called when you move turfs.
	if(glide_size_override)
		set_glide_size(glide_size_override)

	last_move = direct
	last_move_time = world.time

	if(set_dir_on_move && dir != direct && update_dir)
		setDir(flat_direct)
	if(. && has_buckled_mobs() && !handle_buckled_mob_movement(loc, direct, glide_size_override)) //movement failed due to buckled mob(s)
		return FALSE

/**
 * Called after a successful Move(). By this point, we've already moved.
 * Arguments:
 * * old_loc is the location prior to the move. Can be null to indicate nullspace.
 * * movement_dir is the direction the movement took place. Can be NONE if it was some sort of teleport.
 * * The forced flag indicates whether this was a forced move, which skips many checks of regular movement.
 * * The old_locs is an optional argument, in case the moved movable was present in multiple locations before the movement.
 **/
/atom/movable/proc/Moved(atom/old_loc, movement_dir, forced = FALSE, list/old_locs)
	SHOULD_CALL_PARENT(TRUE)

	if(old_loc)
		var/turf/old_turf = get_turf(old_loc)
		var/turf/new_turf = get_turf(src)
		if(old_turf && new_turf && old_turf.z != new_turf.z)
			onTransitZ(old_turf.z, new_turf.z)
	if (!inertia_moving)
		newtonian_move(movement_dir)

	move_stacks--
	if(move_stacks > 0) //we want only the first Moved() call in the stack to send this signal, all the other ones have an incorrect old_loc
		return
	if(move_stacks < 0)
		stack_trace("move_stacks is negative in Moved()!")
		move_stacks = 0 //setting it to 0 so that we dont get every movable with negative move_stacks runtiming on every movement

	SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, old_loc, movement_dir, forced, old_locs)

	// Z-Mimic hook
	if (bound_overlay)
		// The overlay will handle cleaning itself up on non-openspace turfs.
		if (isturf(loc))
			bound_overlay.forceMove(get_step_multiz(src, UP))
			if (bound_overlay && dir != bound_overlay.dir)
				bound_overlay.setDir(dir)
		else	// Not a turf, so we need to destroy immediately instead of waiting for the destruction timer to proc.
			qdel(bound_overlay)

	var/turf/old_turf = get_turf(old_loc)
	var/turf/new_turf = get_turf(src)

	if(HAS_SPATIAL_GRID_CONTENTS(src))
		if(old_turf && new_turf && (old_turf.z != new_turf.z \
			|| ROUND_UP(old_turf.x / SPATIAL_GRID_CELLSIZE) != ROUND_UP(new_turf.x / SPATIAL_GRID_CELLSIZE) \
			|| ROUND_UP(old_turf.y / SPATIAL_GRID_CELLSIZE) != ROUND_UP(new_turf.y / SPATIAL_GRID_CELLSIZE)))

			SSspatial_grid.exit_cell(src, old_turf)
			SSspatial_grid.enter_cell(src, new_turf)

		else if(old_turf && !new_turf)
			SSspatial_grid.exit_cell(src, old_turf)

		else if(new_turf && !old_turf)
			SSspatial_grid.enter_cell(src, new_turf)

	return TRUE

// Make sure you know what you're doing if you call this, this is intended to only be called by byond directly.
// You probably want CanPass()
/atom/movable/Cross(atom/movable/AM)
	. = TRUE
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSS, AM)
	SEND_SIGNAL(AM, COMSIG_MOVABLE_CROSS_OVER, src)
	return CanPass(AM, get_dir(src, AM))

///default byond proc that is deprecated for us in lieu of signals. do not call
/atom/movable/Crossed(atom/movable/AM, oldloc)
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("atom/movable/Crossed() was called!")

/**
 * `Uncross()` is a default BYOND proc that is called when something is *going*
 * to exit this atom's turf. It is preferred over `Uncrossed` when you want to
 * deny that movement, such as in the case of border objects, objects that allow
 * you to walk through them in any direction except the one they block
 * (think side windows).
 *
 * While being seemingly harmless, most everything doesn't actually want to
 * use this, meaning that we are wasting proc calls for every single atom
 * on a turf, every single time something exits it, when basically nothing
 * cares.
 *
 * This overhead caused real problems on Sybil round #159709, where lag
 * attributed to Uncross was so bad that the entire master controller
 * collapsed and people made Among Us lobbies in OOC.
 *
 * If you want to replicate the old `Uncross()` behavior, the most apt
 * replacement is [`/datum/element/connect_loc`] while hooking onto
 * [`COMSIG_ATOM_EXIT`].
 */
/atom/movable/Uncross()
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("Uncross() should not be being called, please read the doc-comment for it for why.")

/**
 * default byond proc that is normally called on everything inside the previous turf
 * a movable was in after moving to its current turf
 * this is wasteful since the vast majority of objects do not use Uncrossed
 * use connect_loc to register to COMSIG_ATOM_EXITED instead
 */
/atom/movable/Uncrossed(atom/movable/AM)
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("/atom/movable/Uncrossed() was called")

/atom/movable/Bump(atom/A)
	if(!A)
		CRASH("Bump was called with no argument.")
	SEND_SIGNAL(src, COMSIG_MOVABLE_BUMP, A)
	. = ..()
	if(!QDELETED(throwing))
		throwing.finalize(hit = TRUE, target = A)
		. = TRUE
		if(QDELETED(A))
			return
	A.Bumped(src)

///called when this movable becomes the parent of a storage component that is currently being viewed by a player. uses important_recursive_contents
/atom/movable/proc/become_active_storage(datum/storage/source)
	if(!HAS_TRAIT(src, TRAIT_ACTIVE_STORAGE))
		for(var/atom/movable/location as anything in get_nested_locs(src) + src)
			LAZYADDASSOCLIST(location.important_recursive_contents, RECURSIVE_CONTENTS_ACTIVE_STORAGE, src)
	ADD_TRAIT(src, TRAIT_ACTIVE_STORAGE, REF(source))

///called when this movable's storage component is no longer viewed by any players, unsets important_recursive_contents
/atom/movable/proc/lose_active_storage(datum/storage/source)
	if(!HAS_TRAIT(src, TRAIT_ACTIVE_STORAGE))
		return
	REMOVE_TRAIT(src, TRAIT_ACTIVE_STORAGE, REF(source))
	if(HAS_TRAIT(src, TRAIT_ACTIVE_STORAGE))
		return

	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYREMOVEASSOC(location.important_recursive_contents, RECURSIVE_CONTENTS_ACTIVE_STORAGE, src)

///Sets the anchored var and returns if it was sucessfully changed or not.
/atom/movable/proc/set_anchored(anchorvalue)
	SHOULD_CALL_PARENT(TRUE)
	if(anchored == anchorvalue)
		return
	. = anchored
	anchored = anchorvalue
	SEND_SIGNAL(src, COMSIG_MOVABLE_SET_ANCHORED, anchorvalue)

/atom/movable/proc/forceMove(atom/destination)
	. = FALSE
	if(destination == null) //destination destroyed due to explosion
		return

	if(destination)
		. = doMove(destination)
	else
		CRASH("No valid destination passed into forceMove")

/atom/movable/proc/moveToNullspace()
	return doMove(null)

/atom/movable/proc/doMove(atom/destination)
	. = FALSE
	move_stacks++
	var/atom/oldloc = loc
	if(destination)
		if(pulledby)
			pulledby.stop_pulling()
		var/same_loc = oldloc == destination
		var/area/old_area = get_area(oldloc)
		var/area/destarea = get_area(destination)

		moving_diagonally = 0

		loc = destination

		if(!same_loc)
			if(oldloc)
				oldloc.Exited(src, destination)
				if(old_area && old_area != destarea)
					old_area.Exited(src, destination)
			destination.Entered(src, oldloc)
			if(destarea && old_area != destarea)
				destarea.Entered(src, old_area)

		. = TRUE

	//If no destination, move the atom into nullspace (don't do this unless you know what you're doing)
	else
		. = TRUE
		loc = null
		if (oldloc)
			var/area/old_area = get_area(oldloc)
			oldloc.Exited(src, null)
			if(old_area)
				old_area.Exited(src, null)

	Moved(oldloc, NONE, TRUE)

//Called whenever an object moves and by mobs when they attempt to move themselves through space
//And when an object or action applies a force on src, see newtonian_move() below
//Return 0 to have src start/keep drifting in a no-grav area and 1 to stop/not start drifting
//Mobs should return 1 if they should be able to move of their own volition, see client/Move() in mob_movement.dm
//movement_dir == 0 when stopping or any dir when trying to move
/atom/movable/proc/Process_Spacemove(movement_dir = FALSE)
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_SPACEMOVE, movement_dir) & COMSIG_MOVABLE_STOP_SPACEMOVE)
		return TRUE

	if(has_gravity(src))
		return TRUE

	if(pulledby && (pulledby.pulledby != src || moving_from_pull))
		return TRUE

	if(throwing)
		return TRUE

	if(!isturf(loc))
		return TRUE

	if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return TRUE

	return FALSE


/// Only moves the object if it's under no gravity
/// Accepts the direction to move, and if the push should be instant
/atom/movable/proc/newtonian_move(direction, instant = FALSE)
	if(!isturf(loc) || Process_Spacemove(0) || !direction)
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_NEWTONIAN_MOVE, direction) & COMPONENT_MOVABLE_NEWTONIAN_BLOCK)
		return TRUE

	set_glide_size(MOVEMENT_ADJUSTED_GLIDE_SIZE(inertia_move_delay, SSspacedrift.visual_delay))
	AddComponent(/datum/component/drift, direction, instant)

	return TRUE

/atom/movable/proc/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	set waitfor = FALSE
	var/hitpush = TRUE
	var/impact_flags = pre_impact(hit_atom, throwingdatum)
	if(impact_flags & COMPONENT_MOVABLE_IMPACT_NEVERMIND)
		return // in case a signal interceptor broke or deleted the thing before we could process our hit
	if(impact_flags & COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH)
		hitpush = FALSE
	var/caught = hit_atom.hitby(src, throwingdatum=throwingdatum, hitpush=hitpush)
	SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, throwingdatum, caught)
	return caught

///Called before we attempt to call hitby and send the COMSIG_MOVABLE_IMPACT signal
/atom/movable/proc/pre_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/impact_flags = SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_IMPACT, hit_atom, throwingdatum)
	var/target_flags = SEND_SIGNAL(hit_atom, COMSIG_ATOM_PREHITBY, src, throwingdatum)
	if(target_flags & COMSIG_HIT_PREVENTED)
		impact_flags |= COMPONENT_MOVABLE_IMPACT_NEVERMIND
	return impact_flags

/atom/movable/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked, datum/thrownthing/throwingdatum)
	if(!anchored && hitpush && (!throwingdatum || (throwingdatum.force >= (move_resist * MOVE_FORCE_PUSH_RATIO))))
		step(src, AM.dir)
	..(AM, skipcatch, hitpush, blocked, throwingdatum)

/atom/movable/proc/safe_throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG)
	if((force < (move_resist * MOVE_FORCE_THROW_RATIO)) || (move_resist == INFINITY))
		return
	return throw_at(target, range, speed, thrower, spin, diagonals_first, callback, force)

///If this returns FALSE then callback will not be called.
/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, quickstart = TRUE)
	. = FALSE

	if(QDELETED(src))
		CRASH("Qdeleted thing being thrown around.")

	//Snowflake case for click masks
	if (istype(target, /atom/movable/screen))
		target = target.loc

	if (!target || speed <= 0)
		return

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_THROW, args) & COMPONENT_CANCEL_THROW)
		return

	if (pulledby)
		pulledby.stop_pulling()


	//They are moving! Wouldn't it be cool if we calculated their momentum and added it to the throw?
	if (thrower && thrower.last_move && thrower.client && thrower.client.move_delay >= world.time + world.tick_lag*2)
		var/user_momentum = thrower.cached_multiplicative_slowdown
		if (!user_momentum) //no movement_delay, this means they move once per byond tick, lets calculate from that instead.
			user_momentum = world.tick_lag

		user_momentum = 1 / user_momentum // convert from ds to the tiles per ds that throw_at uses.

		if (get_dir(thrower, target) & last_move)
			user_momentum = user_momentum //basically a noop, but needed
		else if (get_dir(target, thrower) & last_move)
			user_momentum = -user_momentum //we are moving away from the target, lets slowdown the throw accordingly
		else
			user_momentum = 0


		if (user_momentum)
			//first lets add that momentum to range.
			range *= (user_momentum / speed) + 1
			//then lets add it to speed
			speed += user_momentum
			if (speed <= 0)
				return//no throw speed, the user was moving too fast.

	. = TRUE // No failure conditions past this point.

	var/target_zone
	if(QDELETED(thrower) || !istype(thrower))
		thrower = null //Let's not pass an invalid reference.
	else
		target_zone = thrower.get_combat_bodyzone(target)

	var/datum/thrownthing/TT = new(src, target, get_dir(src, target), range, speed, thrower, diagonals_first, force, callback, target_zone)

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)
	var/dx = (target.x > src.x) ? EAST : WEST
	var/dy = (target.y > src.y) ? NORTH : SOUTH

	if (dist_x == dist_y)
		TT.pure_diagonal = 1

	else if(dist_x <= dist_y)
		var/olddist_x = dist_x
		var/olddx = dx
		dist_x = dist_y
		dist_y = olddist_x
		dx = dy
		dy = olddx
	TT.dist_x = dist_x
	TT.dist_y = dist_y
	TT.dx = dx
	TT.dy = dy
	TT.diagonal_error = dist_x/2 - dist_y
	TT.start_time = world.time

	if(pulledby)
		pulledby.stop_pulling()
	movement_type |= THROWN

	throwing = TT
	if(spin)
		SpinAnimation(5, 1)

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_THROW, TT, spin)
	SSthrowing.processing[src] = TT
	if (SSthrowing.state == SS_PAUSED && length(SSthrowing.currentrun))
		SSthrowing.currentrun[src] = TT

	if(quickstart)
		TT.tick()

/atom/movable/proc/handle_buckled_mob_movement(newloc, direct, glide_size_override)
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		if(!buckled_mob.Move(newloc, direct, glide_size_override))
			doMove(buckled_mob.loc) //forceMove breaks buckles on stairs, use doMove
			last_move = buckled_mob.last_move
			last_move_time = world.time
			return FALSE
	return TRUE

/atom/movable/proc/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/atom/movable/proc/force_push(atom/movable/AM, force = move_force, direction, silent = FALSE)
	. = AM.force_pushed(src, force, direction)
	if(!silent && .)
		visible_message(span_warning("[src] forcefully pushes against [AM]!"), span_warning("You forcefully push against [AM]!"))

/atom/movable/proc/move_crush(atom/movable/AM, force = move_force, direction, silent = FALSE)
	. = AM.move_crushed(src, force, direction)
	if(!silent && .)
		visible_message(span_danger("[src] crushes past [AM]!"), span_danger("You crush [AM]!"))

/atom/movable/proc/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/atom/movable/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover in buckled_mobs)
		return TRUE

/// Returns true or false to allow src to move through the blocker, mover has final say
/atom/movable/proc/CanPassThrough(atom/blocker, movement_dir, blocker_opinion)
	SHOULD_CALL_PARENT(TRUE)
	return blocker_opinion

// called when this atom is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/atom/movable/proc/on_exit_storage(datum/storage/master_storage)
	return

// called when this atom is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/atom/movable/proc/on_enter_storage(datum/storage/master_storage)
	return

/atom/movable/proc/get_spacemove_backup()
	var/atom/movable/dense_object_backup
	for(var/A in orange(1, get_turf(src)))
		if(isarea(A))
			continue
		else if(isturf(A))
			var/turf/turf = A
			if(!turf.density)
				continue
			return turf
		else
			var/atom/movable/AM = A
			if(AM.density || !AM.CanPass(src, get_dir(src, AM)))
				if(AM.anchored)
					return AM
				dense_object_backup = AM
				break
	. = dense_object_backup

//Called when something resists while this atom is its loc
/atom/movable/proc/container_resist(mob/living/user)
	return

//Called when a mob resists while inside a container that is itself inside something.
/atom/movable/proc/relay_container_resist(mob/living/user, obj/O)
	return

/atom/movable/proc/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && (visual_effect_icon || used_item))
		do_item_attack_animation(A, visual_effect_icon, used_item)

	if(A == src)
		return //don't do an animation if attacking self
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/turn_dir = 1

	var/direction = get_dir(src, A)
	if(direction & NORTH)
		pixel_y_diff = 8
		turn_dir = prob(50) ? -1 : 1
	else if(direction & SOUTH)
		pixel_y_diff = -8
		turn_dir = prob(50) ? -1 : 1

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8

	var/matrix/initial_transform = matrix(transform)
	var/matrix/rotated_transform = transform.Turn(rand(13,17) * turn_dir)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, transform=rotated_transform, time = 1, easing=BACK_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, transform=initial_transform, time = 2, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

/atom/movable/proc/do_item_attack_animation(atom/attacked_atom, visual_effect_icon, obj/item/used_item)
	var/image/attack_image
	if(visual_effect_icon)
		attack_image = image(icon = 'icons/effects/effects.dmi', icon_state = visual_effect_icon)
	else if(used_item)
		attack_image = image(icon = used_item)
		attack_image.plane = GAME_PLANE

		// Scale the icon.
		attack_image.transform *= pick(0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55)
		// The icon should not rotate.
		attack_image.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

		// Set the direction of the icon animation.
		var/direction = get_dir(src, attacked_atom)
		if(direction & NORTH)
			attack_image.pixel_y = rand(-15,-11)
		else if(direction & SOUTH)
			attack_image.pixel_y = rand(11,15)

		if(direction & EAST)
			attack_image.pixel_x = rand(-15,-11)
		else if(direction & WEST)
			attack_image.pixel_x = rand(11,15)

		if(!direction) // Attacked self?!
			attack_image.pixel_z = 16

	if(!attack_image)
		return

	var/atom/movable/flick_visual/attack = attacked_atom.flick_overlay_view(attack_image, 1 SECONDS)
	var/matrix/copy_transform = new(transform)
	// And animate the attack!
	animate(attack, alpha = 175, transform = copy_transform.Scale(0.75), pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 0.3 SECONDS)
	animate(time = 0.1 SECONDS)
	animate(alpha = 0, time = 0.3 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

/// Common proc used by painting tools like spraycans and palettes that can access the entire 24 bits color space.
/obj/item/proc/pick_painting_tool_color(mob/user, default_color)
	var/chosen_color = tgui_color_picker(user,"Pick new color", "[src]", default_color)
	if(!chosen_color || QDELETED(src) || IS_DEAD_OR_INCAP(user) || !user.is_holding(src))
		return
	set_painting_tool_color(chosen_color)

/obj/item/proc/set_painting_tool_color(chosen_color)
	SEND_SIGNAL(src, COMSIG_PAINTING_TOOL_SET_COLOR, chosen_color)

/atom/movable/vv_get_dropdown()
	. = ..()
	. += "<option value='byond://?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(src)]'>Follow</option>"
	. += "<option value='byond://?_src_=holder;[HrefToken()];admingetmovable=[REF(src)]'>Get</option>"

	VV_DROPDOWN_OPTION(VV_HK_EDIT_PARTICLES, "Edit Particles")
	VV_DROPDOWN_OPTION(VV_HK_ADD_EMITTER, "Add Emitter")
	VV_DROPDOWN_OPTION(VV_HK_REMOVE_EMITTER, "Remove Emitter")

/atom/movable/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_EDIT_PARTICLES])
		if(!check_rights(R_VAREDIT))
			return
		var/client/interacted_client = usr.client
		interacted_client?.open_particle_editor(src)


	if(href_list[VV_HK_ADD_EMITTER])
		if(!check_rights(R_VAREDIT))
			return

		var/key = stripped_input(usr, "Enter a key for your emitter", "Emitter Key")
		var/lifetime = input("How long should this live for in deciseconds? 0 for infinite, -1 for a single burst.", "Lifespan") as null|num

		if(!key)
			return
		switch(alert("Should this be a pre-filled emitter (empty emitters don't support timers)?",,"Yes","No","Cancel"))
			if("Yes")
				var/choice = input(usr, "Choose an emitter to add", "Choose an Emitter") as null|anything in subtypesof(/obj/emitter)
				var/should_burst = FALSE
				if(lifetime == -1)
					should_burst = TRUE
				if(choice)
					add_emitter(choice, key, lifespan = lifetime, burst_mode = should_burst)
			if("No")
				add_emitter(/obj/emitter, key)
			else
				return

	if(href_list[VV_HK_REMOVE_EMITTER])
		if(!check_rights(R_VAREDIT))
			return
		if(!master_holder?.emitters.len)
			return
		var/removee = input(usr, "Choose an emitter to remove", "Choose an Emitter") as null|anything in master_holder?.emitters
		if(!removee)
			return
		remove_emitter(removee)

/atom/movable/proc/ex_check(ex_id)
	if(!ex_id)
		return TRUE
	LAZYINITLIST(acted_explosions)
	if(ex_id in acted_explosions)
		return FALSE
	acted_explosions += ex_id
	return TRUE

/* 	Language procs
*	Unless you are doing something very specific, these are the ones you want to use.
*/

/// Gets or creates the relevant language holder. For mindless atoms, gets the local one. For atom with mind, gets the mind one.
/atom/movable/proc/get_language_holder()
	RETURN_TYPE(/datum/language_holder)
	if(QDELING(src))
		CRASH("get_language_holder() called on a QDELing atom, \
			this will try to re-instantiate the language holder that's about to be deleted, which is bad.")

	if(!language_holder)
		language_holder = new initial_language_holder(src)
	return language_holder

/// Grants the supplied language and sets omnitongue true.
/atom/movable/proc/grant_language(language, language_flags = ALL, source = LANGUAGE_ATOM)
	return get_language_holder().grant_language(language, language_flags, source)

/// Grants every language.
/atom/movable/proc/grant_all_languages(language_flags = ALL, grant_omnitongue = TRUE, source = LANGUAGE_MIND)
	return get_language_holder().grant_all_languages(language_flags, grant_omnitongue, source)

/// Removes a single language.
/atom/movable/proc/remove_language(language, language_flags = ALL, source = LANGUAGE_ALL)
	return get_language_holder().remove_language(language, language_flags, source)

/// Removes every language and sets omnitongue false.
/atom/movable/proc/remove_all_languages(source = LANGUAGE_ALL, remove_omnitongue = FALSE)
	return get_language_holder().remove_all_languages(source, remove_omnitongue)

/// Adds a language to the blocked language list. Use this over remove_language in cases where you will give languages back later.
/atom/movable/proc/add_blocked_language(language, source = LANGUAGE_ATOM)
	return get_language_holder().add_blocked_language(language, source)

/// Removes a language from the blocked language list.
/atom/movable/proc/remove_blocked_language(language, source = LANGUAGE_ATOM)
	return get_language_holder().remove_blocked_language(language, source)

/// Checks if atom has the language. If spoken is true, only checks if atom can speak the language.
/atom/movable/proc/has_language(language, flags_to_check)
	return get_language_holder().has_language(language, flags_to_check)

/// Checks if atom can speak the language.
/atom/movable/proc/can_speak_language(language)
	return get_language_holder().can_speak_language(language)

/// Returns the result of tongue specific limitations on spoken languages.
/atom/movable/proc/could_speak_language(datum/language/language_path)
	return TRUE

/// Returns selected language, if it can be spoken, or finds, sets and returns a new selected language if possible.
/atom/movable/proc/get_selected_language()
	return get_language_holder().get_selected_language()

/// Gets a random understood language, useful for hallucinations and such.
/atom/movable/proc/get_random_understood_language()
	return get_language_holder().get_random_understood_language()

/// Gets a random spoken language, useful for forced speech and such.
/atom/movable/proc/get_random_spoken_language()
	return get_language_holder().get_random_spoken_language()

/// Copies all languages into the supplied atom/language holder. Source should be overridden when you
/// do not want the language overwritten by later atom updates or want to avoid blocked languages.
/atom/movable/proc/copy_languages(datum/language_holder/from_holder, source_override=FALSE, spoken=TRUE, understood=TRUE, blocked=TRUE)
	if(ismovable(from_holder))
		var/atom/movable/thing = from_holder
		from_holder = thing.get_language_holder()

	return get_language_holder().copy_languages(from_holder, source_override, spoken, understood, blocked)

/// Sets the passed path as the active language
/// Returns the currently selected language if successful, if the language was not valid, returns null
/atom/movable/proc/set_active_language(language_path)
	var/datum/language_holder/our_holder = get_language_holder()
	our_holder.selected_language = language_path

	return our_holder.get_selected_language() // verifies its validity, returns it if successful.

/**
 * Randomizes our atom's language to an uncommon language if:
 * - They are on the station Z level
 * OR
 * - They are on the escape shuttle
 */
/atom/movable/proc/randomize_language_if_on_station()
	var/turf/atom_turf = get_turf(src)
	var/area/atom_area = get_area(src)

	if(!atom_turf) // some machines spawn in nullspace
		return FALSE

	if(!is_station_level(atom_turf.z) && !istype(atom_area, /area/shuttle/escape))
		// Why snowflake check for escape shuttle? Well, a lot of shuttles spawn with machines
		// but docked at centcom, and I wanted those machines to also speak funny languages
		return FALSE
	grant_random_uncommon_language()
	return TRUE

/// Teaches a random non-common language and sets it as the active language
/atom/movable/proc/grant_random_uncommon_language(source)
	if (!length(GLOB.uncommon_roundstart_languages))
		return FALSE
	var/picked = pick(GLOB.uncommon_roundstart_languages)
	grant_language(picked, source = source)
	set_active_language(picked)
	return TRUE

/* End language procs */


//Returns an atom's power cell, if it has one. Overload for individual items.
/atom/movable/proc/get_cell()
	return

/atom/movable/proc/can_be_pulled(user, grab_state, force)
	if(src == user || !isturf(loc))
		return FALSE
	if(anchored || throwing)
		return FALSE
	if(force < (move_resist * MOVE_FORCE_PULL_RATIO))
		return FALSE
	return TRUE

/**
 * Updates the grab state of the movable
 *
 * This exists to act as a hook for behaviour
 */
/atom/movable/proc/setGrabState(newstate)
	if(newstate == grab_state)
		return
	SEND_SIGNAL(src, COMSIG_MOVABLE_SET_GRAB_STATE, newstate)
	. = grab_state
	grab_state = newstate
	switch(grab_state) // Current state.
		if(GRAB_PASSIVE)
			REMOVE_TRAIT(pulling, TRAIT_IMMOBILIZED, CHOKEHOLD_TRAIT)
			REMOVE_TRAIT(pulling, TRAIT_HANDS_BLOCKED, CHOKEHOLD_TRAIT)
			if(. >= GRAB_NECK) // Previous state was a a neck-grab or higher.
				REMOVE_TRAIT(pulling, TRAIT_FLOORED, CHOKEHOLD_TRAIT)
		if(GRAB_AGGRESSIVE)
			if(. >= GRAB_NECK) // Grab got downgraded.
				REMOVE_TRAIT(pulling, TRAIT_FLOORED, CHOKEHOLD_TRAIT)
			else // Grab got upgraded from a passive one.
				ADD_TRAIT(pulling, TRAIT_IMMOBILIZED, CHOKEHOLD_TRAIT)
				ADD_TRAIT(pulling, TRAIT_HANDS_BLOCKED, CHOKEHOLD_TRAIT)
		if(GRAB_NECK, GRAB_KILL)
			if(. <= GRAB_AGGRESSIVE)
				ADD_TRAIT(pulling, TRAIT_FLOORED, CHOKEHOLD_TRAIT)

/obj/item/proc/do_pickup_animation(atom/target, turf/source)
	set waitfor = FALSE
	if(!source)
		if(!istype(loc, /turf))
			return
		source = loc
	var/image/pickup_animation = image(icon = src)
	pickup_animation.plane = GAME_PLANE
	pickup_animation.transform *= 0.75
	pickup_animation.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	var/direction = get_dir(source, target)
	var/to_x = target.base_pixel_x
	var/to_y = target.base_pixel_y

	if(direction & NORTH)
		to_y += 32
	else if(direction & SOUTH)
		to_y -= 32
	if(direction & EAST)
		to_x += 32
	else if(direction & WEST)
		to_x -= 32
	if(!direction)
		to_y += 10
		pickup_animation.pixel_x += 6 * (prob(50) ? 1 : -1) //6 to the right or left, helps break up the straight upward move

	var/atom/movable/flick_visual/pickup = source.flick_overlay_view(pickup_animation, 0.4 SECONDS)
	var/matrix/animation_matrix = new(pickup.transform)
	animation_matrix.Turn(pick(-30, 30))
	animation_matrix.Scale(0.65)

	animate(pickup, alpha = 175, pixel_x = to_x, pixel_y = to_y, time = 0.3 SECONDS, transform = animation_matrix, easing = CUBIC_EASING)
	animate(alpha = 0, transform = matrix().Scale(0.7), time = 0.1 SECONDS)

/obj/item/proc/do_drop_animation(atom/moving_from)
	set waitfor = FALSE
	if(item_flags & WAS_THROWN)
		return
	if(movement_type & THROWN)
		return
	if(!istype(loc, /turf))
		return

	if(!istype(moving_from))
		return

	var/turf/current_turf = get_turf(src)
	var/direction = get_dir(moving_from, current_turf)
	var/from_x = moving_from.base_pixel_x
	var/from_y = moving_from.base_pixel_y

	if(direction & NORTH)
		from_y -= 32
	else if(direction & SOUTH)
		from_y += 32
	if(direction & EAST)
		from_x -= 32
	else if(direction & WEST)
		from_x += 32
	if(!direction)
		from_y += 10
		from_x += 6 * (prob(50) ? 1 : -1) //6 to the right or left, helps break up the straight upward move

	//We're moving from these chords to our current ones
	var/old_x = pixel_x
	var/old_y = pixel_y
	var/old_alpha = alpha
	var/matrix/old_transform = transform
	var/matrix/animation_matrix = new(old_transform)
	animation_matrix.Turn(pick(-30, 30))
	animation_matrix.Scale(0.7) // Shrink to start, end up normal sized

	pixel_x = from_x
	pixel_y = from_y
	alpha = 0
	transform = animation_matrix

	// This is instant on byond's end, but to our clients this looks like a quick drop
	animate(src, alpha = old_alpha, pixel_x = old_x, pixel_y = old_y, transform = old_transform, time = 3, easing = CUBIC_EASING)

/atom/movable/proc/get_spawner_desc()
	return name

/atom/movable/proc/get_spawner_flavour_text()
	return desc

/atom/movable/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()

	if(LAZYLEN(arrived.important_recursive_contents))
		var/list/nested_locs = get_nested_locs(src) + src
		for(var/channel in arrived.important_recursive_contents)
			for(var/atom/movable/location as anything in nested_locs)
				LAZYORASSOCLIST(location.important_recursive_contents, channel, arrived.important_recursive_contents[channel])

/atom/movable/Exited(atom/movable/gone, direction)
	. = ..()

	if(LAZYLEN(gone.important_recursive_contents))
		var/list/nested_locs = get_nested_locs(src) + src
		for(var/channel in gone.important_recursive_contents)
			for(var/atom/movable/location as anything in nested_locs)
				LAZYREMOVEASSOC(location.important_recursive_contents, channel, gone.important_recursive_contents[channel])

///allows this movable to hear and adds itself to the important_recursive_contents list of itself and every movable loc its in
/atom/movable/proc/become_hearing_sensitive(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE))
		for(var/atom/movable/location as anything in get_nested_locs(src) + src)
			LAZYADDASSOCLIST(location.important_recursive_contents, RECURSIVE_CONTENTS_HEARING_SENSITIVE, src)

		var/turf/our_turf = get_turf(src)
		if(our_turf && SSspatial_grid.initialized)
			SSspatial_grid.enter_cell(src, our_turf)

		else if(our_turf && !SSspatial_grid.initialized)//SSspatial_grid isnt init'd yet, add ourselves to the queue
			SSspatial_grid.enter_pre_init_queue(src, RECURSIVE_CONTENTS_HEARING_SENSITIVE)

	ADD_TRAIT(src, TRAIT_HEARING_SENSITIVE, trait_source)

/**
 * removes the hearing sensitivity channel from the important_recursive_contents list of this and all nested locs containing us if there are no more sources of the trait left
 * since RECURSIVE_CONTENTS_HEARING_SENSITIVE is also a spatial grid content type, removes us from the spatial grid if the trait is removed
 *
 * * trait_source - trait source define or ALL, if ALL, force removes hearing sensitivity. if a trait source define, removes hearing sensitivity only if the trait is removed
 */
/atom/movable/proc/lose_hearing_sensitivity(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE))
		return
	REMOVE_TRAIT(src, TRAIT_HEARING_SENSITIVE, trait_source)
	if(HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE))
		return

	var/turf/our_turf = get_turf(src)
	if(our_turf && SSspatial_grid.initialized)
		SSspatial_grid.exit_cell(src, our_turf)
	else if(our_turf && !SSspatial_grid.initialized)
		SSspatial_grid.remove_from_pre_init_queue(src, RECURSIVE_CONTENTS_HEARING_SENSITIVE)

	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYREMOVEASSOC(location.important_recursive_contents, RECURSIVE_CONTENTS_HEARING_SENSITIVE, src)

///allows this movable to know when it has "entered" another area no matter how many movable atoms its stuffed into, uses important_recursive_contents
/atom/movable/proc/become_area_sensitive(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_AREA_SENSITIVE))
		for(var/atom/movable/location as anything in get_nested_locs(src) + src)
			LAZYADDASSOCLIST(location.important_recursive_contents, RECURSIVE_CONTENTS_AREA_SENSITIVE, src)
	ADD_TRAIT(src, TRAIT_AREA_SENSITIVE, trait_source)

///removes the area sensitive channel from the important_recursive_contents list of this and all nested locs containing us if there are no more source of the trait left
/atom/movable/proc/lose_area_sensitivity(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_AREA_SENSITIVE))
		return
	REMOVE_TRAIT(src, TRAIT_AREA_SENSITIVE, trait_source)
	if(HAS_TRAIT(src, TRAIT_AREA_SENSITIVE))
		return

	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYREMOVEASSOC(location.important_recursive_contents, RECURSIVE_CONTENTS_AREA_SENSITIVE, src)

///propogates ourselves through our nested contents, similar to other important_recursive_contents procs
///main difference is that client contents need to possibly duplicate recursive contents for the clients mob AND its eye
/mob/proc/enable_client_mobs_in_contents()
	var/turf/our_turf = get_turf(src)

	if(our_turf && SSspatial_grid.initialized)
		SSspatial_grid.enter_cell(src, our_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)
	else if(our_turf && !SSspatial_grid.initialized)
		SSspatial_grid.enter_pre_init_queue(src, RECURSIVE_CONTENTS_CLIENT_MOBS)

	for(var/atom/movable/movable_loc as anything in get_nested_locs(src) + src)
		LAZYORASSOCLIST(movable_loc.important_recursive_contents, RECURSIVE_CONTENTS_CLIENT_MOBS, src)

///Clears the clients channel of this mob
/mob/proc/clear_important_client_contents()
	var/turf/our_turf = get_turf(src)

	if(our_turf && SSspatial_grid.initialized)
		SSspatial_grid.exit_cell(src, our_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)
	else if(our_turf && !SSspatial_grid.initialized)
		SSspatial_grid.remove_from_pre_init_queue(src, RECURSIVE_CONTENTS_CLIENT_MOBS)

	for(var/atom/movable/movable_loc as anything in get_nested_locs(src) + src)
		LAZYREMOVEASSOC(movable_loc.important_recursive_contents, RECURSIVE_CONTENTS_CLIENT_MOBS, src)

/// Can this mob move between z levels. pre_move is using in /mob/living to dictate is fuel is used based on move delay
/mob/proc/canZMove(direction, turf/source, turf/target, pre_move = TRUE)
	return FALSE
