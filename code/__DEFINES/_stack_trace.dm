#define STACK_TRACE_ADV(error_detail) \
	while(1){ \
		var/static/error_static_detail; \
		if(!error_static_detail){ try {	throw EXCEPTION("TEMP:NOTHING")} catch(var/exception/TEMP_E) { error_static_detail = "[TEMP_E.file]/[TEMP_E.line]"} } \
		stack_trace(error_static_detail, (error_detail)); \
		break;}

// READ "stack_trace_pure()" proc
#define STACK_TRACE_ADV_SHOULD_BE_PURE(error_detail) \
	while(1){ \
		var/static/error_static_detail; \
		if(!error_static_detail){ try {	throw EXCEPTION("TEMP:NOTHING")} catch(var/exception/TEMP_E) { error_static_detail = "[TEMP_E.file]/[TEMP_E.line]"} } \
		stack_trace_pure(error_static_detail, (error_detail)); \
		break;}


/// it's identical CRASH(), but with a return value
#define CRASH_RETURN(return_value, crash_message) . = (return_value); CRASH(crash_message)
