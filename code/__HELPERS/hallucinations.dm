/// A global list of all ongoing hallucinations, primarily for easy access to be able to stop (delete) hallucinations.
GLOBAL_LIST_EMPTY(all_ongoing_hallucinations)

// Macro wrapper for _cause_hallucination so we can cheat in named arguments, like AddComponent.
/**
 * Causes a hallucination of a certain type to the mob.
 *
 * First argument is always the type of halllucination, a /datum/hallucination, required.
 * second argument is always the key source of the hallucination, used for admin logging, required.
 *
 * Additionally, named arguments are supported for passing them forward to the created hallucination's new().
 */
#define cause_hallucination(arguments...) _cause_hallucination(list(##arguments))

/// Unless you need this for an explicit reason, use the cause_hallucination wrapper.
/mob/living/proc/_cause_hallucination(list/raw_args)
	if(!length(raw_args))
		CRASH("cause_hallucination called with no arguments.")

	var/datum/hallucination/hallucination_type = raw_args[1] // first arg is the type always
	if(!ispath(hallucination_type))
		CRASH("cause_hallucination was given a non-hallucination type.")

	var/hallucination_source = raw_args[2] // and second arg, the source
	var/datum/hallucination/new_hallucination

	if(length(raw_args) > 2)
		var/list/passed_args = raw_args.Copy(3)
		passed_args.Insert(1, src)

		new_hallucination = new hallucination_type(arglist(passed_args))
	else
		new_hallucination = new hallucination_type(src)

	// For some reason, we qdel'd in New, maybe something went wrong.
	if(QDELETED(new_hallucination))
		return
	// It's not guaranteed that the hallucination passed can successfully be initiated.
	// This means there may be cases where someone should have a hallucination but nothing happens,
	// notably if you pass a randomly picked hallucination type into this.
	// Maybe there should be a separate proc to reroll on failure?
	if(!new_hallucination.start())
		qdel(new_hallucination)
		return

	investigate_log("was afflicted with a hallucination of type [hallucination_type] by: [hallucination_source]. \
		([new_hallucination.feedback_details])", INVESTIGATE_HALLUCINATIONS)
	return new_hallucination

/**
 * Emits a hallucinating pulse around the passed atom.
 * Affects everyone in the passed radius who can view the center,
 * except for those with TRAIT_MADNESS_IMMUNE, or those who are blind.
 *
 * center - required, the center of the pulse
 * radius - the radius around that the pulse reaches
 * hallucination_duration - how much hallucination is added by the pulse. reduced based on distance to the center.
 * hallucination_max_duration - a cap on how much hallucination can be added
 * optional_messages - optional list of messages passed. Those affected by pulses will be given one of the messages in said list.
 */
/proc/visible_hallucination_pulse(atom/center, radius = 7, hallucination_duration = 50 SECONDS, hallucination_max_duration, list/optional_messages)
	for(var/mob/living/nearby_living in view(center, radius))
		if(HAS_TRAIT(nearby_living, TRAIT_MADNESS_IMMUNE) || (nearby_living.mind && HAS_TRAIT(nearby_living.mind, TRAIT_MADNESS_IMMUNE)))
			continue

		if(nearby_living.is_blind())
			continue

		// Everyone else gets hallucinations.
		var/dist = sqrt(1 / max(1, get_dist(nearby_living, center)))
		nearby_living.adjust_hallucinations_up_to(hallucination_duration * dist, hallucination_max_duration)
		if(length(optional_messages))
			to_chat(nearby_living, pick(optional_messages))

/**
 * Emits a hallucinating pulse around the passed atom.
 * Affects everyone in the passed radius except for those with TRAIT_MADNESS_IMMUNE. This affects blind players.
 *
 * center - required, the center of the pulse
 * radius - the radius around that the pulse reaches
 * hallucination_duration - how much hallucination is added by the pulse. reduced based on distance to the center.
 * hallucination_max_duration - a cap on how much hallucination can be added
 * optional_messages - optional list of messages passed. Those affected by pulses will be given one of the messages in said list.
 */
