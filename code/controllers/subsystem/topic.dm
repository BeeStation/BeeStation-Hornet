SUBSYSTEM_DEF(topic)
	name = "Topic"
	init_order = INIT_ORDER_TOPIC
	flags = SS_NO_FIRE

/datum/controller/subsystem/topic/Initialize(timeofday)
	// Initialize topic datums
	var/list/anonymous_functions = list()
	for(var/path in subtypesof(/datum/world_topic))
		var/datum/world_topic/T = new path()
		if(T.anonymous)
			anonymous_functions[T.key] = TRUE
		GLOB.topic_commands[T.key] = T

	// Setup the anonymous access token
	GLOB.topic_tokens["anonymous"] = anonymous_functions
	// Parse and setup authed tokens from config
	var/list/tokens = CONFIG_GET(keyed_list/comms_key)
	for(var/token in tokens)
		var/list/keys = list()
		if(tokens[token] == "all")
			for(var/key in GLOB.topic_commands)
				keys[key] = TRUE
		else
			for(var/key in splittext(tokens[token], ","))
				keys[trim(key)] = TRUE
			// Grant access to anonymous topic calls (version, authed functions etc.) by default
			keys |= anonymous_functions
		GLOB.topic_tokens[token] = keys

	// Load the servers from config and query for the valid functions
	// A bit expensive but it only runs once at startup, and then we know all the available functions for each server.
	var/list/servers = CONFIG_GET(keyed_list/cross_server)
	for(var/server in servers)
		var/key = servers[server]
		var/request = list("query" = "api_get_authed_functions", "auth" = key)
		var/response = json_decode(world.Export("[server]?[json_encode(request)]"))
		if(response["statuscode"] != 200)
			continue
		GLOB.topic_servers[server] = response["data"]

	return ..()
