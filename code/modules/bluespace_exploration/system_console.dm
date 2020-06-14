/obj/machinery/computer/system_map
	name = "system map console"
	desc = "system map here"
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/security
	light_color = LIGHT_COLOR_RED
	ui_x = 870
	ui_y = 708

	//A list of all the icons used on the starmap
	var/static/list/starmap_icons_cache

/obj/machinery/computer/system_map/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
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
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		//Send assets
		var/datum/asset/assets = get_asset_datum(/datum/asset/spritesheet/simple/starmap)
		assets.send(user)
		// Open UI
		ui = new(user, src, ui_key, "SystemMap", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/system_map/ui_static_data(mob/user)
	var/list/data = list()
	data["icon_cache"] = starmap_icons_cache
	data["stars"] = list()
	data["links"] = list()
	for(var/datum/star_system/star in SSbluespace_exploration.star_systems)
		var/list/formatted_star = list(
			"name" = star.name,
			"x" = star.map_x,
			"y" = star.map_y,
			"orbitting" = current_system == star,
		)
		data["stars"] += list(formatted_star)
	for(var/datum/star_link/link in SSbluespace_exploration.star_links)
		var/list/formatted_link = list(
			"x1" = link.x1,
			"y1" = link.y1,
			"x2" = link.x2,
			"y2" = link.y2
		)
		data["links"] += list(formatted_link)
	return data
