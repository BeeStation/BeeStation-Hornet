
/atom
	var/light_power = 1 // Intensity of the light.
	var/light_range = 0 // Range in tiles of the light.
	var/light_color     // Hexadecimal RGB string representing the colour of the light.
	var/light_mask_type = null

	var/tmp/datum/light_source/light // Our light source. Don't fuck with this directly unless you have a good reason!
	var/tmp/list/light_sources       // Any light sources that are "inside" of us, for example, if src here was a mob that's carrying a flashlight, that flashlight's light source would be part of this list.

// The proc you should always use to set the light of this atom.
// Nonesensical value for l_color default, so we can detect if it gets set to null.
#define NONSENSICAL_VALUE -99999
/atom/proc/set_light(l_range, l_power, l_color = NONSENSICAL_VALUE, mask_type)
	if(l_range > 0 && l_range < MINIMUM_USEFUL_LIGHT_RANGE)
		l_range = MINIMUM_USEFUL_LIGHT_RANGE	//Brings the range up to 1.4, which is just barely brighter than the soft lighting that surrounds players.
	if (l_power != null)
		light_power = l_power

	if (l_range != null)
		light_range = l_range

	if (l_color != NONSENSICAL_VALUE)
		light_color = l_color

	if(mask_type != null)
		light_mask_type = mask_type

	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT, l_range, l_power, l_color)

	update_light()

// Will update the light (duh).
// Creates or destroys it if needed, makes it update values, makes sure it's got the correct source turf...
/atom/proc/update_light()
	set waitfor = FALSE
	if (QDELETED(src))
		return

	if (!light_power || !light_range) // We won't emit light anyways, destroy the light source.
		if(light)
			QDEL_NULL(light)
	else
		if(light && light_mask_type && (light_mask_type != light.mask_type))
			QDEL_NULL(light)
		if (!light) // Update the light or create it if it does not exist.
			light = new /datum/light_source(src, light_mask_type)
		else
			light.set_light(light_range, light_power, light_color)
			light.update_position()

// If we have opacity, make sure to tell (potentially) affected light sources.
/atom/movable/Destroy()
	var/turf/T = loc
	. = ..()
	if(light)
		QDEL_NULL(light)
	if (opacity && istype(T))
		var/old_has_opaque_atom = T.has_opaque_atom
		T.recalc_atom_opacity()
		if (old_has_opaque_atom != T.has_opaque_atom)
			T.reconsider_lights()

// Should always be used to change the opacity of an atom.
// It notifies (potentially) affected light sources so they can update (if needed).
/atom/proc/set_opacity(var/new_opacity)
	if (new_opacity == opacity)
		return

	opacity = new_opacity
	var/turf/T = loc
	if (!isturf(T))
		return

	if (new_opacity == TRUE)
		T.has_opaque_atom = TRUE
		T.reconsider_lights()
	else
		var/old_has_opaque_atom = T.has_opaque_atom
		T.recalc_atom_opacity()
		if (old_has_opaque_atom != T.has_opaque_atom)
			T.reconsider_lights()


/atom/movable/Moved(atom/OldLoc, Dir)
	. = ..()
	var/datum/light_source/L
	var/thing
	for (thing in light_sources) // Cycle through the light sources on this atom and tell them to update.
		L = thing
		L.source_atom.update_light()

/atom/movable/setDir(newdir)
	. = ..()
	for(var/datum/light_source/thing as() in light_sources)
		thing.our_mask?.holder_turned(newdir)

/atom/vv_edit_var(var_name, var_value)
	switch (var_name)
		if ("light_range")
			set_light(l_range=var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE

		if ("light_power")
			set_light(l_power=var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE

		if ("light_color")
			set_light(l_color=var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE

	return ..()


/atom/proc/flash_lighting_fx(
		_range = FLASH_LIGHT_RANGE,
		_power = FLASH_LIGHT_POWER,
		_color = LIGHT_COLOR_WHITE,
		_duration = FLASH_LIGHT_DURATION,
		_reset_lighting = TRUE,
		_flash_times = 1)
	new /obj/effect/light_flash(get_turf(src), _range, _power, _color, _duration, _flash_times)

/atom/proc/add_vis_contents(atom/thing)
	return

/turf/add_vis_contents(atom/thing)
	vis_contents += thing

/atom/movable/add_vis_contents(atom/thing)
	vis_contents += thing

/atom/proc/remove_vis_contents(atom/thing)
	return

/turf/remove_vis_contents(atom/thing)
	vis_contents -= thing

/atom/movable/remove_vis_contents(atom/thing)
	vis_contents -= thing

/obj/effect/light_flash/Initialize(mapload, _range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = LIGHT_COLOR_WHITE, _duration = FLASH_LIGHT_DURATION, _flash_times = 1)
	light_range = _range
	light_power = _power
	light_color = _color
	. = ..()
	do_flashes(_flash_times, _duration)

/obj/effect/light_flash/proc/do_flashes(_flash_times, _duration)
	set waitfor = FALSE
	for(var/i in 1 to _flash_times)
		light.our_mask.alpha = 255
		animate(light.our_mask, time = _duration, easing = SINE_EASING, alpha = 0)
		sleep(_duration)
	qdel(src)
