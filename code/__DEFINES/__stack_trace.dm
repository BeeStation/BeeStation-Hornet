/// gives us the stack trace from CRASH() without ending the current proc.
#define stack_trace(msg) spawn(0) { CRASH(msg); }
