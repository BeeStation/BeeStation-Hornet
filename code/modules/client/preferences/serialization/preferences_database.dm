/datum/preferences/var/dirty_undatumized_preferences_player = FALSE
/datum/preferences/var/dirty_undatumized_preferences_character = FALSE

/// Marks undatumized preferences as dirty, so it will be serialized on the next preference write.
/// Queues a preference write.
/// Use this for player preferences only.
/datum/preferences/proc/mark_undatumized_dirty_player()
	if(parent && IS_GUEST_KEY(parent.key)) // NO saving guests to the DB!
		return FALSE
	dirty_undatumized_preferences_player = TRUE
	log_preferences("[parent?.ckey]: Undatumized player preference changed.")
	SSpreferences.queue_write(src)

/// Marks undatumized preferences as dirty, so it will be serialized on the next preference write.
/// Queues a preference write.
/// Use this for character preferences only.
/datum/preferences/proc/mark_undatumized_dirty_character()
	if(parent && IS_GUEST_KEY(parent.key)) // NO saving guests to the DB!
		return FALSE
	dirty_undatumized_preferences_character = TRUE
	log_preferences("[parent?.ckey]: Undatumized character preference changed.")
	SSpreferences.queue_write(src)

/// If any character preference is dirty.
/datum/preferences/proc/ready_to_save_character()
	return dirty_undatumized_preferences_character || length(character_data.dirty_prefs)

/// If any player preference is dirty.
/datum/preferences/proc/ready_to_save_player()
	return dirty_undatumized_preferences_player || length(player_data.dirty_prefs)

/// checks keybindings for nonexistent keybinds and removes them
/datum/preferences/proc/sanitize_keybinds()
	if(!parent)
		return

	/**
	 * Real world example of invalid keybinds:
	 * (To avoid confusion between list index keys and keys on a keyboard, I will be referring to keys on a keyboard as buttons)
	 *
	 * key_bindings = list(
	 * 	"admin_say" = list("F3"), <--- This is correct. The bind's string form as the index's key and a list of buttons as the index's value.
	 *  "F3" = list("admin_say"), <--- This is incorrect. Buttons shouldn't ever be index keys.
	 *  "select_help_intent" = list("1"), <--- This is incorrect. "select_help_intent" is not a valid index key as it is not apart of GLOB.keybindings_by_name.
	 * 	...
	 * )
	 *
	 * Sample GLOB.keybindings_by_name:
	 *
	 * keybindings_by_name = list(
	 *  "admin_say" = /datum/keybinding/admin/admin_say, <--- Not really relevant here, but these are instances, not typepaths.
	 *  ...
	 * )
	 */
	for(var/bind, buttons_list in key_bindings)
		// Prunes buttons as index keys and deprecated binds.
		if(isnull(GLOB.keybindings_by_name[bind]))
			key_bindings -= bind

// Defines for list sanity
#define READPREF_STR(target, tag) if(prefmap[tag]) target = prefmap[tag]
#define READPREF_INT(target, tag) if(prefmap[tag]) target = text2num(prefmap[tag])

// Did you know byond has try/catch? We use it here so malformed JSON doesnt break the entire loading system
#define READPREF_JSONDEC(target, tag) \
	try {\
		if(prefmap[tag]) {\
			target = json_decode(prefmap[tag]);\
		};\
	} catch {\
		pass();\
	} // we dont need error handling where were going

