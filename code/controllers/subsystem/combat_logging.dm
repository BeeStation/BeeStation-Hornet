// The time in which combat will be considered to be terminated
#define COMBAT_TIMEOUT 60 SECONDS

SUBSYSTEM_DEF(combat_logging)
	name = "Combat Logging"
	wait = 10 SECONDS
	flags = SS_NO_INIT | SS_KEEP_TIMING

	var/list/current_run = list()
	var/list/active_combat_instances = list()

/datum/controller/subsystem/combat_logging/fire(resumed)
	if (!resumed)
		current_run = active_combat_instances.Copy()
	while (length(current_run))
		// Get the combat log
		var/datum/combat_log/current = current_run[length(current_run)]
		current_run.len --
		// Check for timeout, if world.time surpasses the timeout
		if (current.most_recent_entry + COMBAT_TIMEOUT < world.time)
			current.expire()

/datum/controller/subsystem/combat_logging/proc/log_combat(mob/living/attacker, mob/living/defender, tool_name)
	if (!attacker.mind || !defender.mind || !tool_name || attacker == defender || !ishuman(attacker) || !ishuman(defender) || attacker.stat == DEAD || defender.stat == DEAD || SSticker.current_state != GAME_STATE_PLAYING)
		return
	// Attempt to find a combat entry
	var/datum/combat_log/used_log
	for (var/datum/combat_log/combat_log in active_combat_instances)
		if ((combat_log.a == attacker && combat_log.b == defender) || (combat_log.b == attacker && combat_log.a == defender))
			used_log = combat_log
			break
	// Or create one
	if (!used_log)
		used_log = new()
		used_log.a = attacker
		used_log.a_job = attacker.mind.assigned_role || "none"
		used_log.a_status = attacker.mind.special_role || "none"
		used_log.b = defender
		used_log.b_job = defender.mind.assigned_role || "none"
		used_log.b_status = defender.mind.special_role || "none"
	used_log.most_recent_entry = world.time
	// Log the toolname
	if (islist(tool_name))
		for (var/tool in tool_name)
			if (attacker == used_log.a)
				used_log.a_used_tools |= tool
			else if (attacker == used_log.b)
				used_log.b_used_tools |= tool
	else
		if (attacker == used_log.a)
			used_log.a_used_tools |= tool_name
		else if (attacker == used_log.b)
			used_log.b_used_tools |= tool_name

/datum/controller/subsystem/combat_logging/proc/generate_stat_tab()
	var/list/data = list()
	data["Active Combat"] = GENERATE_STAT_TEXT("Active combat instances will display below. Click to follow the initiator.")
	for (var/datum/combat_log/log in active_combat_instances)
		data["[log.a.name] ([log.a_job]) vs [log.b.name] ([log.b_job])"] = list(
			text = "Click to orbit",
			type = STAT_BUTTON,
			action = "orbit",
			params = list("ref" = REF(log.a))
		)
	return data

#define COMBAT_LOG_VICTOR_NONE 0
#define COMBAT_LOG_VICTOR_A 1
#define COMBAT_LOG_VICTOR_B 2
#define COMBAT_LOG_VICTOR_BOTH 3

#define COMBAT_LOG_RESULT_HANDCUFF 1
#define COMBAT_LOG_RESULT_CRIT 2
#define COMBAT_LOG_RESULT_TIMEOUT 3

/datum/combat_log
	// What was the result?
	var/victor = COMBAT_LOG_VICTOR_BOTH
	var/end_result = COMBAT_LOG_RESULT_TIMEOUT
	// When was our last log
	var/most_recent_entry
	// A person entries
	var/mob/living/a
	var/a_used_tools = list()
	var/a_job
	var/a_status
	// B person entries
	var/mob/living/b
	var/b_used_tools = list()
	var/b_job
	var/b_status

/datum/combat_log/New()
	. = ..()
	most_recent_entry = world.time
	SScombat_logging.active_combat_instances += src

/datum/combat_log/Destroy(force, ...)
	SScombat_logging.active_combat_instances -= src
	return ..()

/// Update the status of the combat log, if someone is in crit, dead, or handcuffed then consider the combat to be over
/datum/combat_log/proc/update_status()
	victor = COMBAT_LOG_VICTOR_BOTH
	end_result = COMBAT_LOG_RESULT_TIMEOUT

	if (iscarbon(a))
		var/mob/living/carbon/carbon_a = a
		if (carbon_a.handcuffed)
			victor &= COMBAT_LOG_VICTOR_B
			end_result = COMBAT_LOG_RESULT_HANDCUFF
	if (iscarbon(b))
		var/mob/living/carbon/carbon_b = b
		if (carbon_b.handcuffed)
			victor &= COMBAT_LOG_VICTOR_A
			end_result = COMBAT_LOG_RESULT_HANDCUFF

	if (a.stat > SOFT_CRIT)
		victor &= COMBAT_LOG_VICTOR_B
		end_result = COMBAT_LOG_RESULT_CRIT
	if (b.stat > SOFT_CRIT)
		victor &= COMBAT_LOG_VICTOR_A
		end_result = COMBAT_LOG_RESULT_CRIT

