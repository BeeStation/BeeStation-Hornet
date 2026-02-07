SUBSYSTEM_DEF(directives)
	name = "Priority Directives"
	wait = 10 SECONDS
	/// The currently active shared directive, which all uplink holders are given access to
	var/list/datum/priority_directive/active_directives = list()
	/// The time before the next directive is issued
	var/next_directive_time
	/// A list of directive singleton instances
	var/list/directive_types = list()
	/// Next time when personal objectives are given out.
	var/personal_objectives_time = null

/datum/controller/subsystem/directives/Initialize()
	next_directive_time = world.time + 5 MINUTES
	directive_types = subtypesof(/datum/priority_directive)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/directives/fire(resumed)
	// Find all the minds
	var/list/player_minds = list()
	for (var/datum/mind/player_mind in SSticker.minds)
		if (!ishuman(player_mind.current) || !is_station_level(player_mind.current.z))
			continue
		player_minds += player_mind
	check_personal_directives(player_minds)
	// Run active directives
	for (var/datum/priority_directive/active_directive in active_directives)
		// Are we completed or ended?
		if (active_directive.is_completed() || active_directive.is_timed_out())
			active_directive.finish()
	// Check if we are ready to spawn our next active_directive
	if (world.time < next_directive_time)
		return
	// Filter uplinks to those which can get team missions
	var/list/filtered_uplinks = list()
	for (var/datum/component/uplink/uplink in GLOB.uplinks)
		if (!(uplink.directive_flags & DIRECTIVE_FLAG_COMPETITIVE))
			continue
		filtered_uplinks += uplink
	// Bring on the mission
	var/list/valid_directives = list()
	for (var/datum/priority_directive/directive as anything in directive_types)
		if (!directive:shared)
			continue
		var/datum/priority_directive/instance = new directive
		if (!instance.can_run(filtered_uplinks, player_minds))
			continue
		valid_directives += instance
	// 30% chance for solo global objectives instead of team-based ones
	if (!length(valid_directives) || prob(30))
		// Give out personal directives instead
		var/longest_objective = world.time
		for (var/datum/component/uplink/uplink in GLOB.uplinks)
			if (!(uplink.directive_flags & DIRECTIVE_FLAG_COMPETITIVE))
				continue
			var/datum/priority_directive/result = give_personal_objective(player_minds, uplink)
			if (!result)
				continue
			longest_objective = max(longest_objective, world.time + result.last_for)
		// Queue the next one 10 minutes after half the time of the longest objective.
		// The longest objective will likely be 30 minute (assassination), so this gives the next objective
		// after 25 minutes. This means you might get 2 objectives at the same time, but that is okay.
		next_directive_time = world.time + 0.5 * longest_objective + 10 MINUTES
		return
	var/datum/priority_directive/selected = pick(valid_directives)
	selected.start(filtered_uplinks)
	next_directive_time = INFINITY
	active_directives += selected

/// Check allocation for personal directives
/datum/controller/subsystem/directives/proc/check_personal_directives(list/player_minds)
	for (var/datum/component/uplink/uplink in GLOB.uplinks)
		// Cannot be allocated personal directives
		if (!(uplink.directive_flags & DIRECTIVE_FLAG_PERSONAL))
			continue
		// Not ready to allocate
		if (uplink.next_personal_objective_time > world.time)
			continue
		give_personal_objective(player_minds, uplink)

/datum/controller/subsystem/directives/proc/give_personal_objective(list/player_minds, datum/component/uplink/uplink)
	var/list/uplink_list = list(uplink)
	// Determine valid objectives
	var/list/valid_directives = list()
	for (var/datum/priority_directive/directive as anything in directive_types)
		if (directive:shared)
			continue
		var/datum/priority_directive/instance = new directive
		if (!instance.can_run(uplink_list, player_minds))
			continue
		valid_directives += instance
	// No directives to allocate
	if (!length(valid_directives))
		return null
	var/datum/priority_directive/selected = pick(valid_directives)
	selected.start(uplink_list)
	active_directives += selected
	uplink.next_personal_objective_time = get_next_personal_objective_time()
	return selected

/datum/controller/subsystem/directives/proc/get_uplink_data(datum/component/uplink/uplink)
	var/data = list()
	data["time"] = world.time
	var/atom/uplink_owner = uplink.parent
	var/obj/item/implant/uplink_implant = uplink_owner
	if (istype(uplink_implant))
		uplink_owner = uplink_implant.imp_in || uplink_owner

	var/turf/uplink_turf = uplink_owner && get_turf(uplink_owner)
	if (istype(uplink_turf))
		data["pos_x"] = uplink_turf?.x
		data["pos_y"] = uplink_turf?.y
		data["pos_z"] = uplink_turf?.z
	// The uplink can only detect syndicate assigned objectives of the owner
	if (uplink.owner)
		var/list/known_objectives = list()
		for (var/datum/antagonist/antagonist_type in uplink.owner.antag_datums)
			// The syndicate uplink is only aware of syndicate-given objectives.
			if (antagonist_type.faction != FACTION_SYNDICATE)
				continue
			for (var/datum/objective/objective in antagonist_type.objectives)
				var/atom/tracking_target = objective.get_tracking_target(uplink_turf)
				var/turf/tracking_turf = tracking_target && get_turf(tracking_target)
				known_objectives += list(list(
					"name" = objective.name,
					"tasks" = list(objective.explanation_text),
					"track_x" = tracking_turf?.x,
					"track_y" = tracking_turf?.y,
					"track_z" = tracking_turf?.z,
				))
		// Add the priority directive
		for (var/datum/priority_directive/active_directive in active_directives)
			if (!active_directive.get_team(uplink))
				continue
			var/atom/track_atom = active_directive.get_track_atom(uplink_turf, uplink)
			var/turf/track_turf = get_turf(track_atom)
			known_objectives += list(list(
				"name" = active_directive.name,
				"tasks" = list(active_directive.get_explanation(uplink)),
				"time" = active_directive.end_at,
				"details" = active_directive.get_details(uplink),
				"reward" = ceil(active_directive.tc_reward * uplink.directive_tc_multiplier),
				"track_x" = track_turf?.x,
				"track_y" = track_turf?.y,
				"track_z" = track_turf?.z,
				"action" = active_directive.get_special_action()?.action_name,
				"rep_loss" = active_directive.reputation_loss,
				"rep_gain" = active_directive.reputation_reward,
			))
		data["objectives"] =  known_objectives
	return data

/datum/controller/subsystem/directives/proc/directive_action(datum/component/uplink/uplink, mob/living/user)
	for (var/datum/priority_directive/directive in active_directives)
		if (!directive.get_team(uplink))
			continue
		directive.perform_special_action(uplink, user)

/datum/controller/subsystem/directives/proc/queue_directive()
	next_directive_time = world.time + rand(5 MINUTES, 10 MINUTES)

/datum/controller/subsystem/directives/proc/get_next_personal_objective_time()
	// If the next object will be granted within 5 minutes, start a new batch
	if (world.time + 5 MINUTES > personal_objectives_time)
		personal_objectives_time = world.time + 25 MINUTES
	return personal_objectives_time
