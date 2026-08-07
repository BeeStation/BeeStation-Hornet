/datum/antagonist/vampire/proc/setup_tracker(mob/living/body)
	cleanup_tracker()
	tracker = new(body, REF(src))

	for(var/datum/antagonist/vassal/vassal in vassals)
		vassal.monitor?.add_to_tracking_network(tracker.tracking_beacon)
	tracker.tracking_beacon.toggle_visibility(TRUE)

/datum/antagonist/vampire/proc/cleanup_tracker()
	if(tracker)
		// Remove the tracking beacon from all vassals, maybe this fixes it..
		for(var/datum/antagonist/vassal/vassal in vassals)
			if(!vassal.monitor?.tracking)
				continue
			var/atom/movable/screen/arrow = vassal.monitor.tracking[tracker.tracking_beacon]
			vassal.monitor.tracking.Remove(tracker.tracking_beacon)
			if(arrow)
				if(vassal.monitor.updating?.hud_used)
					vassal.monitor.updating.hud_used.team_finder_arrows -= arrow
				qdel(arrow)
		QDEL_NULL(tracker)

/**
 * An abstract object contained within the vampire, used to host the team_monitor component.
**/
/obj/effect/abstract/vampire_tracker_holder
	name = "vampire tracker holder"
	desc = span_danger("You <b>REALLY</b> shouldn't be seeing this!")

	var/datum/component/tracking_beacon/tracking_beacon

/obj/effect/abstract/vampire_tracker_holder/Initialize(mapload, key)
	. = ..()
	tracking_beacon = AddComponent(/datum/component/tracking_beacon, \
		_frequency_key = key, \
		_colour = "#960000", \
		_global = TRUE, \
		_always_update = TRUE, \
	)

/obj/effect/abstract/vampire_tracker_holder/Destroy(force)
	if(tracking_beacon)
		tracking_beacon.toggle_visibility(FALSE)
		tracking_beacon = null // Let the component system handle cleanup via parent ..()
	. = ..()
