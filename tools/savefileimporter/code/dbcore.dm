#define UNTIL(X) while(!(X)) sleep(world.tick_lag)
#define INVOKE_ASYNC ImmediateInvokeAsync
#define GLOBAL_PROC	"some_magic_bullshit"

/proc/ImmediateInvokeAsync(thingtocall, proctocall, ...)
	set waitfor = FALSE

	if(!thingtocall)
		return

	var/list/calling_arguments = length(args) > 2 ? args.Copy(3) : null

	if(thingtocall == GLOBAL_PROC)
		call(proctocall)(arglist(calling_arguments))
	else
		call(thingtocall, proctocall)(arglist(calling_arguments))



/proc/NewDBQuery(sql_query, arguments)
	return new /datum/DBQuery(GLOB.dbconnection, sql_query, arguments)

/proc/establish_db_connection()
	var/result = json_decode(rustg_sql_connect_pool(json_encode(list(
		"host" = GLOB.config["db_host"],
		"port" = GLOB.config["db_port"],
		"user" = GLOB.config["db_un"],
		"pass" = GLOB.config["db_pw"],
		"db_name" = GLOB.config["db_db"],
		"read_timeout" = 60,
		"write_timeout" = 60,
		"max_threads" = 50,
	))))
	. = (result["status"] == "ok")
	if (.)
		GLOB.dbconnection = result["handle"]
		log_info("Connected to DB")
	else
		GLOB.dbconnection = null
		log_info("establish_db_connection() failed | [result["data"]]")

/datum/DBQuery
	// Inputs
	var/connection
	var/sql
	var/arguments

	// Status information
	var/in_progress
	var/last_error
	var/last_activity
	var/last_activity_time

	// Output
	var/list/list/rows
	var/next_row_to_take = 1
	var/affected
	var/last_insert_id

	var/list/item  //list of data values populated by NextRow()

/datum/DBQuery/New(connection, sql, arguments)
	Activity("Created")
	item = list()

	src.connection = connection
	src.sql = sql
	src.arguments = arguments

/datum/DBQuery/proc/Activity(activity)
	last_activity = activity
	last_activity_time = world.time

/datum/DBQuery/proc/Execute()
	Activity("Execute")
	if(in_progress)
		CRASH("Attempted to start a new query while waiting on the old one")

	var/start_time
	start_time = world.timeofday
	Close()
	. = run_query()
	var/timed_out = !. && findtext(last_error, "Operation timed out")
	if(!.)
		log_info("[last_error] | Query used: [sql] | Arguments: [list2params(arguments)]")
	if(timed_out)
		log_info("Query execution started at [start_time]")
		log_info("Query execution ended at [world.timeofday]")
		log_info("Slow query timeout detected.")
		log_info("Query used: [sql]")
		log_info("Arguments: [list2params(arguments)]")

/datum/DBQuery/proc/run_query()
	var/job_result_str = rustg_sql_query_blocking(connection, sql, json_encode(arguments))

	var/result = json_decode(job_result_str)
	switch (result["status"])
		if ("ok")
			rows = result["rows"]
			affected = result["affected"]
			last_insert_id = result["last_insert_id"]
			return TRUE
		if ("err")
			last_error = result["data"]
			return FALSE
		if ("offline")
			last_error = "offline"
			return FALSE

/datum/DBQuery/proc/NextRow(async = TRUE)
	Activity("NextRow")

	if (rows && next_row_to_take <= rows.len)
		item = rows[next_row_to_take]
		next_row_to_take++
		return !!item
	else
		return FALSE

/datum/DBQuery/proc/ErrorMsg()
	return last_error

/datum/DBQuery/proc/Close()
	rows = null
	item = null
