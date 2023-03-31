/datum/preferences/proc/load_preferences()
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
	key_bindings_by_key = get_key_bindings_by_key(key_bindings) */
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

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if (preference.preference_type != PREFERENCE_PLAYER)
			continue

		if (!(preference.type in recently_updated_keys))
			continue

		recently_updated_keys -= preference.type

		if (preference_type in value_cache)
			write_preference(preference, preference.serialize(value_cache[preference_type]))

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
	SHOULD_NOT_SLEEP(TRUE)
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot

	// Read everything into cache
	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if (preference.preference_type != PREFERENCE_CHARACTER)
			continue

		value_cache -= preference_type
		read_preference(preference_type)

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
	SHOULD_NOT_SLEEP(TRUE)

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.preference_type != PREFERENCE_CHARACTER)
			continue

		if (!(preference.type in recently_updated_keys))
			continue

		recently_updated_keys -= preference.type

		if (preference.type in value_cache)
			write_preference(preference, preference.serialize(value_cache[preference.type]))

/* 	//Character
	save_data["randomise"] = randomise

	//Write prefs
	save_data["job_preferences"] = job_preferences

	//Quirks
	save_data["all_quirks"] = all_quirks */

	return TRUE
