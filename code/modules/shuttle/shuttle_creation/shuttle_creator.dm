#define SHUTTLE_CREATOR_MAX_SIZE CONFIG_GET(number/max_shuttle_size)
#define CUSTOM_SHUTTLE_LIMIT CONFIG_GET(number/max_shuttle_count)
//This must be in the order of the direction bitflags
#define CARDINAL_DIRECTIONS_X list(0, 0, -1, 1)
#define CARDINAL_DIRECTIONS_Y list(-1, 1, 0, 0)

GLOBAL_VAR_INIT(custom_shuttle_count, 0)		//The amount of custom shuttles created to prevent creating hundreds
GLOBAL_LIST_EMPTY(custom_shuttle_machines)		//Machines that require updating (Heaters, engines)

//============ Shuttle Creator Object ============
/obj/item/shuttle_creator
	name = "Rapid Shuttle Designator"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rsd"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	desc = "A device used to define the area required for custom ships. Uses bluespace crystals to create bluespace-capable ships."
	density = FALSE
	anchored = FALSE
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	force = 0
	throwforce = 8
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	req_access_txt = "11"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50, "stamina" = 0)
	resistance_flags = FIRE_PROOF
	var/ready = TRUE
	//pre-designation
	var/override_max_shuttles = FALSE
	var/obj/machinery/computer/camera_advanced/shuttle_creator/internal_shuttle_creator
	//During designation
	var/overwritten_area = /area/space
	var/list/loggedTurfs = list()
	var/area/loggedOldArea
	var/area/recorded_shuttle_area
	var/datum/shuttle_creator_overlay_holder/overlay_holder
	//After designation
	var/linkedShuttleId
	var/turf/recorded_origin //The last remembered location of our airlock
	var/turf/exit //Record the exterior turf next to the airlock to prevent modification designation

/obj/item/shuttle_creator/Initialize(mapload)
	. = ..()
	internal_shuttle_creator = new()
	internal_shuttle_creator.owner_rsd = src
	overlay_holder = new()

/obj/item/shuttle_creator/Destroy()
	. = ..()
	if(internal_shuttle_creator)
		internal_shuttle_creator.owner_rsd = null
		QDEL_NULL(internal_shuttle_creator)
	if(overlay_holder)
		QDEL_NULL(overlay_holder)

/obj/item/shuttle_creator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShuttleDesignator")
		ui.open()

/obj/item/shuttle_creator/ui_data(mob/user)

	var/obj/docking_port/mobile/port
	if(linkedShuttleId)
		port = SSshuttle.getShuttle(linkedShuttleId)

	var/list/data = list()

	//General data
	data["shuttleId"] = linkedShuttleId
	data["inFlight"] = FALSE

	//Status data
	data["buffered_mass"] = loggedTurfs.len
	if(port)
		data["inFlight"] = istype(port.get_docked(), /obj/docking_port/stationary/transit)
		data["name"] = port.name
		data["shuttle_mass"] = port.calculate_mass()

		var/list/areas = port.shuttle_areas
		for(var/obj/machinery/shuttle/engine/E in GLOB.custom_shuttle_machines)
			if(!(get_area(E) in areas))
				continue
			E.check_setup()
			if(E.thruster_active)
				data["current_capacity"] += E.thrust
			data["ideal_capacity"] += E.thrust
		data["ideal_capacity"] *= CUSTOM_SHUTTLE_ACCELERATION_SCALE/CUSTOM_SHUTTLE_MIN_THRUST_TO_WEIGHT
		data["current_capacity"] *= CUSTOM_SHUTTLE_ACCELERATION_SCALE/CUSTOM_SHUTTLE_MIN_THRUST_TO_WEIGHT

	//Designation data
	data["max_size"] = SHUTTLE_CREATOR_MAX_SIZE

	//Configuration data
	if(port)
		data["current_direction"] = capitalize(dir2text(angle2dir_cardinal(dir2angle(port.dir)-dir2angle(port.port_direction)+180)))
		data["preferred_direction"] = capitalize(dir2text(port.preferred_direction))


	return data

