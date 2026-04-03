/**
 * Orbital Reentry Drag Subsystem
 * Handles the spawning of invisible drag meteors during critical orbit.
 * Separated from orbital_altitude so that meteor spawning runs at its own pace
 * without affecting the core altitude/physics subsystem's tick budget.
 *
 * Activation/deactivation is driven by the current orbital altitude:
 * we turn on when the station enters critical orbit, and off when it recovers.
 */

SUBSYSTEM_DEF(orbital_reentry_drag)
	name = "Orbital Reentry Drag"
	// Starts disabled, orbital_altitude turns us on/off via can_fire
	can_fire = FALSE
	wait = 1 SECONDS
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
		/datum/controller/subsystem/orbital_altitude,
	)
	// Only allowed to use small portions of tick
	priority = FIRE_PRIORITY_STATION_ALTITUDE
	runlevels = RUNLEVEL_GAME
	/// Cached station boundaries for each Z-level
	var/list/station_bounds_cache
	/// Whether station bounds have been calculated
	var/bounds_calculated = FALSE

	COOLDOWN_DECLARE(heavy_atmospheric_drag_cooldown)

/datum/controller/subsystem/orbital_reentry_drag/Initialize()
	// Disable for planetary stations
	if(SSmapping.current_map.planetary_station)
		can_fire = FALSE
		return SS_INIT_SUCCESS

	return SS_INIT_SUCCESS

/datum/controller/subsystem/orbital_reentry_drag/fire(resumed)
	// Calculate station boundaries once
	if(!bounds_calculated)
		calculate_all_station_bounds()
		bounds_calculated = TRUE

	// Spawn atmospheric drag
	spawn_atmospheric_drag()

/datum/controller/subsystem/orbital_reentry_drag/proc/spawn_atmospheric_drag()
	var/list/station_z_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!length(station_z_levels))
		return

	var/target_z = pick(station_z_levels)
	var/list/bounds = station_bounds_cache["[target_z]"]
	if(!bounds)
		return

	// Pick a random edge to spawn from
	var/edge = rand(1, 4)
	var/turf/start_turf
	var/turf/target_turf

	switch(edge)
		if(1) // Top edge
			start_turf = locate(rand(bounds["min_x"], bounds["max_x"]), bounds["max_y"] + 10, target_z)
			target_turf = locate(rand(bounds["min_x"], bounds["max_x"]), bounds["min_y"], target_z)
		if(2) // Bottom edge
			start_turf = locate(rand(bounds["min_x"], bounds["max_x"]), bounds["min_y"] - 10, target_z)
			target_turf = locate(rand(bounds["min_x"], bounds["max_x"]), bounds["max_y"], target_z)
		if(3) // Right edge
			start_turf = locate(bounds["max_x"] + 10, rand(bounds["min_y"], bounds["max_y"]), target_z)
			target_turf = locate(bounds["min_x"], rand(bounds["min_y"], bounds["max_y"]), target_z)
		if(4) // Left edge
			start_turf = locate(bounds["min_x"] - 10, rand(bounds["min_y"], bounds["max_y"]), target_z)
			target_turf = locate(bounds["max_x"], rand(bounds["min_y"], bounds["max_y"]), target_z)

	if(!start_turf || !target_turf)
		return

	// Spawn heavy drag occasionally, light drag otherwise
	if(COOLDOWN_FINISHED(src, heavy_atmospheric_drag_cooldown))
		COOLDOWN_START(src, heavy_atmospheric_drag_cooldown, 60 SECONDS)
		new /obj/effect/meteor/atmospheric_drag/heavy(start_turf, target_turf)
	else
		new /obj/effect/meteor/atmospheric_drag(start_turf, target_turf)

