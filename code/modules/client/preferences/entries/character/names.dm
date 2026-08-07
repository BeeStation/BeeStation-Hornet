/// A preference for a name. Used not just for normal names, but also for clown names, etc.
/datum/preference/name
	category = "names"
	priority = PREFERENCE_PRIORITY_NAMES
	preference_type = PREFERENCE_CHARACTER
	abstract_type = /datum/preference/name

	/// The display name when showing on the "other names" panel
	var/explanation

	/// These will be grouped together on the preferences menu
	var/group

	/// Whether or not to allow numbers in the person's name
	var/allow_numbers = FALSE

	/// If the highest priority job matches this, will prioritize this name in the UI
	var/relevant_job

/datum/preference/name/apply_to_human(mob/living/carbon/human/target, value)
	// Only real_name applies directly, everything else is applied by something else
	return

/datum/preference/name/deserialize(input, datum/preferences/preferences)
	return reject_bad_name("[input]", allow_numbers)

/datum/preference/name/serialize(input)
	// `is_valid` should always be run before `serialize`, so it should not
	// be possible for this to return `null`.
	return reject_bad_name(input, allow_numbers)

/datum/preference/name/is_valid(value)
	return istext(value) && !isnull(reject_bad_name(value, allow_numbers))

/// A character's real name
/datum/preference/name/real_name
	explanation = "Name"
	// The `_` makes it first in ABC order.
	group = "_real_name"
	db_key = "real_name"
	informed = TRUE
	// Used in serialize and is_valid
	allow_numbers = TRUE

/datum/preference/name/real_name/apply_to_human(mob/living/carbon/human/target, value)
	target.real_name = value
	target.name = value

/datum/preference/name/real_name/create_informed_default_value(datum/preferences/preferences)
	return generate_random_name_species_based(
		preferences.read_character_preference(/datum/preference/choiced/gender),
		TRUE,
		preferences.read_character_preference(/datum/preference/choiced/species),
	)

/datum/preference/name/real_name/deserialize(input, datum/preferences/preferences)
	var/datum/species/selected_species = preferences.read_character_preference(/datum/preference/choiced/species)
	input = reject_bad_name(input, initial(selected_species.allow_numbers_in_name))
	if (!input)
		return input

	if (CONFIG_GET(flag/humans_need_surnames) && selected_species == /datum/species/human)
		var/first_space = findtext(input, " ")
		if(!first_space) //we need a surname
			input += " [pick(GLOB.last_names)]"
		else if(first_space == length(input))
			input += "[pick(GLOB.last_names)]"
	return input

/// The name for a backup human, when nonhumans are made into head of staff
/datum/preference/name/backup_human
	explanation = "Backup human name"
	group = "backup_human"
	db_key = "human_name"
	informed = TRUE

/datum/preference/name/backup_human/create_informed_default_value(datum/preferences/preferences)
	return generate_random_name(preferences.read_character_preference(/datum/preference/choiced/gender))

/datum/preference/name/clown
	db_key = "clown_name"

	explanation = "Clown name"
	group = "fun"
	relevant_job = /datum/job/clown

/datum/preference/name/clown/create_default_value()
	return pick(GLOB.clown_names)

/datum/preference/name/mime
	db_key = "mime_name"

	explanation = "Mime name"
	group = "fun"
	relevant_job = /datum/job/mime

/datum/preference/name/mime/create_default_value()
	return pick(GLOB.mime_names)

/datum/preference/name/cyborg
	db_key = "cyborg_name"

	allow_numbers = TRUE
	can_randomize = FALSE

	explanation = "Cyborg name"
	group = "silicons"
	relevant_job = /datum/job/cyborg

/datum/preference/name/cyborg/create_default_value()
	return DEFAULT_CYBORG_NAME

/datum/preference/name/ai
	db_key = "ai_name"

	allow_numbers = TRUE
	explanation = "AI name"
	group = "silicons"
	relevant_job = /datum/job/ai

/datum/preference/name/ai/create_default_value()
	return random_ai_name()

/datum/preference/name/religion
	db_key = "religion_name"

	allow_numbers = TRUE

	explanation = "Religion name"
	group = "religion"

/datum/preference/name/religion/create_default_value()
	return DEFAULT_RELIGION

/datum/preference/name/deity
	db_key = "deity_name"

	allow_numbers = TRUE
	can_randomize = FALSE

	explanation = "Deity name"
	group = "religion"

/datum/preference/name/deity/create_default_value()
	return DEFAULT_DEITY

/datum/preference/name/bible
	db_key = "bible_name"

	allow_numbers = TRUE
	can_randomize = FALSE

	explanation = "Bible name"
	group = "religion"

/datum/preference/name/bible/create_default_value()
	return DEFAULT_BIBLE
