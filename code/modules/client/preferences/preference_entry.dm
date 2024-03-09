// Priorities must be in order!
/// The default priority level
#define PREFERENCE_PRIORITY_DEFAULT 1

/// The priority at which species runs, needed for external organs to apply properly.
#define PREFERENCE_PRIORITY_SPECIES 2

/// The priority at which gender is determined, needed for proper randomization.
#define PREFERENCE_PRIORITY_GENDER 3

/// The priority at which body model is decided, applied after gender so we can
/// make sure they're non-binary.
#define PREFERENCE_PRIORITY_BODY_MODEL 4

/// The priority at which eye color is applied, needed so IPCs get the right screen color.
#define PREFERENCE_PRIORITY_EYE_COLOR 5

/// The priority at which hair color is applied, needed so IPCs get the right antenna color.
#define PREFERENCE_PRIORITY_HAIR_COLOR 6

/// The priority at which names are decided, needed for proper randomization.
#define PREFERENCE_PRIORITY_NAMES 7

/// The maximum preference priority, keep this updated, but don't use it for `priority`.
#define MAX_PREFERENCE_PRIORITY PREFERENCE_PRIORITY_NAMES

/// For choiced preferences, this key will be used to set display names in constant data.
#define CHOICED_PREFERENCE_DISPLAY_NAMES "display_names"

/// For main feature preferences, this key refers to a feature considered supplemental.
/// For instance, hair color being supplemental to hair.
#define SUPPLEMENTAL_FEATURE_KEY "supplemental_feature"

/// An assoc list list of types to instantiated `/datum/preference` instances
GLOBAL_LIST_INIT(preference_entries, init_preference_entries())

/// An assoc list of preference entries by their `db_key`
GLOBAL_LIST_INIT(preference_entries_by_key, init_preference_entries_by_key())

/proc/init_preference_entries()
	var/list/output = list()
	for (var/datum/preference/preference_type as anything in subtypesof(/datum/preference))
		if (initial(preference_type.abstract_type) == preference_type)
			continue
		output[preference_type] = new preference_type
	return output

/proc/init_preference_entries_by_key()
	var/list/output = list()
	for (var/datum/preference/preference_type as anything in subtypesof(/datum/preference))
		if (initial(preference_type.abstract_type) == preference_type)
			continue
		output[initial(preference_type.db_key)] = GLOB.preference_entries[preference_type]
	return output

/// Returns a flat list of preferences in order of their priority
/proc/get_preferences_in_priority_order()
	var/list/preferences[MAX_PREFERENCE_PRIORITY]

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		LAZYADD(preferences[preference.priority], preference)

	var/list/flattened = list()
	for (var/index in 1 to MAX_PREFERENCE_PRIORITY)
		flattened += preferences[index]
	return flattened

/// Represents an individual preference.
/datum/preference
	/// The key inside the database to use.
	/// This is also sent to the UI.
	/// Once you pick this, don't change it.
	var/db_key

	/// The category of preference, for use by the PreferencesMenu.
	/// This isn't used for anything other than as a key for UI data.
	/// It is up to the PreferencesMenu UI itself to interpret it.
	var/category = "misc"

	/// Do not instantiate if type matches this.
	var/abstract_type = /datum/preference

	/// What location should this preference be read from?
	/// Valid values are PREFERENCE_CHARACTER and PREFERENCE_PLAYER.
	/// See the documentation in [code/__DEFINES/preferences.dm].
	var/preference_type

	/// The priority of when to apply this preference.
	/// Used for when you need to rely on another preference.
	var/priority = PREFERENCE_PRIORITY_DEFAULT

	/// If set, will be available to randomize, but only if the preference
	/// is for PREFERENCE_CHARACTER.
	var/can_randomize = TRUE

	/// If randomizable (PREFERENCE_CHARACTER and can_randomize), whether
	/// or not to enable randomization by default.
	/// This doesn't mean it'll always be random, but rather if a player
	/// DOES have random body on, will this already be randomized?
	var/randomize_by_default = TRUE

	/// If the selected species has this in its /datum/species/mutant_bodyparts,
	/// will show the feature as selectable.
	var/relevant_mutant_bodypart = null

	/// If the selected species has this in its /datum/species/species_traits,
	/// will show the feature as selectable.
	var/relevant_species_trait = null

	/// If this requires create_informed_default_value
	var/informed = FALSE

	/// Disables database writes. This can be useful for a testmerged preference
	var/disable_serialization = FALSE

