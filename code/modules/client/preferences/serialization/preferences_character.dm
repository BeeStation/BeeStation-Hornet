/// A cache for character preferences data
/datum/preferences_holder/preferences_character
	/// INT: Slot number. Used for internal tracking. The slot number also correspnds to the number of slots in the characters list
	var/slot_number = 0
	/// List of column names to be queried
	var/static/list/column_names

/// Block varedits to column_names
/datum/preferences_holder/preferences_character/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF_STATIC(src, column_names))
		return FALSE
	return ..()

/// Initialize the data cache with default values
/datum/preferences_holder/preferences_character/New(datum/preferences/prefs, slot)
	slot_number = slot
	if(!length(column_names))
		column_names = get_column_names()
	..(prefs)

/datum/preferences_holder/preferences_character/proc/load_from_database(datum/preferences/prefs)
	if(!query_data(prefs)) // Query direct, otherwise create informed defaults
		for (var/preference_type in GLOB.preference_entries)
			var/datum/preference/preference = GLOB.preference_entries[preference_type]
			if (preference.preference_type != pref_type)
				continue
			preference_data[preference.db_key] = preference.deserialize(preference.create_informed_default_value(prefs), prefs)
		return FALSE
	return TRUE

/datum/preferences_holder/preferences_character/proc/query_data(datum/preferences/prefs)
	if(!SSdbcore.IsConnected())
		return FALSE
	var/list/values
	var/datum/DBQuery/Q = SSdbcore.NewQuery(
		"SELECT [db_column_list(column_names)] FROM [format_table_name("characters")] WHERE ckey=:ckey AND slot=:slot",
		list("ckey" = prefs.parent.ckey, "slot" = slot_number)
	)
	if(!Q.warn_execute())
		qdel(Q)
		return FALSE
	if(Q.NextRow())
		values = Q.item
		if(!length(values)) // There is no character
			qdel(Q)
			return FALSE
	else
		qdel(Q)
		return FALSE
	qdel(Q)
	if(length(values) != length(column_names))
		CRASH("Error querying character data: the returned value length is not equal to the number of columns requested.")
	for(var/index in 1 to length(values))
		var/db_key = column_names[index]
		var/datum/preference/preference = GLOB.preference_entries_by_key[db_key]
		if(!istype(preference))
			CRASH("Could not find preference with db_key [db_key] when querying database.")
		var/value = values[index]
		preference_data[db_key] = isnull(value) ? null : preference.deserialize(value, prefs)
	return TRUE

/datum/preferences_holder/preferences_character/proc/write_to_database(datum/preferences/prefs)
	. = write_data(prefs)
	dirty_prefs.Cut() // clear all dirty preferences

/datum/preferences_holder/preferences_character/proc/write_data(datum/preferences/prefs)
	if(!SSdbcore.IsConnected() || IS_GUEST_KEY(prefs.parent.ckey))
		return FALSE
	var/list/column_names_short = list()
	var/list/new_data = list()
	for(var/db_key in dirty_prefs)
		if(!(db_key in preference_data))
			CRASH("Invalid db_key found in dirty preferences list: [db_key].")
		var/datum/preference/preference = GLOB.preference_entries_by_key[db_key]
		if(!istype(preference))
			CRASH("Could not find preference with db_key [db_key] when writing to database.")
		new_data[db_key] = preference.serialize(preference_data[db_key])
		var/column_name = clean_column_name(preference)
		if(length(column_name))
			column_names_short += column_name
	if(!length(column_names_short)) // nothing to update
		return TRUE
	to_chat(prefs.parent, "<span class='notice'>Writing character datumized</span>") // debug tgui-prefs
	new_data["ckey"] = prefs.parent.ckey
	new_data["slot"] = slot_number
	var/datum/DBQuery/Q = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("characters")] (ckey, slot, [db_column_list(column_names_short)]) VALUES (:ckey, :slot, [db_column_list(column_names_short, TRUE)]) ON DUPLICATE KEY UPDATE [db_column_values(column_names_short)]", new_data
	)
	var/success = Q.warn_execute()
	if(!success)
		to_chat(usr, "<span class='boldannounce'>Failed to save your character. Please inform the server operator.</span>")
	qdel(Q)
	return success

/datum/preferences_holder/preferences_character/proc/get_column_names()
	var/list/result = list()
	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if (preference.preference_type != PREFERENCE_CHARACTER)
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
	if(!SSdbcore.IsConnected())
		return list() // No names if DB is not connected
	var/datum/DBQuery/Q = SSdbcore.NewQuery(
		"SELECT slot,real_name FROM [format_table_name("characters")] WHERE ckey=:ckey",
		list("ckey" = prefs.parent.ckey)
	)
	if(!Q.warn_execute())
		qdel(Q)
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
	return data
