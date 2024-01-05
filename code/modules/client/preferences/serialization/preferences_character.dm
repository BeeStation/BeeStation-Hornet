/// A cache for character preferences data
/datum/preferences_holder/preferences_character
	pref_type = PREFERENCE_CHARACTER
	/// INT: Slot number. Used for internal tracking. The slot number also correspnds to the number of slots in the characters list
	var/slot_number = 0
	/// List of column names to be queried
	var/static/list/column_names

/// Block varedits to column_names
/datum/preferences_holder/preferences_character/vv_edit_var(var_name, var_value)
	var/static/list/banned_edits = list(NAMEOF_STATIC(src, column_names))
	return !(var_name in banned_edits) && ..()

/// Initialize the data cache with default values
/datum/preferences_holder/preferences_character/New(datum/preferences/prefs, slot)
	slot_number = slot
	if(!length(column_names))
		column_names = get_column_names()
	..(prefs)

/datum/preferences_holder/preferences_character/query_data(datum/preferences/prefs)
	. = ..()
	if(. != PREFERENCE_LOAD_SUCCESS)
		return .
	var/list/values
	var/datum/DBQuery/Q = SSdbcore.NewQuery(
		"SELECT [db_column_list(column_names)] FROM [format_table_name("characters")] WHERE ckey=:ckey AND slot=:slot",
		list("ckey" = prefs.parent.ckey, "slot" = slot_number)
	)
	if(!Q.warn_execute())
		qdel(Q)
		log_preferences("[prefs.parent.ckey]: ERROR - Datumized character preferences load query failed.")
		return PREFERENCE_LOAD_ERROR
	if(Q.NextRow())
		values = Q.item
		if(!length(values)) // There is no character
			qdel(Q)
			log_preferences("[prefs.parent.ckey]: Datumized character preferences load found no results in row.")
			return PREFERENCE_LOAD_NO_DATA
	else
		qdel(Q)
		log_preferences("[prefs.parent.ckey]: Datumized character preferences load found no rows.")
		return PREFERENCE_LOAD_NO_DATA
	qdel(Q)
	if(length(values) != length(column_names))
		log_preferences("[prefs.parent.ckey]: ERROR - Datumized character preferences load found the wrong amount of columns.")
		CRASH("Error querying character data: the returned value length is not equal to the number of columns requested.")
	for(var/index in 1 to length(values))
		var/db_key = column_names[index]
		var/datum/preference/preference = GLOB.preference_entries_by_key[db_key]
		if(!istype(preference))
			log_preferences("[prefs.parent.ckey]: ERROR - Datumized character preferences failed to find preference column [db_key] in game, but it was in the database.")
			CRASH("Could not find preference with db_key [db_key] when querying database.")
		var/value = values[index]
		preference_data[db_key] = isnull(value) ? null : preference.deserialize(value, prefs)
	log_preferences("[prefs.parent.ckey]: Successfully loaded datumized character preferences.")
	return PREFERENCE_LOAD_SUCCESS

/datum/preferences_holder/preferences_character/write_data(datum/preferences/prefs)
	. = ..()
	if(. != PREFERENCE_LOAD_SUCCESS)
		return .
	var/list/column_names_short = list()
	var/list/new_data = list()
	for(var/db_key in dirty_prefs)
		if(!(db_key in preference_data))
			log_preferences("[prefs.parent.ckey]: ERROR - Datumized character preferences write found invalid db_key [db_key] in dirty preferences list.")
			CRASH("Invalid db_key found in dirty preferences list: [db_key].")
		var/datum/preference/preference = GLOB.preference_entries_by_key[db_key]
		if(!istype(preference))
			log_preferences("[prefs.parent.ckey]: ERROR - Datumized character preferences write found invalid db_key [db_key] in dirty preferences list (2).")
			CRASH("Could not find preference with db_key [db_key] when writing to database.")
		if(preference.disable_serialization)
			continue
		if(preference.preference_type != pref_type)
			log_preferences("[prefs.parent.ckey]: ERROR - Datumized character preferences write found invalid preference type [preference.preference_type] for [db_key] (want [pref_type]).")
			CRASH("Invalid preference located from db_key [db_key] for the preference type [pref_type] (had [preference.preference_type])")
		new_data[db_key] = preference.serialize(preference_data[db_key])
		var/column_name = clean_column_name(preference)
		if(length(column_name))
			column_names_short += column_name
	if(!length(column_names_short)) // nothing to update
		log_preferences("[prefs.parent.ckey]: Datumized character preferences write - no columns to write.")
		return PREFERENCE_LOAD_NO_DATA
	new_data["ckey"] = prefs.parent.ckey
	new_data["slot"] = slot_number
	var/datum/DBQuery/Q = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("characters")] (ckey, slot, [db_column_list(column_names_short)]) VALUES (:ckey, :slot, [db_column_list(column_names_short, TRUE)]) ON DUPLICATE KEY UPDATE [db_column_values(column_names_short)]", new_data
	)
	var/success = Q.warn_execute()
	qdel(Q)
	prefs.fail_state = success
	log_preferences("[prefs.parent.ckey]: Datumized character preferences write result [success ? "GOOD" : "ERROR"].")
	return success ? PREFERENCE_LOAD_SUCCESS : PREFERENCE_LOAD_ERROR