/datum/controller/subsystem/orbital_reentry_drag/proc/calculate_all_station_bounds()
	station_bounds_cache = list()

	var/list/station_z_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!length(station_z_levels))
		return

	// Calculate bounding box for each station Z-level
	for(var/z_level in station_z_levels)
		var/min_x = world.maxx
		var/max_x = 1
		var/min_y = world.maxy
		var/max_y = 1
		var/found_station = FALSE

		// Iterate through all non-space areas
		for(var/area/station_area in GLOB.areas)
			if(station_area.type == /area/space || istype(station_area, /area/space))
				continue

			var/list/area_turfs = station_area.get_contained_turfs()
			if(!length(area_turfs))
				continue

			// Find the bounding box of station turfs on this Z-level
			for(var/turf/area_turf in area_turfs)
				if(area_turf.z != z_level)
					continue
				if(!is_station_level(area_turf.z))
					continue

				found_station = TRUE
				min_x = min(min_x, area_turf.x)
				max_x = max(max_x, area_turf.x)
				min_y = min(min_y, area_turf.y)
				max_y = max(max_y, area_turf.y)

		// Cache the bounds for this Z-level
		if(found_station && max_x >= min_x && max_y >= min_y)
			var/key = "[z_level]"
			station_bounds_cache[key] = list("min_x" = min_x, "max_x" = max_x, "min_y" = min_y, "max_y" = max_y)

// Invisible atmospheric drag effect that damages station structures
// Simulates heating and structural stress from atmospheric re-entry
/obj/effect/meteor/atmospheric_drag
	name = "atmospheric drag"
	desc = "You shouldn't be seeing this."
	icon_state = "dust"
	alpha = 0
	hits = 1
	hitpwr = EXPLODE_LIGHT
	meteorsound = null
	meteordrop = list()
	dropamt = 0
	threat = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB | PASSDOORS
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	movement_type = FLYING

	/// Damage dealt to structures on impact
	var/erosionpower = 20

/obj/effect/meteor/atmospheric_drag/Initialize(mapload, target)
	. = ..()
	// Remove from global meteor list (this isn't a real meteor event)
	GLOB.meteor_list -= src
	SSaugury.unregister_doom(src)

/obj/effect/meteor/atmospheric_drag/Bump(atom/bumped)
	// Pass through mobs harmlessly
	if(isliving(bumped) || ismob(bumped))
		return

	if(isturf(bumped))
		return ..()

	// Damage structures and machinery
	if(bumped.density)
		if(isstructure(bumped) || ismachinery(bumped))
			var/obj/bumped_obj = bumped
			bumped_obj.take_damage(erosionpower, BRUTE, "melee", 0)

	return

/obj/effect/meteor/atmospheric_drag/ram_turf(turf/target)
	// Don't damage turfs with mobs on them
	for(var/mob/occupant in target)
		return

	if(isspaceturf(target))
		return

	// Queue minor explosion on this turf
	SSexplosions.lowturf += target

	get_hit()

/obj/effect/meteor/atmospheric_drag/get_hit()
	hits--
	if(hits <= 0)
		// Play creaking sound for atmosphere
		playsound(src.loc, pick('sound/effects/creak1.ogg', 'sound/effects/creak2.ogg'), 80, TRUE, 300, falloff_distance = 300)
		qdel(src)

/obj/effect/meteor/atmospheric_drag/examine(mob/user)
	return // Cannot be examined

/obj/effect/meteor/atmospheric_drag/attackby(obj/item/used_item, mob/user, params)
	return // Cannot be interacted with

/obj/effect/meteor/atmospheric_drag/CanPass(atom/movable/mover, border_dir)
	// Always let mobs pass through
	if(ismob(mover))
		return TRUE
	return ..()

/obj/effect/meteor/atmospheric_drag/CanPassThrough(atom/blocker, turf/target, blocker_dir)
	// Always pass through mobs
	if(ismob(blocker))
		return TRUE
	return ..()

// Heavy variant for more intense damage
/obj/effect/meteor/atmospheric_drag/heavy
	name = "heavy atmospheric drag"
	hitpwr = EXPLODE_HEAVY
	hits = 50
	erosionpower = 100

/obj/effect/meteor/atmospheric_drag/heavy/ram_turf(turf/T)
	// Don't damage turfs with mobs on them
	for(var/mob/M in T)
		return

	if(isspaceturf(T))
		return

	// Queue major explosion on this turf
	SSexplosions.highturf += T

	get_hit()
