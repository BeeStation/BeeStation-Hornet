/datum/dbcore
	var/connection  // Arbitrary handle returned from rust_g.

/datum/dbcore/New()
	var/result = json_decode(rustg_sql_connect_pool(json_encode(list(
		"host" = DB_HOST,
		"port" = DB_PORT,
		"user" = DB_USER,
		"pass" = DB_PASSWORD,
		"db_name" = DB_NAME,
		"read_timeout" = 5,
		"write_timeout" = 5,
		"max_threads" = 50,
	))))
	. = (result["status"] == "ok")
	if (.)
		connection = result["handle"]
	else
		connection = null
		world.log << "Connect() failed"

/datum/dbcore/proc/Disconnect()
	if (connection)
		rustg_sql_disconnect_pool(connection)
	connection = null

/datum/dbcore/proc/IsConnected()
	if (!connection)
		return FALSE
	return json_decode(rustg_sql_connected(connection))["status"] == "online"

/datum/dbcore/proc/NewQuery(sql_query, arguments)
	return new /datum/DBQuery(connection, sql_query, arguments)

/datum/dbcore/proc/QuerySelect(list/querys, warn = FALSE, qdel = FALSE)
	if (!islist(querys))
		if (!istype(querys, /datum/DBQuery))
			CRASH("Invalid query passed to QuerySelect: [querys]")
		querys = list(querys)

	for (var/thing in querys)
		var/datum/DBQuery/query = thing
		INVOKE_ASYNC(query, /datum/DBQuery.proc/Execute)

	for (var/thing in querys)
		var/datum/DBQuery/query = thing
		UNTIL(!query.in_progress)
		if (qdel)
			del(query)



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
/datum/dbcore/proc/MassInsert(table, list/rows, duplicate_key = FALSE, ignore_errors = FALSE, delayed = FALSE, warn = FALSE, async = TRUE, special_columns = null)
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
	. = Query.Execute(async)
	Query.Destroy()
	del(Query)

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

/datum/DBQuery/proc/Destroy()
	Close()

/datum/DBQuery/proc/Activity(activity)
	last_activity = activity
	last_activity_time = world.time

/datum/DBQuery/proc/Execute(async = TRUE, log_error = TRUE)
	Activity("Execute")
	if(in_progress)
		CRASH("Attempted to start a new query while waiting on the old one")

	var/start_time
	if(!async)
		start_time = world.timeofday
	Close()
	. = run_query(async)
	var/timed_out = !. && findtext(last_error, "Operation timed out")
	if(!. && log_error)
		world.log << "[last_error] | Query used: [sql] | Arguments: [list2params(arguments)]"
	if(!async && timed_out)
		world.log << "Query execution started at [start_time]"
		world.log << "Query execution ended at [world.timeofday]"
		world.log << "Slow query timeout detected."
		world.log << "Query used: [sql]"
		world.log << "Arguments: [list2params(arguments)]"

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
