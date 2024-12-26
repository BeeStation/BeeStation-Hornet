/primitive/appearance
	pseudo_type = "/appearance"
	var/alpha
	var/appearance_flags
	var/color
	var/icon
	var/icon_state
	// snip. should sort out everything

/primitive/appearance/locate_var_pointer(primitive/appearance/p_thing, varname)
	switch(varname)
		LOCATE_VAR_POINTER(alpha)
		LOCATE_VAR_POINTER(appearance_flags)
		LOCATE_VAR_POINTER(color)
		LOCATE_VAR_POINTER(icon)
		LOCATE_VAR_POINTER(icon_state)

/primitive/appearance/set_var(p_thing, varname, val) // read-only
	return

/primitive/appearance/vv_get_dropdown_primitive(primitive/appearance/thing)
	return
