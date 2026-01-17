/atom
	/// Holds merger groups currently active on the atom. Do not access directly, use GetMergeGroup() instead.
	var/list/datum/merger/mergers
	/// How this atom should react to having its astar blocking checked
	var/can_astar_pass = CANASTARPASS_DENSITY

/// Gets a merger datum representing the connected blob of objects in the allowed_types argument
/atom/proc/GetMergeGroup(id, list/allowed_types)
	RETURN_TYPE(/datum/merger)
	var/datum/merger/candidate
	if(mergers)
		candidate = mergers[id]
	if(!candidate)
		new /datum/merger(id, allowed_types, src)
		candidate = mergers[id]
	return candidate

/**
 * This proc is used for telling whether something can pass by this atom in a given direction, for use by the pathfinding system.
 *
 * Trying to generate one long path across the station will call this proc on every single object on every single tile that we're seeing if we can move through, likely
 * multiple times per tile since we're likely checking if we can access said tile from multiple directions, so keep these as lightweight as possible.
 *
 * For turfs this will only be used if pathing_pass_method is TURF_PATHING_PASS_PROC
 *
 * Arguments:
 * * to_dir - What direction we're trying to move in, relevant for things like directional windows that only block movement in certain directions
 * * pass_info - Datum that stores info about the thing that's trying to pass us
 *
 * IMPORTANT NOTE: /turf/proc/LinkBlockedWithAccess assumes that overrides of CanAStarPass will always return true if density is FALSE
 * If this is NOT you, ensure you edit your can_astar_pass variable. Check __DEFINES/path.dm
 **/
/atom/proc/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(pass_info.pass_flags & pass_flags_self)
		return TRUE
	. = !density
