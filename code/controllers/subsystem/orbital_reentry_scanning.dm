/**
 * Orbital Reentry Scanning Subsystem
 * Handles raycasting to find which turfs are exposed to reentry heat.
 * Separated from the erosion subsystem so we can budget raycasts per tick
 * independently of damage application.
 *
 * How it works:
 * 1. On Initialize, we determine the reentry direction from map config and
 *    build a randomized list of coordinates along the perpendicular axis
 *    (e.g. if reentry is from the EAST, we scan each Y coordinate).
 * 2. Each fire(), we process a chunk of those coordinates, raycasting inward
 *    from the reentry edge to find the first solid turf (or space turf with
 *    real contents). Results are stored in `target_turfs`.
 * 3. Once we reach the end of the coordinate list, we reshuffle and restart.
 * 4. `target_turfs` is kept trimmed to `max_target_turfs` entries so the
 *    erosion subsystem never has to iterate a list that's grown unbounded.
 *
 * The erosion subsystem depends on us and reads `target_turfs` each fire to
 * apply damage. We never apply damage here, only scan.
 *
 * Activation / deactivation is driven by orbital altitude: the altitude
 * subsystem toggles our `can_fire` flag, just like it does for the drag
 * subsystem. When turned off we clean up and go dormant.
 */

SUBSYSTEM_DEF(orbital_reentry_scanning)
	name = "Orbital Reentry Scanning"
	// Starts disabled, orbital_altitude turns us on/off via can_fire
	can_fire = FALSE
	wait = 1 SECONDS
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
		/datum/controller/subsystem/orbital_altitude,
	)
	priority = FIRE_PRIORITY_STATION_ALTITUDE
	runlevels = RUNLEVEL_GAME

	/// Direction flames come from (based on map config)
	var/reentry_direction = EAST

	/// Station z-levels we scan across
	var/list/station_levels

	/// Randomized list of coordinate indices we iterate through.
	/// For EAST/WEST reentry this holds Y values; for NORTH/SOUTH, X values.
	var/list/scan_order

	/// Our current position inside `scan_order` (1-indexed)
	var/scan_index = 1
	/// Which station z-level index we're currently working on
	var/scan_z_index = 1

	/// The axis length (max Y for E/W reentry, max X for N/S reentry)
	var/axis_length = 0

	/// Maximum number of turfs we keep in the results list.
	/// Capped to the axis length so one full scan pass replaces the old data.
	var/max_target_turfs = 0

	/// Output list, the turfs that the erosion subsystem will consume.
	/// Stored as an assoc list keyed by the turf ref to avoid duplicates,
	/// value is always TRUE.
	var/list/turf/target_turfs = list()

// ── Initialization ──────────────────────────────────────────────────────

/datum/controller/subsystem/orbital_reentry_scanning/Initialize()
	// Read reentry direction from map config
	reentry_direction = SSmapping.current_map.reentry_direction

	// Cache station z-levels
	station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)

	// Build the randomized scan order
	rebuild_scan_order()

	return SS_INIT_SUCCESS

/// Build (or rebuild) the randomized coordinate list based on the reentry
/// direction and current world size.
/datum/controller/subsystem/orbital_reentry_scanning/proc/rebuild_scan_order()
	// The axis we iterate is perpendicular to the reentry direction.
	if(reentry_direction == EAST || reentry_direction == WEST)
		axis_length = world.maxy
	else
		axis_length = world.maxx

	max_target_turfs = axis_length * length(station_levels)

	// Fill with 1..axis_length, then shuffle
	scan_order = list()
	for(var/coord_index in 1 to axis_length)
		scan_order += coord_index

	// Fisher-Yates shuffle so every pass hits coordinates in a random order
	for(var/shuffle_idx in length(scan_order) to 2 step -1)
		var/swap_idx = rand(1, shuffle_idx)
		scan_order.Swap(shuffle_idx, swap_idx)

	// Reset work cursors
	scan_index = 1
	scan_z_index = 1

// ── Per-tick processing ─────────────────────────────────────────────────

