/// returns which type a variable has as a form of text. Used to debug.
/proc/type_check(datum/V)
	if(isnull(V))
		return "null::null"
	else if(isnum(V))
		return "[V]::num"
	else if(istext(V))
		return "[V]::text"
	else if(islist(V))
		return "(list)"
	else if(ispath(V))
		return "[V]::typepath"
	else if(istype(V))
		return "[V]::[V.type]"
	else
		return "[V]::Unknown"
