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
	//possible shit code
	return ..()

//Get a turf and move all it's contents with us
/obj/structure/elevator_segment/proc/travel(datum/source, _id, z_destination)
	SIGNAL_HANDLER

	if(_id != id || z_destination == z)
		return
	var/old_z_this = z //used for animation
	var/turf/T = get_turf(src)
	//Move ourselves first
	var/turf/destination = locate(x, y, z_destination)
	if(!destination)
		return
	forceMove(destination)
	//Loop through turf contents
	for(var/atom/movable/i in T.contents)
		if(is_type_in_typecache(i, move_blacklist))
			continue
		var/old_z = i.z //used for animation
		i.forceMove(destination)
		elevator_fx(i, old_z, z_destination)
	elevator_fx(src, old_z_this, z_destination)

/obj/structure/elevator_segment/proc/elevator_fx(atom/target, input_z, z_destination, icon_size = 32)
	//animate us too - color
	var/original_color = target.color
	target.color = "#000"
	animate(target, color = original_color, time = 2 SECONDS, flags = ANIMATION_PARALLEL)
	//matrix
	var/matrix/ntransform = matrix(target.transform)
	var/matrix/otransform = matrix(target.transform)
	var/scale = 1
	if(z_destination > input_z)
		scale = 0.5 * (input_z * z_destination)
	else if(z_destination < input_z)
		scale = 2 * (z_destination / input_z)
	ntransform.Scale(scale)
	target.transform = ntransform
	animate(target, transform = otransform, time = 1 SECONDS, flags = ANIMATION_PARALLEL)
	//pixel adjustments
	var/x_diff = SSelevator_controller.elevator_group_positions[id]["middle"]["x"] - target.x
	var/y_diff = SSelevator_controller.elevator_group_positions[id]["middle"]["y"] - target.y
	var/ox = target.pixel_x
	var/oy = target.pixel_y
	target.pixel_x = x_diff * (icon_size - icon_size * scale)
	target.pixel_y = y_diff * (icon_size - icon_size * scale)
	animate(target, pixel_x = ox, time = 1 SECONDS, flags = ANIMATION_PARALLEL)
	animate(target, pixel_y = oy, time = 1 SECONDS, flags = ANIMATION_PARALLEL)
