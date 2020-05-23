GLOBAL_LIST_EMPTY(turbolifts)

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
		to_chat(user, "<span class='warning'>[src] does not respond.</span>")
	if(!shuttle_id || !floor_id)
		say("An unexpected error has occured. Please contact a Nanotrasen Turbolift Repair Technician.")
		return

	var/obj/docking_port/mobile/turbolift/M = SSshuttle.getShuttle(shuttle_id)
	var/obj/machinery/computer/turbolift/T = M?.turbolift_computer?.resolve()
	if(!M || !T)
		say("An unexpected error has occured. Please contact a Nanotrasen Turbolift Repair Technician.")
		return

	if("[floor_id]" in T.destination_queue)
		say("The current deck is already queued.")
	else if(T.z == src.z)
		say("The turbolift is already at this deck.")
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
	var/time_between_stops = 300 //Time in deciseconds before going to the next location in the queue.
	var/in_use = FALSE
	var/online = TRUE //Is the elevator functional? Will be expanded upon later


/obj/machinery/computer/turbolift/Initialize()
	. = ..()
	GLOB.turbolifts += src

/obj/machinery/door/airlock/turbolift
	name = "turbolift airlock"
	icon = 'icons/obj/turbolift_door.dmi'
	desc = "A sleek airlock for walking through. This one looks extremely strong."
	icon_state = "closed"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/dock_dir

/obj/machinery/door/airlock/turbolift/bolt()
	if(locked)
		return
	locked = TRUE
	update_icon()

/obj/machinery/door/airlock/turbolift/unbolt()
	if(!locked)
		return
	locked = FALSE
	update_icon()

/obj/machinery/door/airlock/turbolift/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
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
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall"
	canSmoothWith = list(/turf/closed/indestructible/turbolift)
	smooth = SMOOTH_TRUE

/turf/closed/indestructible/turbolift/afterShuttleMove()
	queue_smooth(src)
	..()

/obj/machinery/computer/turbolift/Destroy()
	GLOB.turbolifts -= src
	. = ..()

/obj/machinery/computer/turbolift/proc/find_airlocks()
	for(var/obj/machinery/door/airlock/turbolift/L in get_area(src))
		airlocks += WEAKREF(L)
		var/obj/docking_port/mobile/turbolift/M = SSshuttle.getShuttle(shuttle_id)
		L.dock_dir = M.dir

/obj/machinery/computer/turbolift/proc/close_airlock(var/obj/machinery/door/airlock/turbolift/T)
	T.unbolt()
	T.close()
	T.bolt()
	var/obj/machinery/door/airlock/turbolift/A = locate(/obj/machinery/door/airlock/turbolift) in get_step(T, T.dock_dir)
	if(!A)
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
		return
	A.unbolt()
	A.open()
	A.bolt()

/obj/machinery/computer/turbolift/process()
	if(!online)
		STOP_PROCESSING(SSmachines, src)
		return
	if(!destination_queue.len)
		STOP_PROCESSING(SSmachines, src)
		for(var/datum/weakref/T in airlocks) //Just in case. Don't want anybody to get locked in.
			var/obj/machinery/door/airlock/turbolift/A = T.resolve()
			if(A)
				INVOKE_ASYNC(src, .proc/open_airlock, A)
			else
				airlocks -= T
		return

	if(!in_use)
		in_use = TRUE
		pre_move(destination_queue[1])

/obj/machinery/computer/turbolift/proc/pre_move(var/destination_id)
	if(!airlocks.len)
		find_airlocks()
	var/obj/docking_port/stationary/turbolift/dock = SSshuttle.getDock(destination_id) //We check this in both procs because who knows what might happen to the dock while the timer is going
	if(!dock)
		destination_queue.Cut(1,2)
		in_use = FALSE
		return

	say("Departing for Deck [dock.deck]: [dock.name].")
	for(var/datum/weakref/T in airlocks)
		var/obj/machinery/door/airlock/turbolift/A = T.resolve()
		if(A)
			INVOKE_ASYNC(src, .proc/close_airlock, A)
		else
			airlocks -= T

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
		destination_queue.Cut(1,2)
		in_use = FALSE
		return

	SSshuttle.moveShuttle(shuttle_id, dock.id, 0)
	addtimer(CALLBACK(src, .proc/post_move, destination_id), 5 SECONDS)

/obj/machinery/computer/turbolift/proc/post_move(var/destination_id)
	var/obj/docking_port/stationary/turbolift/dock = SSshuttle.getDock(destination_id)
	say("Arrived at [dock ? "Deck [dock.deck]: [dock.name]" : "destination"].")
	for(var/datum/weakref/T in airlocks)
		var/obj/machinery/door/airlock/turbolift/A = T.resolve()
		if(A)
			INVOKE_ASYNC(src, .proc/open_airlock, A)
		else
			airlocks -= T

	destination_queue.Cut(1,2)
	if(!destination_queue.len)
		STOP_PROCESSING(SSmachines, src)

	addtimer(VARSET_CALLBACK(src, in_use, FALSE), time_between_stops)

/obj/machinery/computer/turbolift/ui_data(mob/user)
	var/list/data = list()
	var/list/decks = list()
	for(var/id in possible_destinations)
		var/obj/docking_port/stationary/turbolift/dock = SSshuttle.getDock(id)
		var/list/info = list()
		info["deck"] = dock.deck
		info["name"] = dock.name
		info["z"] = dock.z
		info["queued"] = (dock.id in destination_queue)

		decks[dock.id] = info

	data["decks"] = decks
	data["current"] = src.z
	data["online"] = online

	return data

/obj/machinery/computer/turbolift/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("goto")
			var/destID = params["deck"]
			if(!(destID in possible_destinations))
				return //fuckers

			var/obj/docking_port/stationary/turbolift/dest = SSshuttle.getDock(destID)

			if(!dest)
				warning("This code shouldnt ever run, a turbolift has attempted to go to a dock with id [destID] but none were found")
				return //shouldnt ever get to this point but w/e

			if(dest.z == src.z)
				return //this normally shouldnt run either but out of date interfaces might get here

			if(dest.id in destination_queue)
				return //again shouldnt ever run but out of date interfaces
			destination_queue += dest.id

			. = TRUE //we have an update now

			if(online)
				START_PROCESSING(SSmachines, src)

/obj/machinery/computer/turbolift/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
												datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
  ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
  if(!ui)
    ui = new(user, src, ui_key, "TurboLift", name, 300, 300, master_ui, state)
    ui.open()