/// No action within the time limit, expire the logs
/datum/combat_log/proc/expire()
	// Final status check
	update_status()
	// Resolve the combat
	resolve()

/datum/combat_log/proc/resolve()
	// If too many items were used, ignore this combat since we can't know for sure which one was impactful and it could lag our results
	if (length(a_used_tools) > 5 || length(b_used_tools) > 5)
		return
	// Log the tools that were used, and by what role/status
	// Log basic occurances of the tool and result
	for (var/tool_used in length(a_used_tools) ? a_used_tools : list("unarmed"))
		SSblackbox.record_feedback("nested tally", "combat_weapon_usage_job", 1, list("[a_job]", "[tool_used]"))
		SSblackbox.record_feedback("nested tally", "combat_weapon_usage_status", 1, list("[a_status]", "[tool_used]"))
		SSblackbox.record_feedback("nested tally", "combat_weapon_used", 1, list("[tool_used]"))
		SSblackbox.record_feedback("nested tally", "combat_weapon_result", 1, list("[tool_used]", "[get_a_result()]", "[get_end_result()]"))
	for (var/tool_used in length(b_used_tools) ? b_used_tools : list("unarmed"))
		SSblackbox.record_feedback("nested tally", "combat_weapon_usage_job", 1, list("[b_job]", "[tool_used]"))
		SSblackbox.record_feedback("nested tally", "combat_weapon_usage_status", 1, list("[b_status]", "[tool_used]"))
		SSblackbox.record_feedback("nested tally", "combat_weapon_used", 1, list("[tool_used]"))
		SSblackbox.record_feedback("nested tally", "combat_weapon_result", 1, list("[tool_used]", "[get_b_result()]", "[get_end_result()]"))
	// Record items with relation to each other
	if (victor == COMBAT_LOG_VICTOR_A || victor == COMBAT_LOG_VICTOR_B)
		for (var/winning_item in victor == COMBAT_LOG_VICTOR_A ? (length(a_used_tools) ? a_used_tools : list("unarmed")) : (length(b_used_tools) ? b_used_tools : list("unarmed")))
			for (var/losing_item in victor == COMBAT_LOG_VICTOR_A ? (length(b_used_tools) ? b_used_tools : list("unarmed")) : (length(a_used_tools) ? a_used_tools : list("unarmed")))
				SSblackbox.record_feedback("nested tally", "combat_weapon_vs_wins", 1, list("[winning_item]", "[losing_item]"))
				SSblackbox.record_feedback("nested tally", "combat_weapon_vs_loss", 1, list("[losing_item]", "[winning_item]"))
	qdel(src)

/datum/combat_log/proc/get_end_result()
	switch (end_result)
		if (COMBAT_LOG_RESULT_HANDCUFF)
			return "handcuff"
		if (COMBAT_LOG_RESULT_CRIT)
			return "health"
		if (COMBAT_LOG_RESULT_TIMEOUT)
			return "timeout"

/datum/combat_log/proc/get_a_result()
	if (victor == COMBAT_LOG_VICTOR_BOTH)
		return "unresolved"
	if (victor == COMBAT_LOG_VICTOR_NONE)
		return "mutual_loss"
	if (victor == COMBAT_LOG_VICTOR_A)
		return "win"
	if (victor == COMBAT_LOG_VICTOR_B)
		return "loss"

/datum/combat_log/proc/get_b_result()
	if (victor == COMBAT_LOG_VICTOR_BOTH)
		return "unresolved"
	if (victor == COMBAT_LOG_VICTOR_NONE)
		return "mutual_loss"
	if (victor == COMBAT_LOG_VICTOR_B)
		return "win"
	if (victor == COMBAT_LOG_VICTOR_A)
		return "loss"

#undef COMBAT_TIMEOUT

#undef COMBAT_LOG_VICTOR_NONE
#undef COMBAT_LOG_VICTOR_A
#undef COMBAT_LOG_VICTOR_B
#undef COMBAT_LOG_VICTOR_BOTH

#undef COMBAT_LOG_RESULT_HANDCUFF
#undef COMBAT_LOG_RESULT_CRIT
#undef COMBAT_LOG_RESULT_TIMEOUT
