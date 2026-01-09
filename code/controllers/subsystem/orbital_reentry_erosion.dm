// Orbital altitude thresholds for erosion (matches orbital_altitude.dm)
#define EROSION_ALTITUDE_START 95000  // 95km - Light fire effects start
#define EROSION_ALTITUDE_CRITICAL 90000  // 90km - Damage begins
#define EROSION_ALTITUDE_SEVERE 85000  // 85km - Heavy damage
#define EROSION_ALTITUDE_EXTREME 80000  // 80km - Maximum damage

SUBSYSTEM_DEF(orbital_reentry_erosion)
	name = "Orbital Reentry Erosion"
	wait = 1 SECONDS
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
		/datum/controller/subsystem/orbital_altitude,
	)
	// Only allowed to use small portions of tick
	priority = FIRE_PRIORITY_ORBITAL_STUFF
	runlevels = RUNLEVEL_GAME
	/// Station levels
	var/list/station_levels
	/// Record our current work position
	var/work_z
	var/work_coord
	/// Direction flames come from (based on map config)
	var/reentry_direction = EAST
	var/list/created_fires = list()
	/// Is the subsystem currently active (altitude-based)?
	var/erosion_active = FALSE

/datum/controller/subsystem/orbital_reentry_erosion/Initialize()
	// Disable for planetary stations
	if(SSmapping.current_map.planetary_station)
		can_fire = FALSE
		return SS_INIT_SUCCESS

	// Get reentry direction from map config
	reentry_direction = SSmapping.current_map.reentry_direction

	// What are the station z-levels?
	station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/orbital_reentry_erosion/proc/has_real_contents(turf/tile)
	// Check if the tile has any real contents (objects or mobs)
	if (!tile)
		return FALSE

	var/has_contents = FALSE
	for (var/atom/movable/thing in tile)
		// Break for the first real content found
		if (is_real(thing))
			has_contents = TRUE
			break

	return has_contents

/datum/controller/subsystem/orbital_reentry_erosion/proc/is_real(atom/thing)
	if (isobj(thing))
		if (!iseffect(thing)) // With exceptions :3
			return TRUE

	if (ismob(thing))
		if (!isobserver(thing))
			return TRUE

	return FALSE


