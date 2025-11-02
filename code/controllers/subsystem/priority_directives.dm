SUBSYSTEM_DEF(directives)
	name = "Priority Directives"
	wait = 10 SECONDS
	/// The time before the personal directives are issued
	var/next_personal_directive_time
	/// The currently active shared directive, which all uplink holders are given access to
	var/datum/priority_directive/active_directive = null
	/// The time before the next directive is issued
	var/next_directive_time
	/// A list of directive singleton instances
	var/list/directives = list()

/datum/controller/subsystem/directives/Initialize(start_timeofday)
	. = ..()
	next_directive_time = world.time + 20 MINUTES
	next_personal_directive_time = world.time + 5 MINUTES
	for (var/directive_type in subtypesof(/datum/priority_directive))
		directives += new directive_type()

/datum/controller/subsystem/directives/fire(resumed)
	if (active_directive)
		// Are we completed or ended?
		if (active_directive.is_completed() || active_directive.is_timed_out())
			active_directive.finish()
		return
	// Check if we are ready to spawn our next active_directive
	if (world.time < next_directive_time)
		return
	// Find all the minds
	var/list/player_minds = list()
	for (var/datum/mind/player_mind in SSticker.minds)
		if (!ishuman(player_mind.current) || !is_station_level(player_mind.current.z))
			continue
		player_minds += player_mind
	// Bring on the mission
	var/list/valid_directives = list()
	for (var/datum/priority_directive/directive in directives)
		if (!directive.can_run(GLOB.uplinks, player_minds))
			continue
		valid_directives += directive
	if (!length(valid_directives))
		// Try again in a minute
		next_directive_time = world.time + 1 MINUTES
		return
	var/datum/priority_directive/selected = pick(valid_directives)
	selected.start(GLOB.uplinks, player_minds)
	next_directive_time = INFINITY
	active_directive = selected

/client/verb/force_directive()
	set name = "force directive"
	set category = "powerfulbacon"
	if (SSdirectives.active_directive)
		message_admins("not yet")
		return
	// Find all the minds
	var/list/player_minds = list()
	for (var/mob/player in GLOB.alive_mob_list)
		if (!ishuman(player) || !is_station_level(player.z) || !player.mind)
			continue
		player_minds += player.mind
	var/datum/priority_directive/selected = input(src, "What do you want?", "What do you want?") as null|anything in SSdirectives.directives
	if (!selected)
		return
	selected.can_run(GLOB.uplinks, player_minds, TRUE)
	selected.start(GLOB.uplinks, player_minds)
	SSdirectives.next_directive_time = INFINITY
	SSdirectives.active_directive = selected

/datum/controller/subsystem/directives/proc/get_uplink_data(datum/component/uplink/uplink)
	var/data = list()
	data["time"] = world.time
	var/atom/uplink_owner = uplink.parent
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
		if (active_directive)
			var/atom/track_atom = active_directive.get_track_atom()
			var/turf/track_turf = get_turf(track_atom)
			known_objectives += list(list(
				"name" = active_directive.name,
				"tasks" = list(active_directive.get_explanation(uplink)),
				"time" = active_directive.end_at,
				"details" = active_directive.get_details(uplink),
				"reward" = active_directive.tc_reward,
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
	if (!active_directive)
		return
	active_directive.perform_special_action(uplink, user)

/datum/controller/subsystem/directives/proc/queue_directive()
	next_directive_time = world.time + 15 MINUTES

/datum/controller/subsystem/directives/proc/dispatch_personal_objectives()
