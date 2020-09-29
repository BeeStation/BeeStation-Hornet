SUBSYSTEM_DEF(dbcore)
	name = "Database"
	flags = SS_BACKGROUND
	wait = 1 MINUTES
	init_order = INIT_ORDER_DBCORE

	var/schema_mismatch = 0
	var/db_minor = 0
	var/db_major = 0
	var/failed_connections = 0

	var/last_error
	var/list/active_queries = list()

	var/connection  // Arbitrary handle returned from rust_g.

/datum/controller/subsystem/dbcore/Initialize()
	//We send warnings to the admins during subsystem init, as the clients will be New'd and messages
	//will queue properly with goonchat
	switch(schema_mismatch)
		if(1)
			message_admins("Database schema ([db_major].[db_minor]) doesn't match the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
		if(2)
			message_admins("Could not get schema version from database")

	return ..()

/datum/controller/subsystem/dbcore/fire()
	for(var/I in active_queries)
		var/datum/DBQuery/Q = I
		if(world.time - Q.last_activity_time > (5 MINUTES))
			log_sql("Undeleted query: \"[Q.sql]\" ARGS: \"[list2params(Q.arguments)]\" LA: [Q.last_activity] LAT: [Q.last_activity_time]")
			qdel(Q)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/dbcore/Recover()
	connection = SSdbcore.connection

/datum/controller/subsystem/dbcore/Shutdown()
	//This is as close as we can get to the true round end before Disconnect() without changing where it's called, defeating the reason this is a subsystem
	if(SSdbcore.Connect())
		var/datum/DBQuery/query_round_shutdown = SSdbcore.NewQuery(
			"UPDATE [format_table_name("round")] SET shutdown_datetime = Now(), end_state = :end_state WHERE id = :round_id",
			list("end_state" = SSticker.end_state, "round_id" = GLOB.round_id)
		)
		query_round_shutdown.Execute()
		qdel(query_round_shutdown)
	if(IsConnected())
		Disconnect()

//nu
/datum/controller/subsystem/dbcore/can_vv_get(var_name)
	return var_name != NAMEOF(src, connection) && var_name != NAMEOF(src, active_queries) && ..()

/datum/controller/subsystem/dbcore/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, connection))
		return FALSE
	return ..()

/datum/controller/subsystem/dbcore/proc/Connect()
	if(IsConnected())
		return TRUE

	if(failed_connections > 5)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect anymore.
		return FALSE

	if(!CONFIG_GET(flag/sql_enabled))
		return FALSE

	var/user = CONFIG_GET(string/feedback_login)
	var/pass = CONFIG_GET(string/feedback_password)
	var/db = CONFIG_GET(string/feedback_database)
	var/address = CONFIG_GET(string/address)
	var/port = CONFIG_GET(number/port)
	var/timeout = max(CONFIG_GET(number/async_query_timeout), CONFIG_GET(number/blocking_query_timeout))
	var/thread_limit = CONFIG_GET(number/bsql_thread_limit)

	var/result = json_decode(rustg_sql_connect_pool(json_encode(list(
		"host" = address,
		"port" = port,
		"user" = user,
		"pass" = pass,
		"db_name" = db,
		"max_threads" = 5,
		"read_timeout" = timeout,
		"write_timeout" = timeout,
		"max_threads" = thread_limit,
	))))
	. = (result["status"] == "ok")
	if (.)
		connection = result["handle"]
	else
		connection = null
		last_error = result["data"]
		log_sql("Connect() failed | [last_error]")
		++failed_connections

