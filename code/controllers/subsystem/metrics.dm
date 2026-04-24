/*

	Ok listen up

	This thing ingests data to ElasticSearch in a VERY SPECIFIC FORMAT
	Not only is changing this a very bad idea due to elasticsearch being very finnicky with data formatting,
	but if you edit this subsystem and its fields, you invalidate a lot of existing data

	Dont touch this shit without speaking to crossed or AA07 first

*/
SUBSYSTEM_DEF(metrics)
	name = "Metrics"
	wait = 30 SECONDS
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME // ALL THE LEVELS
	flags = SS_KEEP_TIMING // This needs to ingest every 30 IRL seconds, not ingame seconds.
	/// The real time of day the server started. Used to calculate time drift
	var/world_init_time = 0 // Not set in here. Set in world/New()

/datum/controller/subsystem/metrics/Initialize()
	if(!CONFIG_GET(flag/elasticsearch_metrics_enabled))
		flags |= SS_NO_FIRE // Disable firing to save CPU
	return SS_INIT_SUCCESS


/datum/controller/subsystem/metrics/fire(resumed)
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, CONFIG_GET(string/elasticsearch_metrics_endpoint), get_metrics_json(), list(
		"Authorization" = "ApiKey [CONFIG_GET(string/elasticsearch_metrics_apikey)]",
		"Content-Type" = "application/json"
	))
	request.begin_async() // Fire and forget who gives a shit

/datum/controller/subsystem/metrics/proc/get_metrics_json()
	var/list/out = list()
	out["@timestamp"] = iso_timestamp() // This is required by ElasticSearch, complete with this name. DO NOT REMOVE THIS.
	out["cpu"] = world.cpu
	out["maptick"] = world.map_cpu
	out["elapsed_processed"] = world.time
	out["elapsed_real"] = (REALTIMEOFDAY - world_init_time)
	out["client_count"] = length(GLOB.clients_unsafe)
	out["time_dilation_current"] = SStime_track.time_dilation_current
	out["time_dilation_1m"] = SStime_track.time_dilation_avg
	out["time_dilation_5m"] = SStime_track.time_dilation_avg_slow
	out["time_dilation_15m"] = SStime_track.time_dilation_avg_fast
	out["harddel_count"] = length(GLOB.world_qdel_log)
	out["round_id"] = text2num(GLOB.round_id) // This is so we can filter the metrics by a single round ID

	if (Master.diagnostic_mode)
		var/list/diagnostic_report = list()
		for (var/datum/mc_tick/diag_tick in Master.queued_ticks)
			var/list/current_tick_info = list()
			for (var/datum/controller/subsystem/ss in diag_tick.fired_subsystems)
				current_tick_info["[ss.ss_id]"] = diag_tick.fired_subsystems[ss]
			diagnostic_report["[diag_tick.tick_number]"] = current_tick_info
		out["master_controller"] = list(
			"diagnostic_mode" = 1,
			"diagnostic_report" = diagnostic_report
		)
		Master.queued_ticks.Cut()
	else
		out["master_controller"] = list(
			"diagnostic_mode" = 0,
		)

	var/server_name = CONFIG_GET(string/serversqlname)
	if(server_name)
		out["server_name"] = server_name

	// Funnel in all SS metrics
	var/list/ss_data = list()
	for(var/datum/controller/subsystem/SS in Master.subsystems)
		ss_data[SS.ss_id] = SS.get_metrics()

	out["subsystems"] = ss_data

	// And send it all
	return json_encode(out)

/*

// Uncomment this if you add new metrics to verify how the JSON formats

AUTH_CLIENT_VERB(debug_metrics)
	usr << browse(SSmetrics.get_metrics_json(), "window=aadebug")
*/