/datum/preferences/proc/load_preferences()
	if(!istype(parent))
		return PREFERENCE_LOAD_ERROR
	// Cache their ckey because they can disconnect while datumized prefs read.
	var/parent_ckey = parent.ckey
	// Get the datumized stuff first
	player_data = new(src)
	var/load_result = player_data.load_from_database(src)
	if(load_result == PREFERENCE_LOAD_ERROR || load_result == null)
		log_preferences("[parent_ckey]: ERROR - player_data failed to load datumized player preferences.")
		if(istype(parent))
			to_chat(parent, span_boldannounce("Failed to load your datumized preferences. Please inform the server operator or a maintainer of this error."))
		return PREFERENCE_LOAD_ERROR
	if(load_result == PREFERENCE_LOAD_IGNORE)
		log_preferences("[parent_ckey]: WARN - player_data load ignored.")
		return PREFERENCE_LOAD_IGNORE
	log_preferences("[parent_ckey]: Undatumized player preferences loading.")
	var/datum/db_query/read_player_data = SSdbcore.NewQuery(
		"SELECT CAST(preference_tag AS CHAR) AS ptag, preference_value FROM [format_table_name("preferences")] WHERE ckey=:ckey",
		list("ckey" = parent_ckey)
	)

	// K:pref tag | V:pref value
	// DO NOT RENAME THIS. SERIOUSLY. DO NOT RENAME THIS LIST. IT'S USED IN THE READPREF DEFINES.
	var/list/prefmap = list()

	if(!read_player_data.Execute())
		qdel(read_player_data)
		log_preferences("[parent_ckey]: ERROR - Undatumized player preferences load query failed.")
		return PREFERENCE_LOAD_ERROR
	else
		while(read_player_data.NextRow())
			prefmap[read_player_data.item[1]] = read_player_data.item[2]
		qdel(read_player_data)

	READPREF_INT(default_slot, PREFERENCE_TAG_DEFAULT_SLOT)
	READPREF_STR(lastchangelog, PREFERENCE_TAG_LAST_CL)

	READPREF_STR(pai_name, PREFERENCE_TAG_PAI_NAME)
	READPREF_STR(pai_description, PREFERENCE_TAG_PAI_DESCRIPTION)
	READPREF_STR(pai_comment, PREFERENCE_TAG_PAI_COMMENT)

	READPREF_JSONDEC(ignoring, PREFERENCE_TAG_IGNORING)
	READPREF_JSONDEC(purchased_gear, PREFERENCE_TAG_PURCHASED_GEAR)
	READPREF_JSONDEC(role_preferences_global, PREFERENCE_TAG_ROLE_PREFERENCES_GLOBAL)

	READPREF_JSONDEC(favorite_outfits, PREFERENCE_TAG_FAVORITE_OUTFITS)
	var/list/parsed_favs = list()
	for(var/typetext in favorite_outfits)
		var/datum/outfit/path = text2path(typetext)
		if(ispath(path)) //whatever typepath fails this check probably doesn't exist anymore
			parsed_favs += path
	favorite_outfits = unique_list(parsed_favs)

	// Custom hotkeys
	READPREF_JSONDEC(key_bindings, PREFERENCE_TAG_KEYBINDS)

	//Sanitize
	lastchangelog = sanitize_text(lastchangelog, initial(lastchangelog))
	default_slot = sanitize_integer(default_slot, 1, TRUE_MAX_SAVE_SLOTS, initial(default_slot))
	ignoring = SANITIZE_LIST(ignoring)
	purchased_gear = SANITIZE_LIST(purchased_gear)
	role_preferences_global = SANITIZE_LIST(role_preferences_global)

	pai_name = sanitize_text(pai_name, initial(pai_name))
	pai_description = sanitize_text(pai_description, initial(pai_description))
	pai_comment = sanitize_text(pai_comment, initial(pai_comment))

	sanitize_keybinds()
	key_bindings = sanitize_islist(key_bindings, deep_copy_list(GLOB.keybindings_by_name_to_key))
	key_bindings_by_key = get_key_bindings_by_key(key_bindings)

	// Remove any invalid role preference entries
	for(var/preference in role_preferences_global)
		var/path = text2path(preference)
		var/datum/role_preference/entry = GLOB.role_preference_entries[path]
		if(istype(entry))
			continue
		role_preferences_global -= preference
		log_preferences("[parent_ckey]: WARN - Cleaned up invalid global role preference entry [preference].")
		mark_undatumized_dirty_player()

	if (!length(key_bindings))
		set_default_key_bindings(save = TRUE)
		log_preferences("[parent_ckey]: Created default keybindings on load.")
	else
		var/any_changed = FALSE
		for(var/key_name in GLOB.keybindings_by_name)
			var/datum/keybinding/keybind = GLOB.keybindings_by_name[key_name]
			if(key_name in key_bindings) // The bind exists in our keybind data. Good! Skip it.
				continue
			// Assign the default keybindings to the key, since there are none set.
			set_keybind(key_name, keybind.keys.Copy())
			any_changed = TRUE
		if(any_changed)
			log_preferences("[parent_ckey]: Assigned new keybind data on load.")
			if(parent)
				parent.update_special_keybinds(src)
			mark_undatumized_dirty_player() // Write the new keybinds to the database.
	log_preferences("[parent_ckey]: Player preferences load result: [length(prefmap)] records.")
	return length(prefmap) ? PREFERENCE_LOAD_SUCCESS : PREFERENCE_LOAD_NO_DATA