/obj/item/shuttle_creator/ui_act(action, params)
	if(..())
		return

	//Do we have a port?
	var/obj/docking_port/mobile/port
	if(linkedShuttleId)
		port = SSshuttle.getShuttle(linkedShuttleId)
		if(istype(port.get_docked(), /obj/docking_port/stationary/transit)) //Not interaction while in transit
			return
		switch(action)
			if("current_direction")
				port.port_direction = angle2dir_cardinal(dir2angle(port.dir) + 180 - dir2angle(text2dir(params["direction"])))
			if("preferred_direction")
				port.preferred_direction = text2dir(params["direction"])

	switch(action)
		if("designate")
			if(!internal_shuttle_creator)
				return
			if(!linkedShuttleId && GLOB.custom_shuttle_count > CUSTOM_SHUTTLE_LIMIT && !override_max_shuttles)
				to_chat(usr, "<span class='warning'>Too many shuttles have been created.</span>")
				message_admins("[ADMIN_FLW(usr)] attempted to create a shuttle, however [CUSTOM_SHUTTLE_LIMIT] have already been created.")
				return
			if(update_origin()) //Has the shuttle moved? If so, reset the buffer
				reset_saved_area(FALSE)
			overlay_holder.add_client(usr.client)
			internal_shuttle_creator.attack_hand(usr)
			SStgui.close_uis(src)


//=========== shuttle designation actions ============
/obj/item/shuttle_creator/proc/calculate_bounds(obj/docking_port/mobile/port)
	if(!port || !istype(port, /obj/docking_port/mobile))
		return FALSE
	//Heights is the distance away from the port
	//width is the distance perpendicular to the port
	var/minX = INFINITY
	var/maxX = 0
	var/minY = INFINITY
	var/maxY = 0
	for(var/turf/T in loggedTurfs)
		minX = min(T.x, minX)
		maxX = max(T.x, maxX)
		minY = min(T.y, minY)
		maxY = max(T.y, maxY)
	//Make sure shuttle was actually found.
	if(maxX == INFINITY || maxY == INFINITY)
		return FALSE
	minX--
	minY--
	var/width = maxX - minX
	var/height = maxY - minY
	var/offset_x = port.x - minX
	var/offset_y = port.y - minY
	switch(port.dir) //Source: code/datums/shuttles.dm line 77 (14/03/2020) :)
		if(NORTH)
			port.width = width
			port.height = height
			port.dwidth = offset_x - 1
			port.dheight = offset_y - 1
		if(EAST)
			port.width = height
			port.height = width
			port.dwidth = height - offset_y
			port.dheight = offset_x - 1
		if(SOUTH)
			port.width = width
			port.height = height
			port.dwidth = width - offset_x
			port.dheight = height - offset_y
		if(WEST)
			port.width = height
			port.height = width
			port.dwidth = offset_y - 1
			port.dheight = width - offset_x
	return TRUE

//Go through all the all_turfs and check which direction doesn't have the shuttle
/obj/item/shuttle_creator/proc/getNonShuttleDirection(turf/targetTurf)
	var/position = null
	if(!(get_offset_target_turf(targetTurf, 0, 1) in loggedTurfs))
		if(position != null)
			return null
		position = NORTH
	if(!(get_offset_target_turf(targetTurf, 0, -1) in loggedTurfs))
		if(position != null)
			return null
		position = SOUTH
	if(!(get_offset_target_turf(targetTurf, 1, 0) in loggedTurfs))
		if(position != null)
			return null
		position = EAST
	if(!(get_offset_target_turf(targetTurf, -1, 0) in loggedTurfs))
		if(position != null)
			return null
		position = WEST
	return position

