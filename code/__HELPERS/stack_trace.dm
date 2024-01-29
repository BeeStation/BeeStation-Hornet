GLOBAL_LIST_EMPTY(stack_trace_hints)

/// gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(list/hint_dump, msg)
	if(!hint_dump)
		STACK_TRACE_ADV("you're using stack_trace as old version. Use \"STACK_TRACE_ADV()\" macro instead")
		msg = hint_dump
		hint_dump = null
		var/static/list/failsafe_hint_dump = list("tracehint" = "unidentified_unique_hint", "prochint" = null)
	GLOB.stack_trace_hints[msg] = hint_dump || failsafe_hint_dump
	CRASH(msg)

/datum/proc/stack_trace(list/hint_dump, msg)
	if(!hint_dump)
		STACK_TRACE_ADV("you're using stack_trace as old version. Use \"STACK_TRACE_ADV()\" macro instead")
		msg = hint_dump
		hint_dump = null
		var/static/list/extra_hint_dump = list("tracehint" = "unidentified_unique_hint", "prochint" = null)
	GLOB.stack_trace_hints[msg] = hint_dump || failsafe_hint_dump
	CRASH(msg)

// SHOULD_BE_PURE is angry to /datum/proc/stack_trace() because it attempts to change value.
// So, that's why this proc exists.
/datum/proc/stack_trace_pure(list/hint_dump, msg)
	GLOB.stack_trace_hints[msg] = hint_dump
	CRASH(msg)

GLOBAL_REAL_VAR(list/stack_trace_storage)
/proc/gib_stack_trace()
	stack_trace_storage = list()
	stack_trace()
	stack_trace_storage.Cut(1, min(3,stack_trace_storage.len))
	. = stack_trace_storage
	stack_trace_storage = null
