/client/proc/openAdminCam()
	set name = "Admin Camera"
	set desc = "Opens the admin camera allowing you to view players on another tab."
	set category = "Admin"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/datum/admins/admin_datum = GLOB.admin_datums[ckey]
	if(!admin_datum)
		to_chat(src, "Only administrators may use this command.")
		return
	admin_datum.admin_interface.display_ui("admin_camera", usr)

/datum/admin_ui_component/admin_cam
	unique_id = "admin_camera"
	default_ui_key = "admin_camera"
	default_ui_name = "CameraConsole"
	window_name = "Admin Spectate"
	width = 870
	height = 708

	//Thing we are tracking
	var/tracked_ckey
	var/menu_open = FALSE

	var/view_range = 7

	// Stuff needed to render the map
	var/map_name
	var/const/default_map_size = 15
	var/obj/screen/cam_screen
	var/obj/screen/plane_master/lighting/cam_plane_master
	var/obj/screen/background/cam_background

/datum/admin_ui_component/admin_cam/New()
	. = ..()
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	map_name = "camera_console_[REF(src)]_map"
	//Initialize map objects
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"
	cam_plane_master = new
	cam_plane_master.name = "plane_master"
	cam_plane_master.assigned_map = map_name
	cam_plane_master.del_on_map_removal = FALSE
	cam_plane_master.screen_loc = "[map_name]:CENTER"
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE

/datum/admin_ui_component/admin_cam/Destroy()
	qdel(cam_screen)
	qdel(cam_plane_master)
	qdel(cam_background)
	. = ..()

/datum/admin_ui_component/admin_cam/process()
	update_position()

/datum/admin_ui_component/admin_cam/ui_interact(\
		mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
		datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	// Update UI
	ui = SStgui.try_update_ui(user, src, default_ui_key, ui, force_open)
	if(!ui)
		// Register map objects
		user.client.register_map_obj(cam_screen)
		user.client.register_map_obj(cam_plane_master)
		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, default_ui_key, default_ui_name, window_name, width, height, master_ui, state)
		ui.open()

		cam_background.icon_state = "clear"
		cam_background.fill_rect(1, 1, default_map_size, default_map_size)
		START_PROCESSING(SSprocessing, src)

/datum/admin_ui_component/admin_cam/ui_data()
	var/list/data = list()
	data["network"] = list("players")
	data["activeCamera"] = null

	if(tracked_ckey)
		data["activeCamera"] = list(
			name = tracked_ckey,
			status = TRUE,
		)
	var/list/players = get_all_ckeys()
	data["cameras"] = list()
	for(var/i in players)
		data["cameras"] += list(list(
			name = i,
		))
	return data

/datum/admin_ui_component/admin_cam/ui_static_data()
	var/list/data = list()
	data["mapRef"] = map_name
	return data

/datum/admin_ui_component/admin_cam/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "switch_camera")
		var/a_tag = params["name"]
		tracked_ckey = a_tag
		update_position()

/datum/admin_ui_component/admin_cam/ui_close(mob/user)
	STOP_PROCESSING(SSprocessing, src)
	user.client.clear_map(map_name)

/datum/admin_ui_component/admin_cam/proc/update_position()
	var/mob/tracked_obj = get_tracked_object()
	if(!tracked_obj)
		return
	cam_screen.vis_contents = range(view_range, tracked_obj)

/datum/admin_ui_component/admin_cam/proc/get_all_ckeys()
	var/list/D = list()
	for(var/i in GLOB.player_list)
		var/mob/M = i
		D += M.ckey
	return D

/datum/admin_ui_component/admin_cam/proc/get_tracked_object()
	return get_mob_by_ckey(tracked_ckey)
