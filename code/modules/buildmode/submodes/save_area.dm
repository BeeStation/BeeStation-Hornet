GLOBAL_LIST_INIT(save_file_chars, list(
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z"))

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
	//Step 0: Calculate the amount of letters we need (26 ^ n > turf count)
	var/width = L.max_x - L.min_x + 1
	var/height= L.max_y - L.min_y + 1
	var/turfsNeeded = width * height
	var/layers = FLOOR(log(GLOB.save_file_chars.len, turfsNeeded) + 0.999,1)
	message_admins("log : [log(GLOB.save_file_chars.len, turfsNeeded)] Layers required [layers], width [width], height [height], turfs [turfsNeeded]")

	//Step 1: Run through the area and generate file data
	var/header = ""
	var/contents = ""
	for(var/index in 1 to mother.map.len)
		contents += "[index % width == 1 ? "[index != 1 ? "\"}" : ""]\n(1,[FLOOR(index/width, 1) + 1],1) = {\"" : ""]"
		var/turf/place = mother.map[index]
		//Generate Header Character
		var/header_chars = calculate_header_index(index, layers)
		header += "\"[header_chars]\" = ("
		//Get turfs and shit
		var/first = TRUE
		var/empty = TRUE
		for(var/obj/thing in place)
			if(istype(thing, /mob/living/carbon))		//Ignore people, but not animals
				continue
			header += "[empty?"":","][thing.type][generate_metadata(thing)]"
			empty = FALSE
		header += "[empty?"":","][place.type],[get_area(place).type])\n"
		contents += "[header_chars]"
	contents += "\"}"

	//Step 2: Write the data to a file
	var/temp_file = file("data/temp.dmm")
	fdel(temp_file)
	WRITE_FILE(temp_file, "[header]\n\n[contents]")

	//Step 3: Give the file to client for download
	usr << ftp("data/temp.dmm")

	//Step 4: Remove the file from the server (hopefully we can find a way to avoid step)
	fdel(temp_file)

/datum/mapGeneratorModule/save_area/proc/generate_metadata(object)
	var/obj/O = object
	if(!istype(O))
		return ""
	var/dat = ""
	var/data_to_add = list()
	//Direction
	data_to_add += "dir = [O.dir]"
	//Name
	if(O.name)
		data_to_add += "name = \"[O.name]\""
	//Description (Removed, since it's pretty much pointless and gives things their default description anyway)
	//Pixel_
	if(O.pixel_w != 0)
		data_to_add += "pixel_w = \"[O.pixel_w]\""
	if(O.pixel_x != 0)
		data_to_add += "pixel_x = \"[O.pixel_x]\""
	if(O.pixel_y != 0)
		data_to_add += "pixel_y = \"[O.pixel_y]\""
	if(O.pixel_z != 0)
		data_to_add += "pixel_z = \"[O.pixel_z]\""
	//Specific things (Could be important)
	var/obj/item/stack/S = O
	if(istype(S))
		data_to_add += "amount = \"[S.amount]\""
	//Process data to add
	var/first = TRUE
	for(var/data in data_to_add)
		dat += "[first ? "" : ";"][data]"
		first = FALSE
	if(dat)
		dat = "{[dat]}"
	return dat

/datum/mapGeneratorModule/save_area/proc/calculate_header_index(index, layers)
	var/output = ""
	for(var/i in 1 to layers)
		var/l = GLOB.save_file_chars.len
		var/c = FLOOR(index / (l ** (i - 1)), 1)
		c = (c % l) + 1
		log_game("[c] is selected and is associated with [GLOB.save_file_chars[c]]")
		output = "[GLOB.save_file_chars[c]][output]"
	return output
