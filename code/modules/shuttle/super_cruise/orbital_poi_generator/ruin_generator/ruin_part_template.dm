
#define OPEN_CONNECTION 1
#define ROOM_CONNECTION 2

/datum/map_template/ruin_part
	//Weight of the ruin part.
	var/weight = 0
	//Positions of the connection points.
	var/connection_points = list()

/datum/map_template/ruin_part/New(path, rename, cache)
	. = ..(path, rename, TRUE)
	find_connection_points()
	if(!cache)
		cached_map = null

//=======
// Absolute shitcode of a proc right here
// Copy paste but editted.
//=======

//Finds connection points on a template without actually spawning it
/datum/map_template/ruin_part/proc/find_connection_points()
	var/key_len = 0

	var/list/areaCache = list()
	var/list/modelCache = build_cache()
	var/space_key = modelCache[SPACE_KEY]

	for(var/I in cached_map.gridSets)
		var/datum/grid_set/gset = I
		var/ycrd = gset.ycrd - 1

		for(var/line in gset.gridLines)
			if(ycrd <= world.maxy && ycrd >= 1)
				var/xcrd = gset.xcrd - 1
				for(var/tpos = 1 to length(line) - key_len + 1 step key_len)
					if(xcrd >= 1)
						var/model_key = copytext(line, tpos, tpos + key_len)
						var/list/cache = modelCache[model_key]
						if(!cache)
							CRASH("Undefined model key in DMM: [model_key]")
						build_coordinate(areaCache, cache, xcrd, ycrd)
						CHECK_TICK
					++xcrd
			--ycrd

		CHECK_TICK

/datum/map_template/ruin_part/proc/build_coordinate(list/areaCache, list/model, xcrd, ycrd)
	var/index
	var/list/members = model[1]
	var/list/members_attributes = model[2]

	////////////////
	//Instanciation
	////////////////

	//The next part of the code assumes there's ALWAYS an /area AND a /turf on a given tile
	//first instance the /area and remove it from the members list
	index = members.len

	//then instance the /turf and, if multiple tiles are presents, simulates the DMM underlays piling effect

	var/first_turf_index = 1
	while(!ispath(members[first_turf_index], /turf)) //find first /turf object in members
		first_turf_index++

	//instanciate the first /turf
	var/turf/T
	if(members[first_turf_index] != /turf/template_noop)
		T = instance_atom(members[first_turf_index],members_attributes[first_turf_index], xcrd, ycrd)

	if(T)
		//if others /turf are presents, simulates the underlays piling effect
		index = first_turf_index + 1
		while(index <= members.len - 1) // Last item is an /area
			var/underlay = T.appearance
			T = instance_atom(members[index],members_attributes[index],xcrd, ycrd)//instance new turf
			T.underlays += underlay
			index++

	//finally instance all remainings objects/mobs
	for(index in 1 to first_turf_index-1)
		instance_atom(members[index],members_attributes[index], xcrd, ycrd, zcrd)

/datum/map_template/ruin_part/proc/instance_atom(path,list/attributes, xcrd, ycrd)
	world.preloader_setup(attributes, path)

	if(ispath(path, /obj/effect/abstract/open_area_marker))
		connection_points["[xcrd],[ycrd]"] = OPEN_CONNECTION
	else if(ispath(path, /obj/effect/abstract/doorway_marker))
		connection_points["[xcrd],[ycrd]"] = ROOM_CONNECTION

	//custom CHECK_TICK here because we don't want things created while we're sleeping to not initialize
	if(TICK_CHECK)
		stoplag()

/datum/map_template/ruin_part/proc/build_cache(bad_paths=null)
	. = list()
	var/list/grid_models = cached_map.grid_models
	for(var/model_key in grid_models)
		var/model = grid_models[model_key]
		var/list/members = list() //will contain all members (paths) in model (in our example : /turf/unsimulated/wall and /area/mine/explored)
		var/list/members_attributes = list() //will contain lists filled with corresponding variables, if any (in our example : list(icon_state = "rock") and list())

		/////////////////////////////////////////////////////////
		//Constructing members and corresponding variables lists
		////////////////////////////////////////////////////////

		var/index = 1
		var/old_position = 1
		var/dpos

		while(dpos != 0)
			//finding next member (e.g /turf/unsimulated/wall{icon_state = "rock"} or /area/mine/explored)
			dpos = cached_map.find_next_delimiter_position(model, old_position, ",", "{", "}") //find next delimiter (comma here) that's not within {...}

			var/full_def = cached_map.trim_text(copytext(model, old_position, dpos)) //full definition, e.g : /obj/foo/bar{variables=derp}
			var/variables_start = findtext(full_def, "{")
			var/path_text = cached_map.trim_text(copytext(full_def, 1, variables_start))
			var/atom_def = text2path(path_text) //path definition, e.g /obj/foo/bar
			if(dpos)
				old_position = dpos + length(model[dpos])

			if(!ispath(atom_def, /atom)) // Skip the item if the path does not exist.  Fix your crap, mappers!
				if(bad_paths)
					LAZYOR(bad_paths[path_text], model_key)
				continue
			members.Add(atom_def)

			//transform the variables in text format into a list (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
			var/list/fields = list()

			if(variables_start)//if there's any variable
				full_def = copytext(full_def, variables_start + length(full_def[variables_start]), -length(copytext_char(full_def, -1))) //removing the last '}'
				fields = cached_map.readlist(full_def, ";")
				if(fields.len)
					if(!trim(fields[fields.len]))
						--fields.len
					for(var/I in fields)
						var/value = fields[I]
						if(istext(value))
							fields[I] = apply_text_macros(value)

			//then fill the members_attributes list with the corresponding variables
			members_attributes.len++
			members_attributes[index++] = fields

			CHECK_TICK

		//check and see if we can just skip this turf
		//So you don't have to understand this horrid statement, we can do this if
		// 1. no_changeturf is set
		// 2. the space_key isn't set yet
		// 3. there are exactly 2 members
		// 4. with no attributes
		// 5. and the members are world.turf and world.area
		// Basically, if we find an entry like this: "XXX" = (/turf/default, /area/default)
		// We can skip calling this proc every time we see XXX
		if(!(.[SPACE_KEY]) \
			&& members.len == 2 \
			&& members_attributes.len == 2 \
			&& length(members_attributes[1]) == 0 \
			&& length(members_attributes[2]) == 0 \
			&& (world.area in members) \
			&& (world.turf in members))

			.[SPACE_KEY] = model_key
			continue


		.[model_key] = list(members, members_attributes)
