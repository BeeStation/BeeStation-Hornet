/primitive/callee
	pseudo_type = "/callee"
	var/caller
	var/category
	var/file
	var/line
	// snip

/primitive/callee/locate_var_pointer(primitive/callee/p_thing, varname)
	switch(varname)
		LOCATE_VAR_POINTER(caller)
		LOCATE_VAR_POINTER(category)
		LOCATE_VAR_POINTER(file)
		LOCATE_VAR_POINTER(line)

/primitive/callee/set_var(p_thing, varname, val) // read-only
	return
