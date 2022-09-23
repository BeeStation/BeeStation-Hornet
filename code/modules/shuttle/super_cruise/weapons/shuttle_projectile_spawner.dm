/proc/fire_projectile_towards(atom/target, spawn_distance = 5, projectile_type = /obj/item/projectile/beam/laser, missed = FALSE)
	var/angle = rand(0, 360)
	var/sin_angle = sin(angle)
	var/cos_angle = cos(angle)
	//Step away continuously
	var/turf/spawn_turf
	var/area/initial_area = get_area(target)
	//Find the furthest away turf that won't conflict with another shuttle
	for (var/i in spawn_distance to spawn_distance + 30)
		var/x_pos = CLAMP(target.x + spawn_distance * sin_angle, 6, world.maxx - 6)
		var/y_pos = CLAMP(target.y + spawn_distance * cos_angle, 6, world.maxy - 6)
		var/turf/located = locate(x_pos, y_pos, target.z)
		if (!spawn_turf)
			spawn_turf = located
		else if(!istype(located, /turf/open/space/transit) || initial_area == get_area(located))
			spawn_turf = located
		else
			break
	//Create the projectile
	var/obj/item/projectile/P = new projectile_type(spawn_turf)
	if(missed)
		var/obj/item/projectile/bullet/shuttle/shuttle_proj = P
		if(istype(shuttle_proj))
			shuttle_proj.miss = missed
	P.alpha = 0
	animate(P, time = 25, alpha = initial(P.alpha))
	P.preparePixelProjectile(get_turf(target), spawn_turf)
	P.fire()