/datum/controller/subsystem/orbital_reentry_scanning/fire(resumed)
	// If this is a fresh (non-resumed) fire, we just keep going from where we left off since the list is circular-ish.
	while(scan_z_index <= length(station_levels))
		var/target_z = station_levels[scan_z_index]

		while(scan_index <= length(scan_order))
			var/coord = scan_order[scan_index]
			var/turf/hit = raycast_from_edge(coord, target_z)

			if(hit)
				target_turfs[hit] = TRUE
				// Trim oldest entries if we've exceeded our budget
				trim_target_turfs()

			scan_index++

			if(MC_TICK_CHECK)
				return

		// Finished this z-level, move to the next
		scan_index = 1
		scan_z_index++

	// Completed a full pass over every z-level, reshuffle and restart
	reshuffle_scan_order()
	scan_index = 1
	scan_z_index = 1

// ── Raycasting ──────────────────────────────────────────────────────────

/// Cast a ray inward from the reentry edge at the given perpendicular
/// coordinate and z-level. Returns the first solid turf (or space turf with
/// real contents), or null if nothing was hit.
/datum/controller/subsystem/orbital_reentry_scanning/proc/raycast_from_edge(coord, target_z)
	var/turf/target_tile

	switch(reentry_direction)
		if(EAST)
			// Start at the east edge, step west
			for(var/scan_x in world.maxx to 1 step -1)
				target_tile = locate(scan_x, coord, target_z)
				if(is_valid_hit(target_tile))
					return target_tile
		if(WEST)
			// Start at the west edge, step east
			for(var/scan_x in 1 to world.maxx)
				target_tile = locate(scan_x, coord, target_z)
				if(is_valid_hit(target_tile))
					return target_tile
		if(NORTH)
			// Start at the north edge, step south
			for(var/scan_y in world.maxy to 1 step -1)
				target_tile = locate(coord, scan_y, target_z)
				if(is_valid_hit(target_tile))
					return target_tile
		if(SOUTH)
			// Start at the south edge, step north
			for(var/scan_y in 1 to world.maxy)
				target_tile = locate(coord, scan_y, target_z)
				if(is_valid_hit(target_tile))
					return target_tile

	return null

/// A turf counts as a hit if it is a non-space turf, or if it is space but
/// has real contents (objects / mobs) on it that should take reentry damage.
/datum/controller/subsystem/orbital_reentry_scanning/proc/is_valid_hit(turf/tile)
	if(!tile)
		return FALSE
	if(!isspaceturf(tile))
		return TRUE
	// Space turf, only counts if something real is sitting on it
	return has_real_contents(tile)

/// Returns TRUE if the tile has any non-effect objects or living mobs.
/datum/controller/subsystem/orbital_reentry_scanning/proc/has_real_contents(turf/tile)
	for(var/atom/movable/thing in tile)
		if(isobj(thing) && !iseffect(thing))
			return TRUE
		if(isliving(thing))
			return TRUE
	return FALSE

// ── Helpers ─────────────────────────────────────────────────────────────

/// Called by the altitude subsystem when scanning should stop.
/// Cleans up results and resets work cursors so we start fresh next activation.
/datum/controller/subsystem/orbital_reentry_scanning/proc/deactivate()
	can_fire = FALSE
	target_turfs.Cut()
	scan_index = 1
	scan_z_index = 1

/// Trim the target_turfs list down to max_target_turfs by removing the
/// oldest (first) entries. Because DM assoc lists maintain insertion order
/// this effectively ages out the oldest scan results.
/datum/controller/subsystem/orbital_reentry_scanning/proc/trim_target_turfs()
	while(length(target_turfs) > max_target_turfs)
		// Remove the first (oldest) entry
		target_turfs.Cut(1, 2)

/// Reshuffle the scan order for the next full pass.
/datum/controller/subsystem/orbital_reentry_scanning/proc/reshuffle_scan_order()
	for(var/shuffle_idx in length(scan_order) to 2 step -1)
		var/swap_idx = rand(1, shuffle_idx)
		scan_order.Swap(shuffle_idx, swap_idx)
