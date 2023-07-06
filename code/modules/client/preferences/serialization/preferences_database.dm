/datum/preferences/var/dirty_undatumized_preferences_player = FALSE
/datum/preferences/var/dirty_undatumized_preferences_character = FALSE

/// Marks undatumized preferences as dirty, so it will be serialized on the next preference write.
/// Queues a preference write.
/// Use this for player preferences only.
/datum/preferences/proc/mark_undatumized_dirty_player()
	if(IS_GUEST_KEY(parent.key)) // NO saving guests to the DB!
		return FALSE
	dirty_undatumized_preferences_player = TRUE
	SSpreferences.queue_write(src)

/// Marks undatumized preferences as dirty, so it will be serialized on the next preference write.
/// Queues a preference write.
/// Use this for character preferences only.
/datum/preferences/proc/mark_undatumized_dirty_character()
	if(IS_GUEST_KEY(parent.key)) // NO saving guests to the DB!
		return FALSE
	dirty_undatumized_preferences_character = TRUE
	SSpreferences.queue_write(src)

/// If any character preference is dirty.
/datum/preferences/proc/ready_to_save_character()
	return dirty_undatumized_preferences_character || length(character_data.dirty_prefs)

/// If any player preference is dirty.
/datum/preferences/proc/ready_to_save_player()
	return dirty_undatumized_preferences_player || length(player_data.dirty_prefs)

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
	// Get the datumized stuff first
	player_data = new(src)
	if(!player_data.load_from_database(src)) // checks db connection
		return FALSE

	var/datum/DBQuery/read_player_data = SSdbcore.NewQuery(
		"SELECT CAST(preference_tag AS CHAR) AS ptag, preference_value FROM [format_table_name("preferences")] WHERE ckey=:ckey",
		list("ckey" = parent.ckey)
	)

	// K:pref tag | V:pref value
	// DO NOT RENAME THIS. SERIOUSLY. DO NOT RENAME THIS LIST. IT'S USED IN THE READPREF DEFINES.
	var/list/prefmap = list()

	if(!read_player_data.Execute())
		qdel(read_player_data)
		return FALSE
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
	READPREF_JSONDEC(be_special, PREFERENCE_TAG_BE_SPECIAL)

	// Custom hotkeys
	READPREF_JSONDEC(key_bindings, PREFERENCE_TAG_KEYBINDS)

	//Sanitize
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	default_slot	= sanitize_integer(default_slot, 1, TRUE_MAX_SAVE_SLOTS, initial(default_slot))
	ignoring		= SANITIZE_LIST(ignoring)
	purchased_gear	= SANITIZE_LIST(purchased_gear)
	be_special		= SANITIZE_LIST(be_special)

	pai_name		= sanitize_text(pai_name, initial(pai_name))
	pai_description	= sanitize_text(pai_description, initial(pai_description))
	pai_comment		= sanitize_text(pai_comment, initial(pai_comment))

	key_bindings 	= sanitize_islist(key_bindings, deep_copy_list(GLOB.keybindings_by_name_to_key))
	key_bindings_by_key = get_key_bindings_by_key(key_bindings)
	if (!length(key_bindings))
		set_default_key_bindings(save = TRUE)
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
			mark_undatumized_dirty_player() // Write the new keybinds to the database.
	apply_all_client_preferences()
	return TRUE

#undef READPREF_STR
#undef READPREF_INT
#undef READPREF_JSONDEC

#define PREP_WRITEPREF_STR(value, tag) write_queries += SSdbcore.NewQuery("INSERT INTO [format_table_name("preferences")] (ckey, preference_tag, preference_value) VALUES (:ckey, :ptag, :pvalue) ON DUPLICATE KEY UPDATE preference_value=:pvalue2", list("ckey" = parent.ckey, "ptag" = tag, "pvalue" = value, "pvalue2" = value))
#define PREP_WRITEPREF_JSONENC(value, tag) PREP_WRITEPREF_STR(json_encode(value), tag)