#undef READPREF_STR
#undef READPREF_INT
#undef READPREF_JSONDEC

#define PREP_WRITEPREF_STR(value, tag) write_queries += SSdbcore.NewQuery("INSERT INTO [format_table_name("preferences")] (ckey, preference_tag, preference_value) VALUES (:ckey, :ptag, :pvalue) ON DUPLICATE KEY UPDATE preference_value=:pvalue2", list("ckey" = parent_ckey, "ptag" = tag, "pvalue" = value, "pvalue2" = value))
#define PREP_WRITEPREF_JSONENC(value, tag) PREP_WRITEPREF_STR(json_encode(value), tag)

/datum/preferences/proc/save_preferences()
	if(!SSdbcore.IsConnected())
		return FALSE
	if(!istype(parent))
		return FALSE
	if(IS_GUEST_KEY(parent.key)) // NO saving guests to the DB!
		log_preferences("[parent.ckey]: WARN - Preference save ignored due to guest key.")
		return FALSE
	// Cache their ckey because they can disconnect while datumized prefs write.
	// DO NOT RENAME THIS SHIT. it will break the defines
	var/parent_ckey = parent.ckey
	var/write_result = player_data?.write_to_database(src)
	if(write_result == PREFERENCE_LOAD_ERROR || write_result == null)
		log_preferences("[parent_ckey]: ERROR - player_data failed to save datumized player preferences.")
		if(istype(parent))
			to_chat(parent, span_boldannounce("Failed to save your datumized preferences. Please inform the server operator or a maintainer of this error."))
		return FALSE
	if(write_result == PREFERENCE_LOAD_IGNORE)
		log_preferences("[parent_ckey]: WARN - player_data save ignored.")
		return FALSE
	if(!dirty_undatumized_preferences_player) // Nothing to write. Call it a success.
		log_preferences("[parent_ckey]: Undatumized player preferences save skipped due to no changes.")
		return TRUE
	log_preferences("[parent_ckey]: Undatumized player preferences saving.")
	dirty_undatumized_preferences_player = FALSE // we edit this immediately, since the DB query sleeps, the var could be modified during the sleep.
	var/list/datum/db_query/write_queries = list() // do not rename this you muppet

	PREP_WRITEPREF_STR(default_slot, PREFERENCE_TAG_DEFAULT_SLOT)
	PREP_WRITEPREF_STR(lastchangelog, PREFERENCE_TAG_LAST_CL)

	PREP_WRITEPREF_STR(pai_name, PREFERENCE_TAG_PAI_NAME)
	PREP_WRITEPREF_STR(pai_description, PREFERENCE_TAG_PAI_DESCRIPTION)
	PREP_WRITEPREF_STR(pai_comment, PREFERENCE_TAG_PAI_COMMENT)

	PREP_WRITEPREF_JSONENC(ignoring, PREFERENCE_TAG_IGNORING)
	PREP_WRITEPREF_JSONENC(key_bindings, PREFERENCE_TAG_KEYBINDS)
	PREP_WRITEPREF_JSONENC(purchased_gear, PREFERENCE_TAG_PURCHASED_GEAR)
	PREP_WRITEPREF_JSONENC(role_preferences_global, PREFERENCE_TAG_ROLE_PREFERENCES_GLOBAL)
	PREP_WRITEPREF_JSONENC(favorite_outfits, PREFERENCE_TAG_FAVORITE_OUTFITS)

	// QuerySelect can execute many queries at once. That name is dumb but w/e
	SSdbcore.QuerySelect(write_queries, TRUE, TRUE)
	log_preferences("[parent_ckey]: Undatumized player preferences saved.")
	return TRUE

#undef PREP_WRITEPREF_STR
#undef PREP_WRITEPREF_JSONENC

#define JSONREAD_PREF(target, tag) \
	try {\
		var/idx = column_names?.Find(tag);\
		if(idx > 0) {\
			target = json_decode(values[idx]);\
		} else {\
			log_runtime("Missing preference tag '[tag]' in columns: [english_list(column_names)]");\
		};\
	} catch {\
		target = null;\
		pass();\
	} // we dont need error handling where were going

