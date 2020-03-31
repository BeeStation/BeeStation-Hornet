#define SHUTTLE_CREATOR_MAX_SIZE CONFIG_GET(number/max_shuttle_size)
#define CUSTOM_SHUTTLE_LIMIT CONFIG_GET(number/max_shuttle_count)

GLOBAL_VAR_INIT(custom_shuttle_count, 0)		//The amount of custom shuttles created to prevent creating hundreds
GLOBAL_LIST_EMPTY(custom_shuttle_machines)		//Machines that require updating (Heaters, engines)

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
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	var/ready = TRUE
	var/recorded_shuttle_area
	var/list/loggedTurfs = list()
	var/loggedOldArea
	var/linkedShuttleId

/obj/item/shuttle_creator/attack_self(mob/user)
	..()
	if(linkedShuttleId)
		return
	if(GLOB.custom_shuttle_count > CUSTOM_SHUTTLE_LIMIT)
		return
	return check_current_area(user)

/obj/item/shuttle_creator/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!ready)
		to_chat(user, "<span class='warning'>You need to define a shuttle area first.</span>")
		return
	if(!proximity_flag)
		return
	if(istype(target, /obj/machinery/door/airlock))
		if(get_area(target) != loggedOldArea)
			to_chat(user, "<span class='warning'>Caution, airlock must be on the shuttle to function as a dock.</span>")
			return
		if(linkedShuttleId)
			return
		if(GLOB.custom_shuttle_count > CUSTOM_SHUTTLE_LIMIT)
			to_chat(user, "<span class='warning'>Shuttle limit reached, sorry.</span>")
			return
		if(!create_shuttle_area(user))
			return
		if(shuttle_create_docking_port(target, user))
			to_chat(user, "<span class='notice'>Shuttle created!</span>")
		return
	else if(istype(target, /obj/machinery/computer/custom_shuttle))
		if(!linkedShuttleId)
			to_chat(user, "<span class='warning'>Error, no defined shuttle linked to device</span>")
			return
		var/obj/machinery/computer/custom_shuttle/console = target
		console.linkShuttle(linkedShuttleId)
		to_chat(user, "<span class='notice'>Console linked successfully!</span>")
		return
	else if(istype(target, /obj/machinery/computer/camera_advanced/shuttle_docker/custom))
		if(!linkedShuttleId)
			to_chat(user, "<span class='warning'>Error, no defined shuttle linked to device</span>")
			return
		var/obj/machinery/computer/camera_advanced/shuttle_docker/custom/console = target
		console.linkShuttle(linkedShuttleId)
		to_chat(user, "<span class='notice'>Console linked successfully!</span>")
		return
	to_chat(user, "<span class='warning'>The [src] bleeps. Select an airlock to create a docking port, or a valid machine to link.</span>")
	return

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
	to_chat(usr, "Created shuttle with dir [port.dir], width [port.width], height [port.height], dwidth [port.dwidth], dheight [port.dheight]")
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
	to_chat(usr, "Direction to space is [position]")
	return position

/obj/item/shuttle_creator/proc/invertDir(var/input_dir)
	if(input_dir == NORTH)
		return SOUTH
	else if(input_dir == SOUTH)
		return NORTH
	else if(input_dir == EAST)
		return WEST
	else if(input_dir == WEST)
		return EAST
	return null

