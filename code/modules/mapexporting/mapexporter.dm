//Map exporter
//Inputting a list of turfs into convert_map_to_tgm() will output a string
//with the turfs and their objects / areas on said turf into the TGM mapping format
//for .dmm files. This file can then be opened in the map editor or imported
//back into the game.
//============================

//A list of vars that have been altered as a result of pre_save function
//These vars will be reset in post_save
//This may break things, so it is HIGHLY recommended this is executed post round-end, or the thing saved
//is deleted immediately after.
/obj/var/pre_saved_vars

//This has been made semi-modular so you should be able to use these functions
//elsewhere in code if you ever need to get a file in the .dmm format
/atom/proc/get_save_vars(save_flag)
	return

//Gets the saved type
//Allows overriding mapping subtypes that spawn with contents.
/obj/proc/get_saved_type()
	return type

//Executed on anything that is being saved before it gets saved.
//If an object is in a pre_save group, the first parameter will not be the map
//but other things in the group.
//if its in a pre_save group it must also return true when a valid pre save op is performed
/obj/proc/pre_save(list/map, pre_save_key = "")
	return

//Returns the pre-save key for pre save functions that require
//multi object functions
/obj/proc/get_pre_save_key()
	return null

//Resets vars
/obj/proc/post_save()
	if(!pre_saved_vars)
		return
	for(var/varname in pre_saved_vars)
		if(!vars[varname])
			stack_trace("SAVING ERROR: Vars doesn't [varname] but this is somehow conatined in pre_save_vars.")
			continue
		vars[varname] = pre_saved_vars[varname]
	pre_saved_vars = null

/obj/proc/is_save_safe(save_flag)
	//Check safety
	if(flags_1 & HOLOGRAM_1)
		return FALSE
	if(!(flags_1 & SAVE_SAFE_1) && !(save_flag & SAVE_UNSAFE_OBJECTS))
		return FALSE
	//Check indestructible
	if(!(save_flag & SAVE_INDESTRUCTABLE) && (obj_flags & INDESTRUCTIBLE))
		return FALSE
	//Check admineditted
	if(!(save_flag & SAVE_ADMINEDITTED) && (flags_1 & ADMIN_SPAWNED_1))
		return FALSE
	return TRUE

/obj/effect/is_save_safe(save_flag)
	return FALSE

/obj/item/is_save_safe(save_flag)
	//Check safety
	if((item_flags & DROPDEL) || (item_flags & ABSTRACT) || HAS_TRAIT(src, TRAIT_NODROP))
		return FALSE
	if(!(save_flag & SAVE_UNSAFE_OBJECTS) && (item_flags & ILLEGAL))
		return FALSE
	return ..()