/// Called on the saved input when retrieving.
/// Also called by the value sent from the user through UI. Do not trust it.
/// Input is the value inside the database, output is to tell other code
/// what the value is.
/// This is useful either for more optimal data saving or for migrating
/// older data.
/// Must be overridden by subtypes.
/// Can return null if no value was found.
/datum/preference/proc/deserialize(input, datum/preferences/preferences)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("`deserialize()` was not implemented on [type]!")

/// Called on the input while saving.
/// Input is the current value, output is what to save in the database.
/// For PREFERENCE_PLAYER, this will be to a string, for PREFERENCE_CHARACTER, it varies
/datum/preference/proc/serialize(input)
	SHOULD_NOT_SLEEP(TRUE)
	return input

/// Produce a default, potentially random value for when no value for this
/// preference is found in the database.
/// Either this or create_informed_default_value must be overriden by subtypes.
/// For PREFERENCE_PLAYER, this will be from a string, for PREFERENCE_CHARACTER, it varies
/datum/preference/proc/create_default_value()
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("`create_default_value()` was not implemented on [type]!")

/// Produce a default, potentially random value for when no value for this
/// preference is found in the database.
/// Unlike create_default_value(), will provide the preferences object if you
/// need to use it.
/// If not overriden, will call create_default_value() instead.
/datum/preference/proc/create_informed_default_value(datum/preferences/preferences)
	return create_default_value()

/// Produce a random value for the purposes of character randomization.
/// Will just create a default value by default.
/datum/preference/proc/create_random_value(datum/preferences/preferences)
	return create_informed_default_value(preferences)

/// Returns whether or not a preference can be randomized.
/datum/preference/proc/is_randomizable()
	SHOULD_NOT_OVERRIDE(TRUE)
	return preference_type == PREFERENCE_CHARACTER && can_randomize

/// Apply this preference onto the given client.
/// Called when the preference_type == PREFERENCE_PLAYER.
/datum/preference/proc/apply_to_client(client/client, value)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	return

/// Fired when the preference is updated.
/// Calls apply_to_client by default, but can be overridden.
/datum/preference/proc/apply_to_client_updated(client/client, value)
	SHOULD_NOT_SLEEP(TRUE)
	apply_to_client(client, value)

/// Apply this preference onto the given human.
/// Must be overriden by subtypes.
/// Called when the preference_type == PREFERENCE_CHARACTER.
/datum/preference/proc/apply_to_human(mob/living/carbon/human/target, value)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("`apply_to_human()` was not implemented for [type]!")

/datum/preferences/proc/get_preference_holder(datum/preference/preference_entry)
	RETURN_TYPE(/datum/preferences_holder)
	switch(preference_entry.preference_type)
		if(PREFERENCE_CHARACTER)
			return character_data
		if(PREFERENCE_PLAYER)
			return player_data
	return null

/// Read a /datum/preference type and return its value, only using cached values and queueing any necessary writes.
/datum/preferences/proc/read_preference(preference_typepath)
	var/datum/preference/preference_entry = GLOB.preference_entries[preference_typepath]
	if (isnull(preference_entry))
		var/extra_info = ""

		// Current initializing subsystem is important to know because it might be a problem with
		// things running pre-assets-initialization.
		if (!isnull(Master.current_initializing_subsystem))
			extra_info = "Info was attempted to be retrieved while [Master.current_initializing_subsystem] was initializing."

		CRASH("Preference type `[preference_typepath]` is invalid! [extra_info]")
	return get_preference_holder(preference_entry).read_preference(src, preference_entry)

