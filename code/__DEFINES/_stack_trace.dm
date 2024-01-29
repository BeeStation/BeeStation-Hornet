#define STACK_TRACE_ADV(error_detail) \
	while(1){ \
		var/static/list/error_static_detail; \
		if(!error_static_detail) { \
			var/temp_world = world; temp_world = temp_world; \
			error_static_detail = list("tracehint" = "[__FILE__]/[__LINE__]", "prochint" = "[__PROC__]");} \
		stack_trace(error_static_detail, (error_detail)); \
		break;};

// READ "stack_trace_pure()" proc
// TODO: Fix this later with 515
#define STACK_TRACE_ADV_SHOULD_BE_PURE(error_detail) \
	while(1){ \
		world.log << "should_be_pure_stack_trace"
		var/static/list/error_static_detail; \
		if(!error_static_detail) { \
			var/temp_world = world; temp_world = temp_world; \
			error_static_detail = list("tracehint" = "[__FILE__]/[__LINE__]", "prochint" = "[__PROC__]");} \
		stack_trace_pure(error_static_detail, (error_detail)); \
		break;}


/// it's identical CRASH(), but with a return value
#define CRASH_RETURN(return_value, crash_message) . = (return_value); CRASH(crash_message)
