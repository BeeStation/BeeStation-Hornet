/datum/preferences/proc/load_preferences()
	player_data = new(src)
	player_data.load_from_database(src)
	apply_all_client_preferences()


	/* //general preferences
	lastchangelog = savefile.get_entry("lastchangelog", lastchangelog)
	be_special = savefile.get_entry("be_special", be_special)
	default_slot = savefile.get_entry("default_slot", default_slot)
	chat_toggles = savefile.get_entry("chat_toggles", chat_toggles)
	toggles = savefile.get_entry("toggles", toggles)
	ignoring = savefile.get_entry("ignoring", ignoring)

	// OOC commendations
	hearted_until = savefile.get_entry("hearted_until", hearted_until)
	if(hearted_until > world.realtime)
		hearted = TRUE
	//favorite outfits
	favorite_outfits = savefile.get_entry("favorite_outfits", favorite_outfits)

	var/list/parsed_favs = list()
	for(var/typetext in favorite_outfits)
		var/datum/outfit/path = text2path(typetext)
		if(ispath(path)) //whatever typepath fails this check probably doesn't exist anymore
			parsed_favs += path
	favorite_outfits = unique_list(parsed_favs)

	// Custom hotkeys
	key_bindings = savefile.get_entry("key_bindings", key_bindings)
 */
/*
	check_keybindings() // this apparently fails every time and overwrites any unloaded prefs with the default values, so don't load anything after this line or it won't actually save
*/
/*
	//Sanitize
	lastchangelog = sanitize_text(lastchangelog, initial(lastchangelog))
	default_slot = sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	toggles = sanitize_integer(toggles, 0, (2**24)-1, initial(toggles))
	be_special = sanitize_be_special(SANITIZE_LIST(be_special))
	key_bindings = sanitize_keybindings(key_bindings)
	favorite_outfits = SANITIZE_LIST(favorite_outfits)
 */

	return TRUE

/datum/preferences/proc/save_preferences()
	player_data.write_to_database(src)
	/*for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if (preference.preference_type != PREFERENCE_PLAYER)
			continue

		if (!(preference.type in recently_updated_keys))
			continue

		recently_updated_keys -= preference.type

		if (preference_type in player_preference_cache)
			write_preference(preference, preference.serialize(player_preference_cache[preference.db_key]))*/

/* 	savefile.set_entry("lastchangelog", lastchangelog)
	savefile.set_entry("be_special", be_special)
	savefile.set_entry("default_slot", default_slot)
	savefile.set_entry("toggles", toggles)
	savefile.set_entry("chat_toggles", chat_toggles)
	savefile.set_entry("ignoring", ignoring)
	savefile.set_entry("key_bindings", key_bindings)
	savefile.set_entry("hearted_until", (hearted_until > world.realtime ? hearted_until : null))
	savefile.set_entry("favorite_outfits", favorite_outfits)
	savefile.save() */
	return TRUE

/datum/preferences/proc/load_character(slot)
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot

	character_data = new(src, slot)
	character_data.load_from_database(src)

/* 	//Character
	randomise = save_data?["randomise"]

	//Load prefs
	job_preferences = save_data?["job_preferences"]

	//Quirks
	all_quirks = save_data?["all_quirks"]

	//try to fix any outdated data if necessary
	//preference updating will handle saving the updated data for us.
	if(needs_update >= 0)
		update_character(needs_update, save_data) //needs_update == savefile_version if we need an update (positive integer)

	//Sanitize
	randomise = SANITIZE_LIST(randomise)
	job_preferences = SANITIZE_LIST(job_preferences)
	all_quirks = SANITIZE_LIST(all_quirks) */

	//Validate job prefs
/* 	for(var/j in job_preferences)
		if(job_preferences[j] != JP_LOW && job_preferences[j] != JP_MEDIUM && job_preferences[j] != JP_HIGH)
			job_preferences -= j

	all_quirks = SSquirks.filter_invalid_quirks(SANITIZE_LIST(all_quirks))
	validate_quirks() */

	return TRUE

/datum/preferences/proc/save_character()
	character_data.write_to_database(src)

	/*for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.preference_type != PREFERENCE_CHARACTER)
			continue

		if (!(preference.type in recently_updated_keys))
			continue

		recently_updated_keys -= preference.type

		if (preference.type in player_preference_cache)
			write_preference(preference, preference.serialize(player_preference_cache[preference.type]))*/

/* 	//Character
	save_data["randomise"] = randomise

	//Write prefs
	save_data["job_preferences"] = job_preferences

	//Quirks
	save_data["all_quirks"] = all_quirks */

	return TRUE

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
	dirty_prefs |= preference.db_key
	return TRUE
