/// gives us the stack trace from CRASH() without ending the current proc.
/// This is a proc. This actually calls /proc/_stack_trace()
#define stack_trace(msg) _stack_trace(msg, __FILE__, __LINE__, "(__PROC__ is bugged in 515. Should be fixed in 516.)", __TYPE__)
// __PROC__ throws an error. It is fixed in 516.

// This should exist because null value should be checked too.
#define STACK_TRACE_NULL_HINT 1632864 /// This is actually null
