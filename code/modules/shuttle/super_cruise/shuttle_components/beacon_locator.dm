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
		var/datum/space_level/z_level = SSmapping.get_level(z)
		current_location = z_level.orbital_body
	if(!current_location)
		return
	.["x"] = current_location.position.x
	.["y"] = current_location.position.y

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
		update_static_data(usr)
		return TRUE

	//To many pings
	if(length(pings) > 30)
		say("Local memory is full, please clear some results")
		return
	//Check cooldown
	if(world.time < next_ping_cooldown)
		say("Please wait at least 30 seconds between each ping.")
		return
	next_ping_cooldown = world.time + 30 SECONDS
	//Find where we are
	var/datum/orbital_object/current_location
	var/area/shuttle/A = get_area(src)
	if(istype(A))
		current_location = SSorbits.assoc_shuttles[A.mobile_port.id]
	if(!istype(current_location))
		var/datum/space_level/z_level = SSmapping.get_level(z)
		current_location = z_level.orbital_body
	if(!istype(current_location))
		say("Unable to ping, invalid location.")
		return
	//Perform action
	var/orbital_map_index = current_location.orbital_map_index
	var/datum/orbital_map/location = SSorbits.orbital_maps[orbital_map_index]
	for(var/datum/orbital_object/body as() in location.get_all_bodies())
		//Don't ping huge things
		if(body.radius > 250)
			continue
		//Get the distance
		var/distance = body.position.DistanceTo(current_location.position)
		//Too close, or too far
		if(distance < 500 || distance > 10000)
			continue
		distance += rand(-inaccuracy, inaccuracy)
		pings += new /datum/orbital_ping(body.get_locator_name(), current_location.position.x, current_location.position.y, distance, body.locator_colour)
	update_static_data(usr)
	return TRUE
