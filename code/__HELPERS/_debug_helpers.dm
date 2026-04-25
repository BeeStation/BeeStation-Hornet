// Contains procs that can help debuggging

/proc/identify_value(datum/thing)
	if(isnull(thing))
		return "null"
	else if(islist(thing))
		return "/list\[LEN:[length(thing)]\]([identify_args(thing)])"
	else if(istext(thing))
		return "\"[thing]\""
	else if(isnum(thing))
		return thing
	else if(ispath(thing))
		return "[thing]\[TYPEPATH\]"
	else if(isdatum(thing))
		return "[thing]\[[thing.type]\]"
	return "/UNKNOWN\[[thing]\]"

/proc/identify_src(atom/thing)
	var/src_name = "[thing]"
	if(!length(src_name))
		src_name = "(null name)"
	if(isatom(thing))
		var/x = thing.x
		var/y = thing.y
		var/z = thing.z
		return "[src_name]\[[thing.type]\](Located in: [thing.loc]\[x[x],y[y],z[z]\])"
	if(isdatum(thing))
		return "[src_name]\[[thing.type]\]"
	return src_name

/proc/identify_args(list/arg_list)
	var/arg_length = length(arg_list)
	if(!arg_length)
		return

	var/list/results = list()
	for(var/idx in 1 to arg_length)
		results += identify_value(arg_list[idx])

	return jointext(results, ", ")
