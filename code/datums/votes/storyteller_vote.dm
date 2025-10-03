/datum/vote/storyteller_vote
	name = "Storyteller"
	default_message = "Vote for dynamic's storyteller. This is the configuration dynamic will use."
	count_method = VOTE_COUNT_METHOD_SINGLE
	winner_method = VOTE_WINNER_METHOD_WEIGHTED_RANDOM
	display_statistics = FALSE

/datum/vote/storyteller_vote/New()
	. = ..()
	var/list/new_choices = list()
	for (var/storyteller_name in SSdynamic.dynamic_storyteller_jsons)
		new_choices += storyteller_name
		choice_descriptions[storyteller_name] = SSdynamic.dynamic_storyteller_jsons[storyteller_name]["Description"]
	default_choices = new_choices

/datum/vote/storyteller_vote/toggle_votable()
	CONFIG_SET(flag/allow_vote_storyteller, !CONFIG_GET(flag/allow_vote_storyteller))

/datum/vote/storyteller_vote/is_config_enabled()
	return CONFIG_GET(flag/allow_vote_storyteller)

/datum/vote/storyteller_vote/create_vote(mob/vote_creator)
	var/list/new_choices = list()
	for (var/storyteller_name in SSdynamic.dynamic_storyteller_jsons)
		new_choices += storyteller_name
		choice_descriptions[storyteller_name] = SSdynamic.dynamic_storyteller_jsons[storyteller_name]["Description"]
	choices = new_choices

	. = ..()
	if (!.)
		return FALSE

	if(length(choices) == 0)
		to_chat(world, span_boldannounce("A storyteller vote was called, but there are no configured storytellers! \
			Players, complain to the admins. Admins, complain to the coders."))
		return FALSE

/datum/vote/storyteller_vote/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .

	if(!isnull(SSdynamic.current_storyteller))
		return "The dynamic storyteller has already been selected."

/datum/vote/storyteller_vote/get_result_text(list/all_winners, real_winner, list/non_voters)
	// I hate this, but it's better than repeating a ton of code
	display_statistics = TRUE
	message_admins(span_infoplain(span_purple("[..()]")))
	display_statistics = FALSE

	var/list/vote_results = list()
	for(var/option in choices)
		vote_results += "[option]: [choices[option]]"
	log_dynamic("STORYTELLER VOTE RESULTS: [vote_results.Join(", ")]")

	return null

/datum/vote/storyteller_vote/finalize_vote(winning_option)
	log_dynamic("The dynamic storyteller has been selected via vote and is: \"[winning_option]\"")
	SSdynamic.set_storyteller(winning_option)
