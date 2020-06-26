/obj/machinery/computer/system_map
	name = "system map console"
	desc = "system map here"
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/security
	light_color = LIGHT_COLOR_RED
	ui_x = 870
	ui_y = 708

	var/bs_drive_name = "Bluespace Drive"
	var/datum/weakref/linked_bluespace_drive

	//A list of all the icons used on the starmap
	var/static/list/starmap_icons_cache
	var/shuttle_id

/obj/machinery/computer/system_map/exploration
	shuttle_id = "exploration"
	bs_drive_name = "Nanotrasen Bluespace Drive"

/obj/machinery/computer/system_map/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	//Locate the shuttle ID we are attatched to (if we are attatched)
	if(!shuttle_id)
		var/turf/our_turf = get_turf(src)
		for(var/shuttle_dock_id in SSbluespace_exploration.tracked_ships)
			var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttle_dock_id)
			if(!M)
				continue
			if(M.z != z)
				continue
			if(our_turf in M.return_turfs())
				shuttle_id = M.id
				break
	//Locate the bluespace drive
	addtimer(CALLBACK(src, .proc/locate_bluespace_drive), 10)
	//expertly copypasted from pill_press, with some minor altercations to make use of staticness
	starmap_icons_cache = list()
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/starmap)
	for(var/key in assets.assets)
		var/list/asset = list()
		asset["id"] = key
		asset["class_name"] = assets.icon_class_name(key)
		starmap_icons_cache += list(asset)

/obj/machinery/computer/system_map/ui_base_html(html)
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/starmap)
	. = replacetext(html, "<!--customheadhtml-->", assets.css_tag())

/obj/machinery/computer/system_map/ui_interact(\
		mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
		datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	if(!shuttle_id)
		to_chat(usr, "<span class='warning'>Console not attatched to a bluespace capable shuttle.</span>")
		return
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		//Send assets
		var/datum/asset/assets = get_asset_datum(/datum/asset/spritesheet/simple/starmap)
		assets.send(user)
		// Open UI
		ui = new(user, src, ui_key, "SystemMap", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/system_map/ui_act(action, params)
	switch(action)
		if("jump")
			var/obj/machinery/bluespace_drive/bs_drive = null
			if(linked_bluespace_drive)
				bs_drive = linked_bluespace_drive.resolve()
			if(!bs_drive || QDELETED(bs_drive))
				say("Your [bs_drive_name] is experiencing issues. Please contact your ships engineer, or report to a repair depot in the sector.")
				return
			//Locate Star

			//Locate the BS drive and then trigger jump

			return

/obj/machinery/computer/system_map/ui_data(mob/user)
	var/list/data = list()
	data["jump_locations"] = list()
	for(var/datum/star_system/star as anything in SSbluespace_exploration.current_system.linked_stars)
		data["jump_locations"] += list(list(
			"name" = star.name,
			"id" = star.unique_id,
			"dist" = star.distance_from_center,
		))
	return data

/obj/machinery/computer/system_map/ui_static_data(mob/user)
	var/list/data = list()
	data["icon_cache"] = starmap_icons_cache
	data["stars"] = list()
	data["links"] = list()
	data["jump_state"] = linked_bluespace_drive ? TRUE : FALSE
	for(var/datum/star_system/star as anything in SSbluespace_exploration.star_systems)
		var/list/formatted_star = list(
			"name" = star.name,
			"x" = star.map_x,
			"y" = star.map_y,
			"orbitting" = SSbluespace_exploration.current_system == star,
			"can_jump" = SSbluespace_exploration.current_system ? (star in SSbluespace_exploration.current_system.linked_stars) : FALSE,
		)
		data["stars"] += list(formatted_star)
	for(var/datum/star_link/link as anything in SSbluespace_exploration.star_links)
		var/list/formatted_link = list(
			"x1" = link.x1,
			"y1" = link.y1,
			"x2" = link.x2,
			"y2" = link.y2
		)
		data["links"] += list(formatted_link)
	return data

//Do this a few frames after loading everything, since if it loads at the same time as the drive it can fail to be located
/obj/machinery/computer/system_map/proc/locate_bluespace_drive()
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttle_id)
	if(M)
		for(var/obj/machinery/bluespace_drive/BSD as anything in GLOB.bluespace_drives)
			if(get_turf(BSD) in M.return_turfs())
				linked_bluespace_drive = WEAKREF(BSD)
				return
