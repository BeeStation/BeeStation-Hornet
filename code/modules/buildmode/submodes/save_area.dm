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

	var/dat = convert_map_to_tgm(L.map)

	//Step 2: Write the data to a file
	var/filedir = file("data/temp.dmm")
	if(fexists(filedir))
		fdel(filedir)
	WRITE_FILE(filedir, "[dat]")

	//Step 3: Give the file to client for download
	usr << ftp(filedir)

	//Step 4: Remove the file from the server (hopefully we can find a way to avoid step)
	fdel(filedir)