/obj/item/shuttle_creator/proc/shuttle_create_docking_port(atom/target, mob/user)

	if(loggedTurfs.len == 0 || !recorded_shuttle_area)
		to_chat(user, "<span class='warning'>Invalid shuttle, restarting bluespace systems...</span>")
		return FALSE

	var/datum/map_template/shuttle/new_shuttle = new /datum/map_template/shuttle()

	var/obj/docking_port/mobile/port = new /obj/docking_port/mobile(get_turf(target))
	var/obj/docking_port/stationary/stationary_port = new /obj/docking_port/stationary(get_turf(target))
	port.callTime = 50
	port.dir = 1	//Point away from space.
	port.id = "custom_[GLOB.custom_shuttle_count]"
	linkedShuttleId = port.id
	port.ignitionTime = 25
	port.name = "Custom Shuttle"
	port.port_direction = 2
	port.preferred_direction = 4
	port.area_type = recorded_shuttle_area

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

	if(!calculate_bounds(port))
		to_chat(usr, "<span class='warning'>Bluespace calculations failed, please select a new airlock.</span>")
		port.Destroy()
		stationary_port.Destroy()
		linkedShuttleId = null
		return FALSE

	port.shuttle_areas = list()
	//var/list/all_turfs = port.return_ordered_turfs(port.x, port.y, port.z, port.dir)
	var/list/all_turfs = loggedTurfs
	for(var/i in 1 to all_turfs.len)
		var/turf/curT = all_turfs[i]
		var/area/cur_area = curT.loc
		//Add the area to the shuttle <3
		if(istype(cur_area, recorded_shuttle_area))
			if(istype(curT, /turf/open/space))
				continue
			if(length(curT.baseturfs) < 2)
				continue
			//Add the shuttle base shit to the shuttle
			curT.baseturfs.Insert(3, /turf/baseturf_skipover/shuttle)
			port.shuttle_areas[cur_area] = TRUE

	port.linkup(new_shuttle, stationary_port)

	port.movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	port.initiate_docking(stationary_port)

	port.mode = SHUTTLE_IDLE
	port.timer = 0

	port.register()
	GLOB.custom_shuttle_count ++
	message_admins("[ADMIN_LOOKUPFLW(user)] created a new shuttle with a [src] at [ADMIN_VERBOSEJMP(user)] ([GLOB.custom_shuttle_count] custom shuttles, limit is [CUSTOM_SHUTTLE_LIMIT])")
	log_game("[key_name(user)] created a new shuttle with a [src] at [AREACOORD(user)] ([GLOB.custom_shuttle_count] custom shuttles, limit is [CUSTOM_SHUTTLE_LIMIT])")
	return TRUE

/obj/item/shuttle_creator/proc/create_shuttle_area(mob/user)
	if(!loggedTurfs)
		return FALSE
	//Create the new area
	var/area/shuttle/custom/powered/newS
	var/area/oldA = loggedOldArea
	var/str = stripped_input(user, "Shuttle Name:", "Blueprint Editing", "", MAX_NAME_LEN)
	if(!str || !length(str))
		return FALSE
	if(length(str) > 50)
		to_chat(user, "<span class='warning'>The provided ship name is too long, blares the [src]</span>")
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

/obj/item/shuttle_creator/proc/check_current_area(mob/user)
	var/static/area_or_turf_fail_types = typecacheof(list(
		/turf/open/space,
		/area/shuttle
		))
	//Check to see if the user can make a new area to prevent spamming
	if(user)
		if(user.create_area_cooldown >= world.time)
			to_chat(user, "<span class='warning'>Smoke vents from the [src], maybe you should let it cooldown before using it again.</span>")
			return
		user.create_area_cooldown = world.time + 10
	//Detect the turfs connected in the curerrent enclosed area
	var/list/turfs = detect_room(get_turf(user), area_or_turf_fail_types)
	if(!turfs)
		to_chat(user, "<span class='warning'>Shuttles must be created in an airtight space, ensure that the shuttle is airtight, including corners.</span>")
		return
	if(turfs.len > SHUTTLE_CREATOR_MAX_SIZE)
		to_chat(user, "<span class='warning'>The [src]'s internal cooling system wizzes violently and a message appears on the screen, \"Caution, this device can only handle the creation of shuttles up to [SHUTTLE_CREATOR_MAX_SIZE] units in size. Please reduce your shuttle by [turfs.len-SHUTTLE_CREATOR_MAX_SIZE]. Sorry for the inconvinience\"</span>")
		return
	//Check to see if it's a valid shuttle
	for(var/i in 1 to turfs.len)
		var/area/space/place = get_area(turfs[i])
		//If any of the turfs are on station / not in space, a shuttle cannot be forced there
		if(!place)
			to_chat(user, "<span class='warning'>You can't seem to overpower the bluespace harmonics in this location, try somewhere else.</span>")
			return
		if(!istype(place, /area/space))
			to_chat(user, "<span class='warning'>Caution, shuttle must not use any material connected to the station. Your shuttle is currenly overlapping with [place.name]</span>")
			return

	loggedOldArea = get_area(get_turf(user))
	loggedTurfs = turfs
	icon_state = "rsd_used"
	to_chat(user, "<span class='notice'>Your current area was logged into the [src], select an airlock to act as the docking point.</span>")
