
/atom
	var/tmp/datum/legacy_light_source/legacy_light // Our light source. Don't fuck with this directly unless you have a good reason!
	var/tmp/list/legacy_light_sources       // Any light sources that are "inside" of us, for example, if src here was a mob that's carrying a flashlight, that flashlight's light source would be part of this list.

/atom/proc/legacy_update_light()
	set waitfor = FALSE
	if (QDELETED(src))
		return

	if (!light_power || !light_range) // We won't emit light anyways, destroy the light source.
		QDEL_NULL(legacy_light)
	else
		if (!ismovableatom(loc)) // We choose what atom should be the top atom of the light here.
			. = src
		else
			. = loc

		if (legacy_light) // Update the light or create it if it does not exist.
			legacy_light.update(.)
		else
			legacy_light = new/datum/legacy_light_source(src, .)

/atom/movable/Moved(atom/OldLoc, Dir)
	. = ..()
	var/datum/legacy_light_source/L
	var/thing
	for (thing in legacy_light_sources) // Cycle through the light sources on this atom and tell them to update.
		L = thing
		L.source_atom.legacy_update_light()
