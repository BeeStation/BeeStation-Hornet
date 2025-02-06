/*
	Turf stuff
*/

GLOBAL_LIST_INIT(default_turf_damage, list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5", "damaged6", "damaged7"))
GLOBAL_LIST_INIT(default_burn_turf, list("damaged1", "damaged2", "damaged3", "damaged4"))
GLOBAL_LIST_INIT(wood_turf_damage, list("damaged_wood1", "damaged_wood2"))
GLOBAL_LIST_INIT(wood_big_turf_damage, list("damaged_woodbig1", "damaged_woodbig2"))

GLOBAL_LIST_INIT(glass_turf_damage, list("glass-damaged1", "glass-damaged2", "glass-damaged3"))
GLOBAL_LIST_INIT(reinfglass_turf_damage, list("reinf_glass-damaged1", "reinf_glass-damaged2", "reinf_glass-damaged3"))

GLOBAL_LIST_INIT(turf_texture_hallway, list(/datum/turf_texture/hallway))
GLOBAL_LIST_INIT(turf_texture_maint, list(/datum/turf_texture/maint, /datum/turf_texture/hallway, /datum/turf_texture/maint/tile))

GLOBAL_LIST_INIT(turf_texture_iron, list(/datum/turf_texture/hallway, /datum/turf_texture/maint/tile))
GLOBAL_LIST_INIT(turf_texture_iron_nonsegmented, list(/datum/turf_texture/hallway_nonsegmented))
GLOBAL_LIST_INIT(turf_texture_plating, list(/datum/turf_texture/maint))

/*
	Rexture stuff
*/

///List of turf texture effect holders that have been made - This means we can just throw shit into vis_contents and avoid making 100s
GLOBAL_LIST_INIT(turf_textures, list())

/proc/load_turf_texture(datum/turf_texture/texture)
	if(!GLOB.turf_textures[texture])
		var/atom/movable/turf_texture/TF = new(null, texture)
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
