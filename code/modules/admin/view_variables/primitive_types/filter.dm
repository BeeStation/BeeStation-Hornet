/dm_filter
	parent_type = /primitive // some trick. DM already has this, and we take variables of /dm_filter
// Inheritance logic: /datum/primitive/dm_filter/filter

/primitive/filter
	pseudo_type = "/filter"
	parent_type = /dm_filter
	// /dm_filter has everything we need already

/primitive/filter/locate_var_pointer(primitive/filter/p_thing, varname)
	// but still, /filter doesn't have "vars", so we need to do this manually
	switch(varname)
		LOCATE_VAR_POINTER(icon)
		LOCATE_VAR_POINTER(x)
		LOCATE_VAR_POINTER(y)
		LOCATE_VAR_POINTER(repeat)
		LOCATE_VAR_POINTER(falloff)
		LOCATE_VAR_POINTER(alpha)
		LOCATE_VAR_POINTER(color)
		LOCATE_VAR_POINTER(flags)
		LOCATE_VAR_POINTER(size)
		LOCATE_VAR_POINTER(offset)
		LOCATE_VAR_POINTER(render_source)
		LOCATE_VAR_POINTER(space)
		LOCATE_VAR_POINTER(radius)
		LOCATE_VAR_POINTER(tag)
		LOCATE_VAR_POINTER(type) // this tells filter type(i.e. "blur"), not /typepath.
