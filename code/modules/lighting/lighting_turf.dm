//Estimates the light power based on the alpha of the light and the range.
//Assumes a linear fallout at (0, alpha/255) to (range, 0)
#define LIGHT_POWER_ESTIMATION(alpha, range, distance) max((alpha * (range - distance)) / (255 * range), 0)

/turf

	luminosity           = 1

	var/tmp/list/lights_affecting
	var/tmp/has_opaque_atom = FALSE // Not to be confused with opacity, this will be TRUE if there's any opaque atom on the tile.

/turf/Destroy(force)
	if(lights_affecting)
		for(var/atom/movable/lighting_mask/alpha/mask as() in lights_affecting)
			LAZYREMOVE(mask.affecting_turfs, src)
		lights_affecting = null
	. = ..()

// Causes any affecting light sources to be queued for a visibility update, for example a door got opened.
/turf/proc/reconsider_lights()
	if(!lights_affecting)
		return
	//Copy to prevent looping
	for(var/atom/movable/lighting_mask/alpha/mask as() in lights_affecting.Copy())
		mask.calculate_lighting_shadows()

// Used to get a scaled lumcount.
/turf/proc/get_lumcount()
	var/lums = 0
	for(var/atom/movable/lighting_mask/alpha/mask as() in lights_affecting)
		lums += LIGHT_POWER_ESTIMATION(mask.alpha, mask.radius, get_dist(src, get_turf(mask)))
	return min(lums, 1.0)

// Returns a boolean whether the turf is on soft lighting.
// Soft lighting being the threshold at which point the overlay considers
// itself as too dark to allow sight and see_in_dark becomes useful.
// So basically if this returns true the tile is unlit black.
/turf/proc/is_softly_lit()
	return TRUE

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

	if (Obj?.opacity)
		recalc_atom_opacity() // Make sure to do this before reconsider_lights(), incase we're on instant updates.
		reconsider_lights()
