/primitive/pixloc
	pseudo_type = "/pixloc"
	var/x
	var/y
	var/z

/primitive/pixloc/locate_var_pointer(primitive/pixloc/p_thing, varname)
	switch(varname)
		LOCATE_VAR_POINTER(x)
		LOCATE_VAR_POINTER(y)
		LOCATE_VAR_POINTER(z)
