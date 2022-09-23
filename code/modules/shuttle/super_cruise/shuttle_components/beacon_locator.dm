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
	var/target_name
	//A list of orbital pings
	var/list/datum/orbital_ping/pings = list()
	//The range that it can be out by either way
	var/inaccuracy = 100
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
	.["valid_targets"] = current_map.get_all_bodies()
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
			if(object.name == params["target"])
				//Set the new target
				target_name = params["target"]
				return TRUE
		return FALSE

	//To many pings
	if(length(pings) > 30)
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
	//Perform action
	var/orbital_map_index = current_location.orbital_map_index
	var/datum/orbital_map/location = SSorbits.orbital_maps[orbital_map_index]
	for(var/datum/orbital_object/body as() in location.get_all_bodies())
		//Ping the target
		if(body.name != target_name)
			continue
		//Get the distance
		var/distance = body.position.DistanceTo(current_location.position)
		distance += rand(-inaccuracy, inaccuracy)
		pings += new /datum/orbital_ping(body.get_locator_name(), current_location.position.GetX(), current_location.position.GetY(), distance, body.locator_colour)
	SStgui.update_uis_static_data(src)
	return TRUE
