/datum/ruin_decorator/asteriod_station
	decorator_weight = 60

/datum/ruin_decorator/asteriod_station/decorate(datum/map_generator/space_ruin/thing_to_decorate)
	var/z_value = thing_to_decorate.created_space_level.z_value
	var/perlin_noise_scale = 65
	var/seed = rand(0, 999999)
	var/turf/z_center = locate(world.maxx * 0.5, world.maxy * 0.5, z_value)
	var/datum/map_generator/asteroid_generator = new(block(locate(1, 1, z_value), locate(world.maxx, world.maxy, z_value)), z_center, seed)
	asteroid_generator.generate()

/datum/map_generator/asteroid_generator
	//Turfs don't delete so no need to worry about hard dels
	var/list/turfs_to_generate
	var/index = 0
	var/z_center
	var/seed
	var/perlin_noise_scale
	var/max_radius = 70

/datum/map_generator/asteroid_generator/New(list/turfs_to_generate, z_center, seed, perlin_noise_scale)
	. = ..()
	src.turfs_to_generate = turfs_to_generate
	src.z_center = z_center
	src.seed = seed
	src.perlin_noise_scale = perlin_noise_scale

/datum/map_generator/asteroid_generator/execute_run()
	if (index > length(turfs_to_generate))
		turfs_to_generate = null
		return FALSE
	. = ..()
	index ++
	var/turf/T = turfs_to_generate[index]
	//Calculate distance to edge
	var/distance = z_center.Distance(T)
	if(distance > max_radius)
		continue
	var/noise_at_coord = text2num(rustg_noise_get_at_coordinates("[seed]", "[T.x / perlin_noise_scale]", "[T.y / perlin_noise_scale]"))
	var/rock_value = (distance / max_radius) + 0.1
	var/sand_value = (distance / max_radius)
	if(noise_at_coord >= rock_value)
		T.ChangeTurf(/turf/closed/mineral/random, list(/turf/open/floor/plating/asteroid/airless), CHANGETURF_IGNORE_AIR)
	else if(noise_at_coord >= sand_value)
		T.ChangeTurf(/turf/open/floor/plating/asteroid/airless, flags = CHANGETURF_IGNORE_AIR)

/datum/map_generator/asteroid_generator/get_name()
	return "Asteroid generator"
