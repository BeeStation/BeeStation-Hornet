/datum/preference_middleware/antags
	action_delegations = list(
		"set_antags" = PROC_REF(set_antags),
	)

/datum/preference_middleware/antags/get_ui_data(mob/user)
	if (preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()
	var/list/data = list()
	var/list/enabled_global = list()
	var/list/enabled_character = list()
	for(var/datum/role_preference/pref_type as anything in GLOB.role_preference_entries)
		var/role_preference_value = preferences.role_preferences_global["[pref_type]"]
		if(isnum(role_preference_value) && !role_preference_value) // explicitly disabled
			continue
		enabled_global += "[pref_type]"

	for(var/datum/role_preference/pref_type as anything in GLOB.role_preference_entries)
		if(!initial(pref_type.per_character))
			continue
		var/role_preference_value = preferences.role_preferences["[pref_type]"]
		if(isnum(role_preference_value) && !role_preference_value) // explicitly disabled
			continue
		enabled_character += "[pref_type]"
	data["enabled_global"] = enabled_global
	data["enabled_character"] = enabled_character
	return data

/datum/preference_middleware/antags/get_ui_static_data(mob/user)
	if (preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()
	var/list/data = list()
	var/list/antag_bans = get_antag_bans()
	if (length(antag_bans))
		data["antag_bans"] = antag_bans
	var/list/antag_living_playtime_hours_left = get_antag_living_playtime_hours_left()
	if (length(antag_living_playtime_hours_left))
		data["antag_living_playtime_hours_left"] = antag_living_playtime_hours_left
	return data

/datum/preference_middleware/antags/get_constant_data()
	var/list/antags = list()

	for(var/pref_type in GLOB.role_preference_entries)
		var/datum/role_preference/pref = GLOB.role_preference_entries[pref_type]
		var/datum/antagonist/antag_datum = pref.antag_datum
		antags += list(list(
			"name" = pref.name,
			"description" = pref.description,
			"category" = pref.category,
			"per_character" = pref.per_character,
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
	var/per_character = params["character"]

	var/list/valid_antags = list()
	for(var/datum/role_preference/type as anything in GLOB.role_preference_entries)
		if(per_character && !initial(type.per_character))
			continue
		valid_antags += "[type]"

	var/any_changed = FALSE
	for (var/sent_antag in sent_antags)
		if(!(sent_antag in valid_antags))
			log_preferences("[preferences?.parent?.ckey]: WARN - Filtered role preference edit for [sent_antag] to [toggled] due to being invalid.")
			continue
		if(per_character)
			log_preferences("[preferences?.parent?.ckey]: Set per-character role preference for [sent_antag] to [toggled].")
			preferences.role_preferences["[sent_antag]"] = toggled
		else
			log_preferences("[preferences?.parent?.ckey]: Set global role preference for [sent_antag] to [toggled].")
			preferences.role_preferences_global["[sent_antag]"] = toggled
		any_changed = TRUE
	if(any_changed)
		if(per_character)
			preferences.mark_undatumized_dirty_character()
		else
			preferences.mark_undatumized_dirty_player()
	return any_changed

/datum/preference_middleware/antags/proc/get_antag_bans()
	if(!preferences.parent)
		return list()
	var/list/antag_bans = list()
	for(var/type in GLOB.role_preference_entries)
		var/datum/role_preference/pref = GLOB.role_preference_entries[type]
		var/datum/antagonist/antag_datum = pref.antag_datum
		if(!ispath(antag_datum, /datum/antagonist))
			continue
		var/role_ban_key = initial(antag_datum.banning_key)
		if(role_ban_key && is_banned_from(preferences.parent.ckey, role_ban_key))
			antag_bans += role_ban_key
	return antag_bans

/datum/preference_middleware/antags/proc/get_antag_living_playtime_hours_left()
	if(!preferences.parent || preferences.parent.holder)
		return list()
	if(CONFIG_GET(flag/use_exp_restrictions_admin_bypass) && check_rights_for(preferences.parent, R_ADMIN))
		return list()
	var/list/antag_living_playtime_hours_left = list()

	for(var/type in GLOB.role_preference_entries)
		var/datum/role_preference/pref = GLOB.role_preference_entries[type]
		var/datum/antagonist/antag_datum = pref.antag_datum
		if(!ispath(antag_datum, /datum/antagonist))
			continue
		var/living_hours_needed = initial(antag_datum.required_living_playtime)
		if (living_hours_needed <= 0)
			continue
		var/hours_left = max(0, living_hours_needed - (preferences.parent.get_exp_living(TRUE) / 60))
		if(hours_left > 0)
			antag_living_playtime_hours_left["[type]"] = hours_left

	return antag_living_playtime_hours_left

/// Sprites generated for the antagonists panel
/datum/asset/spritesheet/antagonists
	name = "antagonists"
	early = TRUE

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
	return LOWER_TEXT(sanitize_css_class_name(replacetext(antag_name, "/", "_")))
