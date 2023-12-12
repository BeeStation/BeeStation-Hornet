GLOBAL_LIST_EMPTY(stack_trace_hints)

/// gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(unique_hint, msg)
	/*
		< What is 'unique_hint' parameter? >
			All CRASH in stack_trace proc is considered to be the same.
			But also, "msg" can't be an unique value for runtimes.

			Example)
				> msg = "[mob] has a runtime!"
			This means the message is different per mob, but these will not be the same runtime.
			So, if we have this...
				> unique_hint = "somewhere_good_file.dm"
			stack_trace will be stacked together based on this unique_hint.

			You can set unique_hint by your preference
				> unique_hint = "asdf_throw_runtime"
				> unique_hint = "mob has runtime"
				> unique_hint = "some_hash_value_rk238gj23m4gks83"
	 */
	if(!msg)
		stack_trace("stack_trace_no_hint", "stack_trace didn't have unique_hint. Please set a unique hint at the first parameter.")
		msg = unique_hint
		unique_hint = "unidentified_unique_hint"
	GLOB.stack_trace_hints[msg] = unique_hint
	CRASH(msg)

/datum/proc/stack_trace(unique_hint, msg)
	if(!msg)
		stack_trace("stack_trace_no_hint", "stack_trace didn't have unique_hint. Please set a unique hint at the first parameter.")
		msg = unique_hint
		unique_hint = "unidentified_unique_hint"
	GLOB.stack_trace_hints[msg] = unique_hint
	CRASH(msg)

// I hate to have this proc, but SHOULD_BE_PURE setting is angry without this
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