/datum/preferences/proc/load_character(slot)
	//SHOULD_NOT_SLEEP(TRUE) //Should be, but hits some db_query sleeps
	if(!istype(parent))
		return PREFERENCE_LOAD_ERROR
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		log_preferences("[parent.ckey]: Slot change applying, from [default_slot] to [slot].")
		default_slot = slot
		mark_undatumized_dirty_player()

	// Cache their ckey because they can disconnect while datumized prefs read.
	var/parent_ckey = parent.ckey

	if(character_data)
		qdel(character_data)

	character_data = new(src, slot)
	var/read_result = character_data.load_from_database(src)

	if(read_result == PREFERENCE_LOAD_ERROR || read_result == null)
		log_preferences("[parent_ckey]: ERROR - character_data failed to load datumized character preferences.")
		if(istype(parent))
			to_chat(parent, span_boldannounce("Failed to load your datumized character preferences. Please inform the server operator or a maintainer of this error."))
		return PREFERENCE_LOAD_ERROR
	if(read_result == PREFERENCE_LOAD_IGNORE)
		log_preferences("[parent_ckey]: WARN - character_data load ignored.")
		return PREFERENCE_LOAD_IGNORE
	log_preferences("[parent_ckey]: Undatumized character preferences loading.")
	// Do NOT statically cache this or I will kill you. You are asking an evil vareditor to break the DB in a BAD way
	// also DO NOT rename this
	var/list/column_names = list(
		"slot", // this is a literal column name
		CHARACTER_PREFERENCE_RANDOMIZE,
		CHARACTER_PREFERENCE_JOB_PREFERENCES,
		CHARACTER_PREFERENCE_ALL_QUIRKS,
		CHARACTER_PREFERENCE_EQUIPPED_GEAR,
		CHARACTER_PREFERENCE_ROLE_PREFERENCES,
	)

	var/datum/db_query/Q = SSdbcore.NewQuery(
		"SELECT [db_column_list(column_names)] FROM [format_table_name("characters")] WHERE ckey=:ckey AND slot=:slot",
		list("ckey" = parent_ckey, "slot" = slot)
	)

	// DON'T RENAME THIS.
	var/list/values
	if(!Q.warn_execute())
		qdel(Q)
		log_preferences("[parent_ckey]: ERROR - Undatumized character preferences load query failed.")
		return PREFERENCE_LOAD_ERROR
	if(Q.NextRow())
		values = Q.item
		if(!length(values)) // There is no character
			qdel(Q)
			log_preferences("[parent_ckey]: Undatumized character preferences load found no results in row.")
			return PREFERENCE_LOAD_NO_DATA
	else
		qdel(Q)
		log_preferences("[parent_ckey]: Undatumized character preferences load found no rows.")
		return PREFERENCE_LOAD_NO_DATA
	qdel(Q)
	if(length(values) != length(column_names))
		log_preferences("[parent_ckey]: ERROR - Undatumized character preferences load found the wrong amount of columns.")
		CRASH("Error querying character data: the returned value length is not equal to the number of columns requested.")

	// Decode
	JSONREAD_PREF(randomize, CHARACTER_PREFERENCE_RANDOMIZE)
	JSONREAD_PREF(job_preferences, CHARACTER_PREFERENCE_JOB_PREFERENCES)
	JSONREAD_PREF(all_quirks, CHARACTER_PREFERENCE_ALL_QUIRKS)
	JSONREAD_PREF(equipped_gear, CHARACTER_PREFERENCE_EQUIPPED_GEAR)
	JSONREAD_PREF(role_preferences, CHARACTER_PREFERENCE_ROLE_PREFERENCES)

	//Sanitize
	randomize = SANITIZE_LIST(randomize)
	job_preferences = SANITIZE_LIST(job_preferences)
	all_quirks = SANITIZE_LIST(all_quirks)
	equipped_gear = SANITIZE_LIST(equipped_gear)
	role_preferences = SANITIZE_LIST(role_preferences)

	var/antag_prefs_altered = FALSE

	// Validate job prefs
	for(var/j in job_preferences)
		if(job_preferences[j] != JP_LOW && job_preferences[j] != JP_MEDIUM && job_preferences[j] != JP_HIGH)
			job_preferences -= j
			log_preferences("[parent_ckey]: WARN - Cleaned up invalid job preference entry: [j]")
			mark_undatumized_dirty_character()
			antag_prefs_altered = TRUE

	// Validate role prefs
	for(var/preference in role_preferences)
		var/path = text2path(preference)
		var/datum/role_preference/entry = GLOB.role_preference_entries[path]
		if(istype(entry) && entry.per_character)
			continue
		if (length(GLOB.revdata.testmerge))
			log_preferences("[parent_ckey]: WARN - Skipped cleaning up character role preference [preference] due to testmerge.")
			continue
		role_preferences -= preference
		log_preferences("[parent_ckey]: WARN - Cleaned up invalid character role preference entry [preference].")
		mark_undatumized_dirty_character()
		antag_prefs_altered = TRUE

	// Validate equipped gear
	for(var/gear_id in equipped_gear)
		var/datum/gear/gear = GLOB.gear_datums[gear_id]
		if(!length(GLOB.gear_datums)) // error safety, don't wanna clear everyone out
			continue
		if(!istype(gear))
			equipped_gear -= gear_id
			mark_undatumized_dirty_character()
			continue
		// Somehow have a gear equipped that you don't own...
		if(islist(purchased_gear) && !(gear_id in purchased_gear))
			equipped_gear -= gear_id
			mark_undatumized_dirty_character()

	if (parent && antag_prefs_altered)
		to_chat(parent, span_userdanger("You had antagonist or job preferences set which no longer exist, your preferences may have been altered!"))

	return PREFERENCE_LOAD_SUCCESS

