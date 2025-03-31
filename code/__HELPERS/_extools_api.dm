//#define EXTOOLS_LOGGING // rust_g is used as a fallback if this is undefined

/proc/extools_log_write()

/proc/extools_finalize_logging()

GLOBAL_LIST_EMPTY(auxtools_initialized)

#define AUXTOOLS_CHECK(LIB)\
	if (!GLOB.auxtools_initialized[LIB] && fexists(LIB)) {\
		var/string = LIBCALL(LIB,"auxtools_init")();\
		if(findtext(string, "SUCCESS")) {\
			GLOB.auxtools_initialized[LIB] = TRUE;\
		} else {\
			CRASH(string);\
		}\
	}\

#define AUXTOOLS_SHUTDOWN(LIB)\
	if (GLOB.auxtools_initialized[LIB] && fexists(LIB)){\
		LIBCALL(LIB,"auxtools_shutdown")();\
		GLOB.auxtools_initialized[LIB] = FALSE;\
	}\
