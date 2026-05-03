/// Middleware to handle quirks

/datum/preference_middleware/quirks
	var/tainted = FALSE

	action_delegations = list(
		"give_quirk" = PROC_REF(give_quirk),
		"remove_quirk" = PROC_REF(remove_quirk),
	)

/datum/preference_middleware/quirks/get_ui_static_data(mob/user)
	if (preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()

	var/list/data = list()

	data["selected_quirks"] = get_selected_quirks()

	return data

/datum/preference_middleware/quirks/get_ui_data(mob/user)
	var/list/data = list()

	if (tainted)
		tainted = FALSE
		data["selected_quirks"] = get_selected_quirks()

	return data

/datum/preference_middleware/quirks/get_constant_data()
	var/list/quirk_info = list()

	var/list/quirks = SSquirks.get_quirks()

	for (var/quirk_name in quirks)
		var/datum/quirk/quirk = quirks[quirk_name]
		if(!ispath(quirk))
			CRASH("Error: invalid quirk value in quirks for quirk_name [quirk_name]: [quirk]")
		quirk_info[sanitize_css_class_name(quirk_name)] = list(
			"description" = initial(quirk.desc),
			"icon" = initial(quirk.icon),
			"name" = quirk_name,
			"value" = initial(quirk.quirk_value),
			"path" = quirk,
			"species_whitelist" = initial(quirk.species_whitelist),
			"restricted_species" = get_quirk_species_ids(quirk),
		)

	return list(
		"max_positive_quirks" = MAX_POSITIVE_QUIRKS,
		"quirk_info" = quirk_info,
		"quirk_blacklist" = SSquirks.quirk_blacklist,
	)

/datum/preference_middleware/quirks/on_new_character(mob/user)
	tainted = TRUE

/datum/preference_middleware/quirks/proc/give_quirk(list/params, mob/user)
	var/quirk_name = params["quirk"]

	var/list/all_quirks = SSquirks.get_quirks()
	var/datum/quirk/quirk = all_quirks[quirk_name]
	if (!isnull(quirk) && !is_quirk_valid_for_species(quirk, preferences.read_character_preference(/datum/preference/choiced/species)))
		preferences.update_static_data(user)
		return TRUE

	var/list/new_quirks = preferences.all_quirks | quirk_name
	if (SSquirks.filter_invalid_quirks(new_quirks) != new_quirks)
		// If the client is sending an invalid give_quirk, that means that
		// something went wrong with the client prediction, so we should
		// catch it back up to speed.
		preferences.update_static_data(user)
		return TRUE

	preferences.all_quirks = new_quirks
	preferences.mark_undatumized_dirty_character()
	return TRUE

/datum/preference_middleware/quirks/proc/remove_quirk(list/params, mob/user)
	var/quirk_name = params["quirk"]

	var/list/new_quirks = preferences.all_quirks - quirk_name
	if ( \
		!(quirk_name in preferences.all_quirks) \
		|| SSquirks.filter_invalid_quirks(new_quirks) != new_quirks \
	)
		// If the client is sending an invalid remove_quirk, that means that
		// something went wrong with the client prediction, so we should
		// catch it back up to speed.
		preferences.update_static_data(user)
		return TRUE

	preferences.all_quirks = new_quirks
	preferences.mark_undatumized_dirty_character()
	return TRUE

/datum/preference_middleware/quirks/proc/get_selected_quirks()
	var/list/selected_quirks = list()

	for (var/quirk in preferences.all_quirks)
		selected_quirks += sanitize_css_class_name(quirk)

	return selected_quirks

/datum/preference_middleware/quirks/proc/is_quirk_valid_for_species(datum/quirk/quirk, species_type)
	var/restricted_id = initial(quirk.pref_restricted_species_id)
	if (!restricted_id)
		return TRUE
	var/whitelist = initial(quirk.species_whitelist)
	var/datum/species/species_instance = GLOB.species_prototypes[species_type]
	if (!species_instance)
		return TRUE
	var/is_match = (species_instance.id == restricted_id)
	return whitelist ? is_match : !is_match

/datum/preference_middleware/quirks/proc/get_quirk_species_ids(datum/quirk/quirk)
	var/restricted_id = initial(quirk.pref_restricted_species_id)
	if (!restricted_id)
		return null
	return list(restricted_id)
q
