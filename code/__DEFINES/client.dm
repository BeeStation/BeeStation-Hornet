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
