#define DEFAULT_MAP_SIZE 15

/obj/machinery/computer/security
	name = "security camera console"
	desc = "Used to access the various cameras on the station."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/security
	light_color = LIGHT_COLOR_RED

	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_SET_MACHINE|INTERACT_MACHINE_REQUIRES_SIGHT

	var/list/network = list(CAMERA_NETWORK_STATION)
	var/obj/machinery/camera/active_camera
	/// The turf where the camera was last updated.
	var/turf/last_camera_turf
	var/list/concurrent_users = list()
	var/long_ranged = FALSE

	// Stuff needed to render the map
	var/map_name
	var/atom/movable/screen/map_view/cam_screen
	/// All the plane masters that need to be applied.
	var/datum/remote_view/remote_view
	var/atom/movable/screen/background/cam_background

/obj/machinery/computer/security/Initialize(mapload)
	. = ..()
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	// I wasted 6 hours on this. :agony:
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

/obj/machinery/computer/security/Destroy()
	QDEL_NULL(cam_screen)
	QDEL_NULL(remote_view)
	QDEL_NULL(cam_background)
	return ..()

/obj/machinery/computer/security/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	for(var/i in network)
		network -= i
		network += "[idnum][i]"


/obj/machinery/computer/security/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/security/interact(mob/user, special_state)
	if (!user.client) // monkey proof
		return
	. = ..()

/obj/machinery/computer/security/ui_interact(mob/user, datum/tgui/ui)
	if(!user.canUseTopic(src, no_dexterity = FALSE)) //prevents monkeys from using camera consoles
		return
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui)

	// Update the camera, showing static if necessary and updating data if the location has moved.
	update_active_camera_screen()

	if(!ui)
		var/user_ref = REF(user)
		var/is_living = isliving(user)
		// Ghosts shouldn't count towards concurrent users, which produces
		// an audible terminal_on click.
		if(is_living)
			concurrent_users += user_ref
		// Turn on the console
		if(length(concurrent_users) == 1 && is_living)
			playsound(src, 'sound/machines/terminal_on.ogg', 25, FALSE)
			use_power(active_power_usage)
		// Register map objects
		user.client.register_map_obj(cam_screen)
		user.client.register_map_obj(cam_background)
		remote_view.join(user.client)
		// Open UI
		ui = new(user, src, "CameraConsole")
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/computer/security/ui_data()
	var/list/data = list()
	data["activeCamera"] = null
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			ref = REF(active_camera),
			status = active_camera.status,
		)
	return data

/obj/machinery/computer/security/ui_static_data()
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

/obj/machinery/computer/security/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "switch_camera")
		var/obj/machinery/camera/selected_camera = locate(params["camera"]) in GLOB.cameranet.cameras
		active_camera = selected_camera
		ui_update()
		playsound(src, get_sfx("terminal_type"), 25, FALSE)

		if(isnull(active_camera))
			return TRUE

		update_active_camera_screen()

		return TRUE

/obj/machinery/computer/security/proc/update_active_camera_screen()
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		show_camera_static()
		return

	var/list/visible_turfs = list()

	// Is this camera located in or attached to a living thing? If so, assume the camera's loc is the living thing.
	var/atom/cam_location = isliving(active_camera.loc) ? active_camera.loc : active_camera

	// If we're not forcing an update for some reason and the cameras are in the same location,
	// we don't need to update anything.
	// Most security cameras will end here as they're not moving.
	var/newturf = get_turf(cam_location)
	if(last_camera_turf == newturf)
		return

	// Cameras that get here are moving, and are likely attached to some moving atom such as cyborgs.
	last_camera_turf = get_turf(cam_location)

	if(active_camera.isXRay(TRUE))	//ignore_malf_upgrades = TRUE
		visible_turfs += RANGE_TURFS(active_camera.view_range, cam_location)
	else
		for(var/turf/T in view(active_camera.view_range, cam_location))
			visible_turfs += T

	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/obj/machinery/computer/security/ui_close(mob/user, datum/tgui/tgui)
	var/user_ref = REF(user)
	var/is_living = isliving(user)
	// Living creature or not, we remove you anyway.
	concurrent_users -= user_ref
	// Unregister map objects
	remote_view.leave(user.client)
	// Turn off the console
	if(length(concurrent_users) == 0 && is_living)
		active_camera = null
		playsound(src, 'sound/machines/terminal_off.ogg', 25, FALSE)
		use_power(0)

/obj/machinery/computer/security/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)