/datum/controller/subsystem/dbcore/proc/CheckSchemaVersion()
	if(CONFIG_GET(flag/sql_enabled))
		if(Connect())
			log_world("Database connection established.")
			var/datum/DBQuery/query_db_version = NewQuery("SELECT major, minor FROM [format_table_name("schema_revision")] ORDER BY date DESC LIMIT 1")
			query_db_version.Execute()
			if(query_db_version.NextRow())
				db_major = text2num(query_db_version.item[1])
				db_minor = text2num(query_db_version.item[2])
				if(db_major != DB_MAJOR_VERSION || db_minor != DB_MINOR_VERSION)
					schema_mismatch = 1 // flag admin message about mismatch
					log_sql("Database schema ([db_major].[db_minor]) doesn't match the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
			else
				schema_mismatch = 2 //flag admin message about no schema version
				log_sql("Could not get schema version from database")
			qdel(query_db_version)
		else
			log_sql("Your server failed to establish a connection with the database.")
	else
		log_sql("Database is not enabled in configuration.")

/datum/controller/subsystem/dbcore/proc/SetRoundID()
	if(!Connect())
		return
	var/datum/DBQuery/query_round_initialize = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("round")] (initialize_datetime, server_name, server_ip, server_port) VALUES (Now(), :server_name, INET_ATON(:internet_address), :port)",
		list(
			"server_name" = CONFIG_GET(string/serversqlname),
			"internet_address" = world.internet_address || "0",
			"port" = "[world.port]"
		)
	)
	query_round_initialize.Execute(async = FALSE)
	GLOB.round_id = "[query_round_initialize.last_insert_id]"
	qdel(query_round_initialize)
	var/tries = 0
	while (tries < 5 && !GLOB.round_id)
		var/datum/DBQuery/query_round_last_id = SSdbcore.NewQuery("SELECT MAX(id) FROM [format_table_name("round")] WHERE initialize_datetime > date_sub(Now(), interval 15 second) LIMIT 1") // I'm ashamed of it but it fixes the problem. -qwerty
		query_round_last_id.Execute(async = FALSE)
		if(query_round_last_id.NextRow(async = FALSE))
			GLOB.round_id = query_round_last_id.item[1]
		qdel(query_round_last_id)
		tries++

/datum/controller/subsystem/dbcore/proc/SetRoundStart()
	if(!Connect())
		return
	var/datum/DBQuery/query_round_start = SSdbcore.NewQuery(
		"UPDATE [format_table_name("round")] SET start_datetime = Now() WHERE id = :round_id",
		list("round_id" = GLOB.round_id)
	)
	query_round_start.Execute()
	qdel(query_round_start)

/datum/controller/subsystem/dbcore/proc/SetRoundEnd()
	if(!Connect())
		return
	var/datum/DBQuery/query_round_end = SSdbcore.NewQuery(
		"UPDATE [format_table_name("round")] SET end_datetime = Now(), game_mode_result = :game_mode_result, station_name = :station_name WHERE id = :round_id",
		list("game_mode_result" = SSticker.mode_result, "station_name" = station_name(), "round_id" = GLOB.round_id)
	)
	query_round_end.Execute()
	qdel(query_round_end)

/datum/controller/subsystem/dbcore/proc/Disconnect()
	failed_connections = 0
	if (connection)
		rustg_sql_disconnect_pool(connection)
	connection = null

/datum/controller/subsystem/dbcore/proc/IsConnected()
	if (!CONFIG_GET(flag/sql_enabled))
		return FALSE
	if (!connection)
		return FALSE
	return json_decode(rustg_sql_connected(connection))["status"] == "online"

/datum/controller/subsystem/dbcore/proc/ErrorMsg()
	if(!CONFIG_GET(flag/sql_enabled))
		return "Database disabled by configuration"
	return last_error

/datum/controller/subsystem/dbcore/proc/ReportError(error)
	last_error = error

/datum/controller/subsystem/dbcore/proc/NewQuery(sql_query, arguments)
	if(IsAdminAdvancedProcCall())
		log_admin_private("ERROR: Advanced admin proc call led to sql query: [sql_query]. Query has been blocked")
		message_admins("ERROR: Advanced admin proc call led to sql query. Query has been blocked")
		return FALSE
	return new /datum/DBQuery(connection, sql_query, arguments)

/datum/controller/subsystem/dbcore/proc/QuerySelect(list/querys, warn = FALSE, qdel = FALSE)
	if (!islist(querys))
		if (!istype(querys, /datum/DBQuery))
			CRASH("Invalid query passed to QuerySelect: [querys]")
		querys = list(querys)

	for (var/thing in querys)
		var/datum/DBQuery/query = thing
		if (warn)
			INVOKE_ASYNC(query, /datum/DBQuery.proc/warn_execute)
		else
			INVOKE_ASYNC(query, /datum/DBQuery.proc/Execute)

	for (var/thing in querys)
		var/datum/DBQuery/query = thing
		UNTIL(!query.in_progress)
		if (qdel)
			qdel(query)



