/// A cache for player preferences data
/datum/preferences_holder/preferences_player
	pref_type = PREFERENCE_PLAYER

/datum/preferences_holder/preferences_player/load_from_database(datum/preferences/prefs)
	. = ..()
	// Give the developers +1 sanity points
	if(. == PREFERENCE_LOAD_IGNORE && Debugger?.enabled)
		prefs.update_preference(/datum/preference/toggle/sound_ambience, FALSE)
		prefs.update_preference(/datum/preference/toggle/sound_ship_ambience, FALSE)
		prefs.update_preference(/datum/preference/toggle/sound_lobby, FALSE)
	return .

/datum/preferences_holder/preferences_player/query_data(datum/preferences/prefs)
	. = ..()
	if(. != PREFERENCE_LOAD_SUCCESS)
		return .
	var/datum/DBQuery/Q = SSdbcore.NewQuery(
		"SELECT CAST(preference_tag AS CHAR) AS ptag, preference_value FROM [format_table_name("preferences")] WHERE ckey=:ckey",
		list("ckey" = prefs.parent.ckey)
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
			// If you ever want to error for unknown tags, this would be helpful.
			// As of now we don't really care since it doesn't help anything to throw runtimes everywhere.
			//CRASH("Unknown preference tag in database: [db_key] for ckey [prefs.parent.ckey]")
			continue
		preference_data[db_key] = isnull(value) ? null : preference.deserialize(value, prefs)
		any_data = TRUE
	qdel(Q)
	return any_data ? PREFERENCE_LOAD_SUCCESS : PREFERENCE_LOAD_NO_DATA

/datum/preferences_holder/preferences_player/write_data(datum/preferences/prefs)
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
			"preference_tag" = db_key,
			"preference_value" = preference.serialize(preference_data[db_key])
		))
	if(!length(sql_inserts)) // nothing to update
		return PREFERENCE_LOAD_NO_DATA
	var/success = SSdbcore.MassInsert(format_table_name("preferences"), sql_inserts, duplicate_key = TRUE, warn = TRUE)
	prefs.fail_state = success
	return success ? PREFERENCE_LOAD_SUCCESS : PREFERENCE_LOAD_ERROR
