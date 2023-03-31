/proc/fire_projectile_towards(atom/target, spawn_distance = 5, projectile = /obj/item/projectile/beam/laser, missed = FALSE)
	var/area/shuttle/shuttle_area = get_area(target)
	var/angle = rand(0, 360)
	if (istype(shuttle_area))
		var/obj/docking_port/mobile/shuttle = shuttle_area.mobile_port
		var/turf/center_turf = shuttle.return_center_turf()
		angle = get_angle(center_turf, target)
	var/sin_angle = sin(angle)
	var/cos_angle = cos(angle)
	//Step away continuously
	var/turf/spawn_turf
	var/area/shuttle/initial_area = get_area(target)
	var/obj/docking_port/mobile/target_port = null
	if (istype(initial_area))
		target_port = initial_area.mobile_port
	//Find the furthest away turf that won't conflict with another shuttle
	for (var/i in spawn_distance to spawn_distance + 30)
		var/x_pos = CLAMP(target.x + i * sin_angle, 6, world.maxx - 6)
		var/y_pos = CLAMP(target.y + i * cos_angle, 6, world.maxy - 6)
		var/turf/located = locate(x_pos, y_pos, target.z)
		var/area/shuttle/located_area = located.loc
		// Must set an initial value
		if (!spawn_turf)
			spawn_turf = located
		// If the turf isn't on a shuttle, or the shuttle is our shuttle, then we can be fired from here
		else if(!istype(located_area) || istype(located_area, /area/shuttle/transit) || located_area.mobile_port == target_port)
			spawn_turf = located
		else
			break
	//Create the projectile
	var/obj/item/projectile/P = projectile
	if(missed)
		var/obj/item/projectile/bullet/shuttle/shuttle_proj = P
		if(istype(shuttle_proj))
			shuttle_proj.miss = missed
	P.alpha = 0
	animate(P, time = 25, alpha = initial(P.alpha))
	P.preparePixelProjectile(get_turf(target), spawn_turf)
	P.fire()
