/area
	luminosity           = TRUE
	var/mutable_appearance/lighting_effect = null
	var/area_has_base_lighting = FALSE
	var/base_lighting_alpha = 0
	var/base_lighting 	 = null	//The colour of the light acting on this area

/area/proc/set_base_lighting(var/new_base_lighting = -1, var/new_alpha = -1)
	if(base_lighting_alpha == new_alpha && base_lighting == new_base_lighting)
		return FALSE
	if(new_alpha != -1)
		base_lighting_alpha = new_alpha
	if(new_base_lighting != -1)
		base_lighting = new_base_lighting
	update_base_lighting()
	return TRUE

/area/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("base_lighting")
			set_base_lighting(new_base_lighting = var_value)
			return TRUE
		if("base_lighting_alpha")
			set_base_lighting(new_alpha = var_value)
			return TRUE
	return ..()

/area/proc/update_base_lighting()
	if(!area_has_base_lighting && (!base_lighting_alpha || !base_lighting))
		return

	if(area_has_base_lighting)
		remove_base_lighting()
		if(base_lighting_alpha && base_lighting)
			add_base_lighting()
	else
		add_base_lighting()

/area/proc/remove_base_lighting()
	for(var/turf/T in src)
		T.cut_overlay(lighting_effect)
	QDEL_NULL(lighting_effect)
	area_has_base_lighting = FALSE

/area/proc/add_base_lighting()
	lighting_effect = mutable_appearance('icons/effects/alphacolors.dmi', "white")
	lighting_effect.plane = LIGHTING_PLANE
	lighting_effect.layer = LIGHTING_PRIMARY_LAYER
	lighting_effect.blend_mode = BLEND_ADD
	lighting_effect.alpha = base_lighting_alpha
	lighting_effect.color = base_lighting
	for(var/turf/T in src)
		T.add_overlay(lighting_effect)
		T.luminosity = TRUE
	area_has_base_lighting = TRUE
