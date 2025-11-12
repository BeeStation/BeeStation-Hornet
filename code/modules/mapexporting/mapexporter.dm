//Map exporter
//Inputting a list of turfs into convert_map_to_tgm() will output a string
//with the turfs and their objects / areas on said turf into the TGM mapping format
//for .dmm files. This file can then be opened in the map editor or imported
//back into the game.
//============================
//This has been made semi-modular so you should be able to use these functions
//elsewhere in code if you ever need to get a file in the .dmm format
/atom/proc/get_save_vars()
	return

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
/proc/convert_map_to_tgm(list/map,\
						save_flag = SAVE_ALL, \
						shuttle_area_flag = SAVE_SHUTTLEAREA_DONTCARE, \
						list/vars_to_save = list("pixel_x", "pixel_y", "dir", "name", "req_access", "req_access_txt", "piping_layer", "color", "icon_state", "pipe_color", "amount"),\
						list/obj_blacklist = list())
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
	var/index = 1
	for(var/x in 1 to width)
		contents += "\n([x],1,1) = {\"\n"
		for(var/y in height to 1 step -1)
			//====Get turfs Data====
			var/turf/place = sortedmap[x][y]
			var/area/location
			var/list/objects
			var/area/AR = get_area(place)
			//If there is nothing there, save as a noop (For odd shapes)
			if(!place)
				place = /turf/template_noop
				location = /area/template_noop
				objects = list()
			//Ignore things in space, must be a space turf and the area has to be empty space
			else if(istype(place, /turf/open/space) && istype(AR, /area/space) && !(save_flag & SAVE_SPACE))
				place = /turf/template_noop
				location = /area/template_noop
			//Stuff to add
			else
				location = AR.type
				objects = place
				place = place.type
			//====Saving shuttles only / non shuttles only====
			var/is_shuttle_area = istype(location, /area/shuttle)
			if((is_shuttle_area && shuttle_area_flag == SAVE_SHUTTLEAREA_IGNORE) || (!is_shuttle_area && shuttle_area_flag == SAVE_SHUTTLEAREA_ONLY))
				place = /turf/template_noop
				location = /area/template_noop
				objects = list()
			//====For toggling not saving areas and turfs====
			if(!(save_flag & SAVE_AREAS))
				location = /area/template_noop
			if(!(save_flag & SAVE_TURFS))
				place = /turf/template_noop
			//====Generate Header Character====
			var/header_char = calculate_tgm_header_index(index, layers)	//The characters of the header
			var/current_header = "(\n"										//The actual stuff inside the header
			//Add objects to the header file
			var/empty = TRUE
			//====SAVING OBJECTS====
			if(save_flag & SAVE_OBJECTS)
				for(var/obj/thing in objects)
					if(thing.type in obj_blacklist)
						continue
					var/metadata = generate_tgm_metadata(thing, vars_to_save)
					current_header += "[empty?"":",\n"][thing.type][metadata]"
					empty = FALSE
					//====SAVING SPECIAL DATA====
					//This is what causes lockers and machines to save stuff inside of them
					if(save_flag & SAVE_OBJECT_PROPERTIES)
						var/custom_data = thing.on_object_saved()
						current_header += "[custom_data ? ",\n[custom_data]" : ""]"
			//====SAVING MOBS====
			if(save_flag & SAVE_MOBS)
				for(var/mob/living/thing in objects)
					if(istype(thing, /mob/living/carbon))		//Ignore people, but not animals
						continue
					var/metadata = generate_tgm_metadata(thing, vars_to_save)
					current_header += "[empty?"":",\n"][thing.type][metadata]"
					empty = FALSE
			current_header += "[empty?"":",\n"][place],\n[location])\n"
			//====Fill the contents file====
			//Compression is done here
			var/position_of_header = header_dat.Find(current_header)
			if(position_of_header)
				//If the header has already been saved, change the character to the other saved header
				header_char = header_chars[position_of_header]
			else
				header += "\"[header_char]\" = [current_header]"
				header_chars += header_char
				header_dat += current_header
				index ++
			contents += "[header_char]\n"
		contents += "\"}"
	return "[header][contents]"

//Sorts maps in terms of their positions, so scrambled / odd shaped maps can be saved
/proc/sort_map(list/map, minx, miny, maxx, maxy)
	var/width = maxx - minx + 1
	var/height = maxy - miny + 1
	var/allTurfs = new/list(width, height)
	for(var/turf/place in map)
		allTurfs[place.x - minx + 1][place.y - miny + 1] = place
	return allTurfs

//vars_to_save = list() to save all vars
/proc/generate_tgm_metadata(atom/O, list/vars_to_save = list("pixel_x", "pixel_y", "dir", "name", "req_access", "req_access_txt", "piping_layer", "color", "icon_state", "pipe_color", "amount"))
	var/dat = ""
	var/data_to_add = list()
	for(var/V in O.vars)
		if(O.get_save_vars())
			if(!(V in O.get_save_vars()))
				continue
		else
			if(!(V in vars_to_save) && vars_to_save)
				continue
		var/value = O.vars[V]
		if(!value)
			continue
		if(value == initial(O.vars[V]) || !issaved(O.vars[V]))
			continue
		var/symbol = ""
		if(istext(value))
			symbol = "\""
			value = sanitize_simple(value, list("{"="", "}"="", "\""="", ";"="", ","=""))
		else if(isicon(value) || isfile(value))
			symbol = "'"
		else if(!(isnum_safe(value) || ispath(value)))
			continue
		//Prevent symbols from being because otherwise you can name something [";},/obj/item/gun/energy/laser/instakill{name="da epic gun] and spawn yourself an instakill gun.
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
