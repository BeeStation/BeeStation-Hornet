/primitive/vector
	pseudo_type = "/vector"
	var/x
	var/y
	var/z

/primitive/vector/locate_var_pointer(primitive/vector/p_thing, varname)
	switch(varname)
		LOCATE_VAR_POINTER(x)
		LOCATE_VAR_POINTER(y)
		LOCATE_VAR_POINTER(z)
