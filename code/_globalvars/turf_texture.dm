/*
	Turf texture stuff
*/

///List of turf texture effect holders that have been made - This means we can just throw shit into vis_contents and avoid making 100s
GLOBAL_LIST_INIT(turf_textures, list())

/proc/load_turf_texture(datum/turf_texture/texture)
	if(!GLOB.turf_textures[texture])
		var/obj/effect/turf_texture/TF = new(null, texture)
		GLOB.turf_textures[texture] = TF
	return GLOB.turf_textures[texture]
