
/// Creates mentor datums from the database
/proc/load_mentors()
	clear_all_mentors()
	if(CONFIG_GET(flag/mentor_legacy_system))
		load_mentors_legacy()
	else
		load_mentors_database()

/// Clear all mentor datums and assignments of said datum
/proc/clear_all_mentors()
	GLOB.mentor_datums.Cut()
	for(var/client/C in GLOB.mentors)
		C.remove_mentor_verbs()
		if(C.mentor_datum)
			C.mentor_datum.owner = null
		C.mentor_datum = null
	GLOB.mentors.Cut()

/// Loads mentors from mentors.txt
/// use load_mentors() rather than calling this directly
/proc/load_mentors_legacy()
	if(!CONFIG_GET(flag/mentor_legacy_system))
		return FALSE
	var/list/lines = world.file2list("config/mentors.txt")
	for(var/line in lines)
		if(!length(line))
			continue
		if(findtextEx(line, "#", 1, 2))
			continue
		new /datum/mentors(line)
	return TRUE

/// Loads mentors from the ss13_mentors table
/// use load_mentors() rather than calling this directly
/proc/load_mentors_database()
	if(!SSdbcore.Connect())
		log_world("Failed to connect to database in load_mentors(). Reverting to legacy system.")
		WRITE_FILE(GLOB.world_game_log, "Failed to connect to database in load_mentors(). Reverting to legacy system.")
		CONFIG_SET(flag/mentor_legacy_system, TRUE)
		load_mentors_legacy()
		return FALSE
	var/datum/DBQuery/query_load_mentors = SSdbcore.NewQuery("SELECT id,ckey FROM [format_table_name("mentor")]")
	if(!query_load_mentors.Execute())
		qdel(query_load_mentors)
		return FALSE
	while(query_load_mentors.NextRow())
		var/id = query_load_mentors.item[1]
		var/raw_ckey = query_load_mentors.item[2]
		var/ckey = ckey(raw_ckey)
		if(!ckey)
			stack_trace("Invalid mentor row in database with null ckey with id: [id] and raw data: [raw_ckey]")
			continue
		new /datum/mentors(ckey)
	qdel(query_load_mentors)
	return TRUE

/// Assigns any existing mentor datum from GLOB.mentor_datums to this client,
/// adding any mentor verbs and adding the client to GLOB.mentors.
/// This is also responsible for giving admins who are not mentors a mentor datum.
/client/proc/assign_mentor_datum_if_exists()
	if(mentor_datum) // we already have a mentor datum. no need
		return TRUE
	// Get any existing mentor datum for this client
	var/datum/mentors/matching_mentor_datum = GLOB.mentor_datums[ckey]
	// There exists a valid mentor datum that can be assigned... assign it
	if(istype(matching_mentor_datum))
		matching_mentor_datum.assign_to_client(src)
		return TRUE
	// They're an admin, but not a mentor. Create them a mentor datum. This is automatically assigned.
	else if(check_rights_for(src, R_ADMIN))
		new /datum/mentors(ckey)
		return TRUE
	return FALSE
