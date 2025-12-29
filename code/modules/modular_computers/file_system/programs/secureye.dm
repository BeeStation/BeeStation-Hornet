#define DEFAULT_MAP_SIZE 15

/datum/computer_file/program/secureye
	filename = "secureye"
	filedesc = "SecurEye"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "camera"
	extended_desc = "This program allows access to standard security camera networks."
	requires_ntnet = TRUE
	transfer_access = list(ACCESS_SECURITY)
	size = 8
	tgui_id = "NtosSecurEye"
	program_icon = "eye"
	hardware_requirement = MC_CAMERA // Doesn't make sense to use a camera a lot, but this will get security off their ass
	power_consumption = 200 WATT

	var/list/network = list(CAMERA_NETWORK_STATION)
	/// Weakref to the active camera
	var/datum/weakref/camera_ref
	/// The turf where the camera was last updated.
	var/turf/last_camera_turf
	var/list/concurrent_users = list()

	// Stuff needed to render the map
	var/map_name
	var/atom/movable/screen/map_view/cam_screen
	/// All the plane masters that need to be applied.
	var/datum/remote_view/remote_view
	var/atom/movable/screen/background/cam_background

/datum/computer_file/program/secureye/New()
	. = ..()
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	map_name = "camera_console_[REF(src)]_map"
	// Convert networks to lowercase
	for(var/i in network)
		network -= i
		network += LOWER_TEXT(i)
	// Initialize map objects
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"
	remote_view = new(map_name)
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE

/datum/computer_file/program/secureye/Destroy()
	QDEL_NULL(cam_screen)
	QDEL_NULL(remote_view)
	QDEL_NULL(cam_background)
	return ..()

/datum/computer_file/program/secureye/on_ui_create(mob/user, datum/tgui/ui)
	// Update the camera, showing static if necessary and updating data if the location has moved.
	update_active_camera_screen()

	var/user_ref = REF(user)
	// Ghosts shouldn't count towards concurrent users, which produces
	// an audible terminal_on click.
	if(isliving(user))
		concurrent_users += user_ref
	// Register map objects
	user.client.register_map_obj(cam_screen)
	remote_view.join(user.client)
	user.client.register_map_obj(cam_background)

/datum/computer_file/program/secureye/ui_data()
	var/list/data = list()
	data["activeCamera"] = null
	var/obj/machinery/camera/active_camera = camera_ref?.resolve()
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			ref = REF(active_camera),
			status = active_camera.status,
		)
	return data

/datum/computer_file/program/secureye/ui_static_data()
	var/list/data = list()
	data["network"] = network
	data["mapRef"] = map_name
	var/list/cameras = get_available_cameras()
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
			ref = REF(C),
		))

	return data

/datum/computer_file/program/secureye/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("switch_camera")
			var/obj/machinery/camera/selected_camera = locate(params["camera"]) in GLOB.cameranet.cameras
			if(selected_camera)
				camera_ref = WEAKREF(selected_camera)
			else
				camera_ref = null
			ui_update()
			playsound(src, get_sfx("terminal_type"), 5, FALSE)

			if(isnull(camera_ref))
				return TRUE

			update_active_camera_screen()

			return TRUE

/datum/computer_file/program/secureye/on_ui_close(mob/user, datum/tgui/tgui)
	on_exit(user)

/datum/computer_file/program/secureye/kill_program(forced)
	. = ..()
	on_exit()

/datum/computer_file/program/secureye/proc/on_exit(mob/user)
	if(!ismob(user))
		user = usr
	if(!ismob(user))
		return
	var/user_ref = REF(user)
	var/is_living = isliving(user)
	// Living creature or not, we remove you anyway.
	concurrent_users -= user_ref
	// Unregister map objects
	remote_view.leave(user.client)
	// Turn off the console
	if(length(concurrent_users) == 0 && is_living)
		camera_ref = null
		playsound(computer, 'sound/machines/terminal_off.ogg', 25, FALSE)

/datum/computer_file/program/secureye/proc/update_active_camera_screen()
	var/obj/machinery/camera/active_camera = camera_ref?.resolve()
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		show_camera_static()
		return

	var/list/visible_turfs = list()

	// Is this camera located in or attached to a living thing? If so, assume the camera's loc is the living thing.
	var/cam_location = isliving(active_camera.loc) ? active_camera.loc : active_camera

	// If we're not forcing an update for some reason and the cameras are in the same location,
	// we don't need to update anything.
	// Most security cameras will end here as they're not moving.
	var/newturf = get_turf(cam_location)
	if(last_camera_turf == newturf)
		return

	// Cameras that get here are moving, and are likely attached to some moving atom such as cyborgs.
	last_camera_turf = get_turf(cam_location)

	var/list/visible_things = active_camera.isXRay() ? range(active_camera.view_range, cam_location) : view(active_camera.view_range, cam_location)

	for(var/turf/visible_turf in visible_things)
		visible_turfs += visible_turf

	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/datum/computer_file/program/secureye/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)

// Returns the list of cameras accessible from this computer
/datum/computer_file/program/secureye/proc/get_available_cameras()
	var/list/camlist = list()
	for(var/obj/machinery/camera/cam as() in GLOB.cameranet.cameras)
		if(!is_station_level(cam.z))//Only show station cameras.
			continue
		if(!islist(cam.network))
			stack_trace("Camera in a cameranet has invaid camera network")
			continue
		if(!length(cam.network & network))
			continue
		camlist["[cam.c_tag]"] = cam
	return camlist

#undef DEFAULT_MAP_SIZE
