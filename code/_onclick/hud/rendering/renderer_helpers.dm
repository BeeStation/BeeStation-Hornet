
/datum/remote_view
	var/map_name
	VAR_PRIVATE/list/cam_plane_masters
	VAR_PRIVATE/list/relay_images

/datum/remote_view/New(map_name)
	. = ..()
	src.map_name = map_name
	generate_camera_planes(map_name)

/datum/remote_view/Destroy(force, ...)
	. = ..()
	QDEL_LIST(cam_plane_masters)
	QDEL_LIST(relay_images)

/datum/remote_view/proc/generate_camera_planes(map_name)
	cam_plane_masters = list()
	relay_images = list()
	// Create all the plane masters
	for(var/atom/movable/screen/plane_master/plane as() in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
		// Otherwise continue
		var/atom/movable/screen/plane_master/instance = new plane()
		if(instance.blend_mode_override)
			instance.blend_mode = instance.blend_mode_override
		instance.assigned_map = map_name
		instance.del_on_map_removal = FALSE
		instance.screen_loc = "[map_name]:CENTER"
		cam_plane_masters += instance
	// Calculate any render relays that need to be simulated
	var/invalid_planes = 0
	for(var/atom/movable/screen/plane_master/plane in cam_plane_masters)
		if (!plane.render_relay_plane)
			continue
		// Find the correct plane
		var/atom/movable/screen/plane_master/target_plane = null
		for(var/atom/movable/screen/plane_master/other_plane in cam_plane_masters)
			if (other_plane.plane == plane.render_relay_plane)
				target_plane = other_plane
				break
		// Could not find the render relay
		if (!target_plane)
			continue
		// Ensure we have a render target
		if (!plane.render_target)
			plane.render_target = "*plane_rt_[invalid_planes++]"
		// Simulate the relay
		var/atom/movable/screen/relay_image = new()
		relay_image.assigned_map = map_name
		relay_image.del_on_map_removal = FALSE
		relay_image.plane = target_plane.plane
		relay_image.layer = (plane.plane + abs(LOWEST_EVER_PLANE))*0.5
		relay_image.render_source = plane.render_target
		relay_image.blend_mode = plane.blend_mode
		relay_image.screen_loc = "[map_name]:CENTER"
		relay_images += relay_image

/datum/remote_view/proc/get_plane(plane_type)
	for (var/atom/plane as() in cam_plane_masters)
		if (plane.type == plane_type)
			return plane
	return null

/datum/remote_view/proc/join(client/viewer)
	if (!viewer)
		return
	for (var/plane in cam_plane_masters)
		viewer.register_map_obj(plane)
	for (var/relay in relay_images)
		viewer.register_map_obj(relay)

/datum/remote_view/proc/leave(client/viewer)
	if (!viewer)
		return
	viewer.clear_map(map_name)
