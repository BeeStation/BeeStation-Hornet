/proc/fire_projectile_towards(atom/target, spawn_distance = 25, projectile_type = /obj/item/projectile/beam/laser)
	var/angle = rand(0, 360)
	var/x_pos = CLAMP(spawn_distance * sin(angle), 1, world.maxx - 1)
	var/y_pos = CLAMP(spawn_distance * cos(angle), 1, world.maxy - 1)
	var/turf/spawn_turf = locate(x_pos, y_pos, target.z)
	//Create the projectile
	var/obj/item/projectile/P = new projectile_type(spawn_turf)
	P.preparePixelProjectile(get_turf(target), spawn_turf)
	P.fire()