/proc/hallucination_pulse(atom/center, radius = 7, hallucination_duration = 50 SECONDS, hallucination_max_duration, list/optional_messages)
	for(var/mob/living/nearby_living in range(center, radius))
		if(HAS_TRAIT(nearby_living, TRAIT_MADNESS_IMMUNE) || (nearby_living.mind && HAS_TRAIT(nearby_living.mind, TRAIT_MADNESS_IMMUNE)))
			continue

		if(nearby_living.is_blind())
			continue

		// Everyone else gets hallucinations.
		var/dist = sqrt(1 / max(1, get_dist(nearby_living, center)))
		nearby_living.adjust_hallucinations_up_to(hallucination_duration * dist, hallucination_max_duration)
		if(length(optional_messages))
			to_chat(nearby_living, pick(optional_messages))

/// Global weighted list of all hallucinations that can show up randomly.
GLOBAL_LIST_INIT(random_hallucination_weighted_list, generate_hallucination_weighted_list())

/// Generates the global weighted list of random hallucinations.
/proc/generate_hallucination_weighted_list()
	var/list/weighted_list = list()

	for(var/datum/hallucination/hallucination_type as anything in typesof(/datum/hallucination))
		if(hallucination_type == initial(hallucination_type.abstract_hallucination_parent))
			continue
		var/weight = initial(hallucination_type.random_hallucination_weight)
		if(weight <= 0)
			continue

		weighted_list[hallucination_type] = weight

	return weighted_list

/// Debug proc for getting the total weight of the random_hallucination_weighted_list
/proc/debug_hallucination_weighted_list()
	var/total_weight = 0
	for(var/datum/hallucination/hallucination_type as anything in GLOB.random_hallucination_weighted_list)
		total_weight += GLOB.random_hallucination_weighted_list[hallucination_type]

	to_chat(usr, span_boldnotice("The total weight of the hallucination weighted list is [total_weight]."))
	return total_weight

/// Debug verb for getting the weight of each distinct type within the random_hallucination_weighted_list
/client/proc/debug_hallucination_weighted_list_per_type()
	set name = "Show Hallucination Weights"
	set category = "Debug"

	var/header = "<tr><th>Type</th> <th>Weight</th> <th>Percent</th>"

	var/total_weight = debug_hallucination_weighted_list()
	var/list/all_weights = list()
	var/datum/hallucination/last_type
	var/last_type_weight = 0
	for(var/datum/hallucination/hallucination_type as anything in GLOB.random_hallucination_weighted_list)
		var/this_weight = GLOB.random_hallucination_weighted_list[hallucination_type]
		// Last_type is the abstract parent of the last hallucination type we iterated over
		if(last_type)
			// If this hallucination is the same path as the last type (subtype), add it to the total of the last type weight
			if(ispath(hallucination_type, last_type))
				last_type_weight += this_weight
				continue

			// Otherwise we moved onto the next hallucination subtype so we can stop
			else
				all_weights["<tr><td>[last_type]</td> <td>[last_type_weight] / [total_weight]</td> <td>[round(100 * (last_type_weight / total_weight), 0.01)]% chance</td></tr>"] = last_type_weight

		// Set last_type to the abstract parent of this hallucination
		last_type = initial(hallucination_type.abstract_hallucination_parent)
		// If last_type is the base hallucination it has no distinct subtypes so we can total it up immediately
		if(last_type == /datum/hallucination)
			all_weights["<tr><td>[hallucination_type]</td> <td>[this_weight] / [total_weight]</td> <td>[round(100 * (this_weight / total_weight), 0.01)]% chance</td></tr>"] = this_weight
			last_type = null

		// Otherwise we start the weight sum for the next entry here
		else
			last_type_weight = this_weight

	// Sort by weight descending, where weight is the values (not the keys). We assoc_to_keys later to get JUST the text
	all_weights = sortTim(all_weights, /proc/cmp_numeric_dsc, associative = TRUE)

	var/page_style = "<style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style>"
	var/page_contents = "[page_style]<table style=\"width:100%\">[header][jointext(assoc_to_keys(all_weights), "")]</table>"
	var/datum/browser/popup = new(mob, "hallucinationdebug", "Hallucination Weights", 600, 400)
	popup.set_content(page_contents)
	popup.open()

