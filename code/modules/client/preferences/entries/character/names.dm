/// A preference for a name. Used not just for normal names, but also for clown names, etc.
/datum/preference/name
	category = "names"
	priority = PREFERENCE_PRIORITY_NAMES
	preference_type = PREFERENCE_CHARACTER
	abstract_type = /datum/preference/name

	/// Says which kind of this display name is
	var/name_type

	/// Literally tooltip
	var/tooltip

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

// both of these procs are used to tell a server policy that set by server config.
/datum/preference/name/proc/get_policy_link()
	return null
/datum/preference/name/proc/get_policy_tooltip()
	return null

/// A character's real name
/datum/preference/name/real_name
	db_key = "real_name"

	name_type = "Character name"
	tooltip = "Your character's name."
	group = "_real_name" // The `_` makes it first in ABC order.
	informed = TRUE
	// Used in serialize and is_valid
	allow_numbers = TRUE

/datum/preference/name/real_name/apply_to_human(mob/living/carbon/human/target, value)
	target.real_name = value
	target.name = value

/datum/preference/name/real_name/create_informed_default_value(datum/preferences/preferences)
	var/species_type = preferences.read_character_preference(/datum/preference/choiced/species)
	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)

	var/datum/species/species = new species_type

	return species.random_name(gender, unique = TRUE)

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

/datum/preference/name/real_name/get_policy_link()
	return CONFIG_GET(string/policy_naming_link)
/datum/preference/name/real_name/get_policy_tooltip()
	return CONFIG_GET(string/policy_naming_tooltip)

/// The name for a backup human, when nonhumans are made into head of staff
/datum/preference/name/backup_human
	db_key = "human_name"

	name_type = "Alt. Human name"
	tooltip = "This name is used when the role you are picked for only allows for humans."
	group = "alt_human" // extra bar looks ugly
	informed = TRUE

/datum/preference/name/backup_human/create_informed_default_value(datum/preferences/preferences)
	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)

	return random_unique_name(gender)

/datum/preference/name/clown
	db_key = "clown_name"

	name_type = "Clown name"
	tooltip = "Clown's stage name. Overrides over real name when you get a clown job."
	group = "fun"
	relevant_job = /datum/job/clown

/datum/preference/name/clown/create_default_value()
	return pick(GLOB.clown_names)

/datum/preference/name/mime
	db_key = "mime_name"

	name_type = "Mime name"
	tooltip = "Mime's stage name. Overrides over real name when you get a mime job."
	group = "fun"
	relevant_job = /datum/job/mime

/datum/preference/name/mime/create_default_value()
	return pick(GLOB.mime_names)

/datum/preference/name/cyborg
	db_key = "cyborg_name"

	group = "silicons"
	name_type = "Cyborg name"
	tooltip = "Used when you are a cyborg rather than a human."

	allow_numbers = TRUE
	can_randomize = FALSE

	relevant_job = /datum/job/cyborg

/datum/preference/name/cyborg/create_default_value()
	return DEFAULT_CYBORG_NAME

/datum/preference/name/ai
	db_key = "ai_name"

	group = "silicons"
	name_type = "AI name"
	tooltip = "Used when you are a cyborg rather than a human. Same as the cyborg name, but when you are an AI."

	allow_numbers = TRUE
	relevant_job = /datum/job/ai

/datum/preference/name/ai/create_default_value()
	return pick(GLOB.ai_names)

/datum/preference/name/religion
	db_key = "religion_name"

	group = "z_religion" // should be after silicon name group
	name_type = "Religion name"
	tooltip = "The name of your religion. This does nothing ingame, thus it's mostly flavourful."

	allow_numbers = TRUE
	can_randomize = FALSE

/datum/preference/name/religion/create_default_value()
	return DEFAULT_RELIGION

/datum/preference/name/deity
	db_key = "deity_name"

	group = "z_religion"
	name_type = "Deity name"
	tooltip = "The deity's name in your religion, this is used when you are the Chaplain."
	allow_numbers = TRUE
	can_randomize = FALSE

/datum/preference/name/deity/create_default_value()
	return DEFAULT_DEITY

/datum/preference/name/bible
	db_key = "bible_name"

	group = "z_religion"
	name_type = "Bible name"
	tooltip = "The deity's name of your religion. This does nothing ingame, thus it's mostly flavourful."

	allow_numbers = TRUE
	can_randomize = FALSE

/datum/preference/name/bible/create_default_value()
	return DEFAULT_BIBLE
