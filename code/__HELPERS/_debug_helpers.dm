// Contains procs that can help debuggging
#define FAILSAFE_THRESHOLD_RECURSIVE 6 //! a threashold that we think it's too recursive
#define FAILSAFE_THRESHOLD_ARG_LENGTH 25 //! a threshold that we think it's too many

/proc/identify_value(datum/thing, loop_manager = 0)
	if(isnull(thing))
		return "null"
	else if(islist(thing))
		if(loop_manager > FAILSAFE_THRESHOLD_RECURSIVE)
			return "/list\ref[thing].len:[length(thing)](Too deep - force return)"
		return "/list\ref[thing].len:[length(thing)]([identify_args(thing, loop_manager+1)])"
		// getting \ref of /list is intended : it's to recognise whether the lists are identical or not.
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

/proc/identify_args(list/arg_list, loop_manager = 0)
	var/arg_length = length(arg_list)
	if(!arg_length)
		return

	if(arg_length > FAILSAFE_THRESHOLD_ARG_LENGTH)
		return "Compressed / 1:[identify_value(arg_list[1])], 2:[identify_value(arg_list[2])], 3:[identify_value(arg_list[3])], ..., [arg_length]:[identify_value(arg_list[arg_length])]"

	var/list/results = list()
	for(var/idx in 1 to arg_length)
		results += identify_value(arg_list[idx], loop_manager+1)

	return jointext(results, ", ")

#undef FAILSAFE_THRESHOLD_RECURSIVE
#undef FAILSAFE_THRESHOLD_ARG_LENGTH