/// Gets a random subtype of the passed hallucination type that has a random_hallucination_weight > 0.
/// If no subtype is passed, it will get any random hallucination subtype that is not abstract and has weight > 0.
/// This can be used instead of picking from the global weighted list to just get a random valid hallucination.
/proc/get_random_valid_hallucination_subtype(passed_type = /datum/hallucination)
	if(!ispath(passed_type, /datum/hallucination))
		CRASH("get_random_valid_hallucination_subtype - get_random_valid_hallucination_subtype passed not a hallucination subtype.")

	for(var/datum/hallucination/hallucination_type as anything in shuffle(subtypesof(passed_type)))
		if(initial(hallucination_type.abstract_hallucination_parent) == hallucination_type)
			continue
		if(initial(hallucination_type.random_hallucination_weight) <= 0)
			continue

		return hallucination_type

	return null

/// Helper to give the passed mob the ability to select a hallucination from the list of all hallucination subtypes.
/proc/select_hallucination_type(mob/user, message = "Select a hallucination subtype", title = "Choose Hallucination")
	var/static/list/hallucinations
	if(!hallucinations)
		hallucinations = typesof(/datum/hallucination)
		for(var/datum/hallucination/hallucination_type as anything in hallucinations)
			if(initial(hallucination_type.abstract_hallucination_parent) == hallucination_type)
				hallucinations -= hallucination_type

	var/chosen = tgui_input_list(user, message, title, hallucinations)
	if(!chosen || !ispath(chosen, /datum/hallucination))
		return null

	return chosen

/// Helper to give the passed mob the ability to create a delusion hallucination (even a custom one).
/// Returns a list of arguments - pass these to _cause_hallucination to cause the desired hallucination
/proc/create_delusion(mob/user)
	var/static/list/delusions
	if(!delusions)
		delusions = typesof(/datum/hallucination/delusion)
		for(var/datum/hallucination/delusion_type as anything in delusions)
			if(initial(delusion_type.abstract_hallucination_parent) == delusion_type)
				delusions -= delusion_type

	var/chosen = tgui_input_list(user, "Select a delusion type. Custom will allow for custom icon entry.", "Select Delusion", delusions)
	if(!chosen || !ispath(chosen, /datum/hallucination/delusion))
		return

	var/list/delusion_args = list()
	var/static/list/options = list("Yes", "No")
	var/duration = tgui_input_number(user, "How long should it last in seconds?", "Delusion: Duration", max_value = INFINITY, min_value = 1, default = 30)
	var/affects_us = (tgui_alert(user, "Should they see themselves as the delusion?", "Delusion: Affects us", options) == "Yes")
	var/affects_others = (tgui_alert(user, "Should they see everyone else delusion?", "Delusion: Affects others", options) == "Yes")
	var/skip_nearby = (tgui_alert(user, "Should the delusion only affect people outside of their view?", "Delusion: Skip in view", options) == "Yes")
	var/play_wabbajack = (tgui_alert(user, "Play the wabbajack sound when it happens?", "Delusion: Wabbajack sound", options) == "Yes")

	delusion_args = list(
		chosen,
		"forced delusion",
		duration = duration * 1 SECONDS,
		affects_us = affects_us,
		affects_others = affects_others,
		skip_nearby = skip_nearby,
		play_wabbajack = play_wabbajack,
	)

	if(ispath(chosen, /datum/hallucination/delusion/custom))
		var/custom_icon_file = input(user, "Pick file for custom delusion:", "Custom Delusion: File") as null|file
		if(!custom_icon_file)
			return

		var/custom_icon_state = tgui_input_text(user, "What icon state do you wanna use from the file?", "Custom Delusion: Icon State")
		if(!custom_icon_state)
			return

		var/custom_name = tgui_input_text(user, "What name should it show up as? (Can be empty)", "Custom Delusion: Name")

		delusion_args += list(
			custom_icon_file = custom_icon_file,
			custom_icon_state = custom_icon_state,
			custom_name = custom_name,
		)

	return delusion_args

/// Lines the bubblegum hallucinatoin uses when it pops up
#define BUBBLEGUM_HALLUCINATION_LINES list( \
		span_colossus("I AM IMMORTAL."), \
		span_colossus("I SHALL TAKE YOUR WORLD."), \
		span_colossus("I SEE YOU."), \
		span_colossus("YOU CANNOT ESCAPE ME FOREVER."), \
		span_colossus("NOTHING CAN HOLD ME."), \
	)