/obj/item/shuttle_creator/proc/shuttle_create_docking_port(atom/target, mob/user)

	if(loggedTurfs.len == 0 || !recorded_shuttle_area)
		to_chat(user, "<span class='warning'>Invalid shuttle, restarting bluespace systems...</span>")
		return FALSE

	var/datum/map_template/shuttle/new_shuttle = new /datum/map_template/shuttle()

	var/obj/docking_port/mobile/port = new /obj/docking_port/mobile(get_turf(target))
	port.shuttle_object_type = /datum/orbital_object/shuttle/custom_shuttle
	var/obj/docking_port/stationary/stationary_port = new /obj/docking_port/stationary(get_turf(target))
	stationary_port.delete_after = TRUE
	stationary_port.name = "[recorded_shuttle_area.name] Custom Shuttle construction site"
	port.callTime = 50
	port.dir = 1	//Point away from space.
	port.id = "custom_[GLOB.custom_shuttle_count]"
	linkedShuttleId = port.id
	port.ignitionTime = 25
	port.port_direction = 2
	port.preferred_direction = EAST
	port.name = "[recorded_shuttle_area.name] Custom Shuttle"
	port.area_type = recorded_shuttle_area

	stationary_port.area_type = overwritten_area

	var/portDirection = getNonShuttleDirection(get_turf(port))
	var/invertedDir = invertDir(portDirection)
	if(!portDirection || !invertedDir)
		to_chat(usr, "<span class='warning'>Shuttle creation aborted, docking airlock must be on an external wall. Please select a new airlock.</span>")
		port.Destroy()
		stationary_port.Destroy()
		linkedShuttleId = null
		return FALSE
	port.dir = invertedDir
	port.port_direction = portDirection
	update_origin()

	if(!calculate_bounds(port))
		to_chat(usr, "<span class='warning'>Bluespace calculations failed, please select a new airlock.</span>")
		port.Destroy()
		stationary_port.Destroy()
		linkedShuttleId = null
		return FALSE

	//Adds turfs and our area to the shuttle
	port.shuttle_areas = list()
	port.shuttle_areas[recorded_shuttle_area] = TRUE
	for(var/turf/T in loggedTurfs)
		port.add_turf(T, recorded_shuttle_area)
	port.linkup(new_shuttle, stationary_port)

	port.movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	port.initiate_docking(stationary_port)

	port.mode = SHUTTLE_IDLE
	port.timer = 0

	port.register()

	icon_state = "rsd_used"

	//Select shuttle fly direction.
	select_preferred_direction(user)

	//Redraw highlights
	reset_saved_area(FALSE)
	GLOB.custom_shuttle_count ++
	message_admins("[ADMIN_LOOKUPFLW(user)] created a new shuttle with a [src] at [ADMIN_VERBOSEJMP(user)] with a name [recorded_shuttle_area.name] ([GLOB.custom_shuttle_count] custom shuttles, limit is [CUSTOM_SHUTTLE_LIMIT])")
	log_game("[key_name(user)] created a new shuttle with a [src] at [AREACOORD(user)] with a name [recorded_shuttle_area.name] ([GLOB.custom_shuttle_count] custom shuttles, limit is [CUSTOM_SHUTTLE_LIMIT])")
	return TRUE

//When we've detected that we've moved, update the location of important turfs, return true if we've found a change
/obj/item/shuttle_creator/proc/update_origin()
	if(!linkedShuttleId)
		return
	var/obj/docking_port/mobile/port = SSshuttle.getShuttle(linkedShuttleId)
	if(!port)
		return
	var/turf/new_origin = locate(port.x, port.y, port.z)
	if(recorded_origin != new_origin)
		recorded_origin = new_origin
		. = TRUE
	var/dir_hash = BitCount((port.dir - 1)^port.dir) //Some fun bitwise manipulation, dir for ports is expected to be in a cardinal direction, which is a power of two in the bitfield, so use the binary log + 1 as the key
	var/turf/new_exit = get_offset_target_turf(recorded_origin, CARDINAL_DIRECTIONS_X[dir_hash], CARDINAL_DIRECTIONS_Y[dir_hash]) //Get the turf away from the airlock
	if(exit != new_exit)
		exit = new_exit
		. = TRUE

/obj/item/shuttle_creator/proc/create_shuttle_area(mob/user)
	//Check to see if the user can make a new area to prevent spamming
	if(user)
		if(user.create_area_cooldown >= world.time)
			to_chat(user, "<span class='warning'>Smoke vents from the [src], maybe you should let it cooldown before using it again.</span>")
			return FALSE
		user.create_area_cooldown = world.time + 10
	if(!loggedTurfs)
		return FALSE
	if(!check_area(loggedTurfs, FALSE))	//Makes sure nothing (Shuttles) has moved into the area during creation
		return FALSE
	//Create the new area
	var/area/shuttle/custom/powered/newS
	var/area/oldA = loggedOldArea
	var/str = stripped_input(user, "Shuttle Name:", "Blueprint Editing", "", MAX_NAME_LEN)
	if(!str || !length(str))
		return FALSE
	if(length(str) > 50)
		to_chat(user, "<span class='warning'>The provided ship name is too long, blares the [src].</span>")
		return FALSE
	if(OOC_FILTER_CHECK(str))
		to_chat(user, "<span class='warning'>Nanotrasen prohibited words are in use in this shuttle name, blares the [src] in a slightly offended tone.</span>")
		return FALSE
	newS = new /area/shuttle/custom/powered()
	newS.setup(str)
	newS.set_dynamic_lighting()
	//Shuttles always have gravity
	newS.has_gravity = TRUE
	newS.requires_power = TRUE
	//Record the area for use when creating the docking port
	recorded_shuttle_area = newS

	for(var/i in 1 to loggedTurfs.len)
		var/turf/turf_holder = loggedTurfs[i]
		var/area/old_area = turf_holder.loc
		newS.contents += turf_holder
		turf_holder.change_area(old_area, newS)

	newS.reg_in_areas_in_z()

	var/list/firedoors = oldA.firedoors
	for(var/door in firedoors)
		var/obj/machinery/door/firedoor/FD = door
		FD.CalculateAffectingAreas()
	return TRUE

