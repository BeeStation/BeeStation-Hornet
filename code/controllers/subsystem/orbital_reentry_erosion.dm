/**
 * Orbital Reentry Erosion Subsystem
 * Handles the application of damage and fire effects to station tiles, objects, and mobs during orbital reentry.
 * Damage is based on current orbital altitude and increases as the station descends.
 *
 * This subsystem does NOT do any raycasting itself. It reads the list of
 * exposed turfs provided by SSorbital_reentry_scanning and applies
 * damage / fire effects to each one, yielding to the tick budget as needed.
 */

SUBSYSTEM_DEF(orbital_reentry_erosion)
	name = "Orbital Reentry Erosion"
	// Starts disabled, orbital_altitude turns us on/off via can_fire
	can_fire = FALSE
	wait = 1 SECONDS
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
		/datum/controller/subsystem/orbital_altitude,
		/datum/controller/subsystem/orbital_reentry_scanning,
	)
	// Only allowed to use small portions of tick
	priority = FIRE_PRIORITY_STATION_ALTITUDE
	runlevels = RUNLEVEL_GAME
	/// Direction flames come from (based on map config)
	var/reentry_direction = EAST
	/// Fire effects keyed by turf, reused across fires instead of recreated
	var/list/created_fires = list()
	/// Our position inside the target turfs snapshot for resumable processing
	var/work_index = 1
	/// Snapshot of turfs we're working through this fire
	var/list/turf/work_turfs
	/// Cached damage multiplier for the current fire
	var/current_damage_multiplier = 0

/datum/controller/subsystem/orbital_reentry_erosion/Initialize()
	// Disable for planetary stations
	if(SSmapping.current_map.planetary_station)
		can_fire = FALSE
		return SS_INIT_SUCCESS

	// Get reentry direction from map config
	reentry_direction = SSmapping.current_map.reentry_direction

	return SS_INIT_SUCCESS


/datum/controller/subsystem/orbital_reentry_erosion/fire(resumed)
	// Calculate damage multiplier based on altitude
	var/current_altitude = SSorbital_altitude.orbital_altitude
	current_damage_multiplier = get_damage_multiplier(current_altitude)

	// On a fresh (non-resumed) fire, snapshot the scanning results.
	// Fire effects are NOT destroyed here, they persist and get cleaned up
	// only when their turf is no longer in the scan results or on deactivate.
	if(!resumed)
		// Take a snapshot of whatever the scanning subsystem has found so far.
		// The keys of the assoc list are the turfs themselves.
		work_turfs = SSorbital_reentry_scanning.target_turfs.Copy()
		work_index = 1

		// Clean up fire effects on turfs that are no longer exposed
		var/list/stale_turfs = created_fires - work_turfs
		for(var/turf/stale_turf as anything in stale_turfs)
			var/obj/effect/reentry_fire/fire_effect = created_fires[stale_turf]
			if(fire_effect)
				qdel(fire_effect)
			created_fires -= stale_turf
			if(MC_TICK_CHECK)
				return

	// Nothing to do if scanning hasn't found anything yet
	if(!length(work_turfs))
		return

	// Iterate through the snapshot, yielding to the tick budget as needed
	while(work_index <= length(work_turfs))
		var/turf/target_tile = work_turfs[work_index]
		work_index++

		if(QDELETED(target_tile))
			continue

		// Apply damage to the tile and everything on it
		apply_erosion_damage(target_tile, current_damage_multiplier)

		// Tick check, save progress and continue on the next fire
		if(MC_TICK_CHECK)
			return

/// Called by the altitude subsystem when erosion should stop.
/// Cleans up fire effects and resets work state.
/datum/controller/subsystem/orbital_reentry_erosion/proc/deactivate()
	can_fire = FALSE
	for(var/turf/key as anything in created_fires)
		var/obj/effect/reentry_fire/fire_effect = created_fires[key]
		if(fire_effect)
			qdel(fire_effect)
	created_fires.Cut()
	work_turfs = null
	work_index = 1

