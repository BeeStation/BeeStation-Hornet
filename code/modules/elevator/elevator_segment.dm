/obj/structure/elevator_segment
	icon = 'icons/obj/elevator.dmi'
	icon_state = "elevator_maker"
	z_flags = Z_BLOCK_OUT_DOWN | Z_BLOCK_IN_UP
	//Helps us group elevator components
	var/id
	///What turf we'll throw under us when we kill daddy. If not set, we just use dad
	var/turf/base_turf
	///List of things we refuse to transport
	var/static/list/move_blacklist
	///List of elevator music files - format : filepath = volume
	var/list/music_files

//Mapping preset - Primary Elevator
/obj/structure/elevator_segment/primary
	id = "primary"
	base_turf = /turf/open/floor/plasteel/elevatorshaft

// Glowstation
/obj/structure/elevator_segment/secure
	id = "secure"
	base_turf = /turf/open/floor/plasteel/elevatorshaft

/obj/structure/elevator_segment/Initialize(mapload)
	music_files = list('sound/effects/turbolift/elevatormusic.ogg' = 45, 'sound/effects/turbolift/elevator_loop.ogg' = 25)
	move_blacklist = typecacheof(list(/atom/movable/lighting_object, /obj/structure/cable, /obj/structure/disposalpipe, /obj/machinery/atmospherics/pipe))

	var/turf/T = get_turf(src)
	//Technical vanity
	density = T.density
	anchored = density
	//Vanity
	name = "elevator [T.name]"
	icon = T.icon
	icon_state = T.icon_state
	base_icon_state = T.base_icon_state
	layer = T.layer
	plane = T.plane
	RegisterSignal(T, COMSIG_ATOM_UPDATE_OVERLAYS,  PROC_REF(stage_one_copy))
	//Smoothing
	smoothing_flags = T.smoothing_flags
	smoothing_groups = T.smoothing_groups
	canSmoothWith = T.canSmoothWith
	//Replace the turf we're imitating
	if(base_turf)
		T.ChangeTurf(base_turf)
	//Register to the SS so we can move with minimal overhead
	RegisterSignal(SSelevator_controller, COMSIG_ELEVATOR_MOVE, PROC_REF(travel))
	//Register this for some animation stuff
	SSelevator_controller.append_id(id, src)
	//Music related
	RegisterSignal(get_turf(src), COMSIG_ATOM_ENTERED, PROC_REF(atom_enter))
	RegisterSignal(get_turf(src), COMSIG_ATOM_EXITED, PROC_REF(atom_exit))
	//Now that we have smoothing shit, we can do this
	return ..()

/obj/structure/elevator_segment/proc/stage_one_copy(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_ATOM_UPDATE_OVERLAYS)
	//wack
	addtimer(CALLBACK(src, PROC_REF(stage_two_copy)), 3 SECONDS)

/obj/structure/elevator_segment/proc/stage_two_copy()
	var/turf/T = get_turf(src)
	copy_overlays(T)
	T.cut_overlays()

//Get a turf and move all it's contents with us
/obj/structure/elevator_segment/proc/travel(datum/source, _id, z_destination, calltime, crashing)
	SIGNAL_HANDLER

	if(_id != id || z_destination == z)
		return
	var/old_z_this = z //used for animation
	var/turf/T = get_turf(src)
	UnregisterSignal(T, COMSIG_ATOM_ENTERED)
	UnregisterSignal(T, COMSIG_ATOM_EXITED)
	//Move ourselves first
	var/turf/destination = locate(x, y, z_destination)
	if(!destination)
		return
	forceMove(destination)
	RegisterSignal(get_turf(src), COMSIG_ATOM_ENTERED, PROC_REF(atom_enter))
	RegisterSignal(get_turf(src), COMSIG_ATOM_EXITED, PROC_REF(atom_exit))
	//Throw mobs out below us
	for(var/mob/living/i in destination.contents)
		//If it's a mob, throw it out of the way
		if(z_destination < old_z_this)
			var/turf/trg = get_edge_target_turf(i, pick(NORTH, EAST, SOUTH, WEST))
			i.throw_at(trg, 8, 8)
			i.Paralyze(8 SECONDS)
			i.adjustBruteLoss(15)
			i.AddElement(/datum/element/squish, 18 SECONDS)
			playsound(i, 'sound/effects/blobattack.ogg', 40, TRUE)
			playsound(i, 'sound/effects/splat.ogg', 50, TRUE)
	//Loop through turf contents
	for(var/atom/movable/i in T.contents)
		if(is_type_in_typecache(i, move_blacklist))
			continue
		var/old_z = i.get_virtual_z_level() //used for animation
		i.forceMove(destination)
		elevator_fx(i, old_z, z_destination, calltime)
		//lock airlocks and setup a timer to undo them
		if(istype(i, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/A = i
			INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, unbolt))
			INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, close))
			INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, bolt))
			addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/elevator_segment, unlock), A), calltime || 2 SECONDS)
		if(isliving(i) && crashing)
			var/mob/living/L = i
			L.Paralyze(3 SECONDS)

	elevator_fx(src, old_z_this, z_destination, calltime)

/obj/structure/elevator_segment/proc/unlock(obj/machinery/door/airlock/A)
	A.unbolt()
	A.open()

/obj/structure/elevator_segment/proc/atom_exit(datum/source, atom/movable/gone, direction)
	if(!isliving(gone))
		return
	var/mob/living/L = gone
	var/turf/T = get_turf(L)
	if(!(locate(/obj/structure/elevator_segment) in T))
		L.stop_sound_channel(CHANNEL_ELEVATOR_MUSIC)

/obj/structure/elevator_segment/proc/atom_enter(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(!isliving(arrived))
		return
	var/turf/T = get_turf(old_loc)
	if(!(locate(/obj/structure/elevator_segment) in T))
		var/music = pick(music_files)
		SEND_SOUND(arrived, sound(music, repeat = 1, wait = 0, channel = CHANNEL_ELEVATOR_MUSIC, volume = music_files[music]))

/obj/structure/elevator_segment/proc/elevator_fx(atom/target, input_z, z_destination, calltime, icon_size = 32)
	//animate us too - color
	var/original_color = target.color
	target.color = "#000"
	animate(target, color = original_color, time = calltime || 2 SECONDS, flags = ANIMATION_PARALLEL)
	//matrix
	var/matrix/ntransform = matrix(target.transform)
	var/matrix/otransform = matrix(target.transform)
	var/scale = 1
	if(z_destination > input_z)
		scale = 0.5
	else if(z_destination < input_z)
		scale = 2
	ntransform.Scale(scale)
	target.transform = ntransform
	animate(target, transform = otransform, time = calltime / 2 || 1 SECONDS, flags = ANIMATION_PARALLEL)
	//pixel adjustments
	var/x_diff = SSelevator_controller.elevator_group_positions[id]["middle"]["x"] - target.x
	var/y_diff = SSelevator_controller.elevator_group_positions[id]["middle"]["y"] - target.y
	var/ox = target.pixel_x
	var/oy = target.pixel_y
	target.pixel_x = x_diff * (icon_size - icon_size * scale)
	target.pixel_y = y_diff * (icon_size - icon_size * scale)
	animate(target, pixel_x = ox, time = calltime / 2 || 1 SECONDS, flags = ANIMATION_PARALLEL)
	animate(target, pixel_y = oy, time = calltime / 2 || 1 SECONDS, flags = ANIMATION_PARALLEL)
