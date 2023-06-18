/// The threat growth for new antagonists
#define ANTAGONIST_THREAT 2
/// The time it takes for new antagonist threats to decay
#define ANTAG_THREAT_DECAY (15 MINUTES)
/// The threat increase from a crewmember dying
#define DEAD_THREAT 3
/// How long it takes for the threat from a mob dying to decay
#define DEAD_THREAT_DECAY (30 MINUTES)
/// Time based decay of threat gives a threat trajectory over the course of the round.
/// This determines how much danger will be reduced by every hour.
/// A value of 10 would mean that at the 1 hour mark, calculate_danger()'s output will
/// be reduced by 10.
#define HOURLY_THREAT_DECREASE 10

/datum/game_mode/dynamic/admin_stat_info()
	. = list()
	if (world.time < previous_cache_heuristic_time + 30 SECONDS)
		.["Danger Heuristic"] = GENERATE_STAT_TEXT("[previous_cache_heuristic]")
		return
	.["Danger Heuristic"] = GENERATE_STAT_TEXT("[calculate_danger()]")

/datum/game_mode/dynamic/get_metrics()
	. = list()
	.["dynamic"] = list(
		"danger_heuristic" = calculate_danger()
	)

/// Calculate the amount of 'danger' on the station.
/// This will be subtracted from the amount of threat that is spendable, so in intense situations
/// dynamic will be throttled on how much it can spawn to allow for the station to recover.
/// This heuristic should not be overly complicated and have its calculation based on complex
/// factors, otherwise it is less likely to work well as a heuristic for the chaos going on.
/// We allow dynamic to handle population by having higher pops give higher threat levels, so this
/// doesn't scale based on the population.
/datum/game_mode/dynamic/proc/calculate_danger()
	. = 0
	// Increase the danger level based on the proportion of new antagonists
	// We don't care about how many antagonists there are, since active ones causing chaos
	// will likely continuously trip the dead player heuristic, we only care about
	// new antagonists as there needs to be a safe zone that allows antagonists
	// to get active.
	// This specifically targets antagonist growth.
	for (var/datum/antagonist/antagonist in GLOB.antagonists)
		if (!antagonist.is_station_threat)
			continue
		if (!antagonist.owner || !antagonist.owner.current)
			continue
		// Ignore dead antagonists, since they are no threat
		if (antagonist.owner.current.stat == DEAD)
			continue
		var/threat_for = world.time - antagonist.created_at
		. += (1 - CLAMP01(threat_for / ANTAG_THREAT_DECAY)) * ANTAGONIST_THREAT
	// Increase the danger level for every player that can be revived
	// Ignore players that cannot be recovered as they are considered
	for (var/mob/living/L in GLOB.mob_list)
		// Ignore players in the wrong place
		if (!is_station_level(L.z))
			continue
		// Ignore dead players
		if (L.stat != DEAD)
			continue
		// Ignore dead crew with no ghosts
		if (!L.get_ghost(FALSE, TRUE))
			continue
		// We can't handle this
		if (!L.timeofdeath)
			continue
		var/dead_for = world.time - L.timeofdeath
		// The danger decays as people stay dead for 30 minutes
		. += (1 - CLAMP01(dead_for / DEAD_THREAT_DECAY)) * DEAD_THREAT
	// Decrease threat over time to create a threat trajectory that increases the allowed chaos
	// over time.
	. -= (world.time / (1 HOURS)) * HOURLY_THREAT_DECREASE
	// Do not allow threat increases
	. = max(., 0)
	previous_cache_heuristic = .
	previous_cache_heuristic_time = world.time

/// Get the amount of threat that we are allowed to spend
/datum/game_mode/dynamic/proc/get_allowed_midround_budget()
	return mid_round_budget - calculate_danger()
