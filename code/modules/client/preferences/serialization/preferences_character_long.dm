/// A cache for character preferences data
/datum/preferences_holder/preferences_character_long
	pref_type = PREFERENCE_CHARACTER_LONG
	/// INT: Slot number. Used for internal tracking. The slot number also correspnds to the number of slots in the characters list
	var/slot_number = 0

/// Initialize the data cache with default values
/datum/preferences_holder/preferences_character_long/New(datum/preferences/prefs, slot)
	slot_number = slot
	..(prefs)

/datum/preferences_holder/preferences_character_long/query_data(datum/preferences/prefs)
	. = ..()
	if(. != PREFERENCE_LOAD_SUCCESS)
		return .
	var/datum/DBQuery/Q = SSdbcore.NewQuery(
		"SELECT CAST(preference_tag AS CHAR) AS ptag, preference_value FROM [format_table_name("characters_long")] WHERE ckey=:ckey AND slot=:slot",
		list("ckey" = prefs.parent.ckey, "slot" = slot_number)
	)
	if(!Q.warn_execute())
		qdel(Q)
		return PREFERENCE_LOAD_ERROR
	var/any_data = FALSE
	while(Q.NextRow())
		var/db_key = Q.item[1]
		var/value = Q.item[2]
		var/datum/preference/preference = GLOB.preference_entries_by_key[db_key]
		if(!preference)
			stack_trace("Unknown preference tag in database: [db_key] for ckey [prefs.parent.ckey]")
			continue
		preference_data[db_key] = isnull(value) ? null : preference.deserialize(value, prefs)
		any_data = TRUE
	qdel(Q)
	return any_data ? PREFERENCE_LOAD_SUCCESS : PREFERENCE_LOAD_NO_DATA

/datum/preferences_holder/preferences_character_long/write_data(datum/preferences/prefs)
	. = ..()
	if(. != PREFERENCE_LOAD_SUCCESS)
		return .
	var/list/sql_inserts = list()
	for(var/db_key in dirty_prefs)
		if(!(db_key in preference_data))
			CRASH("Invalid db_key found in dirty preferences list: [db_key].")
		var/datum/preference/preference = GLOB.preference_entries_by_key[db_key]
		if(!istype(preference))
			CRASH("Could not find preference with db_key [db_key] when writing to database.")
		if(preference.preference_type != pref_type)
			CRASH("Invalid preference located from db_key [db_key] for the preference type [pref_type] (had [preference.preference_type])")
		sql_inserts += list(list(
			"ckey" = prefs.parent.ckey,
			"slot" = slot_number,
			"preference_tag" = db_key,
			"preference_value" = preference.serialize(preference_data[db_key])
		))
	if(!length(sql_inserts)) // nothing to update
		return PREFERENCE_LOAD_NO_DATA
	var/success = SSdbcore.MassInsert(format_table_name("characters_long"), sql_inserts, duplicate_key = TRUE, warn = TRUE)
	prefs.fail_state = success
	return success ? PREFERENCE_LOAD_SUCCESS : PREFERENCE_LOAD_ERROR
