#define REVOLUTION_VICTORY 1
#define STATION_VICTORY 2

/datum/dynamic_ruleset
	/// For admin logging and round end screen.
	// If you want to change this variable name, the force latejoin/midround rulesets
	// to not use sort_names.
	var/name = ""
	/// For admin logging and round end screen, do not change this unless making a new rule type.
	var/ruletype = ""
	/// If set to TRUE, the rule won't be discarded after being executed, and dynamic will call rule_process() every time it ticks.
	var/persistent = FALSE
	/// If set to TRUE, dynamic mode will be able to draft this ruleset again later on. (doesn't apply for roundstart rules)
	var/repeatable = FALSE
	/// If set higher than 0 decreases weight by itself causing the ruleset to appear less often the more it is repeated.
	var/repeatable_weight_decrease = 2
	/// List of players that are being drafted for this rule
	var/list/mob/candidates = list()
	/// List of players that were selected for this rule
	var/list/datum/mind/assigned = list()
	/// The /datum/role_preference typepath used for this ruleset.
	var/role_preference = null
	/// The antagonist datum that is assigned to the mobs mind on ruleset execution.
	var/datum/antagonist/antag_datum = null
	/// If set, and config flag protect_roles_from_antagonist is false, then the rule will not pick players from these roles.
	var/list/protected_roles = list()
	/// If set, rule will deny candidates from those roles always.
	var/list/restricted_roles = list()
	/// If set, rule will only accept candidates from those roles, IMPORTANT: DOES NOT WORK ON ROUNDSTART RULESETS.
	var/list/exclusive_roles = list()
	/// If set, there needs to be a certain amount of players doing those roles (among the players who won't be drafted) for the rule to be drafted IMPORTANT: DOES NOT WORK ON ROUNDSTART RULESETS.
	var/list/enemy_roles = list()
	/// If enemy_roles was set, this is the amount of enemy job workers needed per threat_level range (0-10,10-20,etc) IMPORTANT: DOES NOT WORK ON ROUNDSTART RULESETS.
	var/required_enemies = list(1,1,0,0,0,0,0,0,0,0)
	/// The rule needs this many candidates (post-trimming) to be executed (example: Cult needs 4 players at round start)
	var/required_candidates = 0
	/// 0 -> 9, probability for this rule to be picked against other rules. If zero this will effectively disable the rule.
	var/weight = 5
	/// Threat cost for this rule, this is decreased from the mode's threat when the rule is executed.
	var/cost = 0
	/// Cost per level the rule scales up.
	var/scaling_cost = 0
	/// How many times a rule has scaled up upon getting picked.
	var/scaled_times = 0
	/// Used for the roundend report
	var/total_cost = 0
	/// A flag that determines how the ruleset is handled. Check __DEFINES/dynamic.dm for an explanation of the accepted values.
	var/flags = NONE
	/// Pop range per requirement. If zero defaults to mode's pop_per_requirement.
	var/pop_per_requirement = 0
	/// Requirements are the threat level requirements per pop range.
	/// With the default values, The rule will never get drafted below 10 threat level (aka: "peaceful extended"), and it requires a higher threat level at lower pops.
	var/list/requirements = list(40,30,20,10,10,10,10,10,10,10)
	/// Reference to the mode, use this instead of SSticker.mode.
	var/datum/game_mode/dynamic/mode = null
	/// If a ruleset type which is in this list has been executed, then the ruleset will not be executed.
	var/list/blocking_rules = list()
	/// The minimum amount of players required for the rule to be considered.
	var/minimum_players = 0
	/// The maximum amount of players required for the rule to be considered.
	/// Anything below zero or exactly zero is ignored.
	var/maximum_players = 0
	/// Calculated during acceptable(), used in scaling and team sizes.
	var/indice_pop = 0
	/// Base probability used in scaling. The higher it is, the more likely to scale. Kept as a var to allow for config editing._SendSignal(sigtype, list/arguments)
	var/base_prob = 60
	/// Delay for when execute will get called from the time of post_setup (roundstart) or process (midround/latejoin).
	/// Make sure your ruleset works with execute being called during the game when using this, and that the clean_up proc reverts it properly in case of faliure.
	var/delay = 0
	/// Whether antag rep should be considered when rolling candidates or not.
	var/consider_antag_rep = FALSE

	/// Judges the amount of antagonists to apply, for both solo and teams.
	/// Note that some antagonists (such as traitors, lings, heretics, etc) will add more based on how many times they've been scaled.
	/// Written as a linear equation--ceil(x/denominator) + offset, or as a fixed constant.
	/// If written as a linear equation, will be in the form of `list("denominator" = denominator, "offset" = offset).
	var/antag_cap = 0

	/// Whether thie ruleset has been determined to be dead or not already.
	/// Currently only used for logging.
	var/dead = FALSE

	/// Whether repeated_mode_adjust weight changes have been logged already.
	var/logged_repeated_mode_adjust = FALSE