/// Read a /datum/preference type and return its value, only using cached values and queueing any necessary writes.
/// Only works for player preferences.
/datum/preferences/proc/read_player_preference(preference_typepath)
	var/datum/preference/preference_entry = GLOB.preference_entries[preference_typepath]
	if (isnull(preference_entry))
		var/extra_info = ""

		// Current initializing subsystem is important to know because it might be a problem with
		// things running pre-assets-initialization.
		if (!isnull(Master.current_initializing_subsystem))
			extra_info = "Info was attempted to be retrieved while [Master.current_initializing_subsystem] was initializing."

		CRASH("Preference type `[preference_typepath]` is invalid! [extra_info]")

	if (preference_entry.preference_type != PREFERENCE_PLAYER)
		CRASH("read_player_preference called on [preference_entry.preference_type] type preference [preference_typepath].")

	return player_data.read_preference(src, preference_entry)

/// Read a /datum/preference type and return its value, only using cached values and queueing any necessary writes.
/// Only works for character preferences.
/datum/preferences/proc/read_character_preference(preference_typepath)
	var/datum/preference/preference_entry = GLOB.preference_entries[preference_typepath]
	if (isnull(preference_entry))
		var/extra_info = ""

		// Current initializing subsystem is important to know because it might be a problem with
		// things running pre-assets-initialization.
		if (!isnull(Master.current_initializing_subsystem))
			extra_info = "Info was attempted to be retrieved while [Master.current_initializing_subsystem] was initializing."

		CRASH("Preference type `[preference_typepath]` is invalid! [extra_info]")

	if (preference_entry.preference_type != PREFERENCE_CHARACTER)
		CRASH("read_character_preference called on [preference_entry.preference_type] type preference [preference_typepath].")
	return character_data.read_preference(src, preference_entry)

/// Set a /datum/preference entry.
/// Returns TRUE for a successful preference application.
/// Returns FALSE if it is invalid.
/datum/preferences/proc/write_preference(datum/preference/preference, preference_value)
	return get_preference_holder(preference).write_preference(src, preference, preference_value)

/// Will perform a write on the preference and update the relevant locations.
/// This will, for instance, update the character preference view.
/// Performs sanity checks.
/datum/preferences/proc/update_preference(preference_or_typepath, preference_value, in_menu = FALSE)
	var/datum/preference/preference
	if (ispath(preference_or_typepath, /datum/preference))
		preference = GLOB.preference_entries[preference_or_typepath]
	else if (istype(preference_or_typepath, /datum/preference))
		preference = preference_or_typepath
	if (isnull(preference))
		CRASH("Preference type `[preference_or_typepath]` is invalid!")

	if (!preference.is_accessible(src, ignore_page = !in_menu))
		return FALSE

	log_preferences("[parent.ckey]: Updating preference [preference.type] TO \"[preference_value]\".")

	write_preference(preference, preference_value)

	log_preferences("[parent.ckey]: Applying updated preference [preference.type].")

	if (preference.preference_type == PREFERENCE_PLAYER)
		preference.apply_to_client_updated(parent, read_preference(preference.type))
	else
		character_preview_view?.update_body()

	// A non-preference menu source changed a preference. We should send new preferences now.
	if(!in_menu)
		ui_update()

	return TRUE

/// Checks that a given value is valid.
/// Must be overriden by subtypes.
/// Any type can be passed through.
/datum/preference/proc/is_valid(value)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("`is_valid()` was not implemented for [type]!")

/// Returns data to be sent to users in the menu
/datum/preference/proc/compile_ui_data(mob/user, value)
	SHOULD_NOT_SLEEP(TRUE)

	return serialize(value)

/// Returns data compiled into the preferences JSON asset
/datum/preference/proc/compile_constant_data()
	SHOULD_NOT_SLEEP(TRUE)

	return null

/// Returns whether or not this preference is accessible.
/// If FALSE, will not show in the UI and will not be editable (by update_preference).
/datum/preference/proc/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)

	if (!isnull(relevant_mutant_bodypart) || !isnull(relevant_species_trait))
		var/species_type = preferences.read_character_preference(/datum/preference/choiced/species)

		var/datum/species/species = new species_type
		if (!(db_key in species.get_features()))
			return FALSE

	if (!ignore_page && !should_show_on_page(preferences.current_window))
		return FALSE

	return TRUE

/// Returns whether or not, given the PREFERENCE_TAB_*, this preference should
/// appear.
/datum/preference/proc/should_show_on_page(preference_tab)
	var/is_on_character_page = preference_tab == PREFERENCE_TAB_CHARACTER_PREFERENCES
	var/is_character_preference = preference_type == PREFERENCE_CHARACTER
	return is_on_character_page == is_character_preference

