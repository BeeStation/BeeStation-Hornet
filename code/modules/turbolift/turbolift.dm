//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 												D O C U M E N T A T I O N  			K m c 2 0 0 0 -> 22/01/2019																				//
// Turbolifts and you! How to make elevators with little to no effort.																														//
// ENSURE that the turbolift object ITSELF lines up with the others. This is to prevent the panel jumping about wildly and looking stupid													//
// If you want to make a multi door turbolift, place the controls at least 1 tile away from the doors. That way it switches to the more CPU intensive area based door acquisition system 	//
// This is area based! Ensure each turbolift is in a unique area, or things will get fucky																									//
// Ensure that turbolift doors are at least one tile away from the next lift. See DeepSpace13.dmm for examples. 																			//
// Use the indestructible elevator turfs or it'll look terrible!				  																											//
// Modify pixel_x and y as needed, it starts off snapped to the tile below a wall.																											//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//Areas//

/area/shuttle/turbolift //Only use subtypes of this area
	requires_power = FALSE //no APCS in the lifts please
	ambientsounds = list('sound/effects/turbolift/elevatormusic.ogg')
	luminosity = 0 //Lighting gets lost when it lands anyway
	var/turbolift_id

/area/shuttle/turbolift/primary
	name = "primary turbolift"
	turbolift_id = "primary_turbolift"

/area/shuttle/turbolift/secondary
	name = "secondary turbolift"
	turbolift_id = "secondary_turbolift"

/area/shuttle/turbolift/tertiary
	name = "tertiary turbolift"
	turbolift_id = "tertiary_turbolift"

/obj/docking_port/stationary/turbolift
	name = "turbolift"

/obj/docking_port/mobile/turbolift
	name = "turbolift"
	dir = NORTH

/obj/docking_port/mobile/turbolift/Initialize()
	. = ..()
	var/area/shuttle/turbolift/A = get_area(src)
	if(!istype(A, /area/shuttle/turbolift) || !A.turbolift_id)
		log_mapping("[src] placed in a non-turbolift area at [AREACOORD(src)]")
	if(!id)
		id = "[A.turbolift_id]"
	to_chat(world, "Turbolift mobile dock id: [id], location: [AREACOORD(src)]") //DEBUG
	if(!SSshuttle.getShuttle(id))
		to_chat(world, "Had to manually register") //DEBUG
		register()


/obj/docking_port/stationary/turbolift/Initialize()
	var/area/shuttle/turbolift/A = get_area(src)
	if((!istype(A, /area/shuttle/turbolift) || !A.turbolift_id) && !id)
		log_mapping("[src] placed in a non-turbolift area at [AREACOORD(src)]")
	if(!id)
		id = "[A.turbolift_id]_[src.z]"
	to_chat(world, "Turbolift stationary dock id: [id], location: [AREACOORD(src)]") //DEBUG
	. = ..()

//Structures and logic//

/obj/machinery/computer/turbolift
	name = "turbolift control console"
	icon = 'icons/obj/turbolift.dmi'
	icon_state = "lift-off"
	density = FALSE
	anchored = TRUE
	can_be_unanchored = FALSE
	mouse_over_pointer = MOUSE_HAND_POINTER
	desc = "Nanotrasen's decision to replace the iconic turboladder was not met with unanimous praise, experts citing increased obesity figures from crewmen no longer needing to climb vertically through several miles of deck to reach their target. However this is undoubtedly much faster."
	var/list/floor_directory
	var/list/turbolift_turfs = list()
	var/floor = 0 //This gets assigned on init(). Allows us to calculate where the lift needs to go next.
	var/list/destinations = list() //Any elevator that's on our path.
	pixel_y = 32 //This just makes it easier for locate...
	var/in_use = FALSE //Is someone using a lift? If they are, then don't let anyone in the lift.
	var/max_floor = 10 //Highest floor we can go to?
	var/bolted = FALSE //Is this door bolted or unbolted? do we need to change that if a person walks into our lift?
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/is_controller = FALSE //Are we controlling the other lifts?
	var/obj/machinery/computer/turbolift/master = null //Who is the one pulling the strings
	var/obj/machinery/door/airlock/linked_door = null //Linked elevator door
	var/shuttle_id
	var/list/possible_destinations

/obj/machinery/computer/turbolift/Initialize()
	..()
	var/area/shuttle/turbolift/A = get_area(src)
	shuttle_id = A.turbolift_id
	if(!shuttle_id)
		log_mapping("[src] placed in a non-turbolift area at [AREACOORD(src)]")
		return
	to_chat(world, "Turbolift shuttle ID: [shuttle_id]") //DEBUG

	return INITIALIZE_HINT_LATELOAD

///obj/machinery/computer/turbolift/LateInitialize()
	//handle_docking_ports()


	//get_position()
	//get_turfs()

