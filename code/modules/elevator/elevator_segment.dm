/obj/structure/elevator_segment
	icon = 'icons/obj/elevator.dmi'
	icon_state = "elevator_maker"
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP
	//Helps us group elevator components
	var/id
	///What turf we'll throw under us when we kill daddy. If not set, we just use dad
	var/turf/base_turf
	///List of things we refuse to transport
	var/static/list/move_blacklist = typecacheof(list(/atom/movable/lighting_object))

//Mapping preset - Primary Elevator
/obj/structure/elevator_segment/primary
	id = "primary"
	base_turf = /turf/open/floor/plasteel/elevatorshaft

/obj/structure/elevator_segment/Initialize(mapload)
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
	RegisterSignal(T, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/stage_one_copy)
	//Smoothing
	smoothing_flags = T.smoothing_flags
	smoothing_groups = T.smoothing_groups
	canSmoothWith = T.canSmoothWith
	//Replace the turf we're imitating
	if(base_turf)
		T.ChangeTurf(base_turf)
	//Register to the SS so we can move with minimal overhead
	RegisterSignal(SSelevator_controller, COMSIG_ELEVATOR_MOVE, .proc/travel)
	//Register this for some animation stuff
	SSelevator_controller.append_id(id, src)
	//Now that we have smoothing shit, we can do this
	return ..()

/obj/structure/elevator_segment/proc/stage_one_copy(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_ATOM_UPDATE_OVERLAYS)
	//wack
	addtimer(CALLBACK(src, .proc/stage_two_copy), 3 SECONDS)

/obj/structure/elevator_segment/proc/stage_two_copy()
	var/turf/T = get_turf(src)
	copy_overlays(T)
	T.cut_overlays()

//Get a turf and move all it's contents with us
/obj/structure/elevator_segment/proc/travel(datum/source, _id, z_destination, calltime, crashing)
	//We can't use SIGNAL_HANDLER since A.close() fucking sleeps

	if(_id != id || z_destination == z)
		return
	var/old_z_this = z //used for animation
	var/turf/T = get_turf(src)
	//Move ourselves first
	var/turf/destination = locate(x, y, z_destination)
	if(!destination)
		return
	forceMove(destination)
	//Throw mobs out below us
	for(var/mob/living/i in destination.contents)
		//If it's a mob, throw it out of the way
		if(z_destination < old_z_this)
			var/turf/trg = get_edge_target_turf(i, pick(NORTH, EAST, SOUTH, WEST))
			i.throw_at(trg, 8, 8)
			i.Paralyze(8 SECONDS)
			i.adjustBruteLoss(15)
			playsound(i, 'sound/effects/blobattack.ogg', 40, TRUE)
			playsound(i, 'sound/effects/splat.ogg', 50, TRUE)
	//Loop through turf contents
	for(var/atom/movable/i in T.contents)
		if(is_type_in_typecache(i, move_blacklist))
			continue
		var/old_z = i.z //used for animation
		i.forceMove(destination)
		elevator_fx(i, old_z, z_destination, calltime)
		//lock airlocks and setup a timer to undo them
		if(istype(i, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/A = i
			A.close()
			A.lock()
			addtimer(CALLBACK(src, .proc/unlock, A), calltime || 2 SECONDS)
		if(crashing && isliving(i))
			var/mob/living/L = i
			L.Paralyze(3 SECONDS)

	elevator_fx(src, old_z_this, z_destination, calltime)

/obj/structure/elevator_segment/proc/unlock(obj/machinery/door/airlock/A)
	A.unlock()
	A.open()

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
