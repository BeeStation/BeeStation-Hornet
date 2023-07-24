/datum/preference_middleware/antags
	action_delegations = list(
		"set_antags" = PROC_REF(set_antags),
	)

/datum/preference_middleware/antags/get_ui_data(mob/user)
	if (preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()
	var/list/data = list()
	var/list/enabled_antags = list()
	for(var/pref_type in GLOB.role_preference_entries)
		if(preferences.parent.role_preference_enabled(pref_type))
			enabled_antags += "[pref_type]"
	data["enabled_antags"] = enabled_antags
	return data

/datum/preference_middleware/antags/get_ui_static_data(mob/user)
	if (preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()
	var/list/data = list()
	var/list/antag_bans = get_antag_bans()
	if (antag_bans.len)
		data["antag_bans"] = antag_bans
	return data

// TODO per-character support
/datum/preference_middleware/antags/get_constant_data()
	var/list/antags = list()

	for(var/pref_type in GLOB.role_preference_entries)
		var/datum/role_preference/pref = GLOB.role_preference_entries[pref_type]
		var/datum/antagonist/antag_datum = pref.antag_datum
		antags += list(list(
			"name" = pref.name,
			"description" = pref.description,
			"category" = pref.category,
			"ban_key" = ispath(antag_datum, /datum/antagonist) ? initial(antag_datum.banning_key) : null,
			"path" = "[pref_type]",
			"icon_path" = "[serialize_antag_name("[pref.use_icon || pref_type]")]"
		))

	return list(
		"antagonists" = antags,
		"categories" = GLOB.role_preference_categories,
	)

/datum/preference_middleware/antags/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/spritesheet/antagonists),
	)

/datum/preference_middleware/antags/proc/set_antags(list/params, mob/user)
	SHOULD_NOT_SLEEP(TRUE)

	var/sent_antags = params["antags"]
	var/toggled = params["toggled"]

	var/list/valid_antags = list()
	for(var/type in GLOB.role_preference_entries)
		valid_antags += "[type]"

	var/any_changed = FALSE
	for (var/sent_antag in sent_antags)
		if(!(sent_antag in valid_antags))
			continue
		preferences.role_preferences_global["[sent_antag]"] = toggled
		any_changed = TRUE
	if(any_changed)
		preferences.mark_undatumized_dirty_player()
	return any_changed

/datum/preference_middleware/antags/proc/get_antag_bans()
	var/list/antag_bans = list()
	for(var/type in GLOB.role_preference_entries)
		var/datum/role_preference/pref = GLOB.role_preference_entries[type]
		var/datum/antagonist/antag_datum = pref.antag_datum
		var/role_ban_key = initial(antag_datum.banning_key)
		if(role_ban_key && is_banned_from(preferences.parent.ckey, role_ban_key))
			antag_bans += role_ban_key
	return antag_bans

/// Sprites generated for the antagonists panel
/datum/asset/spritesheet/antagonists
	name = "antagonists"
	early = TRUE
	cross_round_cachable = TRUE

/datum/asset/spritesheet/antagonists/create_spritesheets()
	var/list/generated_icons = list()
	var/list/to_insert = list()

	for(var/pref_type in GLOB.role_preference_entries)
		var/datum/role_preference/pref = GLOB.role_preference_entries[pref_type]
		if(ispath(pref.use_icon, /datum/role_preference))
			pref_type = pref.use_icon
			var/datum/role_preference/other_pref = GLOB.role_preference_entries[pref.use_icon]
			if(istype(other_pref))
				pref = other_pref

		// antag_flag is guaranteed to be unique by unit tests.
		var/spritesheet_key = serialize_antag_name("[pref_type]")

		if (!isnull(generated_icons["[pref_type]"]))
			to_insert[spritesheet_key] = generated_icons["[pref_type]"]
			continue

		var/icon/preview_icon = pref.get_preview_icon()

		if (isnull(preview_icon))
			continue

		// preview_icons are not scaled at this stage INTENTIONALLY.
		// If an icon is not prepared to be scaled to that size, it looks really ugly, and this
		// makes it harder to figure out what size it *actually* is.
		generated_icons["[pref_type]"] = preview_icon
		to_insert[spritesheet_key] = preview_icon

	for (var/spritesheet_key in to_insert)
		Insert(spritesheet_key, to_insert[spritesheet_key])

/// Serializes an antag name to be used for preferences UI
/proc/serialize_antag_name(antag_name)
	// These are sent through CSS, so they need to be safe to use as class names.
	return lowertext(sanitize_css_class_name(replacetext(antag_name, "/", "_")))
