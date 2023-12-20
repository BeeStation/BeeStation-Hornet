/*
	Turf stuff
*/

GLOBAL_LIST_INIT(default_turf_damage, list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5", "damaged6", "damaged7"))
GLOBAL_LIST_INIT(default_turf_burn, list("damaged1", "damaged2", "damaged3", "damaged4"))

/*
	Rexture stuff
*/

///List of turf texture effect holders that have been made - This means we can just throw shit into vis_contents and avoid making 100s
GLOBAL_LIST_INIT(turf_textures, list())

/proc/load_turf_texture(datum/turf_texture/texture)
	if(!GLOB.turf_textures[texture])
		var/obj/effect/turf_texture/TF = new(null, texture)
		GLOB.turf_textures[texture] = TF
	return GLOB.turf_textures[texture]

///List of turfs that can't be underlays
GLOBAL_LIST_INIT(turf_underlay_blacklist, load_underlay_blacklist())

//For the love of god don't call this anywhere else
/proc/load_underlay_blacklist()
	. = list()
	for(var/turf/T as() in subtypesof(/turf))
		if(!initial(T.can_underlay))
			. += T
