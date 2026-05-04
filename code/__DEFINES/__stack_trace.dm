/// gives us the stack trace from CRASH() without ending the current proc.
/// This is a proc. This actually calls /proc/_stack_trace()
#define stack_trace(msg) _stack_trace(msg, __FILE__, __LINE__, __PROC__, __TYPE__)

// This should exist because null value should be checked too.
#define STACK_TRACE_NULL_HINT 1632864 /// This is actually null