/obj/machinery/computer/turbolift/proc/handle_docking_ports()
	to_chat(world, "Getting mobile dock")
	var/obj/docking_port/mobile/turbolift/mobile_dock = SSshuttle.getShuttle(shuttle_id)
	to_chat(world, "Mobile dock set: [mobile_dock.id]")
	for(var/obj/docking_port/stationary/turbolift/T in SSshuttle.stationary)
		if(findtext(T.id, shuttle_id))
			T.dir = mobile_dock.dir
			T.dwidth = mobile_dock.dwidth
			T.dheight = mobile_dock.dheight
			T.width = mobile_dock.width
			T.height = mobile_dock.height
			possible_destinations += "[T.id];"

/obj/machinery/door/airlock/turbolift
	name = "turbolift airlock"
	icon = 'icons/obj/turbolift_door.dmi'
	desc = "A sleek airlock for walking through. This one looks extremely strong."
	icon_state = "closed"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/machinery/door/airlock/turbolift/do_animate(animation)
	switch(animation)
		if("opening")
			flick("opening", src)
		if("closing")
			flick("closing", src)

/obj/machinery/door/airlock/turbolift/update_icon()
	cut_overlays()
	if(density)
		if(locked)
			icon_state = "locked"
		else
			icon_state = "closed"
		if(welded)
			add_overlay("welded")
	else
		icon_state = "open"

/turf/open/indestructible/turbolift
	name = "turbolift floor"
	desc = "A turbolift floor. You'd have an easier time destroying CentCom than breaking through this."

/turf/closed/indestructible/turbolift
	name = "turbolift wall"
	desc = "A turbolift wall. One of the strongest walls known to man."
	canSmoothWith = list(/turf/closed/indestructible/turbolift)


/obj/machinery/computer/turbolift/process()
	if(!is_controller)
		return
	/*if(loc_check())
		bolt_other_doors()
		return*/
	//unbolt_door()
	/*for(var/obj/machinery/computer/turbolift/S in destinations)
		if(S.loc_check()) //Someone's standing in the lift
			S.bolt_other_doors() //So bolt the other lifts
			return
		S.unbolt_door() //No one's in the lift, and the lift is not moving, so allow entrance
	*/


/obj/machinery/computer/turbolift/Destroy()
	STOP_PROCESSING(SSobj,src)
	. = ..()

/obj/machinery/computer/turbolift/attack_hand(mob/user)
	//START PLACEHOLDER
	SSshuttle.moveShuttle("turbolift_primary", "primary_turbolift_4", 0)
	return
	//END PLACEHOLDER DEBUG

	/*if(!shuttle_id)
		var/area/shuttle/turbolift/A = get_area(src)
		shuttle_id = A.turbolift_id
		if(!shuttle_id)
			log_mapping("[src] placed in a non-turbolift area at [AREACOORD(src)]")
			return
		to_chat(world, "Turbolift shuttle ID: [shuttle_id]") //DEBUG
		handle_docking_ports()*/
	. = ..()
	if(in_use)
		to_chat(user, "The turbolift is already moving!")
		return FALSE
	send_sound_lift('sound/effects/turbolift/turbolift-close.ogg')
	bolt_door()
	in_use = TRUE
	var/list/options = params2list(possible_destinations)
	for(var/id in options)
		var/obj/dock = SSshuttle.getDock(id)
		if(dock.z != src.z)
			to_chat(user, "Deck [dock.z]: [dock.name]")
	icon_state = "lift-off"
	var/S = input(user,"Select a deck (max: [max_floor])") as num
	if(S > max_floor || S <= 0 || S == floor)
		in_use = FALSE
		unbolt_door()
		return
	if(!S)
		return
	var/obj/docking_port/stationary/turbolift/destination
	for(var/id in options)
		to_chat(world, "Checking: [id]") //DEBUG
		var/obj/docking_port/stationary/turbolift/dock = SSshuttle.getDock(id)
		if(dock.z == S)
			to_chat(world, "Success: [dock.id]") //DEBUG
			destination = dock
			break
	SSshuttle.moveShuttle(shuttle_id, destination.id, 0)
	say("The turbolift is departing.")
	to_chat(world, "Shuttle departing.") //DEBUG
	/*if(shuttle_error)
		to_chat(world, "Shuttle error: [shuttle_error]") //DEBUG
	else
		to_chat(world, "Shuttle success.") //DEBUG
	*/
	/*for(var/obj/machinery/computer/turbolift/TS in destinations)
		if(TS.floor == S)
			user.say("Deck [S], fore.")
			send_sound_lift('sound/effects/turbolift/turbolift.ogg', TRUE)
			addtimer(CALLBACK(src, .proc/lift, TS), 90)
			icon_state = "lift-on"
			return*/