/datum/dynamic_ruleset/New(datum/game_mode/dynamic/dynamic_mode)
	// Rulesets can be instantiated more than once, such as when an admin clicks
	// "Execute Midround Ruleset". Thus, it would be wrong to perform any
	// side effects here. Dynamic rulesets should be stateless anyway.
	SHOULD_NOT_OVERRIDE(TRUE)

	mode = dynamic_mode
	..()

/datum/dynamic_ruleset/roundstart // One or more of those drafted at roundstart
	ruletype = "Roundstart"
	consider_antag_rep = TRUE

// Can be drafted when a player joins the server
/datum/dynamic_ruleset/latejoin
	ruletype = "Latejoin"

/// By default, a rule is acceptable if it satisfies the threat level/population requirements.
/// If your rule has extra checks, such as counting security officers, do that in ready() instead
/datum/dynamic_ruleset/proc/acceptable(population = 0, threat_level = 0)
	if(minimum_players > population)
		log_game("DYNAMIC: FAIL: [src] failed acceptable: minimum_players ([minimum_players]) > population ([population])")
		return FALSE

	if(maximum_players > 0 && population > maximum_players)
		log_game("DYNAMIC: FAIL: [src] failed acceptable: maximum_players ([maximum_players]) < population ([population])")
		return FALSE

	pop_per_requirement = pop_per_requirement > 0 ? pop_per_requirement : mode.pop_per_requirement
	indice_pop = min(requirements.len,round(population/pop_per_requirement)+1)
	if (threat_level < requirements[indice_pop])
		log_game("DYNAMIC: FAIL: [src] failed acceptable: threat_level ([threat_level]) < requirement ([requirements[indice_pop]])")
		return FALSE

	return TRUE

/// When picking rulesets, if dynamic picks the same one multiple times, it will "scale up".
/// However, doing this blindly would result in lowpop rounds (think under 10 people) where over 80% of the crew is antags!
/// This function is here to ensure the antag ratio is kept under control while scaling up.
/// Returns how much threat to actually spend in the end.
/datum/dynamic_ruleset/proc/scale_up(population, max_scale)
	if (!scaling_cost)
		return 0

	var/antag_fraction = 0
	for(var/_ruleset in (mode.executed_rules + list(src))) // we care about the antags we *will* assign, too
		var/datum/dynamic_ruleset/ruleset = _ruleset
		antag_fraction += ((1 + ruleset.scaled_times) * ruleset.get_antag_cap(population)) / mode.roundstart_pop_ready

	for(var/i in 1 to max_scale)
		if(antag_fraction < 0.25)
			scaled_times += 1
			antag_fraction += get_antag_cap(population) / mode.roundstart_pop_ready // we added new antags, gotta update the %

	return scaled_times * scaling_cost

