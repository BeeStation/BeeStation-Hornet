/// maximum of 50 specific scrambled lines per language
#define SCRAMBLE_CACHE_LEN 50

/// Datum based languages. Easily editable and modular.
/datum/language
	/// Fluff name of language if any.
	var/name = "an unknown language"
	/// Short description for 'Check Languages'.
	var/desc = "A language."
	/// Character used to speak in language
	/// If key is null, then the language isn't real or learnable.
	var/key
	/// Various language flags.
	var/flags = NONE
	/// Used when scrambling text for a non-speaker.
	var/list/syllables
	/// List of characters that will randomly be inserted between syllables.
	var/list/special_characters
	/// Likelihood of making a new sentence after each syllable.
	var/sentence_chance = 5
	/// Likelihood of getting a space in the random scramble string
	var/space_chance = 55
	/// Spans to apply from this language
	var/list/spans
	/// Cache of recently scrambled text
	/// This allows commonly reused words to not require a full re-scramble every time.
	var/list/scramble_cache = list()
	/// The language that an atom knows with the highest "default_priority" is selected by default.
	var/default_priority = 0
	/// If TRUE, when generating names, we will always use the default human namelist, even if we have syllables set.
	/// This is to be used for languages with very outlandish syllable lists (like pirates).
	var/always_use_default_namelist = FALSE
	/// Icon displayed in the chat window when speaking this language.
	/// if you are seeing someone speak popcorn language, then something is wrong.
	var/icon = 'icons/misc/language.dmi'
	/// Icon state displayed in the chat window when speaking this language.
	var/icon_state = "popcorn"

	/// By default, random names picks this many names
	var/default_name_count = 2
	/// By default, random names picks this many syllables (min)
	var/default_name_syllable_min = 2
	/// By default, random names picks this many syllables (max)
	var/default_name_syllable_max = 4
	/// What char to place in between randomly generated names
	var/random_name_spacer = " "

	// get_icon() proc will return a complete string rather than calling a proc every time.
	var/fast_icon_span

/// Returns TRUE/FALSE based on seeing a language icon is validated to a given hearer in the parameter.
/datum/language/proc/display_icon(atom/movable/hearer)
	// ghosts want to know how it is going.
	if((flags & LANGUAGE_ALWAYS_SHOW_ICON_TO_GHOSTS) && \
			(isobserver(hearer) || (HAS_TRAIT(hearer, TRAIT_METALANGUAGE_KEY_ALLOWED) && istype(src, /datum/language/metalanguage))))
		return TRUE

	var/understands = hearer.has_language(src.type)
	if(understands)
		// It's something common so that you don't have to see a language icon
		// or, it's not a valid language that should show a language icon
		if((flags & LANGUAGE_HIDE_ICON_IF_UNDERSTOOD) || (flags & LANGUAGE_HIDE_ICON_TO_YOURSELF))
			return FALSE

	else
		// Standard to Galatic Common
		if(flags & LANGUAGE_ALWAYS_SHOW_ICON_IF_NOT_UNDERSTOOD)
			return TRUE

		// You'll typically end here - not being able to see a language icon
		if(!HAS_TRAIT(hearer, TRAIT_LINGUIST))
			return FALSE
		else if(flags & LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD__LINGUIST_ONLY) // don't merge with the if above. it's different check.
			return FALSE

	// If you reach here, you'd be a linguist quirk holder, and will be eligible to see a lang icon
	return TRUE

/datum/language/proc/get_icon()
	if(!fast_icon_span)
		var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)
		fast_icon_span = sheet.icon_tag("language-[icon_state]")
	return fast_icon_span

/// Simple helper for getting a default firstname lastname
/datum/language/proc/default_name(gender = NEUTER)
	if(gender != MALE && gender != FEMALE)
		gender = pick(MALE, FEMALE)
	if(gender == FEMALE)
		return capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
	return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

/**
 * Generates a random name this language would use.
 *
 * * gender: What gender to generate from, if neuter / plural coin flips between male and female
 * * name_count: How many names to generate in, by default 2, for firstname lastname
 * * syllable_count: How many syllables to generate in each name, min
 * * syllable_max: How many syllables to generate in each name, max
 * * force_use_syllables: If the name should be generated from the syllables list.
 * Only used for subtypes which implement custom name lists. Also requires the language has syllables set.
 */
/datum/language/proc/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(gender != MALE && gender != FEMALE)
		gender = pick(MALE, FEMALE)
	if(!length(syllables) || always_use_default_namelist)
		return default_name(gender)

	var/list/full_name = list()
	for(var/i in 1 to name_count)
		var/new_name = ""
		for(var/j in 1 to rand(default_name_syllable_min, default_name_syllable_max))
			new_name += pick_weight_recursive(syllables)
		full_name += capitalize(LOWER_TEXT(new_name))

	return jointext(full_name, random_name_spacer)

/// Generates a random name, and attempts to ensure it is unique (IE, no other mob in the world has it)
/datum/language/proc/get_random_unique_name(...)
	var/result = get_random_name(arglist(args))
	for(var/i in 1 to 10)
		if(!findname(result))
			break
		result = get_random_name(arglist(args))

	return result

/datum/language/proc/check_cache(input)
	var/lookup = scramble_cache[input]
	if(lookup)
		scramble_cache -= input
		scramble_cache[input] = lookup
	. = lookup

/datum/language/proc/add_to_cache(input, scrambled_text)
	// Add it to cache, cutting old entries if the list is too long
	scramble_cache[input] = scrambled_text
	if(scramble_cache.len > SCRAMBLE_CACHE_LEN)
		scramble_cache.Cut(1, 2)

/datum/language/proc/scramble(input)

	if(!length(syllables))
		return stars(input)

	// If the input is cached already, move it to the end of the cache and return it
	var/lookup = check_cache(input)
	if(lookup)
		return lookup

	var/input_size = length_char(input)
	var/scrambled_text = ""
	var/capitalize = TRUE

	while(length_char(scrambled_text) < input_size)
		var/next = (length(scrambled_text) && length(special_characters) && prob(1)) ? pick(special_characters) : pick_weight_recursive(syllables)
		if(capitalize)
			next = capitalize(next)
			capitalize = FALSE
		scrambled_text += next
		var/chance = rand(100)
		if(chance <= sentence_chance)
			scrambled_text += ". "
			capitalize = TRUE
		else if(chance > sentence_chance && chance <= space_chance)
			scrambled_text += " "

	scrambled_text = trim(scrambled_text)
	var/ending = copytext_char(scrambled_text, -1)
	if(ending == ".")
		scrambled_text = copytext_char(scrambled_text, 1, -2)
	var/input_ending = copytext_char(input, -1)
	if(input_ending in list("!","?","."))
		scrambled_text += input_ending

	add_to_cache(input, scrambled_text)

	return scrambled_text

#undef SCRAMBLE_CACHE_LEN
