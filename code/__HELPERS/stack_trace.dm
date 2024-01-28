GLOBAL_LIST_EMPTY(stack_trace_hints)

/// gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(unique_hint, msg)
	if(!msg)
		STACK_TRACE_ADV("stack_trace didn't have unique_hint. Please set a unique hint at the first parameter.")
		msg = unique_hint
		unique_hint = "unidentified_unique_hint"
	GLOB.stack_trace_hints[msg] = unique_hint
	CRASH(msg)

/datum/proc/stack_trace(unique_hint, msg)
	if(!msg)
		STACK_TRACE_ADV("stack_trace didn't have unique_hint. Please set a unique hint at the first parameter.")
		msg = unique_hint
		unique_hint = "unidentified_unique_hint"
	GLOB.stack_trace_hints[msg] = unique_hint
	CRASH(msg)

// SHOULD_BE_PURE is angry to /datum/proc/stack_trace() because it attempts to change value.
// So, that's why this proc exists.
/datum/proc/stack_trace_pure(unique_hint, msg)
	GLOB.stack_trace_hints[msg] = unique_hint
	CRASH(msg)

GLOBAL_REAL_VAR(list/stack_trace_storage)
/proc/gib_stack_trace()
	stack_trace_storage = list()
	stack_trace()
	stack_trace_storage.Cut(1, min(3,stack_trace_storage.len))
	. = stack_trace_storage
	stack_trace_storage = null
