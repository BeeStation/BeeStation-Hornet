/// A cache for player preferences data
/datum/preferences_holder/preferences_player
	pref_type = PREFERENCE_PLAYER

/datum/preferences_holder/preferences_player/proc/load_from_database(datum/preferences/prefs)
	if(IS_GUEST_KEY(prefs.parent.key) || !query_data(prefs)) // Query direct, otherwise create informed defaults
		for (var/preference_type in GLOB.preference_entries)
			var/datum/preference/preference = GLOB.preference_entries[preference_type]
			if (preference.preference_type != pref_type)
				continue
			preference_data[preference.db_key] = preference.deserialize(preference.create_informed_default_value(prefs), prefs)
		// Give the developers +1 sanity points
		if(Debugger?.enabled)
			prefs.update_preference(/datum/preference/toggle/sound_ambience, FALSE)
			prefs.update_preference(/datum/preference/toggle/sound_ship_ambience, FALSE)
			prefs.update_preference(/datum/preference/toggle/sound_lobby, FALSE)
		return FALSE
	if(!istype(prefs.parent)) // Client was nulled during query execution
		return FALSE
	return TRUE

/datum/preferences_holder/preferences_player/proc/query_data(datum/preferences/prefs)
	if(!SSdbcore.IsConnected())
		return FALSE
	if(!istype(prefs.parent))
		return FALSE
	var/datum/DBQuery/Q = SSdbcore.NewQuery(
		"SELECT CAST(preference_tag AS CHAR) AS ptag, preference_value FROM [format_table_name("preferences")] WHERE ckey=:ckey",
		list("ckey" = prefs.parent.ckey)
	)
	if(!Q.warn_execute())
		qdel(Q)
		return FALSE
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
	return any_data

/datum/preferences_holder/preferences_player/proc/write_to_database(datum/preferences/prefs)
	. = write_data(prefs)
	dirty_prefs.Cut() // clear all dirty preferences

/datum/preferences_holder/preferences_player/proc/write_data(datum/preferences/prefs)
	if(!SSdbcore.IsConnected() || !istype(prefs.parent) || IS_GUEST_KEY(prefs.parent.key))
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
		to_chat(prefs.parent, "<span class='boldannounce'>Failed to save your player preferences. Please inform the server operator or a maintainer of this error.</span>")
	prefs.fail_state = success
	return success
