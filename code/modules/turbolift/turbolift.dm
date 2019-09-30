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

/area/turbolift //Only use subtypes of this area
	requires_power = FALSE //no APCS in the lifts please
	ambientsounds = list('sound/effects/turbolift/elevatormusic.ogg')

/area/turbolift/primary
	name = "primary turbolift"

/area/turbolift/secondary
	name = "secondary turbolift"

/area/turbolift/tertiary
	name = "tertiary turbolift"



//Structures and logic//

/obj/structure/turbolift
	name = "turbolift control console"
	icon = 'icons/obj/turbolift.dmi'
	icon_state = "lift-off"
	density = FALSE
	anchored = TRUE
	can_be_unanchored = FALSE
	mouse_over_pointer = MOUSE_HAND_POINTER
	desc = "Nanotrasen's decision to replace the iconic turboladder was not met with unanimous praise, experts citing increased obesity figures from crewmen no longer needing to climb vertically through several miles of deck to reach their target. However this is undoubtedly much faster."
	var/floor_directory = "<font color=blue>\
		Deck 1: Engineering <br>\
		Deck 2: Promenade<br>\
		Deck 3: Bridge<br>\
		</font>" //Change this if you intend to make a new map. Helps players know where they're going.
	var/list/turbolift_turfs = list()
	var/floor = 0 //This gets assigned on init(). Allows us to calculate where the lift needs to go next.
	var/list/destinations = list() //Any elevator that's on our path.
	pixel_y = 32 //This just makes it easier for locate...
	var/in_use = FALSE //Is someone using a lift? If they are, then don't let anyone in the lift.
	var/max_floor = 0 //Highest floor we can go to?
	var/bolted = FALSE //Is this door bolted or unbolted? do we need to change that if a person walks into our lift?
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/is_controller = FALSE //Are we controlling the other lifts?
	var/obj/structure/turbolift/master = null //Who is the one pulling the strings
	var/obj/machinery/door/airlock/linked_door = null //Linked elevator door

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


/obj/structure/turbolift/process()
	if(!is_controller)
		return
	if(loc_check())
		bolt_other_doors()
		return
	unbolt_door()
	for(var/obj/structure/turbolift/S in destinations)
		if(S.loc_check()) //Someone's standing in the lift
			S.bolt_other_doors() //So bolt the other lifts
			return
		S.unbolt_door() //No one's in the lift, and the lift is not moving, so allow entrance

/obj/structure/turbolift/proc/loc_check() //Is there someone in the lift? if so, we need to stop other lifts from being used.
	for(var/turf/T in turbolift_turfs)
		if(locate(/mob/living) in T) //If there's a mob in these then bolt the other lifts so no one else can get on.
			return TRUE
	return FALSE


/obj/structure/turbolift/Destroy()
	STOP_PROCESSING(SSobj,src)
	. = ..()

/obj/structure/turbolift/attack_hand(mob/user)
	. = ..()
	if(in_use)
		to_chat(user, "The turbolift is already moving!")
		return FALSE
	send_sound_lift('sound/effects/turbolift/turbolift-close.ogg')
	bolt_door()
	in_use = TRUE
	to_chat(user, floor_directory)
	icon_state = "lift-off"
	var/S = input(user,"Select a deck (max: [max_floor])") as num
	if(S > max_floor || S <= 0 || S == floor)
		in_use = FALSE
		unbolt_door()
		return
	if(!S)
		return
	for(var/obj/structure/turbolift/TS in destinations)
		if(TS.floor == S)
			user.say("Deck [S], fore.")
			send_sound_lift('sound/effects/turbolift/turbolift.ogg', TRUE)
			addtimer(CALLBACK(src, .proc/lift, TS), 90)
			icon_state = "lift-on"
			return

/obj/structure/turbolift/proc/send_sound_lift(var/sound,var/shake = FALSE)
	if(!sound)
		return
	for(var/turf/T in turbolift_turfs)
		for(var/mob/AM in T)
			SEND_SOUND(AM, sound)
			if(shake && AM.client)
				shake_camera(AM, 2, 2)


/obj/structure/turbolift/proc/lift(var/obj/structure/turbolift/target)
	in_use = FALSE
	icon_state = "lift-off"
	if(!target)
		return
	target.in_use = FALSE
	target.unbolt_door()
	for(var/turf/T in turbolift_turfs)
		for(var/atom/movable/AM in T)
			if(AM.anchored) //Don't teleport things that shouldn't go through
				if(istype(AM, /obj/structure/turbolift) || istype(AM, /obj/machinery/light) || istype(AM, /obj/machinery/door/airlock)) //Allow things that aren't part of the lift up
					continue
			if(isobserver(AM)) //Don't teleport ghosts
				continue
			if(isliving(AM))
				var/mob/living/M = AM
				if(M.client)
					shake_camera(M, 2,2)
			AM.z = target.z //Avoids the teleportation effect of zooming to random tiles

//Door management//

/obj/structure/turbolift/proc/bolt_other_doors()
	for(var/obj/structure/turbolift/SS in destinations)
		if(SS.bolted)
			continue
		SS.bolt_door()
		SS.in_use = TRUE

/obj/structure/turbolift/proc/unbolt_other_doors()
	for(var/obj/structure/turbolift/SS in destinations)
		if(!SS.bolted)
			continue
		SS.unbolt_door()
		SS.in_use = FALSE

/obj/structure/turbolift/proc/bolt_door()
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

/obj/structure/turbolift/proc/unbolt_door()
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


/obj/structure/turbolift/Initialize()
	. = ..()
	get_position()
	get_turfs()

//Find positions and related turfs//

/obj/structure/turbolift/proc/get_turfs()
	var/list/temp = get_area_turfs(get_area(src))
	for(var/turf/T in temp)
		if(T.z == z)
			turbolift_turfs += T

/obj/structure/turbolift/proc/get_position() //Let's see where I am in this world...
	var/obj/structure/turbolift/below = locate(/obj/structure/turbolift) in SSmapping.get_turf_below(get_turf(src))
	if(below) //We need to be the bottom lift for this to work.
		return
	START_PROCESSING(SSobj, src)
	floor = 1
	name = "[initial(name)] (Deck [floor])"
	is_controller = TRUE
	var/obj/structure/turbolift/previous
	var/obj/structure/turbolift/next
	for(var/II = 0 to world.maxz) //AKA 1 to 6 for example
		if(!previous)
			var/turf/T = SSmapping.get_turf_above(get_turf(src))
			var/obj/structure/turbolift/target = locate(/obj/structure/turbolift) in T
			next = target

		else
			var/turf/T = SSmapping.get_turf_above(get_turf(previous))
			var/obj/structure/turbolift/target = locate(/obj/structure/turbolift) in T
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
			for(var/obj/structure/turbolift/SSS in destinations)
				SSS.max_floor = max_floor
				SSS.destinations = destinations.Copy()
				SSS.destinations += src
				SSS.destinations -= SSS
			break //No more lifts, no need to loop again.
