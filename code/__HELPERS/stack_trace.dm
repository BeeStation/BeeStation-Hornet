GLOBAL_DATUM_INIT(runtime_helper, /datum/stack_trace_data_holder, new)

/// gives us the stack trace from CRASH() without ending the current proc.
/proc/_stack_trace(msg, _file, _line, _proc, _type)
	GLOB.runtime_helper.relay_data(msg, _file, _line, _proc, _type)
	CRASH(msg)

/datum/proc/_stack_trace(msg, _file, _line, _proc, _type)
	GLOB.runtime_helper.relay_data(msg, _file, _line, _proc, _type)
	CRASH(msg)

GLOBAL_REAL_VAR(list/stack_trace_storage)
/proc/gib_stack_trace()
	stack_trace_storage = list()
	stack_trace(null)
	stack_trace_storage.Cut(1, min(3,stack_trace_storage.len))
	. = stack_trace_storage
	stack_trace_storage = null

/datum/stack_trace_data_holder
	var/runtime_message = STACK_TRACE_NULL_HINT
	var/line
	var/file
	var/procname
	var/error_type

/datum/stack_trace_data_holder/proc/relay_data(_msg, _file, _line, _proc, _type)
	runtime_message = _msg
	file = _file
	line = _line
	procname = _proc
	error_type = _type

/datum/stack_trace_data_holder/proc/report()
	return " ## STACK TRACE INFO: [file],[line]. Proc: [procname] / Type: [error_type || "null"]"