// Returns the list of cameras accessible from this computer
/obj/machinery/computer/security/proc/get_available_cameras()
	var/list/camlist = list()
	for(var/obj/machinery/camera/cam as() in GLOB.cameranet.cameras)
		if((is_away_level(z) || is_away_level(cam.z)) && (cam.get_virtual_z_level() != get_virtual_z_level()))//if on away mission, can only receive feed from same z_level cameras
			continue
		if(!islist(cam.network))
			stack_trace("Camera in a cameranet has invaid camera network")
			continue
		if(!length(cam.network & network))
			continue
		camlist["[cam.c_tag]"] = cam
	return camlist

// SECURITY MONITORS

/obj/machinery/computer/security/wooden_tv
	name = "security camera monitor"
	desc = "An old TV hooked into the station's camera network."
	icon_state = "television"
	icon_keyboard = "no_keyboard"
	icon_screen = "detective_tv"

	//these muthafuckas arent supposed to smooth
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null

	clockwork = TRUE //it'd look weird
	broken_overlay_emissive = TRUE
	pass_flags = PASSTABLE

/obj/machinery/computer/security/mining
	name = "outpost camera console"
	desc = "Used to access the various cameras on the outpost."
	icon_screen = "mining"
	icon_keyboard = "mining_key"
	network = list(CAMERA_NETWORK_MINE, CAMERA_NETWORK_AUXBASE)
	circuit = /obj/item/circuitboard/computer/mining

/obj/machinery/computer/security/research
	name = "research camera console"
	desc = "Used to access the various cameras in science."
	network = list(CAMERA_NETWORK_RESEARCH)
	circuit = /obj/item/circuitboard/computer/research

/obj/machinery/computer/security/security
	name = "internal security camera console"
	desc = "Accesses various cameras on the security camera network."
	network = list(CAMERA_NETWORK_PRISON, CAMERA_NETWORK_LABOR)

/obj/machinery/computer/security/hos
	name = "\improper Head of Security's camera console"
	desc = "A custom security console with added access to the labor camp network."
	network = list(CAMERA_NETWORK_STATION, CAMERA_NETWORK_PRISON, CAMERA_NETWORK_LABOR)
	circuit = null

/obj/machinery/computer/security/labor
	name = "labor camp monitoring"
	desc = "Used to access the various cameras on the labor camp."
	network = list(CAMERA_NETWORK_LABOR)
	circuit = null

/obj/machinery/computer/security/qm
	name = "\improper Quartermaster's camera console"
	desc = "A console with access to the mining, auxillary base and vault camera networks."
	network = list(CAMERA_NETWORK_MINE, CAMERA_NETWORK_VAULT, CAMERA_NETWORK_AUXBASE)
	circuit = null

/obj/machinery/computer/security/medbay
	name = "medbay camera console"
	desc = "A console to access the medical camera network"
	network = list(CAMERA_NETWORK_MEDICAL)

/obj/machinery/computer/security/caravansyndicate
	name = "shuttle camera console"
	desc = "A console to monitor the outside status of the shuttle."
	network = list(CAMERA_NETWORK_CARAVAN_SYNDICATE)

// TELESCREENS

/obj/machinery/computer/security/telescreen
	name = "\improper Telescreen"
	desc = "Used for watching an empty arena."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"

	//these muthafuckas arent supposed to smooth
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null

	layer = SIGN_LAYER
	network = list(CAMERA_NETWORK_THUNDERDOME)
	density = FALSE
	circuit = null
	clockwork = TRUE //it'd look very weird
	broken_overlay_emissive = TRUE
	light_power = 0

/obj/machinery/computer/security/telescreen/update_icon()
	icon_state = initial(icon_state)
	if(machine_stat & BROKEN)
		icon_state += "b"
	return

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have the beestation channel on these things."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment_blank"
	network = list(CAMERA_NETWORK_THUNDERDOME, CAMERA_NETWORK_COURT)
	density = FALSE
	circuit = null
	long_ranged = TRUE
	var/icon_state_off = "entertainment_blank"
	var/icon_state_on = "entertainment"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/entertainment, 32)

//Can use this telescreen at long range.
/obj/machinery/computer/security/telescreen/entertainment/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/security/telescreen/entertainment/examine(mob/user)
	. = ..()
	interact(usr)

/obj/machinery/computer/security/telescreen/entertainment/proc/notify(on)
	if(on && icon_state == icon_state_off)
		say(pick(
			"Feats of bravery live now at the thunderdome!",
			"Two enter, one leaves! Tune in now!",
			"Violence like you've never seen it before!",
			"Spears! Camera! Action! LIVE NOW!"))
		icon_state = icon_state_on
	else
		icon_state = icon_state_off

