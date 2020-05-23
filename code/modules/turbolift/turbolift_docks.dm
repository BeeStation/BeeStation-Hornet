/obj/docking_port/stationary/turbolift
	name = "turbolift"
	area_type = /area/shuttle/turbolift/shaft
	var/bottom_floor = FALSE
	var/deck = 1

/obj/docking_port/mobile/turbolift
	name = "turbolift"
	dir = NORTH
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	var/datum/weakref/turbolift_computer

/obj/docking_port/mobile/turbolift/Initialize()
	register()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/docking_port/mobile/turbolift/LateInitialize()
	for(var/T in GLOB.turbolifts)
		var/obj/machinery/computer/turbolift/C = T
		if(C.shuttle_id == id)
			turbolift_computer = WEAKREF(C)
			break

	if(!turbolift_computer)
		log_mapping("TURBOLIFT: [src] failed to find its turbolift computer at [AREACOORD(src)]")
		message_admins("TURBOLIFT: [src] failed to find its turbolift computer at [AREACOORD(src)]")
		return

	var/obj/docking_port/stationary/turbolift/turbolift_dock
	for(var/S in SSshuttle.stationary)
		var/obj/docking_port/stationary/turbolift/SM = S
		if(!istype(SM))
			continue
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

	turbolift_dock.locate_floors(src)

/obj/docking_port/stationary/turbolift/Initialize()
	. = ..()
	id = "[id]_[src.z]"
	var/lower_dock = (locate(/obj/docking_port/stationary/turbolift) in SSmapping.get_turf_below(get_turf(src)))
	if(!lower_dock)
		bottom_floor = TRUE //We let the lowest dock handle finding all of the other docks


/obj/docking_port/stationary/turbolift/proc/locate_floors(var/obj/docking_port/mobile/turbolift/dock)
	if(!bottom_floor)
		return
	var/obj/docking_port/mobile/turbolift/M = SSshuttle.getShuttle(dock.id)
	if(!M)
		log_mapping("TURBOLIFT: [src] failed to find mobile dock: [dock.id]")
		message_admins("TURBOLIFT: [src] failed to find mobile dock: [dock.id]")
	var/obj/machinery/computer/turbolift/turbolift_computer = M.turbolift_computer.resolve()
	if(!turbolift_computer)
		log_mapping("TURBOLIFT: [src] failed to find its turbolift computer in locate_floors()")
		message_admins("TURBOLIFT: [src] failed to find its turbolift computer in locate_floors()")
		return
	turbolift_computer.possible_destinations += "[id]"

	for(var/S in SSshuttle.stationary)
		var/obj/docking_port/stationary/turbolift/SM = S
		if(!istype(SM))
			continue
		if(findtext(SM.id, M.id) && !SM.bottom_floor)
			SM.deck = (SM.z - src.z + src.deck)
			SM.dir = dir
			SM.dwidth = dwidth
			SM.dheight = dheight
			SM.width = width
			SM.height = height
			turbolift_computer.possible_destinations += "[SM.id]"