/// Returns what the antag cap with the given population is.
/datum/dynamic_ruleset/proc/get_antag_cap(population)
	if (isnum(antag_cap))
		return antag_cap

	return CEILING(population / antag_cap["denominator"], 1) + (antag_cap["offset"] || 0)

/// This is called if persistent variable is true everytime SSTicker ticks.
/datum/dynamic_ruleset/proc/rule_process()
	return

/// Called on game mode pre_setup for roundstart rulesets.
/// Do everything you need to do before job is assigned here.
/// IMPORTANT: ASSIGN special_role HERE (for midrounds, this doesn't apply)
/datum/dynamic_ruleset/proc/pre_execute()
	return TRUE

/// Called on post_setup on roundstart and when the rule executes on midround and latejoin.
/// Give your candidates or assignees equipment and antag datum here.
/datum/dynamic_ruleset/proc/execute(forced = FALSE)
	for(var/datum/mind/M in assigned)
		M.add_antag_datum(antag_datum)
	return TRUE

/// Here you can perform any additional checks you want. (such as checking the map etc)
/// Remember that on roundstart no one knows what their job is at this point.
/// IMPORTANT: If ready() returns TRUE, that means pre_execute() or execute() should never fail!
/datum/dynamic_ruleset/proc/ready(forced = FALSE)
	return check_candidates()

/// Runs from gamemode process() if ruleset fails to start, like delayed rulesets not getting valid candidates.
/// This one only handles refunding the threat, override in ruleset to clean up the rest.
/datum/dynamic_ruleset/proc/clean_up()
	mode.refund_threat(cost + (scaled_times * scaling_cost))
	var/msg = "[ruletype] [name] refunded [cost + (scaled_times * scaling_cost)]. Failed to execute."
	mode.threat_log += "[worldtime2text()]: [msg]"
	message_admins(msg)
	log_game("DYNAMIC: [ruletype] [name] is cleaning up, failed to execute.")

/// Gets weight of the ruleset
/// Note that this decreases weight if repeatable is TRUE and repeatable_weight_decrease is higher than 0
/// Note: If you don't want repeatable rulesets to decrease their weight use the weight variable directly
/datum/dynamic_ruleset/proc/get_weight()
	if(repeatable && weight > 1 && repeatable_weight_decrease > 0)
		for(var/datum/dynamic_ruleset/DR in mode.executed_rules)
			if(istype(DR, type))
				weight = max(weight-repeatable_weight_decrease,1)
	var/list/repeated_mode_adjust = CONFIG_GET(number_list/repeated_mode_adjust)
	if(CHECK_BITFIELD(flags, PERSISTENT_RULESET) && LAZYLEN(repeated_mode_adjust))
		var/adjustment = 0
		for(var/rounds_ago = 1 to min(length(SSpersistence.saved_dynamic_rulesets), length(repeated_mode_adjust)))
			var/list/round = SSpersistence.saved_dynamic_rulesets[rounds_ago]
			if(!round)
				continue
			if(!islist(round))
				round = list(round)
			if(name in round)
				adjustment += repeated_mode_adjust[rounds_ago]
		if(adjustment)
			var/old_weight = weight
			weight *= ((100 - adjustment) / 100)
			if(!logged_repeated_mode_adjust)
				log_game("DYNAMIC: weight of [src] adjusted from [old_weight] to [weight] by repeated_mode_adjust")
				logged_repeated_mode_adjust = TRUE
	return weight

/// Checks if there are enough candidates to run, and logs otherwise
/datum/dynamic_ruleset/proc/check_candidates()
	var/candidates_amt = length(candidates)
	if (required_candidates > candidates_amt)
		log_game("DYNAMIC: FAIL: [src] does not have enough candidates ([required_candidates] needed, [candidates_amt] found)")
		return FALSE
	return TRUE

/// Here you can remove candidates that do not meet your requirements.
/// This means if their job is not correct or they have disconnected you can remove them from candidates here.
/// Usually this does not need to be changed unless you need some specific requirements from your candidates.
/datum/dynamic_ruleset/proc/trim_candidates()
	return