#undef JSONREAD_PREF

#define WRITEPREF_STR(value, tag) new_data[tag] = value;column_names += tag
#define WRITEPREF_JSONENC(value, tag) WRITEPREF_STR(json_encode(value), tag)

/datum/preferences/proc/save_character()
	if(!SSdbcore.IsConnected())
		return FALSE
	if(!istype(parent))
		return FALSE
	if(IS_GUEST_KEY(parent.key)) // NO saving guests to the DB!
		log_preferences("[parent.ckey]: WARN - Character preference save ignored due to guest key.")
		return FALSE
	// Cache their ckey because they can disconnect while datumized prefs write.
	var/parent_ckey = parent.ckey

	var/write_result = character_data?.write_to_database(src)
	if(write_result == PREFERENCE_LOAD_ERROR || write_result == null)
		log_preferences("[parent_ckey]: ERROR - character_data failed to save datumized character preferences.")
		if(istype(parent))
			to_chat(parent, span_boldannounce("Failed to save your datumized character preferences. Please inform the server operator or a maintainer of this error."))
		return FALSE
	if(write_result == PREFERENCE_LOAD_IGNORE)
		log_preferences("[parent_ckey]: WARN - character_data save ignored.")
		return FALSE

	if(!dirty_undatumized_preferences_character) // Nothing to write. Call it a success.
		log_preferences("[parent_ckey]: Undatumized character preferences save skipped due to no changes.")
		return TRUE
	log_preferences("[parent_ckey]: Undatumized character preferences saving.")
	dirty_undatumized_preferences_character = FALSE // we edit this immediately, since the DB query sleeps, the var could be modified during the sleep.

	// DO NOT RENAME THESE LISTS! THANKS!! <3
	var/list/column_names = list()
	var/list/new_data = list()

	WRITEPREF_JSONENC(randomize, CHARACTER_PREFERENCE_RANDOMIZE)
	WRITEPREF_JSONENC(job_preferences, CHARACTER_PREFERENCE_JOB_PREFERENCES)
	WRITEPREF_JSONENC(all_quirks, CHARACTER_PREFERENCE_ALL_QUIRKS)
	WRITEPREF_JSONENC(equipped_gear, CHARACTER_PREFERENCE_EQUIPPED_GEAR)
	WRITEPREF_JSONENC(role_preferences, CHARACTER_PREFERENCE_ROLE_PREFERENCES)

	new_data["ckey"] = parent_ckey
	new_data["slot"] = character_data.slot_number
	var/datum/db_query/Q = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("characters")] (ckey, slot, [db_column_list(column_names)]) VALUES (:ckey, :slot, [db_column_list(column_names, TRUE)]) ON DUPLICATE KEY UPDATE [db_column_values(column_names)]", new_data
	)
	var/success = Q.warn_execute()
	if(!success && istype(parent))
		to_chat(parent, span_boldannounce("Failed to save your undatumized character preferences. Please inform the server operator or a maintainer of this error."))
	qdel(Q)
	fail_state = success
	log_preferences("[parent_ckey]: Undatumized character preferences save status: [success ? "GOOD" : "ERROR"].")
	return success