/// A preference that is a choice of one option among a fixed set.
/// Used for preferences such as clothing.
/datum/preference/choiced
	/// If this is TRUE, icons will be generated.
	/// This is necessary for if your `init_possible_values()` override
	/// returns an assoc list of names to atoms/icons.
	var/should_generate_icons = FALSE

	var/list/cached_values

	/// If the preference is a main feature (PREFERENCE_CATEGORY_FEATURES or PREFERENCE_CATEGORY_CLOTHING)
	/// this is the name of the feature that will be presented.
	var/main_feature_name

	/// Which spritesheet this preference should go on. This is used for particularly massive choice lists to reduce mount lag.
	var/preference_spritesheet = PREFERENCE_SHEET_NORMAL

	abstract_type = /datum/preference/choiced

/// Returns a list of every possible value.
/// The first time this is called, will run `init_values()`.
/// Return value can be in the form of:
/// - A flat list of raw values, such as list(MALE, FEMALE, PLURAL).
/// - An assoc list of raw values to atoms/icons.
/datum/preference/choiced/proc/get_choices()
	// Override `init_values()` instead.
	SHOULD_NOT_OVERRIDE(TRUE)

	if (isnull(cached_values))
		cached_values = init_possible_values()
		ASSERT(cached_values.len)

	return cached_values

/// Returns a list of every possible value, serialized.
/// Return value can be in the form of:
/// - A flat list of serialized values, such as list(MALE, FEMALE, PLURAL).
/// - An assoc list of serialized values to atoms/icons.
/datum/preference/choiced/proc/get_choices_serialized()
	// Override `init_values()` instead.
	SHOULD_NOT_OVERRIDE(TRUE)

	var/list/serialized_choices = list()
	var/choices = get_choices()

	if (should_generate_icons)
		for (var/choice in choices)
			serialized_choices[serialize(choice)] = choices[choice]
	else
		for (var/choice in choices)
			serialized_choices += serialize(choice)

	return serialized_choices

/// Returns a list of every possible value.
/// This must be overriden by `/datum/preference/choiced` subtypes.
/// Return value can be in the form of:
/// - A flat list of raw values, such as list(MALE, FEMALE, PLURAL).
/// - An assoc list of raw values to atoms/icons, in which case
/// icons will be generated.
/datum/preference/choiced/proc/init_possible_values()
	CRASH("`init_possible_values()` was not implemented for [type]!")

/datum/preference/choiced/is_valid(value)
	return value in get_choices()

/datum/preference/choiced/deserialize(input, datum/preferences/preferences)
	return sanitize_inlist(input, get_choices(), create_default_value())

/datum/preference/choiced/create_default_value()
	return pick(get_choices())

/datum/preference/choiced/compile_constant_data()
	var/list/data = list()

	var/list/choices = list()

	for (var/choice in get_choices())
		choices += choice

	data["choices"] = choices

	if (should_generate_icons)
		var/list/icons = list()

		for (var/choice in choices)
			icons[choice] = get_spritesheet_key(choice)

		data["icons"] = icons
		data["icon_sheet"] = preference_spritesheet

	if (!isnull(main_feature_name))
		data["name"] = main_feature_name

	return data

/// A preference that represents an RGB color of something, crunched down to 3 hex numbers.
/// Was used heavily in the past, but doesn't provide as much range and only barely conserves space.
/datum/preference/color_legacy
	abstract_type = /datum/preference/color_legacy

/datum/preference/color_legacy/deserialize(input, datum/preferences/preferences)
	return sanitize_hexcolor(input)

/datum/preference/color_legacy/create_default_value()
	return random_short_color()

/datum/preference/color_legacy/is_valid(value)
	var/static/regex/is_legacy_color = regex(@"^[0-9a-fA-F]{3}$")
	return findtext(value, is_legacy_color)

/// A preference that represents an RGB color of something.
/// Will give the value as 6 hex digits, without a hash.
/datum/preference/color
	abstract_type = /datum/preference/color

