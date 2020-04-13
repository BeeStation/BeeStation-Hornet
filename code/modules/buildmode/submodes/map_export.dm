/datum/buildmode_mode/export
	key = "export"

	use_corner_selection = TRUE

/datum/buildmode_mode/export/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************</span>")
	to_chat(c, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Select corner</span>")
	to_chat(c, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/export/handle_selected_area(client/c, params)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")

	if(left_click) //rectangular

		var/confirm = alert("Are you sure you want to do this? This will cause extreme lag!", "Map Exporter", "Yes", "No")

		if(confirm != "Yes")
			return

		var/file_name = input("File name to export:", "Map Exporter", "exportedmap") as text

		log_admin("Build Mode: [key_name(c)] exported the map area from [AREACOORD(cornerA)] through [AREACOORD(cornerB)]") //I put this before the actual saving of the map because it likely won't log if it crashes the fucking server

		var map_text = write_map(cornerA.x, cornerA.y, cornerA.z, cornerB.x, cornerB.y, cornerB.z, 24)
		text2file(map_text, "data/[file_name].dmm")
		usr << ftp("data/[file_name].dmm", "[file_name].dmm")