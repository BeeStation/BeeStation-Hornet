// Mutable appearances are an inbuilt byond datastructure. Read the documentation on them by hitting F1 in DM.
// Basically use them instead of images for overlays/underlays and when changing an object's appearance if you're doing so with any regularity.
// Unless you need the overlay/underlay to have a different direction than the base object. Then you have to use an image due to a bug.

// Mutable appearances are children of images, just so you know.

// Mutable appearances erase template vars on new, because they accept an appearance to copy as an arg
// If we have nothin to copy, we set the float plane
/mutable_appearance/New(mutable_appearance/to_copy)
	..()
	if(!to_copy)
		plane = FLOAT_PLANE

// Helper similar to image()
/proc/mutable_appearance(icon, icon_state = "", layer = FLOAT_LAYER, plane = FLOAT_PLANE, alpha = 255, appearance_flags = NONE, color)
	var/mutable_appearance/MA = new()
	MA.icon = icon
	MA.icon_state = icon_state
	MA.layer = layer
	MA.plane = plane
	MA.alpha = alpha
	MA.appearance_flags |= appearance_flags
	if(color)
		MA.color = color
	return MA

/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EMISSIVE_COLOR].
/// Setting the layer is highly important
/proc/emissive_appearance(icon, icon_state = "", layer = FLOAT_LAYER, alpha = 255, appearance_flags = NONE, filters)
	// We actually increase the layer ever so slightly so that emissives overpower blockers.
	// We do this because emissives and blockers can be applied to the same item and in that case
	// we do not want the item to block its own emissive overlay.
	var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, layer + 0.01, EMISSIVE_PLANE, alpha, appearance_flags | EMISSIVE_APPEARANCE_FLAGS)
	appearance.filters = filters
	var/list/found = GLOB.emissive_color[alpha+1]
	if (!found)
		found = GLOB.emissive_color[alpha+1] = list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,alpha/255, 1,1,1,0)
	appearance.color = found
	return appearance

/// Produces a mutable appearance glued to the [EMISSIVE_PLANE], but instead of more opaque being white, more opaque is black.
/// Setting the layer is highly important
/proc/emissive_blocker(icon, icon_state = "", layer = FLOAT_LAYER, alpha = 255, appearance_flags = NONE)
	// Note: alpha doesn't "do" anything, since it's overridden by the color set shortly after
	// Consider removing it someday?
	var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, layer, EMISSIVE_PLANE, alpha, appearance_flags | EMISSIVE_APPEARANCE_FLAGS)
	appearance.color = GLOB.em_blocker_matrix
	return appearance

/// Takes an input mutable appearance, returns a copy of it with the hidden flag flipped to avoid inheriting dir from what it's drawn on
/// This inheriting thing is handled by a hidden flag on the /image (MAs are subtypes of /image)
/proc/make_mutable_appearance_directional(mutable_appearance/to_process, dir = NORTH)
	// We use the image() proc in combo with a manually set dir to flip this flag
	// We can then copy the image's appearance to retain the flag, even on MAs and such
	var/image/holder = image(to_process, dir = dir)
	return new /mutable_appearance(holder)
