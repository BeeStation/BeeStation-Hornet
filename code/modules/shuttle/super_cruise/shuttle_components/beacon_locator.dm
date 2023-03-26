/datum/orbital_ping
	var/name
	var/x
	var/y
	var/distance
	var/colour

/datum/orbital_ping/New(name, x, y, distance, colour)
	. = ..()
	src.name = name
	src.x = x
	src.y = y
	src.distance = distance
	src.colour = colour

/obj/machinery/computer/locator
	name = "triangulation computer"
	desc = "A computer console that can be used to triangulate the position of orbital beacons."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list()
	circuit = /obj/item/circuitboard/computer/navigation
	var/target_name
	//A list of orbital pings
	var/list/datum/orbital_ping/pings = list()
	//The range that it can be out by either way
	var/inaccuracy = 100
	//The amount of pings it performs at any time
	//More pings = less accurate
	var/bad_ping_count = 19
	//The world time cooldown
	var/next_ping_cooldown = 0

/obj/machinery/computer/locator/Destroy()
	QDEL_LIST(pings)
	return ..()

/obj/machinery/computer/locator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Locator")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/locator/ui_data(mob/user)
	. = list()
	var/datum/orbital_object/current_location
	var/area/shuttle/A = get_area(src)
	if(istype(A))
		current_location = SSorbits.assoc_shuttles[A.mobile_port.id]
	if(!istype(current_location))
		current_location = SSorbits.assoc_z_levels["[z]"]
	if(!current_location)
		return
	var/datum/orbital_map/current_map = SSorbits.orbital_maps[current_location.orbital_map_index]
	.["selected_target"] = target_name
	.["valid_targets"] = list()
	for (var/datum/orbital_object/object in current_map.get_all_bodies())
		.["valid_targets"] += object.get_locator_name()
	.["x"] = current_location.position.GetX()
	.["y"] = current_location.position.GetY()

/obj/machinery/computer/locator/ui_static_data(mob/user)
	. = list()
	.["pings"] = list()
	for (var/datum/orbital_ping/ping as() in pings)
		.["pings"] += list(list(
			"x" = ping.x,
			"y" = ping.y,
			"distance" = ping.distance,
			"colour" = ping.colour,
			"name" = ping.name
		))

/obj/machinery/computer/locator/ui_act(action, params)
	. = ..()

	//Check if the console is usable
	if(.)
		return

	if(action == "clear")
		QDEL_LIST(pings)
		SStgui.update_uis_static_data(src)
		return TRUE

	if(action == "set_target")
		//All this code for some simple href validation
		var/datum/orbital_object/current_location
		var/area/shuttle/A = get_area(src)
		if(istype(A))
			current_location = SSorbits.assoc_shuttles[A.mobile_port.id]
		if(!istype(current_location))
			current_location = SSorbits.assoc_z_levels["[z]"]
		if(!current_location)
			return
		var/datum/orbital_map/current_map = SSorbits.orbital_maps[current_location.orbital_map_index]
		for(var/datum/orbital_object/object as() in current_map.get_all_bodies())
			if(object.get_locator_name() == params["target"])
				//Set the new target
				target_name = params["target"]
				return TRUE
		return FALSE

	//To many pings
	if(length(pings) > 40)
		say("Local memory is full, please clear some results")
		return
	//Check cooldown
	if(world.time < next_ping_cooldown)
		say("Please wait at least 3 seconds between each ping.")
		return
	next_ping_cooldown = world.time + 3 SECONDS
	//Find where we are
	var/datum/orbital_object/current_location
	var/area/shuttle/A = get_area(src)
	if(istype(A))
		current_location = SSorbits.assoc_shuttles[A.mobile_port.id]
	if(!istype(current_location))
		current_location = SSorbits.assoc_z_levels["[z]"]
	if(!istype(current_location))
		say("Unable to ping, invalid location.")
		return
	//playsound(src, 'sound/effects/beacon.ogg', 70, FALSE)
	// Determine if we are a new scan or not
	var/new_scan = pings.len == 0
	//Perform action
	var/orbital_map_index = current_location.orbital_map_index
	var/datum/orbital_map/location = SSorbits.orbital_maps[orbital_map_index]
	var/list/new_pings = list()
	var/target_exists = FALSE
	for(var/datum/orbital_object/body as() in location.get_all_bodies())
		//Ping the target
		if(body.get_locator_name() != target_name)
			continue
		target_exists = TRUE
		//Get the distance
		var/distance = body.position.DistanceTo(current_location.position)
		// Create bad pings
		for (var/i in 1 to bad_ping_count)
			//Calculate somewhere on the circle curcumference to put this thing
			var/angle = rand(0, 360)
			var/pos_x = cos(angle) * distance
			var/pos_y = sin(angle) * distance
			new_pings += new /datum/orbital_ping("???", current_location.position.GetX() + pos_x + rand(-inaccuracy, inaccuracy), current_location.position.GetY() + pos_y + rand(-inaccuracy, inaccuracy), rand(inaccuracy, 3 * inaccuracy), body.locator_colour)
		// Create accurate ping
		new_pings += new /datum/orbital_ping("???", body.position.GetX() + rand(-inaccuracy, inaccuracy), body.position.GetY() + rand(-inaccuracy, inaccuracy), rand(inaccuracy, 3 * inaccuracy), body.locator_colour)
	if (!target_exists)
		say("Target signal dropped out of supercruise and could not be picked up.")
		target_name = null
		return
	//Remove all pings that aren't intersecting with another ping
	//N^2 algorithm, but N will always be low and this is a non-hot path
	//This prevents us from filling up the console memory
	if (!new_scan)
		for (var/datum/orbital_ping/start_ping as() in new_pings)
			var/is_safe = FALSE
			// Check if we are near the actual target
			for(var/datum/orbital_object/body as() in location.get_all_bodies())
				//Ping the target
				if(body.get_locator_name() != target_name)
					continue
				var/delta_x = body.position.GetX() - start_ping.x
				var/delta_y = body.position.GetY() - start_ping.y
				var/dist = sqrt(delta_x * delta_x + delta_y * delta_y)
				if (dist < 500)
					is_safe = TRUE
					break
			// Check if we are near another ping
			if (!is_safe)
				for (var/datum/orbital_ping/other_ping as() in pings)
					// Check if we are intersecting
					var/delta_x = other_ping.x - start_ping.x
					var/delta_y = other_ping.y - start_ping.y
					var/dist = sqrt(delta_x * delta_x + delta_y * delta_y)
					if (dist <= start_ping.distance + other_ping.distance)
						//If our ping is safe, we can safely remove the other ping
						is_safe = TRUE
						break
			if (!is_safe)
				new_pings -= start_ping
				qdel(start_ping)
		// Replace pings to prevent the inputs size of this slow algorithm from getting too big
		QDEL_LIST(pings)
		pings = new_pings
	else
		pings += new_pings
	SStgui.update_uis_static_data(src)
	return TRUE
