//Travels through walls until it hits the target
/obj/item/projectile/bullet/shuttle
	name = "shuttle projectile"
	desc = "A projectile fired from someone else"
	icon_state = "84mm-hedp"
	icon = 'icons/obj/shuttle_weapons.dmi'
	movement_type = FLYING
	range = 120
	reflectable = NONE

	//Turf damage factor
	//Values are between 0 and 10
	var/light_damage_factor = 11
	var/heavy_damage_factor = 11
	var/devestate_damage_factor = 11

	var/obj_damage = 0
	var/miss = FALSE
	var/is_outgoing = FALSE

	var/fired_from_shuttle

/obj/item/projectile/bullet/shuttle/prehit_pierce(atom/A)
	if (miss || is_outgoing)
		return PROJECTILE_PIERCE_PHASE
	return ..()

/obj/item/projectile/bullet/shuttle/on_hit(atom/target, blocked)
	//Damage turfs
	if (isclosedturf(target))
		var/turf/T = target
		//Apply damage overlay
		if(impact_effect_type && !hitscan)
			new impact_effect_type(T, target.pixel_x + rand(-8, 8), target.pixel_y + rand(-8, 8))
		//Damage the turf
		var/selected_damage = rand(0, 10)
		if(selected_damage >= light_damage_factor && selected_damage <= heavy_damage_factor - 1)
			T.ex_act(EXPLODE_LIGHT)
		if (selected_damage >= heavy_damage_factor && selected_damage <= devestate_damage_factor - 1)
			T.ex_act(EXPLODE_HEAVY)
		if (selected_damage >= devestate_damage_factor)
			T.ex_act(EXPLODE_DEVASTATE)
		//Damage objects in the turf
		for(var/obj/object in T)
			object.take_damage(damage)
	return ..()

/obj/item/projectile/bullet/shuttle/Range()
	. = ..()
	if (!is_outgoing)
		return
	var/area/shuttle/found_shuttle = get_area(src)
	if (found_shuttle.mobile_port && found_shuttle.mobile_port.id != fired_from_shuttle)
		// Go to nullspace
		forceMove(null)

/obj/item/projectile/bullet/shuttle/pixel_move(trajectory_multiplier, hitscanning = FALSE)
	if(!loc || !trajectory)
		return
	last_projectile_move = world.time
	if(!nondirectional_sprite && !hitscanning)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	if(homing)
		process_homing()
	var/forcemoved = FALSE
	for(var/i in 1 to SSprojectiles.global_iterations_per_move)
		if(QDELETED(src))
			return
		trajectory.increment(trajectory_multiplier)
		var/turf/T = trajectory.return_turf()
		if(!istype(T))
			//CHANGE: Go to nullspace
			forceMove(null)
			return
		if(T.z != loc.z)
			var/old = loc
			before_z_change(loc, T)
			trajectory_ignore_forcemove = TRUE
			forceMove(T)
			trajectory_ignore_forcemove = FALSE
			after_z_change(old, loc)
			if(!hitscanning)
				pixel_x = trajectory.return_px()
				pixel_y = trajectory.return_py()
			forcemoved = TRUE
			hitscan_last = loc
		else if(T != loc)
			step_towards(src, T)
			hitscan_last = loc
	if(QDELETED(src))
		return
	if(!hitscanning && !forcemoved)
		pixel_x = trajectory.return_px() - trajectory.mpx * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		pixel_y = trajectory.return_py() - trajectory.mpy * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		animate(src, pixel_x = trajectory.return_px(), pixel_y = trajectory.return_py(), time = 1, flags = ANIMATION_END_NOW)
	Range()
