GLOBAL_LIST_EMPTY(turbolifts)

/obj/docking_port/stationary/turbolift
	name = "turbolift"
	area_type = /area/shuttle/turbolift/shaft
	var/bottom_floor = FALSE
	var/ztrait = ZTRAIT_STATION //In case we want elevators elsewhere. Multi-z lavaland mining base, anyone?
	var/deck = 1

/obj/docking_port/mobile/turbolift
	name = "turbolift"
	dir = NORTH
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	var/obj/machinery/computer/turbolift/turbolift_computer

/obj/docking_port/mobile/turbolift/Initialize()
	register()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/docking_port/mobile/turbolift/LateInitialize()
	for(var/T in GLOB.turbolifts)
		var/obj/machinery/computer/turbolift/C = T
		if(C.shuttle_id == id)
			turbolift_computer = C
			to_chat(world, "FOUND TURBOLIFT COMPUTER") //DEBUG
			break

	if(!turbolift_computer)
		log_mapping("TURBOLIFT: [src] failed to find its turbolift computer at [AREACOORD(src)]")
		message_admins("TURBOLIFT: [src] failed to find its turbolift computer at [AREACOORD(src)]")
		return

	to_chat(world, "GETTING STATIONARY DOCK") //DEBUG
	var/obj/docking_port/stationary/turbolift/turbolift_dock
	for(var/S in SSshuttle.stationary)
		var/obj/docking_port/stationary/turbolift/SM = S
		to_chat(world, "GOT THIS FAR.") //DEBUG
		if(!istype(SM))
			continue
		to_chat(world, "FOUND THE BASTARD")
		to_chat(world, "REEEE. SM ID: [SM.id], ID: [id], BOTTOM: [SM.bottom_floor]") //DEBUG
		if(findtext(SM.id, id) && SM.bottom_floor)
			turbolift_dock = SM
			break
	if(!turbolift_dock)
		log_mapping("TURBOLIFT: [src] failed to find its dock at [AREACOORD(src)]")
		message_admins("TURBOLIFT: [src] failed to find its dock at [AREACOORD(src)]")
		return
	if(!turbolift_dock.bottom_floor)
		log_mapping("TURBOLIFT: [src] was loaded in somewhere other than the lowest floor at [AREACOORD(src)]")
		message_admins("TURBOLIFT: [src] was loaded in somewhere other than the lowest floor at [AREACOORD(src)]")
		return

	to_chat(world, "TRYING TO LOCATE") //DEBUG
	turbolift_dock.locate_floors(src)

/obj/docking_port/stationary/turbolift/Initialize()
	. = ..()
	id = "[id]_[src.z]"
	var/lower_dock = (locate(/obj/docking_port/stationary/turbolift) in SSmapping.get_turf_below(get_turf(src)))
	if(!lower_dock)
		to_chat(world, "FOUND BOTTOM DOCK: [src], ID: [id] at [AREACOORD(src)]") //DEBUG
		bottom_floor = TRUE //We let the lowest dock handle finding all of the other docks


/obj/docking_port/stationary/turbolift/proc/locate_floors(var/obj/docking_port/mobile/turbolift/dock)
	if(!bottom_floor)
		return
	var/obj/docking_port/mobile/turbolift/M = SSshuttle.getShuttle(dock.id)
	if(!M)
		log_mapping("TURBOLIFT: [src] failed to find mobile dock: [dock.id]")
		message_admins("TURBOLIFT: [src] failed to find mobile dock: [dock.id]")
	to_chat(world, "FOUND MOBILE DOCK") //DEBUG
	M.turbolift_computer.possible_destinations += "[id]"
	to_chat(world, "ADDED SRC") //DEBUG

	for(var/S in SSshuttle.stationary)
		var/obj/docking_port/stationary/turbolift/SM = S
		to_chat(world, "GOT THIS FAR.") //DEBUG
		if(!istype(SM))
			continue
		to_chat(world, "FOUND A BASTARD")
		if(findtext(SM.id, M.id) && !SM.bottom_floor)
			to_chat(world, "ADDED [SM] at [AREACOORD(SM)]") //DEBUG
			SM.deck = (SM.z - src.z + src.deck)
			SM.dir = dir
			SM.dwidth = dwidth
			SM.dheight = dheight
			SM.width = width
			SM.height = height
			M.turbolift_computer.possible_destinations += "[SM.id]"

	to_chat(world, "FINISHED LOCATING") //DEBUG

//Structures and logic//

/obj/machinery/turbolift_button
	icon = 'icons/obj/turbolift.dmi'
	icon_state = "button"
	can_be_unanchored = FALSE
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	use_power = IDLE_POWER_USE
	idle_power_usage = 2

	var/shuttle_id //Needs to match the turbolift computer & mobile dock
	var/floor_id

/obj/machinery/turbolift_button/Initialize()
	. = ..()
	if(!shuttle_id)
		log_mapping("TURBOLIFT: [src] has no shuttle_id at [AREACOORD(src)]")
		message_admins("TURBOLIFT: [src] has no shuttle_id at [AREACOORD(src)]")
		return
	floor_id = "[shuttle_id]_[src.z]"

