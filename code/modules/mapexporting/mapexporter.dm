//Map exporter
//Inputting a list of turfs into convert_map_to_tgm() will output a string
//with the turfs and their objects / areas on said turf into the TGM mapping format
//for .dmm files. This file can then be opened in the map editor or imported
//back into the game.
//============================
//This has been made semi-modular so you should be able to use these functions
//elsewhere in code if you ever need to get a file in the .dmm format

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

//Converts a list of turfs into TGM file format
/proc/convert_map_to_tgm(var/list/map, var/save_flag = SAVE_ALL, var/shuttle_area_flag = SAVE_SHUTTLEAREA_DONTCARE)
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
	var/list/header_chars	= list()	//The characters of the header
	var/list/header_dat 	= list()	//The data of the header, lines up with chars
	var/header				= ""		//The actual header in text
	var/contents			= ""		//The contents in text (bit at the end)
	var/current_x_rel = 1
	var/current_x_abs = 0
	for(var/index in 1 to sortedmap.len)
		var/turf/place = sortedmap[index]
		//Check to see if a new row has been reached
		if(place.x != current_x_abs)
			contents += "[index != 1 ? "\"}" : ""]\n([current_x_rel],1,1) = {\"\n"
			current_x_rel ++
			current_x_abs = place.x
		//Generate Header Character
		var/header_char = calculate_tgm_header_index(index, layers)	//The characters of the header
		var/current_header = "(\n"										//The actual stuff inside the header
		//Add objects to the header file
		var/empty = TRUE
		for(var/obj/thing in place)
			if(istype(thing, /mob/living/carbon))		//Ignore people, but not animals
				continue
			var/metadata = generate_tgm_metadata(thing)
			current_header += "[empty?"":",\n"][thing.type][metadata]"
			empty = FALSE
		current_header += "[empty?"":",\n"][place.type],\n[get_area(place).type])\n"
		//Check if the current header is already used, so we aren't repeating headers
		var/position_of_header = header_dat.Find(current_header)
		if(position_of_header)
			//If the header has already been saved, change the character to the other saved header
			header_char = header_chars[position_of_header]
		else
			header += "\"[header_char]\" = [current_header]"
			header_chars += header_char
			header_dat += current_header
		//Add the header to the contents
		contents += "[header_char]\n"
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
