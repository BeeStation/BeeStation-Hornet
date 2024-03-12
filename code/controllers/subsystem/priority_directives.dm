SUBSYSTEM_DEF(directives)
	name = "Priority Directives"
	wait = 10 SECONDS
	var/list/current = list()
	var/datum/priority_directive/directive = null
	var/next_directive_time

/datum/controller/subsystem/directives/Initialize(start_timeofday)
	. = ..()
	next_directive_time = world.time + rand(20 MINUTES, 30 MINUTES)

/datum/controller/subsystem/directives/fire(resumed)
	if (directive)
		// Are we completed or ended?
		if (directive.is_completed() || world.time > directive.end_at)
			directive.finish()
		return
	// Check if we are ready to spawn our next directive
	if (world.time < next_directive_time)
		return
	// Identify all the uplinks and spawn a directive
	if (!resumed)
		// Find all uplinks
		for (var/mob/antag in SSticker.mode.current_players[CURRENT_LIVING_ANTAGS])
			var/datum/component/uplink/uplink = antag.mind.find_syndicate_uplink()
			if (!uplink)
				continue
			current += uplink
		if (!length(current))
			can_fire = FALSE
	// Bring on the mission
	directive = new /obj/item/storage/deaddrop_box()
	directive.activate()