/obj/machinery/turbolift_button/attack_hand(mob/user)
	if (stat & NOPOWER)
		to_chat(user, "<span class='notice'>[src] does not respond.</span>")
	if(!shuttle_id || !floor_id)
		say("An unexpected error has occured. Please contact a Nanotrasen Turbolift Repair Technician.")
		return

	var/obj/docking_port/mobile/turbolift/M = SSshuttle.getShuttle(shuttle_id)
	var/obj/machinery/computer/turbolift/T = M?.turbolift_computer
	if(!M || !T)
		say("An unexpected error has occured. Please contact a Nanotrasen Turbolift Repair Technician.")
		return

	if("[floor_id]" in T.destination_queue)
		to_chat(user, "<span class='notice'>The current deck is already queued.</span>")
	else if(T.z == src.z)
		to_chat(user, "<span class='notice'>The turbolift is already at this deck.</span>")
	else
		say("The turbolift will arrive shortly. Thank you for using Nanotrasen Turbolift Services(TM).")
		T.destination_queue += "[floor_id]"
		START_PROCESSING(SSmachines, T)

/obj/machinery/computer/turbolift
	name = "turbolift control console"
	icon = 'icons/obj/turbolift.dmi'
	icon_state = "panel"
	density = FALSE
	anchored = TRUE
	can_be_unanchored = FALSE
	mouse_over_pointer = MOUSE_HAND_POINTER
	desc = "Nanotrasen's decision to replace the iconic turboladder was not met with unanimous praise, experts citing increased obesity figures from crewmen no longer needing to climb vertically through several miles of deck to reach their target. However this is undoubtedly much faster."
	pixel_y = 32
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

	var/shuttle_id //Needs to match the mobile docking port's ID
	var/list/possible_destinations = list()
	var/list/airlocks = list()
	var/list/destination_queue = list()
	var/time_between_stops = 50 //Time in deciseconds before going to the next location in the queue. //DEBUG PLACEHOLDER
	var/in_use = FALSE
	var/online = TRUE //Is the elevator functional? Will be expanded upon later

	var/list/deck_descriptions = list()

/obj/machinery/computer/turbolift/Initialize()
	. = ..()
	GLOB.turbolifts += src

/obj/machinery/door/airlock/turbolift
	name = "turbolift airlock"
	icon = 'icons/obj/turbolift_door.dmi'
	desc = "A sleek airlock for walking through. This one looks extremely strong."
	icon_state = "closed"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/obj/machinery/computer/turbolift/lift_computer
	var/dock_dir

/obj/machinery/door/airlock/turbolift/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	to_chat(world, "ME: [AREACOORD(src)] TURF: [T.below()], AREA: [A.name]") //DEBUG
	if(T.below() && !istype(A, /area/shuttle/turbolift)) //We know the elevator will spawn on the bottom floor, and the airlocks on all other floors should stay closed.
		unbolt()
		close()
		bolt()
	else
		unbolt()
		open()
		bolt()

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
	//canSmoothWith = list(/turf/closed/indestructible/turbolift)
	smooth = TRUE

/obj/machinery/computer/turbolift/Destroy()
	GLOB.turbolifts -= src
	var/obj/docking_port/mobile/turbolift/M = SSshuttle.getShuttle(shuttle_id)
	if(M)
		M.turbolift_computer = null
	for(var/obj/machinery/door/airlock/turbolift/A in airlocks)
		A.lift_computer = null
	. = ..()

/obj/machinery/computer/turbolift/proc/find_airlocks()
	for(var/obj/machinery/door/airlock/turbolift/L in get_area(src))
		airlocks += L
		L.lift_computer = src
		var/obj/docking_port/mobile/turbolift/M = SSshuttle.getShuttle(shuttle_id)
		L.dock_dir = M.dir

/obj/machinery/computer/turbolift/proc/close_airlock(var/obj/machinery/door/airlock/turbolift/T)
	T.unbolt()
	T.close()
	T.bolt()
	var/obj/machinery/door/airlock/turbolift/A = locate(/obj/machinery/door/airlock/turbolift) in get_step(T, T.dock_dir)
	if(!A)
		to_chat(world, "Couldn't find the other airlock!") //DEBUG
		return
	A.unbolt()
	A.close()
	A.bolt()

/obj/machinery/computer/turbolift/proc/open_airlock(var/obj/machinery/door/airlock/turbolift/T)
	T.unbolt()
	T.open()
	T.bolt()
	var/obj/machinery/door/airlock/turbolift/A = locate(/obj/machinery/door/airlock/turbolift) in get_step(T, T.dock_dir)
	if(!A)
		to_chat(world, "Couldn't find the other airlock!") //DEBUG
		return
	A.unbolt()
	A.open()
	A.bolt()

