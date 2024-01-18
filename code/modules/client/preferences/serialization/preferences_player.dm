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
		log_preferences("[prefs.parent.ckey]: ERROR - Datumized player preferences load query failed.")
		return PREFERENCE_LOAD_ERROR
	var/any_data = FALSE
	while(Q.NextRow())
		var/db_key = Q.item[1]
		var/value = Q.item[2]
		var/datum/preference/preference = GLOB.preference_entries_by_key[db_key]
		if(!preference)
			if(!(db_key in GLOB.undatumized_preference_tags_player))
				log_preferences("[prefs.parent.ckey]: WARN - Datumized player preferences failed to find preference [db_key] in game, but it was in the database.")
			continue
		preference_data[db_key] = isnull(value) ? null : preference.deserialize(value, prefs)
		any_data = TRUE
	qdel(Q)
	log_preferences("[prefs.parent.ckey]: Successfully loaded datumized player preferences[!any_data ? " (no records found)" : ""].")
	return any_data ? PREFERENCE_LOAD_SUCCESS : PREFERENCE_LOAD_NO_DATA

/datum/preferences_holder/preferences_player/write_data(datum/preferences/prefs)
	. = ..()
	if(. != PREFERENCE_LOAD_SUCCESS)
		return .
	var/list/sql_inserts = list()
	for(var/db_key in dirty_prefs)
		if(!(db_key in preference_data))
			log_preferences("[prefs.parent.ckey]: ERROR - Datumized player preferences write found invalid db_key [db_key] in dirty preferences list.")
			CRASH("Invalid db_key found in dirty preferences list: [db_key].")
		var/datum/preference/preference = GLOB.preference_entries_by_key[db_key]
		if(!istype(preference))
			log_preferences("[prefs.parent.ckey]: ERROR - Datumized player preferences write found invalid db_key [db_key] in dirty preferences list (2).")
			CRASH("Could not find preference with db_key [db_key] when writing to database.")
		if(preference.disable_serialization)
			continue
		if(preference.preference_type != pref_type)
			log_preferences("[prefs.parent.ckey]: ERROR - Datumized player preferences write found invalid preference type [preference.preference_type] for [db_key] (want [pref_type]).")
			CRASH("Invalid preference located from db_key [db_key] for the preference type [pref_type] (had [preference.preference_type])")
		sql_inserts += list(list(
			"ckey" = prefs.parent.ckey,
			"preference_tag" = db_key,
			"preference_value" = preference.serialize(preference_data[db_key])
		))
	if(!length(sql_inserts)) // nothing to update
		log_preferences("[prefs.parent.ckey]: Datumized player preferences write - no columns to write.")
		return PREFERENCE_LOAD_NO_DATA
	var/success = SSdbcore.MassInsert(format_table_name("preferences"), sql_inserts, duplicate_key = TRUE, warn = TRUE)
	prefs.fail_state = success
	log_preferences("[prefs.parent.ckey]: Datumized player preferences write result [success ? "GOOD" : "ERROR"].")
	return success ? PREFERENCE_LOAD_SUCCESS : PREFERENCE_LOAD_ERROR
