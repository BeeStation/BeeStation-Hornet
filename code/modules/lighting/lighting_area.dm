/area
	luminosity = 1
	/// Lighting overlay
	var/image/lighting_overlay
	/// Cached zmimic lighting vars
	var/lighting_overlay_matrix_cr = 0
	var/lighting_overlay_matrix_cg = 0
	var/lighting_overlay_matrix_cb = 0
	var/list/lighting_overlay_cached_darkening_matrix
	/// Whether this area has a currently active base lighting, bool
	var/area_has_base_lighting = FALSE
	/// alpha 0-255 of lighting_effect and thus baselighting intensity
	var/base_lighting_alpha = 0
	/// The colour of the light acting on this area.
	var/base_lighting_color = COLOR_WHITE
	/// If GLOB.starlight_overlay should be applied to this area
	var/has_starlight_overlay = FALSE

/area/proc/set_base_lighting(new_base_lighting_color = -1, new_alpha = -1)
	if(base_lighting_alpha == new_alpha && base_lighting_color == new_base_lighting_color)
		return FALSE
	if(new_alpha != -1)
		base_lighting_alpha = new_alpha
	if(new_base_lighting_color != -1)
		base_lighting_color = new_base_lighting_color
	update_base_lighting()
	return TRUE

/area/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, base_lighting_color))
			set_base_lighting(new_base_lighting_color = var_value)
			return TRUE
		if(NAMEOF(src, base_lighting_alpha))
			set_base_lighting(new_alpha = var_value)
			return TRUE
		if(NAMEOF(src, static_lighting))
			if(var_value && !static_lighting)
				create_area_lighting_objects()
			else
				remove_area_lighting_objects()
		if(NAMEOF(src, has_starlight_overlay))
			if(var_value && !has_starlight_overlay)
				add_overlay(GLOB.starlight_overlay)
			else
				cut_overlay(GLOB.starlight_overlay)
	return ..()

/area/proc/update_base_lighting()
	if(!area_has_base_lighting && (!base_lighting_alpha || !base_lighting_color))
		return

	if(!area_has_base_lighting)
		add_base_lighting()
		return
	remove_base_lighting()
	if(base_lighting_alpha && base_lighting_color)
		add_base_lighting()

/area/proc/remove_base_lighting()
	cut_overlay(lighting_overlay)
	QDEL_NULL(lighting_overlay)
	area_has_base_lighting = FALSE

/area/proc/add_base_lighting()
	lighting_overlay = create_fullbright_overlay()
	lighting_overlay.color = base_lighting_color
	lighting_overlay.alpha = base_lighting_alpha

	add_overlay(lighting_overlay)
	area_has_base_lighting = TRUE

	if(length_char(base_lighting_color) != 7)
		return

	var/list/rgb = rgb2num(base_lighting_color)
	lighting_overlay_matrix_cr = (rgb[1] / 255) * (base_lighting_alpha / 255)
	lighting_overlay_matrix_cg = (rgb[2] / 255) * (base_lighting_alpha / 255)
	lighting_overlay_matrix_cb = (rgb[3] / 255) * (base_lighting_alpha / 255)
	lighting_overlay_cached_darkening_matrix = null // Clear cached list
