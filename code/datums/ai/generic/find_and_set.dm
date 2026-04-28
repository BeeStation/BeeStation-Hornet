/**find and set
 * Finds an item near themselves, sets a blackboard key as it. Very useful for ais that need to use machines or something.
 * if you want to do something more complicated than find a single atom, change the search_tactic() proc
 * cool tip: search_tactic() can set lists
 */
/datum/ai_behavior/find_and_set
	action_cooldown = 2 SECONDS

/datum/ai_behavior/find_and_set/perform(delta_time, datum/ai_controller/controller, set_key, locate_path, search_range)
	if (controller.blackboard_key_exists(set_key))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(QDELETED(controller.pawn))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	var/find_this_thing = search_tactic(controller, locate_path, search_range)
	if(isnull(find_this_thing))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(set_key, find_this_thing)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/find_and_set/proc/search_tactic(datum/ai_controller/controller, locate_path, search_range = 3)
	return locate(locate_path) in oview(search_range, controller.pawn)

/**
 * Variant of find and set that fails if the living pawn doesn't hold something
 */
/datum/ai_behavior/find_and_set/pawn_must_hold_item

/datum/ai_behavior/find_and_set/pawn_must_hold_item/search_tactic(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.get_num_held_items())
		return //we want to fail the search if we don't have something held
	return ..()

/**
 * Variant of find and set that also requires the item to be edible. checks hands too
 */
/datum/ai_behavior/find_and_set/edible

/datum/ai_behavior/find_and_set/edible/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	var/mob/living/living_pawn = controller.pawn
	var/list/food_candidates = list()
	for(var/held_candidate as anything in living_pawn.held_items)
		if(!held_candidate || !IsEdible(held_candidate))
			continue
		food_candidates += held_candidate

	var/list/local_results = locate(locate_path) in oview(search_range, controller.pawn)
	for(var/local_candidate in local_results)
		if(!IsEdible(local_candidate))
			continue
		food_candidates += local_candidate
	if(food_candidates.len)
		return pick(food_candidates)

/**
 * Variant of find and set that only checks in hands, search range should be excluded for this
 */
/datum/ai_behavior/find_and_set/in_hands

/datum/ai_behavior/find_and_set/in_hands/search_tactic(datum/ai_controller/controller, locate_path)
	var/mob/living/living_pawn = controller.pawn
	return locate(locate_path) in living_pawn.held_items

/datum/ai_behavior/find_and_set/in_hands/given_list

/datum/ai_behavior/find_and_set/in_hands/given_list/search_tactic(datum/ai_controller/controller, locate_paths)
	var/list/found = typecache_filter_list(controller.pawn, locate_paths)
	if(length(found))
		return pick(found)

/**
 * Variant of find and set that takes a list of things to find.
 */
/datum/ai_behavior/find_and_set/in_list

/datum/ai_behavior/find_and_set/in_list/search_tactic(datum/ai_controller/controller, locate_paths, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	var/list/found = typecache_filter_list(oview(search_range, controller.pawn), locate_paths)
	if(length(found))
		return pick(found)

/// Like find_and_set/in_list, but we return the turf location of the item instead of the item itself.
/datum/ai_behavior/find_and_set/in_list/turf_location

/datum/ai_behavior/find_and_set/in_list/turf_location/search_tactic(datum/ai_controller/controller, locate_paths, search_range)
	. = ..()
	if(isnull(.))
		return null

	return get_turf(.)
