PROCESSING_SUBSYSTEM_DEF(station)
	name = "Station"
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	wait = 5 SECONDS

	/// A list of currently active station traits
	var/list/station_traits = list()
	/// Assoc list of trait type || assoc list of traits with weighted value. Used for picking traits from a specific category.
	var/list/selectable_traits_by_types = list(
		STATION_TRAIT_POSITIVE = list(),
		STATION_TRAIT_NEUTRAL = list(),
		STATION_TRAIT_NEGATIVE = list(),
		STATION_TRAIT_EXCLUSIVE = list(),
	)
	/// Currently active announcer. Starts as a type but gets initialized after traits are selected
	var/datum/centcom_announcer/announcer = /datum/centcom_announcer/default

	/// Assosciative list of station goal type -> goal instance
	var/list/datum/station_goal/goals_by_type = list()

/datum/controller/subsystem/processing/station/Initialize()
	//If doing unit tests we don't do none of that trait shit ya know?
	// Autowiki also wants consistent outputs, for example making sure the vending machine page always reports the normal products
#if !defined(UNIT_TESTS) && !defined(AUTOWIKI)
	setup_traits()
#endif

	announcer = new announcer() //Initialize the station's announcer datum

	return SS_INIT_SUCCESS

/datum/controller/subsystem/processing/station/Recover()
	station_traits = SSstation.station_traits
	selectable_traits_by_types = SSstation.selectable_traits_by_types
	announcer = SSstation.announcer
	goals_by_type = SSstation.goals_by_type

/**
 * This gets called by SSdynamic during initial gamemode setup.
 */
/datum/controller/subsystem/processing/station/proc/generate_station_goals(goal_budget)
	var/list/possible_goals = subtypesof(/datum/station_goal)

	var/goal_weights = 0
	var/chosen_goals = list()
	while (length(possible_goals) && goal_weights < goal_budget)
		var/datum/station_goal/picked = pick_n_take(possible_goals)

		goal_weights += initial(picked.weight)
		chosen_goals += picked

	for (var/chosen in chosen_goals)
		new chosen()

/// Returns all station goals that are currently active
/datum/controller/subsystem/processing/station/proc/get_station_goals()
	var/list/goals = list()
	for (var/goal_type in goals_by_type)
		goals += goals_by_type[goal_type]
	return goals

/// Returns a specific station goal by type
/datum/controller/subsystem/processing/station/proc/get_station_goal(goal_type)
	return goals_by_type[goal_type]

