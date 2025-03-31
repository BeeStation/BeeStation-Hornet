/client/proc/map_template_load()
	set category = "Debug"
	set name = "Map template - Place"

	var/datum/map_template/template

	var/map = input(src, "Choose a Map Template to place at your CURRENT LOCATION","Place Map Template") as null|anything in sort_list(SSmapping.map_templates)
	if(!map)
		return
	template = SSmapping.map_templates[map]

	var/turf/T = get_turf(mob)
	if(!T)
		return

	var/list/preview = list()
	for(var/S in template.get_affected_turfs(T,centered = TRUE))
		var/image/item = image('icons/turf/overlays.dmi',S,"greenOverlay")
		item.plane = ABOVE_LIGHTING_PLANE
		preview += item
	images += preview
	if(alert(src,"Confirm location.","Template Confirm","Yes","No") == "Yes")
		var/datum/async_map_generator/template_placer = template.load(T, centered = TRUE)
		template_placer.on_completion(CALLBACK(src, PROC_REF(after_map_load), template.name))
	images -= preview

/client/proc/after_map_load(template_name, datum/async_map_generator/map_place/async_map_generator, turf/T)
	message_admins(span_adminnotice("[key_name_admin(src)] has placed a map template ([template_name]) at [ADMIN_COORDJMP(T)]"))

/client/proc/map_template_upload()
	set category = "Debug"
	set name = "Map Template - Upload"

	var/map = input(src, "Choose a Map Template to upload to template storage","Upload Map Template") as null|file
	if(!map)
		return
	if(copytext("[map]", -4) != ".dmm")//4 == length(".dmm")
		to_chat(src, span_warning("Filename must end in '.dmm': [map]"))
		return
	var/datum/map_template/M
	var/type
	switch(alert(src, "What kind of map is this?", "Map type", "Normal", "Shuttle", "Cancel"))
		if("Normal")
			type = "Normal"
			M = new /datum/map_template(map, "[map] - Uploaded by [ckey] at [time2text(world.timeofday,"YYYY-MM-DD hh:mm:ss")]", TRUE)
		if("Shuttle")
			type = "Shuttle"
			M = new /datum/map_template/shuttle(map, "[map] - Uploaded by [ckey] at [time2text(world.timeofday,"YYYY-MM-DD hh:mm:ss")]", TRUE, copytext("[map]",1, -4))
		else
			return
	if(!M.cached_map)
		to_chat(src, span_warning("Map template '[map]' failed to parse properly."))
		return

	var/datum/map_report/report = M.cached_map.check_for_errors()
	var/report_link
	if(report)
		report.show_to(src)
		report_link = " - <a href='byond://?src=[REF(report)];[HrefToken(TRUE)];show=1'>validation report</a>"
		to_chat(src, span_warning("Map template '[map]' <a href='byond://?src=[REF(report)];[HrefToken()];show=1'>failed validation</a>."))
		if(report.loadable)
			var/response = alert(src, "The map failed validation, would you like to load it anyways?", "Map Errors", "Cancel", "Upload Anyways")
			if(response != "Upload Anyways")
				return
		else
			alert(src, "The map failed validation and cannot be loaded.", "Map Errors", "Oh Darn")
			return
	switch(type)
		if("Normal")
			SSmapping.map_templates[M.name] = M
		if("Shuttle")
			var/datum/map_template/shuttle/S = M
			SSmapping.shuttle_templates[S.shuttle_id] = S
	message_admins(span_adminnotice("[key_name_admin(src)] has uploaded a [type] map template '[map]' ([M.width]x[M.height])[report_link]."))
	to_chat(src, span_notice("Map template '[map]' ready to place ([M.width]x[M.height])"))