/obj/machinery/computer/turbolift/attack_hand(mob/user)
	for(var/id in possible_destinations)
		var/obj/docking_port/stationary/turbolift/dock = SSshuttle.getDock(id)
		if(dock.z != src.z)
			to_chat(user, "Deck [dock.deck]: [dock.name]")
	var/S = input(user,"Select a deck") as num
	if(S > 1000 || S <= 0)
		to_chat(user, "<span class='warning'>Deck [S] is not a valid destination!</span>")
		return
	if(!S)
		return
	var/obj/docking_port/stationary/turbolift/destination
	for(var/id in possible_destinations)
		to_chat(world, "Checking: [id]") //DEBUG
		var/obj/docking_port/stationary/turbolift/dock = SSshuttle.getDock(id)
		if(dock.deck == S)
			to_chat(world, "Success: [dock.id]") //DEBUG
			destination = dock
			break
	if(!destination || !("[destination.id]" in possible_destinations))
		to_chat(user, "<span class='warning'>Deck [S] is not a valid destination!</span>")
		return
	if(destination.z == src.z)
		to_chat(user, "<span class='notice'>Deck [S] is the current deck.</span>")
		return
	if("[destination.id]" in destination_queue)
		to_chat(user, "<span class='notice'>Deck [destination.deck] is already queued.</span>")
		return
	destination_queue += "[destination.id]"
	if(online)
		START_PROCESSING(SSmachines, src)
		to_chat(world, "SHOULD PROCESS NOW") //DEBUG
	else
		say("An unexpected error has occured. Please contact a Nanotrasen Turbolift Repair Technician.")
		to_chat(world, "OFFLINE, DIDN'T START PROCESSING") //DEBUG

/obj/machinery/computer/turbolift/process()
	to_chat(world, "I ATTEMPTED TO PROCESS") //DEBUG
	if(!online)
		STOP_PROCESSING(SSmachines, src)
		return
	if(!destination_queue.len)
		STOP_PROCESSING(SSmachines, src)
		to_chat(world, "I AM NO LONGER PROCESSING.") //DEBUG
		for(var/obj/machinery/door/airlock/turbolift/T in airlocks) //Just in case. Don't want anybody to get locked in.
			INVOKE_ASYNC(src, .proc/open_airlock, T)
		return

	if(!in_use)
		in_use = TRUE
		var/debug = destination_queue[1]	//DEBUG
		to_chat(world, "Process called premove for: [debug]") //DEBUG
		pre_move(destination_queue[1])

/obj/machinery/computer/turbolift/proc/pre_move(var/destination_id)
	if(!airlocks.len)
		find_airlocks()
	var/obj/docking_port/stationary/turbolift/dock = SSshuttle.getDock(destination_id) //We check this in both procs because who knows what might happen to the dock while the timer is going
	if(!dock)
		to_chat(world, "FAILED TO FIND DOCK 1") //DEBUG
		destination_queue.Cut(1,2)
		in_use = FALSE
		return

	say("Departing for Deck [dock.deck]: [dock.name].")
	to_chat(world, "Shuttle departing.") //DEBUG
	for(var/obj/machinery/door/airlock/turbolift/T in airlocks)
		INVOKE_ASYNC(src, .proc/close_airlock, T)

	addtimer(CALLBACK(src, .proc/move, destination_id), 5 SECONDS)

/obj/machinery/computer/turbolift/proc/move(var/destination_id)
	var/obj/docking_port/mobile/turbolift/M = SSshuttle.getShuttle(shuttle_id)
	if(!M)
		say("An unexpected error has occured. The turbolift is now offline. Please contact a Nanotrasen Turbolift Repair Technician.")
		STOP_PROCESSING(SSmachines, src)
		online = FALSE
		log_mapping("TURBOLIFT: [src] could not find mobile dock: [shuttle_id] at [AREACOORD(src)]")
		message_admins("TURBOLIFT: [src] could not find mobile dock: [shuttle_id] at [AREACOORD(src)]")
		return


	var/obj/docking_port/stationary/turbolift/dock = SSshuttle.getDock(destination_id)
	if(!dock)
		say("ERROR 404: Deck not found.")
		to_chat(world, "FAILED TO FIND DOCK 2") //DEBUG
		destination_queue.Cut(1,2)
		in_use = FALSE
		return

	SSshuttle.moveShuttle(shuttle_id, dock.id, 0)
	addtimer(CALLBACK(src, .proc/post_move, destination_id), 5 SECONDS)

/obj/machinery/computer/turbolift/proc/post_move(var/destination_id)
	var/obj/docking_port/stationary/turbolift/dock = SSshuttle.getDock(destination_id)
	say("Arrived at [dock ? "Deck [dock.deck]: [dock.name]" : "destination"].")
	for(var/obj/machinery/door/airlock/turbolift/T in airlocks)
		INVOKE_ASYNC(src, .proc/open_airlock, T)

	destination_queue.Cut(1,2)
	if(!destination_queue.len)
		STOP_PROCESSING(SSmachines, src)

	addtimer(VARSET_CALLBACK(src, in_use, FALSE), time_between_stops)
