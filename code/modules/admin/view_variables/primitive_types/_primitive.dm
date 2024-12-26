/primitive
	parent_type = /datum
	var/pseudo_type = "/primitive"

/primitive/proc/locate_var_pointer(p_thing, varname)
	return

/primitive/proc/show_var(primitive/p_thing, varname)
	var/_ptr = locate_var_pointer(p_thing, varname)
	return *_ptr

/primitive/proc/set_var(primitive/p_thing, varname, val)
	var/_ptr = locate_var_pointer(p_thing, varname)
	*_ptr = val

/primitive/proc/debug_variable_primitive(primitive/thing, varname)
	return "<li style='backgroundColor:white'>(READ ONLY) [varname] = [_debug_variable_value(varname, show_var(&thing, varname), 0, thing, sanitize = TRUE, display_flags = NONE)]</li>"

/primitive/proc/show_pseudo_type()
	return pseudo_type

/primitive/proc/vv_get_header_primitive()
	return pseudo_type

/primitive/proc/vv_get_dropdown_primitive(primitive/thing)
	// need to have mark datum or something
	return