/datum/controller/subsystem/orbital_reentry_erosion/proc/get_damage_multiplier(altitude)
	// No damage above EROSION_ALTITUDE_START
	if (altitude >= EROSION_ALTITUDE_START)
		return 0

	// Light effects only between EROSION_ALTITUDE_CRITICAL and EROSION_ALTITUDE_START
	if (altitude >= EROSION_ALTITUDE_CRITICAL)
		return (EROSION_ALTITUDE_START - altitude) / (EROSION_ALTITUDE_START - EROSION_ALTITUDE_CRITICAL) * 0.1

	// Escalating damage between EROSION_ALTITUDE_CRITICAL and EROSION_ALTITUDE_SEVERE
	if (altitude >= EROSION_ALTITUDE_SEVERE)
		return 0.1 + (EROSION_ALTITUDE_CRITICAL - altitude) / (EROSION_ALTITUDE_CRITICAL - EROSION_ALTITUDE_SEVERE) * 2.9

	// Maximum damage at or below EROSION_ALTITUDE_SEVERE
	return 3.0

/datum/controller/subsystem/orbital_reentry_erosion/proc/apply_erosion_damage(turf/target_tile, damage_multiplier)
	// Very light fire effect only (no damage)
	if (damage_multiplier <= 0.1)
		// Only spawn fire visual, no actual damage
		if (prob(damage_multiplier * 100))
			ensure_fire_effect(target_tile)
		return

	// Create fire effect (reuses existing one if present)
	ensure_fire_effect(target_tile)

	// Calculate actual damage values with much higher scaling
	var/fire_temp = 600 + (1400 * damage_multiplier)  // 600 to 4800K at max
	var/fire_volume = 200 + (800 * damage_multiplier)  // 200 to 2600 at max
	var/plasma_amount = 5 + (45 * damage_multiplier)  // 5 to 140 at max
	var/o2_amount = 5 + (45 * damage_multiplier)  // 5 to 140 at max

	// Quadratic scaling for aggressive ramp-up
	var/tile_damage = 150 * damage_multiplier * damage_multiplier  // 0 to 1350
	var/obj_damage = 8 * damage_multiplier * damage_multiplier  // 0 to 72
	var/mob_damage = 3 * damage_multiplier * damage_multiplier  // 0 to 27

	// Apply damage to things
	var/dense = FALSE
	for (var/atom/thing in target_tile)

		if(QDELETED(thing))
			continue

		// Objects
		if (isobj(thing))
			if (iseffect(thing)) // With exceptions :3
				continue

			var/obj/obj_thing = thing
			obj_thing.newtonian_move(REVERSE_DIR(reentry_direction))

			if (obj_thing.density)
				dense = TRUE
			obj_thing.fire_act(fire_volume, fire_temp)
			// fire_act may have destroyed the object
			if(QDELETED(obj_thing))
				continue
			// Apply object damage. We use MELEE flag instead of FIRE to bypass fire armor. I know it's janky.
			// Orbital reentry heat is far beyond normal fire resistance!
			obj_thing.take_damage(obj_damage, BURN, MELEE)

		// Mobs
		if (ismob(thing))
			if (isobserver(thing))
				continue

			var/mob/mob_thing = thing
			mob_thing.newtonian_move(REVERSE_DIR(reentry_direction))

			mob_thing.fire_act(fire_volume, fire_temp) // Does this do anything on mobs?

			if (isliving(mob_thing))
				var/mob/living/living_thing = mob_thing
				living_thing.adjustFireLoss(mob_damage)

	// Apply damage to turf if not blocked
	if (!dense)
		target_tile.take_damage(tile_damage, BURN, MELEE, TRUE, reentry_direction)
		if (isopenturf(target_tile))
			var/turf/open/open_tile = target_tile
			open_tile.atmos_spawn_air("plasma=[plasma_amount];o2=[o2_amount];TEMP=[fire_temp]")

/// Ensures a fire effect exists on the given turf, reusing an existing one
/// or creating a new one as needed.
/datum/controller/subsystem/orbital_reentry_erosion/proc/ensure_fire_effect(turf/target_tile)
	var/obj/effect/reentry_fire/existing = created_fires[target_tile]
	if(existing && !QDELETED(existing))
		return // Already have a valid fire effect here
	var/obj/effect/reentry_fire/new_fire = new(target_tile)
	created_fires[target_tile] = new_fire

/obj/effect/reentry_fire
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "light"
	layer = GASFIRE_LAYER
	blend_mode = BLEND_ADD
	light_system = MOVABLE_LIGHT
	light_range = LIGHT_RANGE_FIRE
	light_power = 1
	light_color = LIGHT_COLOR_FIRE
