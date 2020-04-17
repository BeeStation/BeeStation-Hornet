//Bits to save
#define SAVE_OBJECTS (1 << 1)		//Save objects?
#define SAVE_MOBS (1 << 2)			//Save Mobs?
#define SAVE_TURFS (1 << 3)			//Save turfs?
#define SAVE_AREAS (1 << 4)			//Save areas?
#define SAVE_SPACE (1 << 5)			//Save space areas? (If not they will be saved as NOOP)

//Ignore turf if it contains
#define SAVE_SHUTTLEAREA_DONTCARE 0
#define SAVE_SHUTTLEAREA_IGNORE 1
#define SAVE_SHUTTLEAREA_ONLY 2

GLOBAL_LIST_INIT(save_file_chars, list(
	"a","b","c","d","e",
	"f","g","h","i","j",
	"k","l","m","n","o",
	"p","q","r","s","t",
	"u","v","w","x","y",
	"z","A","B","C","D",
	"E","F","G","H","I",
	"J","K","L","M","N",
	"O","P","Q","R","S",
	"T","U","V","W","X",
	"Y","Z"
))

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

//Converts a list of turfs into TGM file format
/proc/convert_map_to_tgm(var/list/map)
	//Calculate the bounds
	var/minx = 1024
	var/miny = 1024
	var/maxx = -1
	var/maxy = -1
	for(var/turf/place in map)
		minx = min(place.x, minx)
		miny = min(place.y, miny)
		maxx = max(place.x, maxx)
		maxy = max(place.y, maxy)
	var/width = maxx - minx + 1
	var/height = maxy - miny + 1

	//Sort the map so weird shaped / bad inputted maps can be handled
	var/list/sortedmap = sort_map(map, minx, miny, maxx, maxy)

	//Step 0: Calculate the amount of letters we need (26 ^ n > turf count)
	var/turfsNeeded = width * height
	var/layers = FLOOR(log(GLOB.save_file_chars.len, turfsNeeded) + 0.999,1)

	//Step 1: Run through the area and generate file data
	var/header = ""
	var/contents = ""
	var/current_x_rel = 1
	var/current_x_abs = 0
	for(var/index in 1 to sortedmap.len)
		var/turf/place = sortedmap[index]
		if(place.x != current_x_abs)
			contents += "[index != 1 ? "\"}" : ""]\n([current_x_rel],1,1) = {\"\n"
			current_x_rel ++
			current_x_abs = place.x
		//Generate Header Character
		var/header_chars = calculate_tgm_header_index(index, layers)
		header += "\"[header_chars]\" = (\n"
		//Get turfs and shit
		var/empty = TRUE
		for(var/obj/thing in place)
			if(istype(thing, /mob/living/carbon))		//Ignore people, but not animals
				continue
			var/metadata = generate_tgm_metadata(thing)
			header += "[empty?"":",\n"][thing.type][metadata]"
			empty = FALSE
		header += "[empty?"":",\n"][place.type],\n[get_area(place).type])\n"
		contents += "[header_chars]\n"
	contents += "\"}"

	return "[header][contents]"

//Sorts maps in terms of their positions, so scrambled / odd shaped maps can be saved
/proc/sort_map(var/list/map, minx, miny, maxx, maxy)
	var/width = maxx - minx + 1
	var/height = maxy - miny + 1
	var/allTurfs = new/list(width, height)
	for(var/turf/place in map)
		allTurfs[place.x - minx + 1][place.y - miny + 1] = place
	var/list/output = list()
	for(var/x in 1 to width)
		for(var/y in height to 1 step -1)
			if(allTurfs[x][y])
				output += allTurfs[x][y]
	return output

//vars_to_save = list() to save all vars
/proc/generate_tgm_metadata(var/atom/O, var/list/vars_to_save = list("pixel_x", "pixel_y", "dir", "name", "req_access", "req_access_txt", "piping_layer", "color", "icon_state", "pipe_color", "amount"))
	//This idea was taken from https://github.com/WaspStation/WaspStation-1.0/pull/109/files
	var/list/dont_save_if_empty = list("icon_state")
	var/dat = ""
	var/data_to_add = list()
	for(var/V in O.vars)
		if(!(V in vars_to_save) && vars_to_save)
			continue
		var/value = O.vars[V]
		if(!value)
			continue
		if(value == initial(O.vars[V]) || !issaved(O.vars[V]))
			continue
		if((V in dont_save_if_empty) && value == "")
			continue
		var/symbol = ""
		if(istext(value))
			symbol = "\""
		else if(isicon(value) || isfile(value))
			symbol = "'"
		else if(!(isnum(value) || ispath(value)))
			continue
		data_to_add += "[V] = [symbol][value][symbol]"
	//Process data to add
	var/first = TRUE
	for(var/data in data_to_add)
		dat += "[first ? "" : ";\n"]\t[data]"
		first = FALSE
	if(dat)
		dat = "{\n[dat]\n\t}"
	return dat

/proc/calculate_tgm_header_index(index, layers)
	var/output = ""
	for(var/i in 1 to layers)
		var/l = GLOB.save_file_chars.len
		var/c = FLOOR((index-1) / (l ** (i - 1)), 1)
		c = (c % l) + 1
		output = "[GLOB.save_file_chars[c]][output]"
	return output