/datum/controller/subsystem/orbital_reentry_erosion/fire(resumed)
	// Check if we should be active based on altitude
	var/current_altitude = SSorbital_altitude.orbital_altitude
	var/should_be_active = current_altitude < EROSION_ALTITUDE_START

	// Handle activation/deactivation
	if (should_be_active && !erosion_active)
		erosion_active = TRUE

	else if (!should_be_active && erosion_active)
		erosion_active = FALSE
		// Clear all fires when deactivating
		for (var/thing in created_fires)
			qdel(thing)
		created_fires.Cut()
		return

	// If not active, don't process
	if (!erosion_active)
		return

	// Calculate damage multiplier based on altitude
	var/damage_multiplier = get_damage_multiplier(current_altitude)

	// Set the initial working conditions
	if (!resumed)
		work_z = 1
		work_coord = 1
		// Clear old fires
		for (var/thing in created_fires)
			qdel(thing)
		created_fires.Cut()

	// Start working
	var/max_coord = (reentry_direction == EAST || reentry_direction == WEST) ? world.maxy : world.maxx

	while (work_z <= length(station_levels))
		var/target_z = station_levels[work_z]

		// Always scan from the edge to find the first valid target for this coordinate
		var/current_target_pos
		var/turf/target_tile

		if (reentry_direction == EAST || reentry_direction == WEST)
			// Start from the edge based on direction
			current_target_pos = reentry_direction == EAST ? world.maxx : 1
			var/x_increment = reentry_direction == EAST ? -1 : 1

			// Scan until we find a valid target
			while (current_target_pos > 0 && current_target_pos <= world.maxx)
				target_tile = locate(current_target_pos, work_coord, target_z)

				// Found a valid target (solid turf or space with real contents)
				if (target_tile && (!isspaceturf(target_tile) || has_real_contents(target_tile)))
					break

				current_target_pos += x_increment
		else
			// Start from the edge based on direction
			current_target_pos = reentry_direction == SOUTH ? 1 : world.maxy
			var/y_increment = reentry_direction == SOUTH ? 1 : -1

			// Scan until we find a valid target
			while (current_target_pos > 0 && current_target_pos <= world.maxy)
				target_tile = locate(work_coord, current_target_pos, target_z)

				// Found a valid target (solid turf or space with real contents)
				if (target_tile && (!isspaceturf(target_tile) || has_real_contents(target_tile)))
					break

				current_target_pos += y_increment

		// Apply damage to the tile and everything on it (only if it's valid and not empty space)
		if (target_tile && (!isspaceturf(target_tile) || has_real_contents(target_tile)))
			apply_erosion_damage(target_tile, damage_multiplier)

		// Increment coordinate
		work_coord++

		// Increment z if necessary
		if (work_coord > max_coord)
			work_coord = 1
			work_z++

		// Tick check, abort this run and continue on the next
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/orbital_reentry_erosion/proc/get_damage_multiplier(altitude)
	// No damage above EROSION_ALTITUDE_START
	if (altitude >= EROSION_ALTITUDE_START)
		return 0

	// Light effects only between EROSION_ALTITUDE_CRITICAL and EROSION_ALTITUDE_START
	if (altitude >= EROSION_ALTITUDE_CRITICAL)
		return (EROSION_ALTITUDE_START - altitude) / (EROSION_ALTITUDE_START - EROSION_ALTITUDE_CRITICAL) * 0.1

	// Moderate damage between EROSION_ALTITUDE_CRITICAL and EROSION_ALTITUDE_SEVERE
	if (altitude >= EROSION_ALTITUDE_SEVERE)
		return 0.1 + (EROSION_ALTITUDE_CRITICAL - altitude) / (EROSION_ALTITUDE_CRITICAL - EROSION_ALTITUDE_SEVERE) * 1.5

	// Heavy damage between EROSION_ALTITUDE_SEVERE and EROSION_ALTITUDE_EXTREME
	if (altitude >= EROSION_ALTITUDE_EXTREME)
		return 1.5 + (EROSION_ALTITUDE_SEVERE - altitude) / (EROSION_ALTITUDE_SEVERE - EROSION_ALTITUDE_EXTREME) * 1.5

	// Maximum damage below EROSION_ALTITUDE_EXTREME. Though this should not really be reachable.
	return 4.0

/datum/controller/subsystem/orbital_reentry_erosion/proc/apply_erosion_damage(turf/target_tile, damage_multiplier)
	// Very light fire effect only (no damage)
	if (damage_multiplier <= 0.1)
		// Only spawn fire visual, no actual damage
		if (prob(damage_multiplier * 100))
			created_fires += new /obj/effect/reentry_fire(target_tile)
		return

	// Create fire effect
	created_fires += new /obj/effect/reentry_fire(target_tile)

	// Calculate actual damage values with much higher scaling
	var/fire_temp = 600 + (1400 * damage_multiplier)  // 600 to 4800K at max
	var/fire_volume = 200 + (800 * damage_multiplier)  // 200 to 2600 at max
	var/plasma_amount = 5 + (45 * damage_multiplier)  // 5 to 140 at max
	var/o2_amount = 5 + (45 * damage_multiplier)  // 5 to 140 at max

	// Yeah we go exponential
	var/tile_damage = ((100 * damage_multiplier) * (damage_multiplier * damage_multiplier)) // 0 to 2700
	var/obj_damage = ((2 * damage_multiplier) * (damage_multiplier * damage_multiplier)) // 0 to 54
	var/mob_damage = (1 * (damage_multiplier * damage_multiplier)) // 0 to 9

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
			// Apply object damage
			obj_thing.take_damage(obj_damage, BURN, FIRE)

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
		target_tile.take_damage(tile_damage, BURN, FIRE, TRUE, reentry_direction, fire_volume)
		if (isopenturf(target_tile))
			var/turf/open/open_tile = target_tile
			open_tile.atmos_spawn_air("plasma=[plasma_amount];o2=[o2_amount];TEMP=[fire_temp]")

#undef EROSION_ALTITUDE_START
#undef EROSION_ALTITUDE_CRITICAL
#undef EROSION_ALTITUDE_SEVERE
#undef EROSION_ALTITUDE_EXTREME

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