/*
Takes a list of rows (each row being an associated list of column => value) and inserts them via a single mass query.
Rows missing columns present in other rows will resolve to SQL NULL
You are expected to do your own escaping of the data, and expected to provide your own quotes for strings.
The duplicate_key arg can be true to automatically generate this part of the query
	or set to a string that is appended to the end of the query
Ignore_errors instructes mysql to continue inserting rows if some of them have errors.
	 the erroneous row(s) aren't inserted and there isn't really any way to know why or why errored
Delayed insert mode was removed in mysql 7 and only works with MyISAM type tables,
	It was included because it is still supported in mariadb.
	It does not work with duplicate_key and the mysql server ignores it in those cases
*/
/datum/controller/subsystem/dbcore/proc/MassInsert(table, list/rows, duplicate_key = FALSE, ignore_errors = FALSE, delayed = FALSE, warn = FALSE, async = TRUE, special_columns = null)
	if (!table || !rows || !istype(rows))
		return

	// Prepare column list
	var/list/columns = list()
	var/list/has_question_mark = list()
	for (var/list/row in rows)
		for (var/column in row)
			columns[column] = "?"
			has_question_mark[column] = TRUE
	for (var/column in special_columns)
		columns[column] = special_columns[column]
		has_question_mark[column] = findtext(special_columns[column], "?")

	// Prepare SQL query full of placeholders
	var/list/query_parts = list("INSERT")
	if (delayed)
		query_parts += " DELAYED"
	if (ignore_errors)
		query_parts += " IGNORE"
	query_parts += " INTO "
	query_parts += table
	query_parts += "\n([columns.Join(", ")])\nVALUES"

	var/list/arguments = list()
	var/has_row = FALSE
	for (var/list/row in rows)
		if (has_row)
			query_parts += ","
		query_parts += "\n  ("
		var/has_col = FALSE
		for (var/column in columns)
			if (has_col)
				query_parts += ", "
			if (has_question_mark[column])
				var/name = "p[arguments.len]"
				query_parts += replacetext(columns[column], "?", ":[name]")
				arguments[name] = row[column]
			else
				query_parts += columns[column]
			has_col = TRUE
		query_parts += ")"
		has_row = TRUE

	if (duplicate_key == TRUE)
		var/list/column_list = list()
		for (var/column in columns)
			column_list += "[column] = VALUES([column])"
		query_parts += "\nON DUPLICATE KEY UPDATE [column_list.Join(", ")]"
	else if (duplicate_key != FALSE)
		query_parts += duplicate_key

	var/datum/DBQuery/Query = NewQuery(query_parts.Join(), arguments)
	if (warn)
		. = Query.warn_execute(async)
	else
		. = Query.Execute(async)
	qdel(Query)

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
	SSdbcore.active_queries[src] = TRUE
	Activity("Created")
	item = list()

	src.connection = connection
	src.sql = sql
	src.arguments = arguments

/datum/DBQuery/Destroy()
	Close()
	SSdbcore.active_queries -= src
	return ..()

/datum/DBQuery/CanProcCall(proc_name)
	//fuck off kevinz
	return FALSE

/datum/DBQuery/proc/Activity(activity)
	last_activity = activity
	last_activity_time = world.time

/datum/DBQuery/proc/warn_execute(async = TRUE)
	. = Execute(async)
	if(!.)
		to_chat(usr, "<span class='danger'>A SQL error occurred during this operation, check the server logs.</span>")

/datum/DBQuery/proc/Execute(async = TRUE, log_error = TRUE)
	Activity("Execute")
	if(in_progress)
		CRASH("Attempted to start a new query while waiting on the old one")

	if(!SSdbcore.IsConnected())
		last_error = "No connection!"
		return FALSE

	var/start_time
	if(!async)
		start_time = REALTIMEOFDAY
	Close()
	. = run_query(async)
	var/timed_out = !. && findtext(last_error, "Operation timed out")
	if(!. && log_error)
		log_sql("[last_error] | Query used: [sql] | Arguments: [list2params(arguments)]")
	if(!async && timed_out)
		log_query_debug("Query execution started at [start_time]")
		log_query_debug("Query execution ended at [REALTIMEOFDAY]")
		log_query_debug("Slow query timeout detected.")
		log_query_debug("Query used: [sql]")
		log_query_debug("Arguments: [list2params(arguments)]")
		slow_query_check()

/datum/DBQuery/proc/run_query(async)
	var/job_result_str

	if (async)
		var/job_id = rustg_sql_query_async(connection, sql, json_encode(arguments))
		in_progress = TRUE
		UNTIL((job_result_str = rustg_sql_check_query(job_id)) != RUSTG_JOB_NO_RESULTS_YET)
		in_progress = FALSE

		if (job_result_str == RUSTG_JOB_ERROR)
			last_error = job_result_str
			return FALSE
	else
		job_result_str = rustg_sql_query_blocking(connection, sql, json_encode(arguments))

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

/datum/DBQuery/proc/slow_query_check()
	message_admins("HEY! A database query timed out. Did the server just hang? <a href='?_src_=holder;[HrefToken()];slowquery=yes'>\[YES\]</a>|<a href='?_src_=holder;[HrefToken()];slowquery=no'>\[NO\]</a>")

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
