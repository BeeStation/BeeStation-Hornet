// This is where the fun begins.
// These are the main datums that emit light.

/datum/light_source
	var/atom/top_atom        // The atom we're emitting light from (for example a mob if we're from a flashlight that's being held).
	var/atom/source_atom     // The atom that we belong to.

	var/turf/source_turf     // The turf under the above.
	var/turf/pixel_turf      // The turf the top_atom appears to over.
	var/light_power    // Intensity of the emitter light.
	var/light_range      // The range of the emitted light.
	var/light_color    // The colour of the light, string, decomposed by parse_light_color()

	// Variables for keeping track of the colour.
	var/lum_r
	var/lum_g
	var/lum_b

	var/list/turf/affecting_turfs

	var/applied = FALSE // Whether we have applied our light yet or not.

	var/atom/movable/lighting_mask/alpha/our_mask

// Thanks to Lohikar for flinging this tiny bit of code at me, increasing my brain cell count from 1 to 2 in the process.
// This macro will only offset up to 1 tile, but anything with a greater offset is an outlier and probably should handle its own lighting offsets.
// Anything pixelshifted 16px or more will be considered on the next tile.
#define GET_APPROXIMATE_PIXEL_DIR(PX, PY) ((!(PX) ? 0 : ((PX >= 16 ? EAST : (PX <= -16 ? WEST : 0)))) | (!PY ? 0 : (PY >= 16 ? NORTH : (PY <= -16 ? SOUTH : 0))))
#define UPDATE_APPROXIMATE_PIXEL_TURF var/_mask = GET_APPROXIMATE_PIXEL_DIR(top_atom.pixel_x, top_atom.pixel_y); pixel_turf = _mask ? (get_step(source_turf, _mask) || source_turf) : source_turf

/datum/light_source/New(var/atom/movable/owner, var/atom/top)
	source_atom = owner // Set our new owner.
	top_atom = top
	LAZYADD(source_atom.light_sources, src)
	top_atom = top
	if (top_atom != source_atom)
		LAZYADD(top_atom.light_sources, src)

	source_turf = top_atom
	UPDATE_APPROXIMATE_PIXEL_TURF

	light_power = owner.light_power
	light_range = owner.light_range
	light_color = owner.light_color

	PARSE_LIGHT_COLOR(src)

	our_mask = new()
	set_light(light_range, light_power, light_color)
	top_atom.add_vis_contents(our_mask)

/datum/light_source/Destroy(force, ...)
	. = ..()
	qdel(our_mask, force = TRUE)
	top_atom.remove_vis_contents(our_mask)

/datum/light_source/proc/set_light(var/l_range, var/l_power, var/l_color = NONSENSICAL_VALUE)
	if(!our_mask)
		return
	if(l_range)
		our_mask.set_radius(l_range)
	if(l_power)
		our_mask.set_intensity(l_power)
	if(l_color != NONSENSICAL_VALUE)
		our_mask.set_colour(l_color)

/datum/light_source/proc/change_loc(atom/movable/new_loc)
	top_atom.remove_vis_contents(our_mask)
	//TODO our_mask.generate_shadows()
	top_atom = new_loc
	top_atom.add_vis_contents(our_mask)