/// Set mode result and news report here.
/// Only called if ruleset is flagged as HIGH_IMPACT_RULESET
/datum/dynamic_ruleset/proc/round_result()


/// Checks if the ruleset is "dead", where all the antags are either dead or deconverted.
/datum/dynamic_ruleset/proc/is_dead()
	for(var/datum/mind/mind in assigned)
		var/mob/living/body = mind.current
		// If they have no body, they're dead for realsies.
		if(QDELETED(body))
			continue
		// Well, if there's nobody in the body, they might as well be dead.
		if(!body.ckey)
			continue
		// Have they been AFK for over 20 minutes? If so, eh, we won't take them into consdideration.
		if(body.client?.is_afk(20 MINUTES))
			continue
		// Have they been husked by a non-burn source? Probably really really dead.
		if(HAS_TRAIT_NOT_FROM(body, TRAIT_HUSK, "burn"))
			continue
		// Alright, they have a body with a ckey, but are they actually dead?
		if(body.stat == DEAD)
			// Has their soul departed or been ripped out? If so, yep, they dead alright.
			if(body.soul_departed() || mind.hellbound)
				continue
			// Are they in medbay or an operating table/stasis bed, and have been dead for less than 20 minutes? If so, they're probably being revived.
			if(world.time <= (mind.last_death + 15 MINUTES) && (istype(get_area(body), /area/medical) || (locate(/obj/machinery/stasis) in body.loc) || (locate(/obj/structure/table/optable) in body.loc)))
				log_undead()
				return FALSE
		else
			// Are they a silicon? If so, might as well be dead.
			if(issilicon(body) && mind.assigned_role != JOB_NAME_AI)
				continue
			// Well, they're at least somewhat alive. But are they still antag?
			if(antag_datum && mind.has_antag_datum(antag_datum))
				// They're still antag and not dead.
				log_undead()
				return FALSE
	log_dead()
	return TRUE

/datum/dynamic_ruleset/proc/log_dead()
	if(dead)
		return
	dead = TRUE
	log_game("DYNAMIC: ruleset [src] is considered dead now, new midround rulesets may be able to roll now")
	message_admins("DYNAMIC: ruleset [src] is considered dead now, new midround rulesets may be able to roll now")

/datum/dynamic_ruleset/proc/log_undead()
	if(!dead)
		return
	dead = FALSE
	log_game("DYNAMIC: ruleset [src] is no longer considered dead")
	message_admins("DYNAMIC: ruleset [src] is no longer considered dead")

/// Picks a candidate from a list, while potentially taking antag rep into consideration.
/datum/dynamic_ruleset/proc/antag_pick_n_take(list/candidates)
	. = (mode && consider_antag_rep) ? mode.antag_pick(candidates, role_preference) : pick(candidates)
	if(.)
		candidates -= .

//////////////////////////////////////////////
//                                          //
//           ROUNDSTART RULESETS            //
//                                          //
//////////////////////////////////////////////

/// Checks if candidates are connected and if they are banned or don't want to be the antagonist.
/datum/dynamic_ruleset/roundstart/trim_candidates()
	for(var/mob/dead/new_player/P in candidates)
		var/client/client = GET_CLIENT(P)
		if (!client || !P.mind) // Are they connected?
			candidates.Remove(P)
			continue

		if(!client.should_include_for_role(
			banning_key = initial(antag_datum.banning_key),
			role_preference_key = role_preference,
			req_hours = initial(antag_datum.required_living_playtime)
		))
			candidates.Remove(P)
			continue

		if(P.mind.special_role) // We really don't want to give antag to an antag.
			candidates.Remove(P)
			continue

/// Do your checks if the ruleset is ready to be executed here.
/// Should ignore certain checks if forced is TRUE
/datum/dynamic_ruleset/roundstart/ready(population, forced = FALSE)
	return ..()