//A list of characters that are valid as DMM file keys
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
/proc/convert_map_to_tgm(
		//List of the turfs we want to save
		var/list/map,\
		//The flags we want to use when saving
		var/save_flag = SAVE_DEFAULT, \
		//Should shuttle areas be included or excluded? See _DEFINES/mapexporting.dm for options.
		var/shuttle_area_flag = SAVE_SHUTTLEAREA_IGNORE, \
		//A list of the vars to save raw.
		//Assoc list
		//Key - Varname
		//Value - EITHER: Define from _DEFINES/MAPEXPORTING.DM ~~Callbacks were removed and replaced with just adding a new define~~
		var/list/vars_to_save = list(
			"pixel_x" = MAPEXPORTER_VAR_NUM,
			"pixel_y" = MAPEXPORTER_VAR_NUM,
			"dir" = MAPEXPORTER_VAR_NUM,
			"req_access" = MAPEXPORTER_VAR_ACCESS_LIST,
			"req_one_access" = MAPEXPORTER_VAR_ACCESS_LIST,
			"piping_layer" = MAPEXPORTER_VAR_NUM,
			"color" = MAPEXPORTER_VAR_COLOUR,
			"pipe_color" = MAPEXPORTER_VAR_COLOUR,
			"amount" = MAPEXPORTER_VAR_NUM,
		),\
		//A list of objects that are save safe that we want to blacklist anyway
		var/list/obj_blacklist = list())
	//Calculate the bounds
	var/minx = world.maxx
	var/miny = world.maxy
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
	var/layers = CEILING(log(GLOB.save_file_chars.len, turfsNeeded),1)

	var/list/pre_save_groups = list()

	//Step 0.5: Execute pre_save on all objects that will be saved
	if(save_flag & SAVE_OBJECTS)
		for(var/x in 1 to width)
			for(var/y in height to 1 step -1)
				//====Get turfs Data====
				var/turf/place = sortedmap[x][y]
				var/list/objects = place
				var/area/AR = get_area(place)
				//If there is nothing there, save as a noop (For odd shapes)
				if(!place)
					continue
				//Ignore things in space, must be a space turf and the area has to be empty space
				else if(istype(place, /turf/open/space) && (istype(AR, /area/space) || istype(AR, /area/shuttle/transit))&& !(save_flag & SAVE_SPACE))
					continue
				//====Saving shuttles only / non shuttles only====
				var/is_shuttle_area = istype(AR, /area/shuttle)
				if((is_shuttle_area && shuttle_area_flag == SAVE_SHUTTLEAREA_IGNORE) || (!is_shuttle_area && shuttle_area_flag == SAVE_SHUTTLEAREA_ONLY))
					continue
				//====SAVING OBJECTS====
				for(var/obj/thing in objects)
					//Check blacklist
					if(thing.type in obj_blacklist)
						continue
					//Check safety
					if(!thing.is_save_safe(save_flag))
						continue
					var/key = thing.get_pre_save_key()
					if(key)
						LAZYADDASSOCLIST(pre_save_groups, key, thing)
					else
						thing.pre_save(map)

	//Step 0.75: Run through pre save groups and execute them
	//This allows machines that need to pre save together to do that.
	for(var/key in pre_save_groups)
		var/list/things_in_group = pre_save_groups[key]
		for(var/obj/object as() in things_in_group)
			//Pre save only needs to run on 1 object.
			if(object.pre_save(things_in_group, key))
				break
	pre_save_groups = null

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
			var/is_shuttle_area = istype(AR, /area/shuttle)
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
					//Check blacklist
					if(thing.type in obj_blacklist)
						continue
					if(!thing.is_save_safe(save_flag))
						continue
					var/metadata = generate_tgm_metadata(thing, vars_to_save, save_flag)
					current_header += "[empty?"":",\n"][thing.get_saved_type()][metadata]"
					empty = FALSE
					//====SAVING SPECIAL DATA====
					//This is what causes lockers and machines to save stuff inside of them
					if(save_flag & SAVE_OBJECT_PROPERTIES)
						var/custom_data = thing.on_object_saved(save_flag)
						current_header += "[custom_data ? ",\n[custom_data]" : ""]"
					//====POSTSAVE====
					thing.post_save()
			//====SAVING MOBS====
			if(save_flag & SAVE_MOBS)
				for(var/mob/living/thing in objects)
					if(!isanimal(thing) || ismegafauna(thing))		//Ignore people, but not animals
						continue
					//Check safety
					if(!(thing.flags_1 & SAVE_SAFE_1) && !(save_flag & SAVE_UNSAFE_OBJECTS))
						continue
					//Check admineditted
					if(!(save_flag & SAVE_ADMINEDITTED) && (thing.flags_1 & ADMIN_SPAWNED_1))
						continue
					var/metadata = generate_tgm_metadata(thing, vars_to_save, save_flag)
					current_header += "[empty?"":",\n"][thing.type][metadata]"
					empty = FALSE
			else
				for(var/mob/living/thing in objects)
					//The long gone explorers
					current_header += "[empty?"":",\n"]/obj/effect/decal/remains/human"
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
/proc/sort_map(var/list/map, minx, miny, maxx, maxy)
	var/width = maxx - minx + 1
	var/height = maxy - miny + 1
	var/allTurfs = new/list(width, height)
	for(var/turf/place in map)
		allTurfs[place.x - minx + 1][place.y - miny + 1] = place
	return allTurfs

