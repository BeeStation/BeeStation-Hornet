/**
 * A language holder that just mirrors the language holder of the owning holoparasite's summoner.
 */
/datum/language_holder/holoparasite
	/// Holoparasites are bluespace mind crystal bullshit, they don't have tongue limitations.
	omnitongue = TRUE
	/// The parent holder of the holoparasite, which is the holder of the summoner.
	var/datum/holoparasite_holder/holder

/datum/language_holder/holoparasite/New(atom/owner, datum/holoparasite_holder/new_holder)
	holder = new_holder
	return ..()

/**
 * Ensures that the holoparasite can understand any language that its summoner can understand.
 */
/datum/language_holder/holoparasite/has_language(language, flags_to_check)
	var/datum/language_holder/summoner_body_language_holder = holder.owner.current?.get_language_holder()
	return ..() || summoner_body_language_holder?.has_language(language, flags_to_check)

/**
 * Ensures that the holoparasite can speak any language that its summoner can understand.
 */
/datum/language_holder/holoparasite/can_speak_language(language)
	var/datum/language_holder/summoner_body_language_holder = holder.owner.current?.get_language_holder()
	return ..() || summoner_body_language_holder?.can_speak_language(language)

/**
 * Picks a random understood language, combining the holoparasite's understood languages with that of the summoner's mind and body.
 */
/datum/language_holder/holoparasite/get_random_understood_language()
	var/datum/language_holder/summoner_body_language_holder = holder.owner.current?.get_language_holder()
	var/list/choices = understood_languages.Copy()
	if(summoner_body_language_holder)
		choices |= summoner_body_language_holder.understood_languages
	return pick(choices)

/**
 * Picks a random spoken language, combining the holoparasite's spoken languages with that of the summoner's mind and body.
 */
/datum/language_holder/holoparasite/get_random_spoken_language()
	var/datum/language_holder/summoner_body_language_holder = holder.owner.current?.get_language_holder()
	var/list/choices = spoken_languages.Copy()
	if(summoner_body_language_holder)
		choices |= summoner_body_language_holder.spoken_languages
	return pick(choices)

/**
 * Creates a language holder linked to the holoparasite holder if it doesn't exist yet, and returns it.
 */
/mob/living/simple_animal/hostile/holoparasite/get_language_holder(get_minds = TRUE)
	if(!language_holder)
		language_holder = new /datum/language_holder/holoparasite(src, parent_holder)
	return language_holder
