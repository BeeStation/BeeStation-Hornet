SUBSYSTEM_DEF(asteroid_generation)
	name = "Asteroid Generation"
	flags = SS_NO_FIRE
	var/list/asteroid_ruins

/datum/controller/subsystem/asteroid_generation/Initialize(start_timeofday)
	. = ..()
	// Load the map files
	asteroid_ruins = list()
	for (var/template_type in subtypesof(/datum/map_template/asteroid))
		var/datum/map_template/asteroid/template = new template_type
		asteroid_ruins[template] = template.weight

/datum/controller/subsystem/asteroid_generation/proc/generate_asteroid_cavity(turf/asteroid_center, width, height, list/biome, list/ore_list)
	// Reserve some space
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(width + 2, height + 2)
	if (!reservation)
		CRASH("Unable to get reservation for asteroid fracture.")
	// Border the edge of the z-level with impassable turfs that are outside of the virtual Z
	var/turf/bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	var/turf/top_left = locate(reservation.bottom_left_coords[1], reservation.top_right_coords[2], reservation.bottom_left_coords[3])
	var/turf/bottom_right = locate(reservation.top_right_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	var/turf/top_right = locate(reservation.top_right_coords[1], reservation.top_right_coords[2], reservation.bottom_left_coords[3])
	// Setup the border area
	var/area/border_area = GLOB.areas_by_type[/area/asteroid/interior/border]
	if (!border_area)
		border_area = new /area/asteroid/interior/border
		GLOB.areas_by_type[/area/asteroid/interior/border] = border_area
	// Add on the border
	for (var/turf/T in (block(bottom_left, top_left) | block(top_left, top_right) | block(top_right, bottom_right) | block(bottom_right, bottom_left)))
		T.ChangeTurf(/turf/closed/indestructible/rock)
		T.change_area(T.loc, border_area)
	// Load the map
	var/datum/map_template/asteroid/asteroid_ruin = pick_ruin()
	var/turf/asteroid_interior_center = locate((reservation.bottom_left_coords[1] + reservation.top_right_coords[1]) / 2, (reservation.bottom_left_coords[2] + reservation.top_right_coords[2]) / 2, reservation.bottom_left_coords[3])
	var/datum/map_generator/map_place/map_placer = asteroid_ruin.load(asteroid_interior_center, TRUE)
	// Once the map has loaded then we can create the way down
	map_placer.on_completion(CALLBACK(src, PROC_REF(finalise_asteroid_hole), asteroid_center, asteroid_interior_center, reservation, width, height, biome, ore_list))

/datum/controller/subsystem/asteroid_generation/proc/finalise_asteroid_hole(turf/asteroid_center, turf/asteroid_interior_center, datum/turf_reservation/reservation, width, height, list/biome, list/ore_list)
	// We need this back
	var/turf/bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	// Generate the asteroid rocks
	// Start creating the area underneath
	var/area/asteroid/interior/asteroid_interior = new()
	asteroid_interior.virtual_z = get_new_virtual_z()
	// Update the turfs to be the correct type
	for (var/turf/T in block(locate(reservation.bottom_left_coords[1] + 1, reservation.bottom_left_coords[2] + 1, reservation.bottom_left_coords[3]), locate(reservation.top_right_coords[1] - 1, reservation.top_right_coords[2] - 1, reservation.bottom_left_coords[3])))
		T.change_area(T.loc, asteroid_interior)
	var/asteroid_radius = (min(width, height) - 1) / 2
	// Generate the asteroid
	var/datum/asteroid_generator/asteroid_generator = new()
	asteroid_generator.max_radius = asteroid_radius
	asteroid_generator.weight_offset = -0.6
	asteroid_generator.scale = rand(10, 20)
	asteroid_generator.biome = biome
	asteroid_generator.ores_list = ore_list
	asteroid_generator.inverted = TRUE
	asteroid_generator.force_floor = TRUE
	asteroid_generator.change_area = FALSE
	asteroid_generator.generate_asteroids(asteroid_interior_center.x, asteroid_interior_center.y, asteroid_interior_center.z)
	// Find a turf that is clear to make the hole
	var/best_value = 0
	var/turf/best_top = null
	var/turf/best_bottom = null
	for (var/x in 0 to width)
		for (var/y in 0 to height)
			var/turf/interior_turf = locate(bottom_left.x + x, bottom_left.y + y, bottom_left.z)
			var/turf/surface_turf = locate(asteroid_center.x - (width - 1) / 2, asteroid_center.y - (height - 1) / 2, asteroid_center.z)
			// Fix the baseturfs so that we will never fall through to space
			interior_turf.baseturfs = baseturfs_string_list(list(/turf/open/floor/plating/asteroid/airless), interior_turf)
			// Interior turf should be open, surface turf should be asteroid sand
			if (!interior_turf.is_blocked_turf(TRUE) && (istype(surface_turf, /turf/open/floor/plating/asteroid) || istype(surface_turf, /turf/closed/mineral)))
				// We would much rather have asteroid platings on the top
				var/spawn_value = istype(surface_turf, /turf/open/floor/plating/asteroid) ? 100 : 50
				var/distance_from_center = get_dist(asteroid_center, surface_turf)
				spawn_value -= distance_from_center
				if (spawn_value < best_value)
					continue
				best_top = surface_turf
				best_bottom = interior_turf
				best_value = spawn_value
	if (!best_top || !best_bottom)
		best_top = asteroid_center
		best_bottom = asteroid_interior_center
	// Create the hole that can be laddered down
	best_top.ChangeTurf(/turf/open/floor/mineral/gold, flags = CHANGETURF_IGNORE_AIR)
	best_bottom.ChangeTurf(/turf/open/floor/mineral/gold, flags = CHANGETURF_IGNORE_AIR)

/datum/controller/subsystem/asteroid_generation/proc/pick_ruin()
	return pick_weight(asteroid_ruins)