/obj/item/shuttle_creator/proc/modify_shuttle_area(mob/user)
	//Check to see if we waited long enough between edits to prevent spamming
	if(user)
		if(user.create_area_cooldown >= world.time)
			to_chat(user, "<span class='warning'>Smoke vents from the [src], maybe you should let it cooldown before using it again.</span>")
			return FALSE
		user.create_area_cooldown = world.time + 10
	if(!loggedTurfs)
		to_chat(user, "<span class='warning'>The [src] blares, \"The shuttle cannot be completely undesignated.\"</span>")
		return FALSE

	var/obj/docking_port/mobile/port = SSshuttle.getShuttle(linkedShuttleId)
	if(!port || !istype(port, /obj/docking_port/mobile))
		return FALSE

	if(!calculate_bounds(port))
		to_chat(usr, "<span class='warning'>Bluespace calculations failed, modification terminated.</span>")
		return FALSE

	//Remove turfs not in our buffer
	for(var/turf/T in recorded_shuttle_area.contents)
		if(T in loggedTurfs)
			continue
		port.remove_turf(T)

	//Add turfs not in the area
	for(var/turf/T in loggedTurfs)
		port.add_turf(T, recorded_shuttle_area)

	var/list/firedoors = loggedOldArea.firedoors
	for(var/door in firedoors)
		var/obj/machinery/door/firedoor/FD = door
		FD.CalculateAffectingAreas()

	//Redraw highlights
	reset_saved_area(FALSE)
	return TRUE


//Select shuttle fly direction.
/obj/item/shuttle_creator/proc/select_preferred_direction(mob/user)
	var/obj/docking_port/mobile/port = SSshuttle.getShuttle(linkedShuttleId)
	if(!port || !istype(port, /obj/docking_port/mobile))
		return FALSE
	var/static/list/choice = list("NORTH" = NORTH, "SOUTH" = SOUTH, "EAST" = EAST, "WEST" = WEST)
	var/Pdir = input(user, "Shuttle Fly Direction:", "Blueprint Editing", "NORTH") as null|anything in list("NORTH", "SOUTH", "EAST", "WEST")
	if(Pdir)
		port.preferred_direction = choice[Pdir]

//Checks an area to ensure that the turfs provided are valid to be made into a shuttle
/obj/item/shuttle_creator/proc/check_area(list/turfs, addingTurfs = TRUE)
	if(!turfs)
		to_chat(usr, "<span class='warning'>Shuttles must be created in an airtight space, ensure that the shuttle is airtight, including corners.</span>")
		return FALSE
	if(turfs.len + (addingTurfs ? loggedTurfs.len : 0) > SHUTTLE_CREATOR_MAX_SIZE)
		to_chat(usr, "<span class='warning'>The [src]'s internal cooling system wizzes violently and a message appears on the screen, \"Caution, this device can only handle the creation of shuttles up to [SHUTTLE_CREATOR_MAX_SIZE] units in size. Please reduce your shuttle by [turfs.len + (addingTurfs ? loggedTurfs.len : 0) - SHUTTLE_CREATOR_MAX_SIZE]. Sorry for the inconvinience\"</span>")
		return FALSE
	if(turfs.Find(exit))
		to_chat(usr, "<span class='warning'>Do not block open space required for the exterior airlock to function.</span>")
		return
	//Check to see if it's a valid shuttle
	for(var/i in 1 to turfs.len)
		var/area/place = get_area(turfs[i])
		//If any of the turfs are on station / not in space, a shuttle cannot be forced there
		if(!place)
			to_chat(usr, "<span class='warning'>You can't seem to overpower the bluespace harmonics in this location, try somewhere else.</span>")
			return FALSE
		if(istype(place, /area/space))
			overwritten_area = /area/space
		else if(istype(place, /area/lavaland/surface/outdoors))
			overwritten_area = /area/lavaland/surface/outdoors
		else if(istype(place, /area/asteroid/generated))
			overwritten_area = /area/asteroid/generated
		else if(place != recorded_shuttle_area)
			to_chat(usr, "<span class='warning'>Caution, shuttle must not use any material connected to the station. Your shuttle is currenly overlapping with [place.name].</span>")
			return FALSE
	//Finally, check to see if the area is actually attached
	if(!LAZYLEN(loggedTurfs))
		return TRUE
	for(var/turf/T in turfs)
		if(turf_connected_to_saved_turfs(T))
			return TRUE
		CHECK_TICK
	to_chat(usr, "<span class='warning'>Caution, new areas of the shuttle must be connected to the other areas of the shuttle.</span>")
	return FALSE

