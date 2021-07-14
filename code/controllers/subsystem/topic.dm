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

	var/list/servers = CONFIG_GET(keyed_list/cross_server)
	for(var/server in servers)
		handshake_server(server, servers[server])

	return ..()

/*
	A bit of background for future coders maintaining this:
	When we contact a server or we contact a server to handshake, there are two outcomes to account for:

	First, if the server being contacted has freshly rebooted, they will have no knowledge of us,
	and as such will need to store our server details too by sending a handshake request back to us for information.

	Second, if we rebooted while the other server was mid-round, they simply can send back the current details they have about us,
	and don't need to get any additional information of their own.

	Code for handling requests is in world_topic.dm

	Basically, this proc exists to allow servers to make ad-hoc connections, going offline and coming back up without interrupting anything.
*/
/datum/controller/subsystem/topic/proc/handshake_server(addr, key)
	set waitfor = FALSE
	var/request = list("query" = "api_do_handshake", "auth" = key)
	var/response = world.Export("[addr]?[json_encode(request)]")
	if(!response)
		return
	response = json_decode(response)
	if(response["statuscode"] != 200)
		return
	var/list/local_funcs = GLOB.topic_tokens[LAZYACCESS(response["data"], "token")]
	var/list/remote_funcs = LAZYACCESS(response["data"], "functions")
	var/list/functions = list()
	// Both servers need to have a function available to each other for it to be valid
	for(var/func in remote_funcs)
		if(local_funcs[func])
			functions[func] = TRUE
	GLOB.topic_servers[addr] = functions
