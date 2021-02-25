/turf
	var/tmp/lighting_corners_initialised = FALSE

	var/tmp/list/datum/legacy_light_source/legacy_affecting_lights       // List of light sources affecting this turf.
	var/tmp/atom/movable/legacy_lighting_object/legacy_lighting_object // Our lighting object.
	var/tmp/list/datum/legacy_lighting_corner/legacy_corners

/turf/proc/legacy_reconsider_lights()
	for(var/datum/legacy_light_source/L as() in legacy_affecting_lights)
		L.vis_update()

/turf/proc/legacy_lighting_clear_overlay()
	if (legacy_lighting_object)
		qdel(legacy_lighting_object, TRUE)

	var/datum/legacy_lighting_corner/C
	var/thing
	for (thing in legacy_corners)
		if(!thing)
			continue
		C = thing
		C.update_active()

// Builds a lighting object for us, but only if our area is dynamic.
/turf/proc/legacy_lighting_build_overlay()
	if (legacy_lighting_object)
		qdel(legacy_lighting_object,force=TRUE) //Shitty fix for lighting objects persisting after death

	var/area/A = loc
	if (!IS_DYNAMIC_LIGHTING(A) && !light_sources)
		return

	if (!lighting_corners_initialised)
		legacy_generate_missing_corners()

	new/atom/movable/legacy_lighting_object(src)

	var/thing
	var/datum/legacy_lighting_corner/C
	var/datum/legacy_light_source/S
	for (thing in legacy_corners)
		if(!thing)
			continue
		C = thing
		if (!C.active) // We would activate the corner, calculate the lighting for it.
			for (thing in C.affecting)
				S = thing
				S.recalc_corner(C)
			C.active = TRUE

// Used to get a scaled lumcount.
/turf/proc/legacy_get_lumcount(var/minlum = 0, var/maxlum = 1)
	if (!legacy_lighting_object)
		return 0

	var/totallums = 0
	var/thing
	var/datum/legacy_lighting_corner/L
	for (thing in legacy_corners)
		if(!thing)
			continue
		L = thing
		totallums += L.lum_r + L.lum_b + L.lum_g

	totallums /= 12 // 4 corners, each with 3 channels, get the average.

	totallums = (totallums - minlum) / (maxlum - minlum)

	return CLAMP01(totallums)

// Returns a boolean whether the turf is on soft lighting.
// Soft lighting being the threshold at which point the overlay considers
// itself as too dark to allow sight and see_in_dark becomes useful.
// So basically if this returns true the tile is unlit black.
/turf/proc/legacy_is_softly_lit()
	if (!legacy_lighting_object)
		return FALSE

	return !legacy_lighting_object.luminosity

/turf/proc/change_area(var/area/old_area, var/area/new_area)
	if(SSlighting.initialized)
		if (new_area.legacy_lighting != old_area.legacy_lighting)
			if (new_area.legacy_lighting)
				legacy_lighting_build_overlay()
			else
				legacy_lighting_clear_overlay()

/turf/proc/legacy_get_corners()
	if (!lighting_corners_initialised)
		legacy_generate_missing_corners()
	if (has_opaque_atom)
		return null // Since this proc gets used in a for loop, null won't be looped though.

	return legacy_corners

/turf/proc/legacy_generate_missing_corners()
	var/area/A = loc
	if (!A.legacy_lighting && !legacy_light_sources)
		return
	lighting_corners_initialised = TRUE
	if (!legacy_corners)
		legacy_corners = list(null, null, null, null)

	for (var/i = 1 to 4)
		if (legacy_corners[i]) // Already have a corner on this direction.
			continue

		legacy_corners[i] = new/datum/legacy_lighting_corner(src, GLOB.LIGHTING_CORNER_DIAGONAL[i])

