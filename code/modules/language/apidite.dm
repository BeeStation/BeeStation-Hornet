
/datum/language/apidite
	name = "Apidite"
	icon_state = "apidite"
	desc = "The language of Apids, oh god, that's a lot of buzzing."
	key = "*"
	flags = TONGUELESS_SPEECH
	space_chance = 40
	syllables = list(
		"bzz"
	)
	default_priority = 90

/datum/language/apidite/get_random_name(
	gender = NEUTER,
	name_count = 2,
	syllable_min = 2,
	syllable_max = 4,
	unique = FALSE,
	lastname = null,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()
	if(gender == MALE)
		name = "[pick(GLOB.apid_names_male)]"
	else
		name = "[pick(GLOB.apid_names_female)]"

	if(lastname)
		name += " [lastname]"
	else
		name += " [pick(GLOB.apid_names_last)]"

	return name
