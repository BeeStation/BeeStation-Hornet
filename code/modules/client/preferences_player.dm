/// A cache for player preferences data
/datum/preferences_holder/preferences_player
	pref_type = PREFERENCE_PLAYER

/datum/preferences_holder/preferences_player/proc/load_from_database(datum/preferences/prefs)
	if(!query_data(prefs)) // Query direct, otherwise create informed defaults
		for (var/preference_type in GLOB.preference_entries)
			var/datum/preference/preference = GLOB.preference_entries[preference_type]
			if (preference.preference_type != pref_type)
				continue
			preference_data[preference.db_key] = preference.deserialize(preference.create_informed_default_value(prefs), prefs)
		return FALSE
	return TRUE

/datum/preferences_holder/preferences_player/proc/query_data(datum/preferences/prefs)
	if(!SSdbcore.IsConnected())
		return FALSE
	var/datum/DBQuery/Q = SSdbcore.NewQuery(
		"SELECT CAST(preference_tag AS CHAR) AS ptag, preference_value FROM [format_table_name("preferences")] WHERE ckey=:ckey",
		list("ckey" = prefs.parent.ckey)
	)
	if(!Q.warn_execute())
		qdel(Q)
		return FALSE
	while(Q.NextRow())
		var/db_key = Q.item[1]
		var/value = Q.item[2]
		var/datum/preference/preference = GLOB.preference_entries_by_key[db_key]
		if(!preference)
			// TODO tgui-prefs clean out database and re-enable this
			//CRASH("Unknown preference tag in database: [db_key] for ckey [prefs.parent.ckey]")
			continue
		preference_data[db_key] = isnull(value) ? null : preference.deserialize(value, prefs)
	qdel(Q)
	return TRUE

/datum/preferences_holder/preferences_player/proc/write_to_database(datum/preferences/prefs)
	write_data(prefs)
	dirty_prefs.Cut() // clear all dirty preferences

/datum/preferences_holder/preferences_player/proc/write_data(datum/preferences/prefs)
	if(!SSdbcore.IsConnected() || IS_GUEST_KEY(prefs.parent.ckey))
		return FALSE
	var/list/sql_inserts = list()
	for(var/db_key in dirty_prefs)
		if(!(db_key in preference_data))
			CRASH("Invalid db_key found in dirty preferences list: [db_key].")
		var/datum/preference/preference = GLOB.preference_entries_by_key[db_key]
		if(!istype(preference))
			CRASH("Could not find preference with db_key [db_key] when writing to database.")
		sql_inserts += list(list(
			"ckey" = prefs.parent.ckey,
			"preference_tag" = db_key,
			"preference_value" = preference.serialize(preference_data[db_key])
		))
	if(!length(sql_inserts)) // nothing to update
		return TRUE

	var/success = SSdbcore.MassInsert(format_table_name("preferences"), sql_inserts, duplicate_key = TRUE, warn = TRUE)
	if(!success)
		to_chat(usr, "<span class='boldannounce'>Failed to save your player preferences. Please inform the server operator.</span>")
	return success
