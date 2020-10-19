GLOBAL_VAR_INIT(save_area_executing, FALSE)

/datum/mapGenerator/save_area
	buildmode_name = "Save Area"
	modules = list(/datum/mapGeneratorModule/save_area)
	var/min_x = 0
	var/min_y = 0
	var/max_x = 0
	var/max_y = 0

/datum/mapGenerator/save_area/defineRegion(turf/Start, turf/End, replace = 0)
	min_x = min(Start.x,End.x)
	min_y = min(Start.y,End.y)
	max_x = max(Start.x,End.x)
	max_y = max(Start.y,End.y)
	..()

/datum/mapGeneratorModule/save_area
	var/areaName = "default.dm"

//This could be optimised by making turfs that are the same go in the same, but this is a quick bodge solution so yea, fun job for coder here :)
/datum/mapGeneratorModule/save_area/generate()
	var/datum/mapGenerator/save_area/L = mother
	if(!istype(L))
		return
	//If someone somehow gets build mode, stop them from using this.
	if(!check_rights(R_ADMIN))
		message_admins("[ckey(usr)] tried to run the map save generator but was rejected due to insufficient perms.")
		to_chat(usr, "<span class='warning'>You must have R_ADMIN privellages to use this.</span>")
		return
	//Emergency check
	if(L.map.len > 1600)
		var/confirm = alert("Uhm, are you sure, the area is quiet large?", "Run generator", "Yes", "No")
		if(confirm != "Yes")
			return

	if(GLOB.save_area_executing)
		to_chat(usr, "<span class='warning'>Someone is already running the generator! Try again in a bit.</span>")
		return

	to_chat(usr, "<span class='warning'>Saving, please wait...</span>")
	GLOB.save_area_executing = TRUE

	//Log just in case something happens
	log_game("[key_name(usr)] ran the save level map generator on [L.map.len] turfs.")
	message_admins("[key_name(usr)] ran the save level map generator on [L.map.len] turfs.")

	//Step 1: Get the data (This can take a while)
	var/dat = "//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE\n"
	dat += convert_map_to_tgm(L.map)

	//Step 2: Write the data to a file
	var/filedir = file("data/temp.dmm")
	if(fexists(filedir))
		fdel(filedir)
	WRITE_FILE(filedir, "[dat]")

	//Step 3: Give the file to client for download
	usr << ftp(filedir)

	//Step 4: Remove the file from the server (hopefully we can find a way to avoid step)
	fdel(filedir)
	log_game("[L.map.len] turfs have been saved by [ckey(usr)]")
	alert("Area saved successfully.", "Action Successful!", "Ok")
	GLOB.save_area_executing = FALSE
