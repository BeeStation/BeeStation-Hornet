GLOBAL_DATUM_INIT(fullbright_overlay, /image, create_fullbright_overlay())

/proc/create_fullbright_overlay()
	var/image/lighting_effect = new()
	lighting_effect.appearance = /obj/effect/fullbright
	return lighting_effect

GLOBAL_DATUM_INIT(starlight_overlay, /image, create_starlight_overlay())

/proc/create_starlight_overlay()
	var/image/lighting_effect = new()
	lighting_effect.appearance = /obj/effect/fullbright/starlight
	return lighting_effect

/area
	/// Whether this area allows static lighting and thus loads the lighting objects
	/// If FALSE, lighting objects aren't initialized for the turfs in this area
	var/static_lighting = TRUE

//Non static lighting areas.
//Any lighting area that wont support static lights.
//These areas will NOT have corners generated.

///regenerates lighting objects for turfs in this area, primary use is VV changes
/area/proc/create_area_lighting_objects()
	for(var/turf/contained_turf in get_turfs_from_all_zlevels())
		if(contained_turf.fullbright_type != FULLBRIGHT_NONE)
			continue
		contained_turf.lighting_build_overlay()
		CHECK_TICK

///Removes lighting objects from turfs in this area if we have them, primary use is VV changes
/area/proc/remove_area_lighting_objects()
	for(var/turf/contained_turf in get_turfs_from_all_zlevels())
		if(contained_turf.fullbright_type != FULLBRIGHT_NONE)
			continue
		contained_turf.lighting_clear_overlay()
		CHECK_TICK