//vars_to_save = list() to save all vars
/proc/generate_tgm_metadata(atom/O, list/vars_to_save, save_flag)
	var/dat = ""
	var/data_to_add = list()
	//Fetch specific vars to save on objects
	var/list/object_save_vars = O.get_save_vars(save_flag)

	//Save object specific vars
	//Works slightly differently to normal:
	//We don't need to check returned values to see if they should be saved, we only ever return values we want to save.
	//This returns the varname and the varvalue, rather than the varname and the data type.
	//We will assume that the returned datavalue is already verified, safe.
	//Convert strings to the proper format too.
	for(var/varname in object_save_vars)
		//Get the value, or add null if its null.
		//Assume null is on purpose.
		var/varvalue = object_save_vars[varname] || "null"
		//Prevent symbols from being because otherwise you can name something [";},/obj/item/gun/energy/laser/instakill{name="da epic gun] and spawn yourself an instakill gun.
		data_to_add += "[varname] = [varvalue]"

	//Save vars directly from vars_to_save
	for(var/V in O.vars)
		var/var_name = V
		var/save_data
		var/verified = FALSE
		//Check if the variable is in the list of variables to save
		if(V in vars_to_save)
			//Fetch the save type
			save_data = vars_to_save[V]
		else
			continue
		//Check if it was saved already
		if(V in object_save_vars)
			continue
		//Fetch the vlaue
		var/value = O.vars[V]

		//Verify if the value actually needs saving
		if(!value)
			continue
		if(value == initial(O.vars[V]) || !issaved(O.vars[V]))
			continue

		//Check data types
		var/symbol = ""

		//Verify data types
		if(!verified)
			switch(save_data)
				//Numbers are relatively safe, even if editted by the player
				//Watch out for objects that use defines to define operations of objects
				if(MAPEXPORTER_VAR_NUM)
					if(!isnum_safe(value))
						continue
				// !DANGEROUS! STRING THAT CAN BE ALTERED BY THE PLAYER _CANNOT_ BE TRUSTED.
				if(MAPEXPORTER_VAR_STRING)
					if(!istext(value))
						continue
					symbol = "\""
					value = sanitize_simple(value, list("{"="", "}"="", "\""="", ";"="", ","=""))
				// !DANGEROUS! Typepaths can be pretty dangerous if used incorrectly.
				// These should almost always be manually verified.
				if(MAPEXPORTER_VAR_TYPEPATH)
					if(!ispath(value))
						continue
				if(MAPEXPORTER_VAR_ACCESS_LIST)
					value = convert_access_to_txt(value)
					symbol = "\""
					var_name = "[V]_txt"
					if(!value)
						continue
				if(MAPEXPORTER_VAR_COLOUR)
					value = verify_colour(value)
					if(!value)
						continue
					symbol = "\""
				if(MAPEXPORTER_VAR_CKEY)
					//ckey() only allows for characters and @s which are safe to dmm files.
					value = ckey(value)
					symbol = "\""
				else
					continue

		//Prevent symbols from being because otherwise you can name something [";},/obj/item/gun/energy/laser/instakill{name="da epic gun] and spawn yourself an instakill gun.
		data_to_add += "[var_name] = [symbol][value][symbol]"
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

/proc/convert_access_to_txt(list/req_access)
	//Verification
	for(var/thing in req_access)
		if(!isnum(thing))
			return null
	//Return
	return req_access.Join(";")

//Very simple colour verification
/proc/verify_colour(colour)
	var/regex/r = regex("^#(\[\\dabcdefABCDEF\]\[\\dabcdefABCDEF\]\[\\dabcdefABCDEF\]$|\[\\dabcdefABCDEF\]\[\\dabcdefABCDEF\]\[\\dabcdefABCDEF\]\[\\dabcdefABCDEF\]\[\\dabcdefABCDEF\]\[\\dabcdefABCDEF\]$)", "g")
	if(findtext(colour, r))
		return colour
	return null