/obj/item/shuttle_creator/proc/turf_connected_to_saved_turfs(turf/T)
	for(var/i in 1 to 4)
		var/turf/adjacentT = get_offset_target_turf(T, CARDINAL_DIRECTIONS_X[i], CARDINAL_DIRECTIONS_Y[i])
		if(adjacentT in loggedTurfs)
			return TRUE
	return FALSE

//Checks if all the turfs in loggedTurfs are connected to each other
/obj/item/shuttle_creator/proc/are_turfs_connected()
	if(!loggedTurfs || !length(loggedTurfs))
		return TRUE //It's fully connected I guess
	var/queue_pointer = 1 //The end of the queue, new entries are put after this
	var/dequeue_pointer = 1 //How many we have checked
	var/found_index = 0 //Index of discovered turf in T
	var/swap_temp //Storage for array entry swapping
	do
		for(var/i in 1 to 4)
			found_index = loggedTurfs.Find(get_offset_target_turf(loggedTurfs[dequeue_pointer], CARDINAL_DIRECTIONS_X[i], CARDINAL_DIRECTIONS_Y[i]))
			if(found_index > queue_pointer) //If the turf is found and hasn't been queued yet, queue it
				swap_temp = loggedTurfs[++queue_pointer]
				loggedTurfs[queue_pointer] = loggedTurfs[found_index]
				loggedTurfs[found_index] = swap_temp
	while(++dequeue_pointer <= queue_pointer && queue_pointer < length(loggedTurfs)) //If we run out of turfs in the connected list, stop. If we find all the turfs, stop.
	return queue_pointer == length(loggedTurfs)

/obj/item/shuttle_creator/proc/turf_in_list(turf/T)
	return loggedTurfs.Find(T)

/obj/item/shuttle_creator/proc/add_single_turf(turf/T)
	if(!check_area(list(T)))
		return FALSE
	loggedTurfs |= T
	loggedOldArea = get_area(T)
	overlay_holder.highlight_turf(T)

/obj/item/shuttle_creator/proc/add_saved_area(mob/user)
	var/static/area_or_turf_fail_types = typecacheof(list(/area/shuttle))
	area_or_turf_fail_types += GLOB.shuttle_turf_blacklist
	//Detect the turfs connected in the curerrent enclosed area
	var/list/turfs = detect_room(get_turf(user), area_or_turf_fail_types)
	if(!check_area(turfs))
		return FALSE
	loggedOldArea = get_area(get_turf(user))
	loggedTurfs |= turfs
	overlay_holder.highlight_area(turfs)
	//TODO READD THIS SHIT: icon_state = "rsd_used"
	to_chat(user, "<span class='notice'>You add the area into the buffer of the [src], you made add more areas or select an airlock to act as a docking port to complete the shuttle.</span>")
	return turfs

/obj/item/shuttle_creator/proc/remove_single_turf(turf/T)
	if(!turf_in_list(T))
		return
	if(T == recorded_origin)
		to_chat(usr, "<span class='warning'>You cannot undesignate the exterior airlock.</span>")
		return
	loggedTurfs -= T
	if(are_turfs_connected())
		loggedOldArea = get_area(T)
		overlay_holder.unhighlight_turf(T)
	else
		to_chat(usr, "<span class='warning'>Caution, removing this turf would split the shuttle.</span>")
		loggedTurfs |= T

/obj/item/shuttle_creator/proc/reset_saved_area(loud = TRUE)
	overlay_holder.clear_highlights()
	loggedTurfs.Cut()
	if(recorded_shuttle_area)
		for(var/turf/T in recorded_shuttle_area.contents)
			loggedTurfs |= T
			overlay_holder.create_hightlight(T, T == recorded_origin)
	if(loud)
		to_chat(usr, "<span class='notice'>You reset the area buffer on the [src].</span>")

#undef CARDINAL_DIRECTIONS_X
#undef CARDINAL_DIRECTIONS_Y
