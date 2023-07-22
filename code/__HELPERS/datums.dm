///Check if a datum has not been deleted and is a valid source
/proc/is_valid_src(datum/source_datum)
	if(istype(source_datum))
		return !QDELETED(source_datum)
	return FALSE

/proc/call_async(datum/source, proctype, list/arguments)
	set waitfor = FALSE
	if(IS_ADMIN_ADVANCED_PROC_CALL)
		return
	return call(source, proctype)(arglist(arguments))

//Takes: Anything that could possibly have variables and a varname to check.
//Returns: 1 if found, 0 if not.
/proc/hasvar(datum/A, varname)
	if(A.vars.Find(lowertext(varname)))
		return 1
	else
		return 0
