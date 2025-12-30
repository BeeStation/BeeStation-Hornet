#define AUTH_CLIENT_VERB(verb_name, args...)\
/client/collect_client_verbs(){\
	. = ..();\
	. += /client/proc/##verb_name;\
};\
/client/proc/##verb_name(args)\

/// This gathers all the client *procs* that we are pretending are verbs - but only particularly want
/// authorized users to be able to use
/client/proc/collect_client_verbs() as /list
	return list()

/// If BYOND's HTTP API currently responding?
/// Set to false on the first request failure
#ifndef DISABLE_BYOND_AUTH
GLOBAL_VAR_INIT(byond_http, TRUE)
#else
GLOBAL_VAR_INIT(byond_http, FALSE)
#endif

GLOBAL_LIST_EMPTY(disconnected_mobs)
GLOBAL_PROTECT(disconnected_mobs)