/datum/preferences/proc/save_preferences()
	if(!SSdbcore.IsConnected())
		return FALSE
	if(IS_GUEST_KEY(parent.key)) // NO saving guests to the DB!
		return FALSE
	if(!player_data?.write_to_database(src))
		return FALSE
	if(!dirty_undatumized_preferences_player) // Nothing to write. Call it a success.
		return TRUE
	dirty_undatumized_preferences_player = FALSE // we edit this immediately, since the DB query sleeps, the var could be modified during the sleep.
	to_chat(parent, "<span class='notice'>Writing player undatumized</span>") // debug tgui-prefs
	var/list/datum/DBQuery/write_queries = list() // do not rename this you muppet

	PREP_WRITEPREF_STR(default_slot, PREFERENCE_TAG_DEFAULT_SLOT)
	PREP_WRITEPREF_STR(lastchangelog, PREFERENCE_TAG_LAST_CL)

	PREP_WRITEPREF_STR(pai_name, PREFERENCE_TAG_PAI_NAME)
	PREP_WRITEPREF_STR(pai_description, PREFERENCE_TAG_PAI_DESCRIPTION)
	PREP_WRITEPREF_STR(pai_comment, PREFERENCE_TAG_PAI_COMMENT)

	PREP_WRITEPREF_JSONENC(ignoring, PREFERENCE_TAG_IGNORING)
	PREP_WRITEPREF_JSONENC(key_bindings, PREFERENCE_TAG_KEYBINDS)
	PREP_WRITEPREF_JSONENC(purchased_gear, PREFERENCE_TAG_PURCHASED_GEAR)
	PREP_WRITEPREF_JSONENC(be_special, PREFERENCE_TAG_BE_SPECIAL)

	// QuerySelect can execute many queries at once. That name is dumb but w/e
	SSdbcore.QuerySelect(write_queries, TRUE, TRUE)
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
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		mark_undatumized_dirty_player()

	character_data = new(src, slot)
	if(!character_data.load_from_database(src)) // checks db connection
		return FALSE

	// Do NOT statically cache this or I will kill you. You are asking an evil vareditor to break the DB in a BAD way
	// also DO NOT rename this
	var/list/column_names = list(
		"slot", // this is a literal column name
		CHARACTER_PREFERENCE_RANDOMISE,
		CHARACTER_PREFERENCE_JOB_PREFERENCES,
		CHARACTER_PREFERENCE_ALL_QUIRKS,
		CHARACTER_PREFERENCE_EQUIPPED_GEAR,
	)

	var/datum/DBQuery/Q = SSdbcore.NewQuery(
		"SELECT [db_column_list(column_names)] FROM [format_table_name("characters")] WHERE ckey=:ckey AND slot=:slot",
		list("ckey" = parent.ckey, "slot" = slot)
	)

	// DON'T RENAME THIS.
	var/list/values
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

	// Decode
	JSONREAD_PREF(randomise, CHARACTER_PREFERENCE_RANDOMISE)
	JSONREAD_PREF(job_preferences, CHARACTER_PREFERENCE_JOB_PREFERENCES)
	JSONREAD_PREF(all_quirks, CHARACTER_PREFERENCE_ALL_QUIRKS)
	JSONREAD_PREF(equipped_gear, CHARACTER_PREFERENCE_EQUIPPED_GEAR)

	//Sanitize
	randomise = SANITIZE_LIST(randomise)
	job_preferences = SANITIZE_LIST(job_preferences)
	all_quirks = SANITIZE_LIST(all_quirks)
	equipped_gear = SANITIZE_LIST(equipped_gear)

	//Validate job prefs
	for(var/j in job_preferences)
		if(job_preferences[j] != JP_LOW && job_preferences[j] != JP_MEDIUM && job_preferences[j] != JP_HIGH)
			job_preferences -= j
			mark_undatumized_dirty_character()
	return TRUE

#undef JSONREAD_PREF

#define WRITEPREF_STR(value, tag) new_data[tag] = value;column_names += tag
#define WRITEPREF_JSONENC(value, tag) WRITEPREF_STR(json_encode(value), tag)

/datum/preferences/proc/save_character()
	if(!SSdbcore.IsConnected())
		return FALSE
	if(IS_GUEST_KEY(parent.key)) // NO saving guests to the DB!
		return FALSE
	if(!character_data?.write_to_database(src))
		return FALSE
	if(!dirty_undatumized_preferences_character) // Nothing to write. Call it a success.
		return TRUE
	dirty_undatumized_preferences_character = FALSE // we edit this immediately, since the DB query sleeps, the var could be modified during the sleep.
	to_chat(parent, "<span class='notice'>Writing character undatumized</span>") // debug tgui-prefs

	// DO NOT RENAME THESE LISTS! THANKS!! <3
	var/list/column_names = list()
	var/list/new_data = list()

	WRITEPREF_JSONENC(randomise, CHARACTER_PREFERENCE_RANDOMISE)
	WRITEPREF_JSONENC(job_preferences, CHARACTER_PREFERENCE_JOB_PREFERENCES)
	WRITEPREF_JSONENC(all_quirks, CHARACTER_PREFERENCE_ALL_QUIRKS)
	WRITEPREF_JSONENC(equipped_gear, CHARACTER_PREFERENCE_EQUIPPED_GEAR)

	new_data["ckey"] = parent.ckey
	new_data["slot"] = character_data.slot_number
	var/datum/DBQuery/Q = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("characters")] (ckey, slot, [db_column_list(column_names)]) VALUES (:ckey, :slot, [db_column_list(column_names, TRUE)]) ON DUPLICATE KEY UPDATE [db_column_values(column_names)]", new_data
	)
	var/success = Q.warn_execute()
	if(!success)
		to_chat(parent, "<span class='boldannounce'>Failed to save your character. Please inform the server operator or a maintainer of this error.</span>")
	qdel(Q)
	fail_state = success
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
	preference_data = list()
	dirty_prefs = list()
	// Read everything into cache
	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if (preference.preference_type != pref_type || preference.informed)
			continue

		// we can't use informed values here. The name will get populated manually
		preference_data[preference.db_key] = preference.deserialize(preference.create_default_value(), prefs)

/datum/preferences_holder/proc/read_preference(datum/preferences/preferences, datum/preference/preference)
	SHOULD_NOT_SLEEP(TRUE)
	var/value = read_raw(preferences, preference)
	if (isnull(value))
		value = preference.create_informed_default_value(preferences)
		if (write_preference(preferences, preference, value))
			return value
		else
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
		return FALSE
	preference_data[preference.db_key] = new_value
	if(IS_GUEST_KEY(preferences.parent.key)) // NO saving guests to the DB!
		return TRUE
	dirty_prefs |= preference.db_key
	SSpreferences.queue_write(preferences)
	return TRUE