/datum/preference/color/deserialize(input, datum/preferences/preferences)
	return sanitize_hexcolor(input, desired_format = 6, include_crunch = TRUE)

/datum/preference/color/create_default_value()
	return random_color()

/datum/preference/color/serialize(input)
	return sanitize_hexcolor(input, desired_format = 6, include_crunch = TRUE)

/datum/preference/color/is_valid(value)
	return findtext(value, GLOB.is_color)

/// Takes an assoc list of names to /datum/sprite_accessory and returns a value
/// fit for `/datum/preference/init_possible_values()`
/proc/possible_values_for_sprite_accessory_list(list/datum/sprite_accessory/sprite_accessories)
	var/list/possible_values = list()
	for (var/name in sprite_accessories)
		var/datum/sprite_accessory/sprite_accessory = sprite_accessories[name]
		if (istype(sprite_accessory))
			possible_values[name] = uni_icon(sprite_accessory.icon, sprite_accessory.icon_state)
		else
			// This means it didn't have an icon state
			possible_values[name] = uni_icon('icons/mob/landmarks.dmi', "x")
	return possible_values

/// Takes an assoc list of names to /datum/sprite_accessory and returns a value
/// fit for `/datum/preference/init_possible_values()`
/// Different from `possible_values_for_sprite_accessory_list` in that it takes a list of layers
/// such as BEHIND, FRONT, and ADJ.
/// It also takes a "body part name", such as body_markings, moth_wings, etc
/// They are expected to be in order from lowest to top.
/proc/possible_values_for_sprite_accessory_list_for_body_part(
	list/datum/sprite_accessory/sprite_accessories,
	body_part,
	list/layers,
)
	var/list/possible_values = list()

	for (var/name in sprite_accessories)
		var/datum/sprite_accessory/sprite_accessory = sprite_accessories[name]

		var/datum/universal_icon/final_icon

		for (var/layer in layers)
			var/datum/universal_icon/icon = uni_icon(sprite_accessory.icon, "m_[body_part]_[sprite_accessory.icon_state]_[layer]")

			if (isnull(final_icon))
				final_icon = icon
			else
				final_icon.blend_icon(icon, ICON_OVERLAY)

		possible_values[name] = final_icon

	return possible_values

/// A numeric preference with a minimum and maximum value
/datum/preference/numeric
	/// The minimum value
	var/minimum

	/// The maximum value
	var/maximum

	/// The step of the number, such as 1 for integers or 0.5 for half-steps.
	var/step = 1

	abstract_type = /datum/preference/numeric

/datum/preference/numeric/deserialize(input, datum/preferences/preferences)
	if(istext(input)) // Sometimes TGUI will return a string instead of a number, so we take that into account.
		input = text2num(input) // Worst case, it's null, it'll just use create_default_value()
	return sanitize_float(input, minimum, maximum, step, create_default_value())

/datum/preference/numeric/serialize(input)
	return sanitize_float(input, minimum, maximum, step, create_default_value())

/datum/preference/numeric/create_default_value()
	return rand(minimum, maximum)

/datum/preference/numeric/is_valid(value)
	return isnum(value) && value >= round(minimum, step) && value <= round(maximum, step)

/datum/preference/numeric/compile_constant_data()
	return list(
		"minimum" = minimum,
		"maximum" = maximum,
		"step" = step,
	)

/// A preference whose value is always TRUE or FALSE
/datum/preference/toggle
	abstract_type = /datum/preference/toggle

	/// The default value of the toggle, if create_default_value is not specified
	var/default_value = TRUE

/datum/preference/toggle/create_default_value()
	return default_value

/datum/preference/toggle/deserialize(input, datum/preferences/preferences)
	if(istext(input))
		input = text2num(input)
	return !!input

/datum/preference/toggle/is_valid(value)
	return value == TRUE || value == FALSE

/// A simple string type preference.
/datum/preference/string
	abstract_type = /datum/preference/string

	/// The default value of the string, if create_default_value is not specified
	var/default_value = ""

/datum/preference/string/create_default_value()
	return default_value

/datum/preference/string/deserialize(input, datum/preferences/preferences)
	return sanitize_text(input, create_default_value())

/datum/preference/string/is_valid(value)
	return istext(value)
