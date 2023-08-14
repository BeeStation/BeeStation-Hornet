/datum/component/orbiter
	can_transfer = TRUE
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/list/current_orbiters
	var/datum/movement_detector/tracker

//radius: range to orbit at, radius of the circle formed by orbiting (in pixels)
//clockwise: whether you orbit clockwise or anti clockwise
//rotation_speed: how fast to rotate (how many ds should it take for a rotation to complete)
//rotation_segments: the resolution of the orbit circle, less = a more block circle, this can be used to produce hexagons (6 segments) triangles (3 segments), and so on, 36 is the best default.
//pre_rotation: Chooses to rotate src 90 degress towards the orbit dir (clockwise/anticlockwise), useful for things to go "head first" like ghosts
/datum/component/orbiter/Initialize(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	if(!istype(orbiter) || !isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE

	current_orbiters = list()

	begin_orbit(orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)

/datum/component/orbiter/RegisterWithParent()
	var/atom/target = parent

	target.orbit_datum = src
	if(ismovable(target))
		tracker = new(target, CALLBACK(src, PROC_REF(move_react)))

/datum/component/orbiter/UnregisterFromParent()
	var/atom/target = parent
	target.orbit_datum = null
	QDEL_NULL(tracker)

/datum/component/orbiter/Destroy()
	var/atom/master = parent
	if(master?.orbit_datum == src)
		master.orbit_datum = null
	for(var/i in current_orbiters)
		end_orbit(i)
	current_orbiters = null
	return ..()

/datum/component/orbiter/InheritComponent(datum/component/orbiter/newcomp, original, atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	if(!newcomp)
		begin_orbit(arglist(args.Copy(3)))
		return
	// The following only happens on component transfers
	for(var/o in newcomp.current_orbiters)
		var/atom/movable/incoming_orbiter = o
		incoming_orbiter.orbiting = src
		// It is important to transfer the signals so we don't get locked to the new orbiter component for all time
		newcomp.UnregisterSignal(incoming_orbiter, COMSIG_MOVABLE_MOVED)
		RegisterSignal(incoming_orbiter, COMSIG_MOVABLE_MOVED, PROC_REF(orbiter_move_react))
	current_orbiters += newcomp.current_orbiters
	newcomp.current_orbiters = null

/datum/component/orbiter/PostTransfer()
	if(!isatom(parent) || isarea(parent) || !get_turf(parent))
		return COMPONENT_INCOMPATIBLE
	move_react(parent)

/datum/component/orbiter/proc/begin_orbit(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	if(orbiter.orbiting)
		if(orbiter.orbiting == src)
			orbiter.orbiting.end_orbit(orbiter, TRUE)
		else
			orbiter.orbiting.end_orbit(orbiter)
	current_orbiters[orbiter] = TRUE
	orbiter.orbiting = src
	RegisterSignal(orbiter, COMSIG_MOVABLE_MOVED, PROC_REF(orbiter_move_react))
	SEND_SIGNAL(parent, COMSIG_ATOM_ORBIT_BEGIN, orbiter)
	var/matrix/initial_transform = matrix(orbiter.transform)
	current_orbiters[orbiter] = initial_transform

	// Head first!
	if(pre_rotation)
		var/matrix/M = matrix(orbiter.transform)
		var/pre_rot = 90
		if(!clockwise)
			pre_rot = -90
		M.Turn(pre_rot)
		orbiter.transform = M

	var/matrix/shift = matrix(orbiter.transform)
	shift.Translate(0, radius)
	orbiter.transform = shift

	orbiter.SpinAnimation(rotation_speed, -1, clockwise, rotation_segments, parallel = FALSE)

	orbiter.abstract_move(get_turf(parent))
	to_chat(orbiter, "<span class='notice'>Now orbiting [parent].</span>")

/datum/component/orbiter/proc/end_orbit(atom/movable/orbiter, refreshing=FALSE)
	if(!current_orbiters[orbiter])
		return
	UnregisterSignal(orbiter, COMSIG_MOVABLE_MOVED)
	SEND_SIGNAL(parent, COMSIG_ATOM_ORBIT_STOP, orbiter)
	orbiter.SpinAnimation(0, 0)
	if(istype(current_orbiters[orbiter],/matrix)) //This is ugly.
		orbiter.transform = current_orbiters[orbiter]
	current_orbiters -= orbiter
	orbiter.stop_orbit(src)
	orbiter.orbiting = null
	if(!refreshing && !length(current_orbiters) && !QDELING(src))
		qdel(src)

/**
 * [Proc Behavior]
 * 		If target_orbited is null, incoming_orbiter will stop orbiting and start to orbit the new target.
 * 			-> This is because 'check_orbitable()' makes an orbit component properly.
 * 		If original_orbited.current_orbiters has one orbiter, incoming_orbiter will stop orbiting and start to orbit the new target.
 * 			-> This is beacuse 'end_orbit()' removes an orbit component properly.
 * 		If target_orbited is not null, manually control signals (send, register, unregister), then transfer to the new target.
 * 			-> We can keep ghosts' orbit animation without glitching theirs.
 */
/datum/component/orbiter/proc/transfer_orbiter_to(atom/movable/incoming_orbiter, atom/new_target)
	if(!new_target || !incoming_orbiter)
		return
	if(!new_target.orbit_datum || length(current_orbiters)==1) // if target has no orbiters or original orbit has only one orbiter
		end_orbit(incoming_orbiter)
		incoming_orbiter.check_orbitable(new_target)
		return

	SEND_SIGNAL(parent, COMSIG_ATOM_ORBIT_STOP, incoming_orbiter)
	UnregisterSignal(incoming_orbiter, COMSIG_MOVABLE_MOVED)
	new_target.orbit_datum.RegisterSignal(incoming_orbiter, COMSIG_MOVABLE_MOVED, PROC_REF(orbiter_move_react))
	SEND_SIGNAL(new_target, COMSIG_ATOM_ORBIT_BEGIN, incoming_orbiter)

	incoming_orbiter.orbiting = new_target.orbit_datum
	new_target.orbit_datum.current_orbiters[incoming_orbiter] = current_orbiters[incoming_orbiter]
	current_orbiters -= incoming_orbiter

// This proc can receive signals by either the thing being directly orbited or anything holding it
/datum/component/orbiter/proc/move_react(atom/movable/master, atom/mover, atom/oldloc, direction)
	set waitfor = FALSE // Transfer calls this directly and it doesnt care if the ghosts arent done moving

	if(master.loc == oldloc)
		return

	var/turf/newturf = get_turf(master)
	if(!newturf)
		qdel(src)

	var/atom/curloc = master.loc
	for(var/atom/movable/movable_orbiter as anything in current_orbiters)
		if(QDELETED(movable_orbiter) || movable_orbiter.loc == newturf)
			continue
		movable_orbiter.abstract_move(newturf)
		if(CHECK_TICK && master.loc != curloc)
			// We moved again during the checktick, cancel current operation
			break


/datum/component/orbiter/proc/orbiter_move_react(atom/movable/orbiter, atom/oldloc, direction)
	SIGNAL_HANDLER

	if(orbiter.loc == get_turf(parent))
		return
	end_orbit(orbiter)

/////////////////////

/atom/movable/proc/check_orbitable(atom/A)
	if(!isatom(A))
		return
	if(A.orbit_datum?.parent == A) // orbiting what you're orbiting causes runtime
		return
	var/icon/I = icon(A.icon, A.icon_state, A.dir)
	var/orbitsize = (I.Width()+I.Height())*0.5
	orbitsize -= (orbitsize/world.icon_size)*(world.icon_size*0.25)
	orbit(A, orbitsize)

/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE)
	if(!istype(A) || !get_turf(A) || A == src)
		return

	return A.AddComponent(/datum/component/orbiter, src, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)

/atom/movable/proc/stop_orbit(datum/component/orbiter/orbits)
	return // We're just a simple hook

/// includes_everyone=FALSE: when an orbitted mob is a camera eye or something. That shouldn't transfer revenants.
/// includes_everyone=TRUE: when an orbitted mob is a mob who is being transformed(monkeyize). They should keep orbiters.
/atom/proc/transfer_observers_to(atom/target, includes_everyone=FALSE)
	if(!orbit_datum || !istype(target) || !get_turf(target) || target == src)
		return
	if(includes_everyone)
		target.TakeComponent(orbit_datum)
		return
	for(var/each in orbit_datum.current_orbiters)
		if(!isobserver(each))
			continue
		orbit_datum.transfer_orbiter_to(each, target)
