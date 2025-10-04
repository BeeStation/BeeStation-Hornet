SUBSYSTEM_DEF(topic)
	name = "Topic"
	init_stage = INITSTAGE_EARLY
	flags = SS_NO_FIRE

/datum/controller/subsystem/topic/Initialize()
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

	return SS_INIT_SUCCESS

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
	var/logging = CONFIG_GET(flag/log_world_topic)
	var/request = list("query" = "api_do_handshake", "auth" = key, "source" = CONFIG_GET(string/cross_comms_name))
	var/response_raw = world.Export("[addr]?[json_encode(request)]")
	request["auth"] = "***[copytext(request["auth"], -4)]"
	if(!response_raw)
		if(logging)
			log_topic("Topic handshake with [addr] failed. Server did not return a response. Payload: \"[json_encode(request)]\"")
		return
	var/response = json_decode(response_raw)
	if(response["statuscode"] != 200)
		if(logging)
			log_topic("Topic handshake with [addr] failed. Payload: \"[json_encode(request)]\", Response: \"[response_raw]\"")
		return
	var/list/local_funcs = GLOB.topic_tokens[LAZYACCESS(response["data"], "token")]
	var/list/remote_funcs = LAZYACCESS(response["data"], "functions")
	if(!local_funcs || !remote_funcs)
		if(logging)
			log_topic("Topic handshake with [addr] completed, but no mutual functions were found. Payload: \"[json_encode(request)]\", Response: \"[response_raw]\"")
		return
	var/list/functions = list()
	// Both servers need to have a function available to each other for it to be valid
	for(var/func in remote_funcs)
		if(local_funcs[func])
			functions[func] = TRUE
	GLOB.topic_servers[addr] = functions
	if(logging)
		log_topic("Handshake with [addr] successful.")

/**
 * Wrapper proc for world.Export() that adds additional params and handles auth.
 *
 * Params:
 *
 * * addr: address of the receiving BYOND server (*including* the byond://)
 * * query: name of the topic endpoint to request
 * * params: associated list of parameters to send to the receiving server
 * * anonymous: TRUE or FALSE whether to use anonymous token for the request *(default: FALSE)*
 * Note that request will fail if a token cannot be found for the target server and anonymous is not set.
 * * nocheck: TRUE or FALSE whether to check if the receiving server is authorized to get the topic call *(default: FALSE)*
*/
/datum/controller/subsystem/topic/proc/export_async(addr, query, list/params, anonymous = FALSE, nocheck = FALSE)
	DECLARE_ASYNC
	var/list/request = list()
	request["query"] = query

	if(anonymous)
		var/datum/world_topic/topic = GLOB.topic_commands[query]
		if((!istype(topic) || !topic.anonymous) && !nocheck)
			ASYNC_RETURN(TRUE)
		request["auth"] = "anonymous"
	else
		var/list/servers = CONFIG_GET(keyed_list/cross_server)
		if(!servers[addr] || (!LAZYACCESS(GLOB.topic_servers[addr], query) && !nocheck))
			ASYNC_RETURN(TRUE) // Couldn't find an authorized key, or trying to send secure data to unsecure server
		request["auth"] = servers[addr]

	request.Add(params)
	request["source"] = CONFIG_GET(string/cross_comms_name)
	var/result = world.Export("[addr]?[rustg_url_encode(json_encode(request))]")
	if(CONFIG_GET(flag/log_world_topic))
		request["auth"] = "***[copytext(request["auth"], -4)]"
		log_topic("outgoing: \"[json_encode(request)]\", response: \"[result]\", auth: [request["auth"]], to: [addr], anonymous: [anonymous]")
	ASYNC_RETURN(TRUE)

/**
 * Broadcast topic to all known authorized servers for things like comms consoles or ahelps.
 * Follows a set topic format for ease of use, and is therefore incompatible with other topic endpoints.
 *
 * Params:
 *
 * * query: name of the topic endpoint for the requests
 * * msg: message text to send
 * * sender: name of the sending entity (station name, ckey etc)
*/
/datum/controller/subsystem/topic/proc/crosscomms_send_async(query, msg, sender)
	RETURN_TYPE(/datum/task)
	var/list/servers = CONFIG_GET(keyed_list/cross_server)
	var/datum/task/parent_task = new()
	for(var/I in servers)
		parent_task.add_subtask(export_async(I, query, list("message" = msg, "message_sender" = sender)))
	return parent_task