/datum/preferences_holder/preferences_character/proc/get_column_names()
	var/list/result = list()
	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if (preference.preference_type != PREFERENCE_CHARACTER)
			continue
		if(preference.disable_serialization)
			continue
		// IMPORTANT: use of initial evades varedits. Filter to only alphanumeric and underscores
		var/column_name = clean_column_name(preference)
		if(length(column_name))
			result += column_name
	if(!length(result))
		CRASH("Something is very wrong, /datum/prefence_character/proc/get_column_names() returned a zero length list.")
	return result

/datum/preferences_holder/preferences_character/proc/clean_column_name(datum/preference/preference)
	var/column_name = reject_bad_text(initial(preference.db_key), max_length = 64, ascii_only = TRUE, alphanumeric_only = TRUE, underscore_allowed = TRUE)
	if(!length(column_name) || findtext(column_name, " ") || column_name != preference.db_key)
		CRASH("Invalid or possibly modified column name: '[column_name]' for db_key '[preference.db_key]'! Something bad is going on.")
	return column_name

/// Minimized copy of english_list because I don't want someone breaking this very important function later on
/proc/db_column_list(list/input, colon = FALSE)
	var/total = length(input)
	switch(total)
		if (0)
			return ""
		if (1)
			return "[colon ? ":" : ""][input[1]]"
		if (2)
			return "[colon ? ":" : ""][input[1]], [colon ? ":" : ""][input[2]]"
		else
			var/output = ""
			var/index = 1
			while (index < total)
				output += "[colon ? ":" : ""][input[index]], "
				index++

			return "[output][colon ? ":" : ""][input[index]]"

/proc/db_column_values(list/input)
	var/total = length(input)
	switch(total)
		if (0)
			return ""
		if (1)
			return "[input[1]]=VALUES([input[1]])"
		if (2)
			return "[input[1]]=VALUES([input[1]]), [input[2]]=VALUES([input[2]])"
		else
			var/output = ""
			var/index = 1
			while (index < total)
				output += "[input[index]]=VALUES([input[index]]),"
				index++

			return "[output][input[index]]=VALUES([input[index]])"


/datum/preferences_holder/preferences_character/proc/get_all_character_names(datum/preferences/prefs)
	if(!SSdbcore.IsConnected() || IS_GUEST_KEY(prefs.parent.key))
		var/list/data = list()
		for(var/index in 1 to TRUE_MAX_SAVE_SLOTS)
			data += null
		// Only the current slot is valid
		data[prefs.default_slot] = read_preference(prefs, GLOB.preference_entries[/datum/preference/name/real_name])
		prefs.character_profiles_cached = data
		return
	var/datum/DBQuery/Q = SSdbcore.NewQuery(
		"SELECT slot,real_name FROM [format_table_name("characters")] WHERE ckey=:ckey",
		list("ckey" = prefs.parent.ckey)
	)
	if(!Q.warn_execute())
		qdel(Q)
		log_preferences("[prefs.parent.ckey]: ERROR - SQL error while retrieving character profiles.")
		CRASH("An SQL error occurred while retrieving character profile data.")
	var/list/data = list()
	for(var/index in 1 to TRUE_MAX_SAVE_SLOTS)
		data += null
	while(Q.NextRow())
		var/list/values = Q.item
		if(length(values) != 2)
			CRASH("Error querying character profile data: the returned value length is greater than the number of columns requested.")
		if(!isnum(values[1]))
			CRASH("Error querying character profile data: slot number was not a number")
		if(!istext(values[2]))
			CRASH("Error querying character profile data: character name was not a string")
		if(values[1] > TRUE_MAX_SAVE_SLOTS)
			CRASH("Slot number in database is greater than the maximum allowed slots! Please purge this character entry or increase the slot number.")
		data[values[1]] = values[2] // data[1] = "John Smith"
	qdel(Q)
	prefs.character_profiles_cached = data
	log_preferences("[prefs.parent.ckey]: Successfully retrieved character profiles.")
