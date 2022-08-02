
/datum/orbital_object/shuttle/proc/check_collisions()
	var/current_speed = velocity.Length()
	//Calculate our heading
	var/direction_heading = velocity.AngleFrom(new /datum/orbital_vector(0, 0))
	var/new_alert = FALSE
	var/datum/orbital_map/current_map = SSorbits.orbital_maps[orbital_map_index]
	//Get all things in view, that we can hit
	for(var/datum/orbital_object/z_linked/object in current_map.get_all_bodies())
		if(!object)
			continue
		if(object == src)
			continue
		//Check velocity
		if(!object.min_collision_velocity || current_speed < object.min_collision_velocity)
			continue
		//we can't see it, unless we are stealth too
		if(object.stealth && !stealth)
			continue
		//Check visibility
		var/distress = object.is_distress()
		if(!distress)
			var/max_vis_distance = max(shuttle_data.detection_range, object.signal_range)
			//Quick Distance Check
			if(position.GetX() > object.position.GetX() + max_vis_distance\
				|| position.GetX() < object.position.GetX() - max_vis_distance\
				|| position.GetY() > object.position.GetY() + max_vis_distance\
				|| position.GetY() < object.position.GetY() - max_vis_distance)
				continue
			//Refined Distance Check
			if(position.DistanceTo(object.position) > max_vis_distance)
				continue
		//Calculate the lower angle
		//Calculate the upper angle
		var/angle_to_target = object.position.AngleFrom(position)
		//If we are heading close to the target
		if(direction_heading + 5 > angle_to_target && direction_heading - 5 < angle_to_target)
			new_alert = TRUE
			break
	if(new_alert && !collision_alert)
		SEND_SIGNAL(src, COMSIG_SHUTTLE_TOGGLE_COLLISION_ALERT, TRUE)
		collision_alert = TRUE
	else if(!new_alert && collision_alert)
		SEND_SIGNAL(src, COMSIG_SHUTTLE_TOGGLE_COLLISION_ALERT, FALSE)
		collision_alert = FALSE
