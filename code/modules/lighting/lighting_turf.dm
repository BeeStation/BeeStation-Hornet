/turf
	var/dynamic_lighting = TRUE
	luminosity           = 1

	var/tmp/lighting_corners_initialised = FALSE

	var/tmp/list/datum/light_source/affecting_lights       // List of light sources affecting this turf.
	var/tmp/atom/movable/lighting_object/lighting_object // Our lighting object.
	var/tmp/datum/lighting_corner/lc_topleft
	var/tmp/datum/lighting_corner/lc_topright
	var/tmp/datum/lighting_corner/lc_bottomleft
	var/tmp/datum/lighting_corner/lc_bottomright
	var/tmp/has_opaque_atom = FALSE // Not to be confused with opacity, this will be TRUE if there's any opaque atom on the tile.

// counterclockwisse 0 to 360
#define PROC_ON_CORNERS(operation) lc_topright?.##operation;lc_bottomright?.##operation;lc_bottomleft?.##operation;lc_topleft?.##operation

// Causes any affecting light sources to be queued for a visibility update, for example a door got opened.
/turf/proc/reconsider_lights()
	var/datum/light_source/L
	var/thing
	for (thing in affecting_lights)
		L = thing
		L.vis_update()

/turf/proc/lighting_clear_overlay()
	if (lighting_object)
		qdel(lighting_object, TRUE)

	PROC_ON_CORNERS(update_active())

// Builds a lighting object for us, but only if our area is dynamic.
/turf/proc/lighting_build_overlay()
	if (lighting_object)
		qdel(lighting_object,force=TRUE) //Shitty fix for lighting objects persisting after death

	var/area/A = loc
	if (!IS_DYNAMIC_LIGHTING(A) && !light_sources)
		return

	if (!lighting_corners_initialised)
		generate_missing_corners()

	new/atom/movable/lighting_object(src)

	var/datum/light_source/S
	var/i
#define OPERATE(corner) \
	if(corner && !corner.active) { \
		for(i in corner.affecting) { \
			S = i ; \
			S.recalc_corner(corner) \
		} \
		corner.active = TRUE \
	}
	OPERATE(lc_topright)
	OPERATE(lc_bottomright)
	OPERATE(lc_bottomleft)
	OPERATE(lc_topleft)
#undef OPERATE

// Used to get a scaled lumcount.
/turf/proc/get_lumcount(var/minlum = 0, var/maxlum = 1)
	if(!lighting_object)
		return 1

	var/totallums = (lc_topright? (lc_topright.lum_r + lc_topright.lum_g + lc_topright.lum_b) : 0) \
	+ (lc_bottomright? (lc_bottomright.lum_r + lc_bottomright.lum_g + lc_bottomright.lum_b) : 0) \
	+ (lc_bottomleft? (lc_bottomleft.lum_r + lc_bottomleft.lum_g + lc_bottomleft.lum_b) : 0) \
	+ (lc_topleft? (lc_topleft.lum_r + lc_topleft.lum_g + lc_topleft.lum_b) : 0)

	totallums /= 12 // 4 corners, each with 3 channels, get the average.

	totallums = (totallums - minlum) / (maxlum - minlum)

	return CLAMP01(totallums)

// Returns a boolean whether the turf is on soft lighting.
// Soft lighting being the threshold at which point the overlay considers
// itself as too dark to allow sight and see_in_dark becomes useful.
// So basically if this returns true the tile is unlit black.
/turf/proc/is_softly_lit()
	if (!lighting_object)
		return FALSE

	return !lighting_object.luminosity

// Can't think of a good name, this proc will recalculate the has_opaque_atom variable.
/turf/proc/recalc_atom_opacity()
	has_opaque_atom = opacity
	if (!has_opaque_atom)
		for (var/atom/A in src.contents) // Loop through every movable atom on our tile PLUS ourselves (we matter too...)
			if (A.opacity)
				has_opaque_atom = TRUE
				break

/turf/Exited(atom/movable/Obj, atom/newloc)
	. = ..()

	if (Obj && Obj.opacity)
		recalc_atom_opacity() // Make sure to do this before reconsider_lights(), incase we're on instant updates.
		reconsider_lights()

/turf/proc/change_area(var/area/old_area, var/area/new_area)
	if(SSlighting.initialized)
		if (new_area.dynamic_lighting != old_area.dynamic_lighting)
			if (new_area.dynamic_lighting)
				lighting_build_overlay()
			else
				lighting_clear_overlay()

/turf/proc/generate_missing_corners()
	if (!IS_DYNAMIC_LIGHTING(src) && !light_sources)
		return
	lighting_corners_initialised = TRUE
	// counterclockwise from 0 to 360.
	if(!lc_topright)
		new /datum/lighting_corner(src, NORTHEAST)
	if(!lc_bottomright)
		new /datum/lighting_corner(src, SOUTHEAST)
	if(!lc_bottomleft)
		new /datum/lighting_corner(src, SOUTHWEST)
	if(!lc_topleft)
		new /datum/lighting_corner(src, NORTHWEST)

#undef PROC_ON_CORNERS
