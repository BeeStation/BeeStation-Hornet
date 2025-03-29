// using datum is best, but "SHOULD_BE_PURE" lint doesn't like that way. list works well.
GLOBAL_LIST_INIT(runtime_helper, list(
	"runtime_message" = STACK_TRACE_NULL_HINT,
	"file" = null,
	"line" = null,
	"procname" = null,
	"error_type = null"
))

#define BUILD_STACK_TRACE_HELPER(msg, _file, _line, _proc, _type) \
GLOB.runtime_helper["runtime_message"] = msg;\
GLOB.runtime_helper["file"] = _file;\
GLOB.runtime_helper["line"] = _line;\
GLOB.runtime_helper["procname"] = _proc;\
GLOB.runtime_helper["error_type"] = _type;

/// gives us the stack trace from CRASH() without ending the current proc.
/proc/_stack_trace(msg, _file, _line, _proc, _type)
	BUILD_STACK_TRACE_HELPER(msg, _file, _line, _proc, _type)
	CRASH(msg)

/datum/proc/_stack_trace(msg, _file, _line, _proc, _type)
	BUILD_STACK_TRACE_HELPER(msg, _file, _line, _proc, _type)
	CRASH(msg)

GLOBAL_REAL_VAR(list/stack_trace_storage)
/proc/gib_stack_trace()
	stack_trace_storage = list()
	stack_trace(null)
	stack_trace_storage.Cut(1, min(3,stack_trace_storage.len))
	. = stack_trace_storage
	stack_trace_storage = null
