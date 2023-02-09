/obj/structure/elevator_segment
	icon = 'icons/obj/elevator.dmi'
	icon_state = "elevator_maker"
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP
	//Helps us group elevator components
	var/id
	///What turf we'll throw under us when we kill daddy. If not set, we just use dad
	var/turf/base_turf
	///List of things we refuse to transport
	var/static/list/move_blacklist = typecacheof(list(/atom/movable/lighting_object ))

//Mapping preset - Primary Elevator
/obj/structure/elevator_segment/primary
	id = "primary"
	base_turf = /turf/open/floor/plasteel/elevatorshaft

/obj/structure/elevator_segment/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	//
	density = T.density
	anchored = density
	
	appearance = T.appearance
	layer = T.layer
	plane = T.plane
	//
	if(base_turf)
		qdel(T)
		base_turf = new(get_turf(src))
	//
	RegisterSignal(SSelevator_controller, COMSIG_ELEVATOR_MOVE, .proc/travel)

//Get a turf and move all it's contents with us
/obj/structure/elevator_segment/proc/travel(datum/source, _id, z_destination)
	SIGNAL_HANDLER

	if(_id != id)
		return
	var/turf/T = get_turf(src)
	//Move ourselves first
	var/turf/destination = locate(x, y, z_destination)
	if(!destination)
		return
	Move(destination)
	//Loop through turf contents
	for(var/atom/movable/i in T.contents)
		if(is_type_in_typecache(i, move_blacklist))
			continue
		i.Move(destination)
