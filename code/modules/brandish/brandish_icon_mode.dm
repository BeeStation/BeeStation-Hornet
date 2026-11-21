/// Atom appearance policies and shared-resource binding.
/atom
	/// Explicit geometry policy for non-turf artwork; null keeps native sprites.
	var/brandish_icon_mode

/turf/open/floor
	brandish_icon_mode = BRANDISH_MODE_ROTATE

/obj/effect/decal/cleanable
	brandish_icon_mode = BRANDISH_MODE_ROTATE

/obj/machinery
	/// Canonical sheet for connection states drawn with an explicit overlay direction.
	var/brandish_connection_icon
	var/image/brandish_connection_image

/// Whether attachment offsets should use the rotating world axes.
/atom/proc/has_rotated_brandish_surface()
	return brandish_icon_mode == BRANDISH_MODE_ROTATE || brandish_icon_mode == BRANDISH_MODE_GROUP_ROTATE || smoothing_flags

/obj/machinery/apply_brandish_icon()
	var/kind = brandish_icon_mode
	// Ducts retain their overlay while icon is null. Pipes also use native
	// artwork, so only their canonical connection sheet takes this path.
	if(brandish_connection_icon && (kind == BRANDISH_MODE_CONNECTED || (kind == BRANDISH_MODE_ROTATE && icon && GLOB.brandish_assets.source_for(icon) == brandish_connection_icon)))
		var/image/geometry = GLOB.brandish_assets.fixed_surface_overlay(brandish_connection_icon, icon_state)
		if(geometry)
			if(brandish_connection_image != geometry)
				cut_overlay(brandish_connection_image)
				brandish_connection_image = geometry
			if(!(geometry.appearance in overlays))
				add_overlay(geometry)
			icon = null
			return
		if(kind == BRANDISH_MODE_CONNECTED && !icon)
			icon = brandish_connection_icon
	if(brandish_connection_image)
		cut_overlay(brandish_connection_image)
		brandish_connection_image = null
	return ..()

/atom/proc/apply_brandish_icon()
	if(!icon)
		return
	var/kind = brandish_icon_mode
	if(kind == BRANDISH_MODE_GROUP_ROTATE)
		if(!brandish_image_projector)
			brandish_image_projector = new /datum/brandish_image_projector/group(src)
		return
	if(!kind && !(smoothing_flags & (SMOOTH_BITMASK | SMOOTH_CORNERS)))
		return
	if(!GLOB?.brandish_assets?.enabled)
		return
	if((smoothing_flags & SMOOTH_BITMASK) && base_icon_state)
		kind = BRANDISH_MODE_SMOOTH
	else if(smoothing_flags & SMOOTH_CORNERS)
		kind = BRANDISH_MODE_CORNER
	else if(!kind)
		return
	var/replacement = GLOB.brandish_assets.icon_for(icon, kind, dir, base_icon_state, icon_state)
	if(replacement && replacement != icon)
		if(kind == BRANDISH_MODE_CORNER)
			clear_smooth_overlays()
		icon = replacement
