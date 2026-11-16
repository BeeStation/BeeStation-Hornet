/// Atom appearance policies and shared-resource binding.
/atom
	/// Explicit geometry policy for non-turf artwork; null keeps native sprites.
	var/brandish_icon_mode

/turf/open/floor
	brandish_icon_mode = BRANDISH_MODE_SURFACE

/obj/effect/decal/cleanable
	brandish_icon_mode = BRANDISH_MODE_SURFACE

/atom/proc/apply_brandish_icon()
	if(!icon)
		return
	if(brandish_icon_mode == BRANDISH_MODE_WORLD)
		if(!world_space_icon)
			world_space_icon = new /datum/world_space_icon/geometry(src)
		world_space_icon.refresh()
		return
	var/kind = brandish_icon_mode
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