/// Rolls for the amount of traits and adds them to the traits list
/datum/controller/subsystem/processing/station/proc/setup_traits()
	if (!CONFIG_GET(flag/station_traits))
		return

	if (fexists(FUTURE_STATION_TRAITS_FILE))
		var/forced_traits_contents = file2text(FUTURE_STATION_TRAITS_FILE)
		fdel(FUTURE_STATION_TRAITS_FILE)

		var/list/forced_traits_text_paths = json_decode(forced_traits_contents)
		forced_traits_text_paths = SANITIZE_LIST(forced_traits_text_paths)

		for (var/trait_text_path in forced_traits_text_paths)
			var/station_trait_path = text2path(trait_text_path)
			if (!ispath(station_trait_path, /datum/station_trait) || station_trait_path == /datum/station_trait)
				var/message = "Invalid station trait path [station_trait_path] was requested in the future station traits!"
				log_game(message)
				message_admins(message)
				continue

			setup_trait(station_trait_path)

		return

	// Get list of possible traits
	for (var/datum/station_trait/trait_typepath as anything in subtypesof(/datum/station_trait))
		// If forced, (probably debugging), just set it up now, keep it out of the pool.
		if (initial(trait_typepath.force))
			setup_trait(trait_typepath)
			continue

		// Don't add abstract traits
		if (initial(trait_typepath.abstract_type) == trait_typepath)
			continue

		// we're on a planet but we can't do planet ;_;
		if (!(initial(trait_typepath.trait_flags) & STATION_TRAIT_PLANETARY) && SSmapping.is_planetary())
			continue

		// we're in space but we can't do space ;_;
		if (!(initial(trait_typepath.trait_flags) & STATION_TRAIT_SPACE_BOUND) && !SSmapping.is_planetary())
			continue

		// can't have AI traits without AI
		if (!(initial(trait_typepath.trait_flags) & STATION_TRAIT_REQUIRES_AI) && !CONFIG_GET(flag/allow_ai))
			continue

		selectable_traits_by_types[initial(trait_typepath.trait_type)][trait_typepath] = initial(trait_typepath.weight)

	var/positive_trait_budget = text2num(pick_weight(CONFIG_GET(keyed_list/positive_station_traits)))
	var/neutral_trait_budget = text2num(pick_weight(CONFIG_GET(keyed_list/neutral_station_traits)))
	var/negative_trait_budget = text2num(pick_weight(CONFIG_GET(keyed_list/negative_station_traits)))

	// Choose positive, neutral, and negative traits in a random order
	var/possible_types = list(STATION_TRAIT_POSITIVE, STATION_TRAIT_NEUTRAL, STATION_TRAIT_NEGATIVE, STATION_TRAIT_EXCLUSIVE)
	while (length(possible_types))
		var/picked = pick_n_take(possible_types)
		switch(picked)
			if (STATION_TRAIT_POSITIVE)
				pick_traits(STATION_TRAIT_POSITIVE, positive_trait_budget)
			if (STATION_TRAIT_NEUTRAL)
				pick_traits(STATION_TRAIT_NEUTRAL, neutral_trait_budget)
			if (STATION_TRAIT_NEGATIVE)
				pick_traits(STATION_TRAIT_NEGATIVE, negative_trait_budget)
			if (STATION_TRAIT_EXCLUSIVE)
				pick_exclusive_traits()

/**
 * Picks traits of a specific category (e.g. bad or good), initializes them, adds them to the list of traits,
 * then removes them from possible traits as to not roll twice and subtracts their cost from the budget.
 * All until the whole budget is spent or no more traits can be picked with it.
 */
/datum/controller/subsystem/processing/station/proc/pick_traits(trait_category, budget)
	if (!budget)
		return

	var/list/datum/station_trait/selectable_traits = selectable_traits_by_types[trait_category]
	while (budget)
		// Remove any station trait with a cost bigger than the budget
		for (var/datum/station_trait/proto_trait as anything in selectable_traits)
			if (initial(proto_trait.cost) > budget)
				selectable_traits -= proto_trait

		// We have spare budget but no trait that can be bought with what's left of it
		if (!length(selectable_traits))
			return

		// Rolls from the table for the specific trait type
		var/datum/station_trait/trait_type = pick_weight(selectable_traits)
		selectable_traits -= trait_type
		budget -= initial(trait_type.cost)
		setup_trait(trait_type)

/// Adds exclusive station trait based on each weight regardless of count
/datum/controller/subsystem/processing/station/proc/pick_exclusive_traits()
	for (var/datum/station_trait/exclusive_trait as anything in selectable_traits_by_types[STATION_TRAIT_EXCLUSIVE])
		if (!prob(initial(exclusive_trait.weight)))
			continue
		setup_trait(exclusive_trait)

/// Creates a given trait of a specific type, while also removing any blacklisted ones from the future pool.
/datum/controller/subsystem/processing/station/proc/setup_trait(datum/station_trait/trait_type)
	if (locate(trait_type) in station_traits)
		return
	var/datum/station_trait/trait_instance = new trait_type()
	station_traits += trait_instance
	log_game("Station Trait: [trait_instance.name] chosen for this round.")
	if (!trait_instance.blacklist)
		return
	for (var/i in trait_instance.blacklist)
		var/datum/station_trait/trait_to_remove = i
		selectable_traits_by_types[initial(trait_to_remove.trait_type)] -= trait_to_remove