/obj/machinery/computer/security/telescreen/entertainment/theathre
	name = "stage monitor"
	desc = "Used for watching the stage from the back seats."
	network = list(CAMERA_NETWORK_THEATHRE)

/obj/machinery/computer/security/telescreen/rd
	name = "\improper Research Director's telescreen"
	desc = "Used for watching the AI and the RD's goons from the safety of his office."
	// Can't see minisat since it would expose the AI core
	network = list(CAMERA_NETWORK_RESEARCH, CAMERA_NETWORK_AI_UPLOAD)

/obj/machinery/computer/security/telescreen/research
	name = "research telescreen"
	desc = "A telescreen with access to the research division's camera network."
	network = list(CAMERA_NETWORK_RESEARCH)

/obj/machinery/computer/security/telescreen/ce
	name = "\improper Chief Engineer's telescreen"
	desc = "Used for watching the engine, telecommunications and the minisat."
	network = list(CAMERA_NETWORK_ENGINEERING)

/obj/machinery/computer/security/telescreen/cmo
	name = "\improper Chief Medical Officer's telescreen"
	desc = "A telescreen with access to the medbay's camera network."
	network = list(CAMERA_NETWORK_MEDICAL)

/obj/machinery/computer/security/telescreen/medical
	name = "medical telescreen"
	desc = "A telescreen with access to the medbay's camera network."
	network = list(CAMERA_NETWORK_MEDICAL)

/obj/machinery/computer/security/telescreen/vault
	name = "vault monitor"
	desc = "A telescreen that connects to the vault's camera network."
	network = list(CAMERA_NETWORK_VAULT)

/obj/machinery/computer/security/telescreen/toxins
	name = "bomb test site monitor"
	desc = "A telescreen that connects to the bomb test site's camera."
	network = list(CAMERA_NETWORK_TOXINS_TEST)

/obj/machinery/computer/security/telescreen/engine
	name = "engine monitor"
	desc = "A telescreen that connects to the engine's camera network."
	network = list(CAMERA_NETWORK_ENGINEERING)

/obj/machinery/computer/security/telescreen/turbine
	name = "turbine monitor"
	desc = "A telescreen that connects to the turbine's camera."
	network = list("turbine")

/obj/machinery/computer/security/telescreen/interrogation
	name = "interrogation room monitor"
	desc = "A telescreen that connects to the interrogation room's camera."
	network = list(CAMERA_NETWORK_INTERROGATION)

/obj/machinery/computer/security/telescreen/prison
	name = "prison monitor"
	desc = "A telescreen that connects to the permabrig's camera network."
	network = list(CAMERA_NETWORK_PRISON, CAMERA_NETWORK_LABOR)

/obj/machinery/computer/security/telescreen/auxbase
	name = "auxillary base monitor"
	desc = "A telescreen that connects to the auxillary base's camera."
	network = list(CAMERA_NETWORK_AUXBASE)

/obj/machinery/computer/security/telescreen/mining
	name = "outpost camera monitor"
	desc = "A telescreen that connects to the mining outpost."
	network = list(CAMERA_NETWORK_AUXBASE, CAMERA_NETWORK_MINE)

/obj/machinery/computer/security/telescreen/minisat
	name = "minisat monitor"
	desc = "A telescreen that connects to the minisat's camera network."
	network = list(CAMERA_NETWORK_MINISAT)

/obj/machinery/computer/security/telescreen/aiupload
	name = "\improper AI upload monitor"
	desc = "A telescreen that connects to the AI upload's camera network."
	network = list(CAMERA_NETWORK_AI_UPLOAD)

/obj/machinery/computer/security/telescreen/tcomms
	name = "telecommunications monitor"
	desc = "A telescreen that connects to the telecommunications camera network."
	network = list(CAMERA_NETWORK_TCOMMS)

/obj/machinery/computer/security/telescreen/court
	name = "court monitor"
	desc = "A telescreen that connects to the courtrooms's camera network."
	network = list(CAMERA_NETWORK_COURT)

/obj/machinery/computer/security/telescreen/evac
	name = "evacuation shuttle monitor"
	desc = "A telescreen that connects to the camera network of the evacuation shuttle."
	network = list(CAMERA_NETWORK_EVAC)

/obj/machinery/computer/security/telescreen/bunker
	name = "bunker monitor"
	desc = "A telescreen that connects to the camera network of the bunker."
	network = list(CAMERA_NETWORK_BUNKER)

/obj/machinery/computer/security/telescreen/station
	name = "station monitor"
	desc = "A telescreen that monitors the station's camera network."
	network = list(CAMERA_NETWORK_STATION)

#undef DEFAULT_MAP_SIZE