#undef WRITEPREF_STR
#undef WRITEPREF_JSONENC

/datum/preferences_holder
	/// A map of db_key -> value. Data type varies.
	var/list/preference_data
	/// A list of preference db_keys that require writing
	var/list/dirty_prefs
	/// Preference type to parse
	var/pref_type

/datum/preferences_holder/New(datum/preferences/prefs)
	if(!pref_type)
		CRASH("Preferences holder pref_type is [pref_type]")
	preference_data = list()
	dirty_prefs = list()
	log_preferences("[prefs?.parent?.ckey]: Holder created of type [pref_type].")

/datum/preferences_holder/proc/provide_defaults(datum/preferences/prefs, should_use_informed)
	log_preferences("[prefs?.parent?.ckey]: Holder of type [pref_type] providing defaults (informed: [should_use_informed]).")
	// Uses priority order as some values may rely on others for creating default values
	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.preference_type != pref_type || (preference.informed != should_use_informed))
			continue

		if(should_use_informed)
			preference_data[preference.db_key] = preference.deserialize(preference.create_informed_default_value(prefs), prefs)
		else
			preference_data[preference.db_key] = preference.deserialize(preference.create_default_value(), prefs)

/datum/preferences_holder/proc/load_from_database(datum/preferences/prefs)
	var/result = !IS_GUEST_KEY(prefs.parent.key) ? query_data(prefs) : PREFERENCE_LOAD_IGNORE
	if(!istype(prefs.parent)) // Client was nulled during query execution
		return PREFERENCE_LOAD_ERROR
	return result

/datum/preferences_holder/proc/query_data(datum/preferences/prefs)
	SHOULD_CALL_PARENT(TRUE)
	if(!SSdbcore.IsConnected())
		return PREFERENCE_LOAD_IGNORE
	if(!istype(prefs.parent))
		return PREFERENCE_LOAD_ERROR
	return PREFERENCE_LOAD_SUCCESS

/datum/preferences_holder/proc/read_preference(datum/preferences/preferences, datum/preference/preference)
	SHOULD_NOT_SLEEP(TRUE)
	var/value = read_raw(preferences, preference)
	if (isnull(value))
		log_preferences("[preferences?.parent?.ckey]: Creating default value for [preference.type].")
		value = preference.create_informed_default_value(preferences)
		if (write_preference(preferences, preference, value))
			return value
		else
			log_preferences("[preferences?.parent?.ckey]: Failed to write default value. See runtime log.")
			CRASH("Couldn't write the default value for [preference.type] (received [value])")
	return value

/datum/preferences_holder/proc/read_raw(datum/preferences/preferences, datum/preference/preference)
	// Data is already deserialized by the time it's in the cache. Don't deserialize it again.
	var/value = preference_data[preference.db_key]
	if (isnull(value))
		return null
	else
		return value

/datum/preferences_holder/proc/write_preference(datum/preferences/preferences, datum/preference/preference, value)
	var/new_value = preference.deserialize(value, preferences)
	if (!preference.is_valid(new_value))
		log_preferences("[preferences?.parent?.ckey]: Preference value write for [preference.type] TO \"[new_value]\" ignored due to being invalid.")
		return FALSE
	preference_data[preference.db_key] = new_value
	if(!istype(preferences.parent) || IS_GUEST_KEY(preferences.parent.key)) // NO saving guests to the DB!
		return TRUE
	dirty_prefs |= preference.db_key
	SSpreferences.queue_write(preferences)
	log_preferences("[preferences?.parent?.ckey]: Preference value write for [preference.type] TO \"[value]\" created.")
	return TRUE

/datum/preferences_holder/proc/write_to_database(datum/preferences/prefs)
	. = write_data(prefs)
	dirty_prefs.Cut() // clear all dirty preferences

/datum/preferences_holder/proc/write_data(datum/preferences/prefs)
	SHOULD_CALL_PARENT(TRUE)
	if(!SSdbcore.IsConnected())
		return PREFERENCE_LOAD_IGNORE
	if(!istype(prefs.parent))
		return PREFERENCE_LOAD_ERROR
	if(IS_GUEST_KEY(prefs.parent.key))
		return PREFERENCE_LOAD_IGNORE
	return PREFERENCE_LOAD_SUCCESS