/obj/machinery/computer/turbolift/proc/send_sound_lift(var/sound,var/shake = FALSE)
	if(!sound)
		return
	for(var/turf/T in turbolift_turfs)
		for(var/mob/AM in T)
			SEND_SOUND(AM, sound)
			if(shake && AM.client)
				shake_camera(AM, 2, 2)


/obj/machinery/computer/turbolift/proc/lift(var/obj/machinery/computer/turbolift/target)
	in_use = FALSE
	icon_state = "lift-off"
	if(!target)
		return
	target.in_use = FALSE
	target.unbolt_door()
	for(var/turf/T in turbolift_turfs)
		for(var/atom/movable/AM in T)
			if(AM.anchored) //Don't teleport things that shouldn't go through
				if(istype(AM, /obj/machinery/computer/turbolift) || istype(AM, /obj/machinery/light) || istype(AM, /obj/machinery/door/airlock)) //Allow things that aren't part of the lift up
					continue
			if(isobserver(AM)) //Don't teleport ghosts
				continue
			if(isliving(AM))
				var/mob/living/M = AM
				if(M.client)
					shake_camera(M, 2,2)
			AM.z = target.z //Avoids the teleportation effect of zooming to random tiles

//Door management//

/obj/machinery/computer/turbolift/proc/bolt_other_doors()
	for(var/obj/machinery/computer/turbolift/SS in destinations)
		if(SS.bolted)
			continue
		SS.bolt_door()
		SS.in_use = TRUE

/obj/machinery/computer/turbolift/proc/unbolt_other_doors()
	for(var/obj/machinery/computer/turbolift/SS in destinations)
		if(!SS.bolted)
			continue
		SS.unbolt_door()
		SS.in_use = FALSE

/obj/machinery/computer/turbolift/proc/bolt_door()
	if(bolted)
		return
	if(!in_use)
		in_use = TRUE //so no one can ride the lift when it's locked
	if(!linked_door)
		linked_door = locate(/obj/machinery/door/airlock) in get_step(src, SOUTH)
		if(!linked_door || !istype(linked_door, /obj/machinery/door))
			for(var/obj/machinery/door/airlock/AS in get_area(src))  //If you have a big turbolift with multiple airlocks
				if(AS.z == z)
					linked_door = AS
	bolted = TRUE//Tones down the processing use
	linked_door.close()
	linked_door.bolt()

/obj/machinery/computer/turbolift/proc/unbolt_door()
	if(!bolted)
		return
	if(in_use)
		in_use = FALSE
	if(!linked_door)
		linked_door = locate(/obj/machinery/door/airlock) in get_step(src, SOUTH)
		if(!linked_door || !istype(linked_door, /obj/machinery/door))
			for(var/obj/machinery/door/airlock/AS in get_area(src))  //If you have a big turbolift with multiple airlocks
				if(AS.z == z)
					linked_door = AS
	bolted = FALSE//Tones down the processing use
	linked_door.unbolt()


//Find positions and related turfs//

/obj/machinery/computer/turbolift/proc/get_turfs()
	var/list/temp = get_area_turfs(get_area(src))
	for(var/turf/T in temp)
		if(T.z == z)
			turbolift_turfs += T

/obj/machinery/computer/turbolift/proc/get_position() //Let's see where I am in this world...
	var/obj/machinery/computer/turbolift/below = locate(/obj/machinery/computer/turbolift) in SSmapping.get_turf_below(get_turf(src))
	if(below) //We need to be the bottom lift for this to work.
		return
	START_PROCESSING(SSobj, src)
	floor = 1
	name = "[initial(name)] (Deck [floor])"
	is_controller = TRUE
	var/obj/machinery/computer/turbolift/previous
	var/obj/machinery/computer/turbolift/next
	for(var/II = 0 to world.maxz) //AKA 1 to 6 for example
		if(!previous)
			var/turf/T = SSmapping.get_turf_above(get_turf(src))
			var/obj/machinery/computer/turbolift/target = locate(/obj/machinery/computer/turbolift) in T
			next = target

		else
			var/turf/T = SSmapping.get_turf_above(get_turf(previous))
			var/obj/machinery/computer/turbolift/target = locate(/obj/machinery/computer/turbolift) in T
			next = target
		if(next)
			previous = next
			II ++
			next.master = src
			next.floor = II+1
			next.name = "[initial(next.name)] (Deck [next.floor])"
			destinations += next
		else
			max_floor = II+1
			for(var/obj/machinery/computer/turbolift/SSS in destinations)
				SSS.max_floor = max_floor
				SSS.destinations = destinations.Copy()
				SSS.destinations += src
				SSS.destinations -= SSS
			break //No more lifts, no need to loop again.
