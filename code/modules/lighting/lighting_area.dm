/area
	luminosity           = TRUE
	var/base_lighting 	 = FALSE	//The colour of the light acting on this area

/area/proc/set_base_lighting(var/new_base_lighting = FALSE)
	if (new_base_lighting == base_lighting)
		return FALSE

	base_lighting = new_base_lighting

	return TRUE

/area/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("base_lighting")
			set_base_lighting(var_value)
			return TRUE
	return ..()
