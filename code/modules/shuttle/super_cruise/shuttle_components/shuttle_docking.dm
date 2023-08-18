
/obj/machinery/computer/shuttle_flight
	var/mob/camera/ai_eye/remote/eyeobj
	var/mob/living/current_user = null
	var/list/actions = list()
	var/datum/action/innate/camera_off/off_action = new
	var/datum/action/innate/shuttledocker_rotate/rotate_action = new
	var/datum/action/innate/shuttledocker_place/place_action = new
	var/shuttlePortId = ""
	var/shuttlePortName = "custom location"
	var/obj/docking_port/stationary/my_port //the custom docking port placed by this console
	var/obj/docking_port/mobile/shuttle_port //the mobile docking port of the connected shuttle
	var/view_range = 0
	var/list/whitelist_turfs = list(
		/turf/open/space,
		/turf/open/floor/plating/lavaland,
		/turf/open/floor/plating/asteroid,
		/turf/open/lava,
		/turf/open/floor/dock,
		/turf/open/floor/plating/snowed,
		/turf/open/floor/plating/ice,
	)
	var/designate_time = 50
	var/turf/designating_target_loc
	var/datum/action/innate/camera_jump/shuttle_docker/docker_action = new
	///Camera action button to move up a Z level
	var/datum/action/innate/camera_multiz_up/move_up_action = new
	///Camera action button to move down a Z level
	var/datum/action/innate/camera_multiz_down/move_down_action = new

/obj/machinery/computer/shuttle_flight/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	GLOB.navigation_computers += src
	whitelist_turfs = typecacheof(whitelist_turfs)

/obj/machinery/computer/shuttle_flight/Destroy()
	. = ..()
	GLOB.navigation_computers -= src

/obj/machinery/computer/shuttle_flight/proc/GrantActions(mob/living/user)
	if(off_action)
		off_action.target = user
		off_action.Grant(user)
		actions += off_action

	if(rotate_action)
		rotate_action.target = user
		rotate_action.Grant(user)
		actions += rotate_action

	if(place_action)
		place_action.target = user
		place_action.Grant(user)
		actions += place_action

	if(docker_action)
		docker_action.target = user
		docker_action.Grant(user)
		actions += docker_action

	if(move_up_action)
		move_up_action.target = user
		move_up_action.Grant(user)
		actions += move_up_action

	if(move_down_action)
		move_down_action.target = user
		move_down_action.Grant(user)
		actions += move_down_action

/obj/machinery/computer/shuttle_flight/proc/CreateEye()
	shuttle_port = SSshuttle.getShuttle(shuttleId)
	if(QDELETED(shuttle_port))
		shuttle_port = null
		return

	var/static/list/passible_things = list(
		/obj/machinery/door,
		/obj/structure/falsewall,
		/obj/structure/holosign/barrier/atmos,
		/obj/structure/fans/tiny
	)

	var/turf/origin = locate(shuttle_port.x, shuttle_port.y, shuttle_port.z)
	eyeobj = new /mob/camera/ai_eye/remote/shuttle_docker(origin, src)
	var/mob/camera/ai_eye/remote/shuttle_docker/the_eye = eyeobj
	the_eye.setDir(shuttle_port.dir)
	for(var/obj/docking_port/mobile/M in shuttle_port.get_all_towed_shuttles())
		for(var/area/A in M.shuttle_areas)
			for(var/turf/T in A)
				if(T.get_virtual_z_level() != origin.get_virtual_z_level())
					continue
				// if it has doors or something passible, turn on a flag so it can return a better flag to show better result
				var/passible = FALSE
				for(var/each in passible_things)
					if(locate(each) in T)
						passible = TRUE
						break
				var/image/I = image('icons/effects/alphacolors_shuttle.dmi', origin, "red", dir=NORTH)
				var/x_off = T.x - origin.x
				var/y_off = T.y - origin.y
				I.loc = locate(origin.x + x_off, origin.y + y_off, origin.z) //we have to set this after creating the image because it might be null, and images created in nullspace are immutable.
				I.plane = ABOVE_LIGHTING_PLANE
				I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
				the_eye.placement_images[I] = list(x_off, y_off, passible)

/obj/machinery/computer/shuttle_flight/proc/give_eye_control(mob/user)
	if(!isliving(user))
		return
	if(eyeobj)
		qdel(eyeobj) //Custom shuttles can be modified, this needs to be updated to catch for that.
	CreateEye()
	GrantActions(user)
	current_user = user
	eyeobj.eye_user = user
	eyeobj.name = "Camera Eye ([user.name])"
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)
	eyeobj.setLoc(eyeobj.loc)
	if(!QDELETED(user) && user.client)
		var/mob/camera/ai_eye/remote/shuttle_docker/the_eye = eyeobj
		var/list/to_add = list()
		to_add += the_eye.placement_images
		to_add += the_eye.placed_images
		if(!shuttleObject.stealth)
			to_add += SSshuttle.hidden_shuttle_turf_images

		user.client.images += to_add
		user.client.view_size.setTo(view_range)

/obj/machinery/computer/shuttle_flight/remove_eye_control(mob/user)
	if(!user)
		return
	for(var/V in actions)
		var/datum/action/A = V
		A.Remove(user)
	actions.Cut()
	for(var/V in eyeobj.visibleCameraChunks)
		var/datum/camerachunk/C = V
		C.remove(eyeobj)
	if(user.client)
		user.reset_perspective(null)
		if(eyeobj.visible_icon && user.client)
			user.client.images -= eyeobj.user_image

	eyeobj.eye_user = null
	user.remote_control = null

	current_user = null
	user.unset_machine()

	playsound(src, 'sound/machines/terminal_off.ogg', 25, FALSE)

	if(!QDELETED(user) && user.client)
		var/mob/camera/ai_eye/remote/shuttle_docker/the_eye = eyeobj
		var/list/to_remove = list()
		to_remove += the_eye.placement_images
		to_remove += the_eye.placed_images
		if(!shuttleObject.stealth)
			to_remove += SSshuttle.hidden_shuttle_turf_images

		user.client.images -= to_remove
		user.client.view_size.resetToDefault()

/obj/machinery/computer/shuttle_flight/proc/placeLandingSpot()
	if(designating_target_loc || !current_user)
		return

	if(QDELETED(shuttleObject))
		to_chat(usr, "<span class='warning'>Shuttle has already docked.</span>")
		return

	var/mob/camera/ai_eye/remote/shuttle_docker/the_eye = eyeobj
	var/landing_clear = checkLandingSpot()
	if(designate_time && (landing_clear != SHUTTLE_DOCKER_BLOCKED))
		to_chat(current_user, "<span class='warning'>Targeting transit location, please wait [DisplayTimeText(designate_time)]...</span>")
		designating_target_loc = the_eye.loc
		var/wait_completed = do_after(current_user, designate_time, designating_target_loc, progress = TRUE, timed_action_flags = IGNORE_HELD_ITEM, extra_checks = CALLBACK(src, PROC_REF(canDesignateTarget)))
		designating_target_loc = null
		if(!current_user)
			return
		if(!wait_completed)
			to_chat(current_user, "<span class='warning'>Operation aborted.</span>")
			return
		landing_clear = checkLandingSpot()

	if(landing_clear != SHUTTLE_DOCKER_LANDING_CLEAR)
		switch(landing_clear)
			if(SHUTTLE_DOCKER_BLOCKED)
				to_chat(current_user, "<span class='warning'>Invalid transit location.</span>")
			if(SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT)
				to_chat(current_user, "<span class='warning'>Unknown object detected in landing zone. Please designate another location.</span>")
		return

	///Make one use port that deleted after fly off, to don't lose info that need on to properly fly off.
	if(my_port)
		my_port.delete_after = TRUE
		my_port.id = null
		my_port.name = "Old [my_port.name]"
		my_port = null

	if(!my_port)
		var/list/bounds = shuttle_port.return_union_bounds(shuttle_port.get_all_towed_shuttles())
		my_port = new()
		my_port.name = shuttlePortName
		my_port.id = shuttlePortId
		my_port.dwidth = bounds[1]
		my_port.dheight = bounds[2]
		my_port.width = bounds[3]
		my_port.height = bounds[4]
		my_port.hidden = shuttle_port.hidden
		my_port.delete_after = TRUE
	my_port.setDir(the_eye.dir)
	my_port.forceMove(locate(eyeobj.x, eyeobj.y, eyeobj.z))

	if(current_user.client)
		current_user.client.images -= the_eye.placed_images

	QDEL_LIST(the_eye.placed_images)

	for(var/V in the_eye.placement_images)
		var/image/I = V
		var/image/newI = image('icons/effects/alphacolors_shuttle.dmi', the_eye.loc, "blue")
		newI.loc = I.loc //It is highly unlikely that any landing spot including a null tile will get this far, but better safe than sorry.
		newI.plane = ABOVE_LIGHTING_PLANE
		newI.mouse_opacity = 0
		the_eye.placed_images += newI

	//Go to destination
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	switch(SSshuttle.moveShuttle(shuttleId, shuttlePortId, 1))
		if(0)
			remove_eye_control(usr)
			QDEL_NULL(shuttleObject)
			//Hold the shuttle in the docking position until ready.
			M.setTimer(INFINITY)
			say("Waiting for hyperspace lane...")
			INVOKE_ASYNC(src, PROC_REF(unfreeze_shuttle), M, SSmapping.get_level(eyeobj.z))
		if(1)
			to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
		else
			to_chat(usr, "<span class='notice'>Unable to comply.</span>")

	return TRUE

/obj/machinery/computer/shuttle_flight/proc/canDesignateTarget()
	if(!designating_target_loc || !current_user || (eyeobj.loc != designating_target_loc) || (machine_stat & (NOPOWER|BROKEN)) )
		return FALSE
	return TRUE

/obj/machinery/computer/shuttle_flight/proc/rotateLandingSpot()
	var/mob/camera/ai_eye/remote/shuttle_docker/the_eye = eyeobj
	var/list/image_cache = the_eye.placement_images
	the_eye.setDir(turn(the_eye.dir, -90))
	for(var/i in 1 to image_cache.len)
		var/image/pic = image_cache[i]
		var/list/coords = image_cache[pic]
		var/Tmp = coords[1]
		coords[1] = coords[2]
		coords[2] = -Tmp
		pic.loc = locate(the_eye.x + coords[1], the_eye.y + coords[2], the_eye.z)
		pic.setDir(turn(pic.dir, -90))
	checkLandingSpot()

/obj/machinery/computer/shuttle_flight/proc/checkLandingSpot()
	var/mob/camera/ai_eye/remote/shuttle_docker/the_eye = eyeobj
	var/turf/eyeturf = get_turf(the_eye)
	if(!eyeturf)
		return SHUTTLE_DOCKER_BLOCKED
	if(!eyeturf.z)
		return SHUTTLE_DOCKER_BLOCKED

	. = SHUTTLE_DOCKER_LANDING_CLEAR
	var/list/bounds = shuttle_port.return_coords(the_eye.x, the_eye.y, the_eye.dir)
	var/list/overlappers = SSshuttle.get_dock_overlap(bounds[1], bounds[2], bounds[3], bounds[4], the_eye.z)
	var/list/image_cache = the_eye.placement_images
	for(var/i in 1 to image_cache.len)
		var/image/I = image_cache[i]
		var/list/coords = image_cache[I]
		var/turf/T = locate(eyeturf.x + coords[1], eyeturf.y + coords[2], eyeturf.z)
		I.loc = T
		switch(checkLandingTurf(T, overlappers))
			if(SHUTTLE_DOCKER_LANDING_CLEAR)
				if(coords[3])
					I.icon_state = "blue"
				else
					I.icon_state = "green_arrows"
			if(SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT)
				if(coords[3])
					I.icon_state = "blue"
				else
					I.icon_state = "green_arrows"
				if(. == SHUTTLE_DOCKER_LANDING_CLEAR)
					. = SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT
			else
				if(coords[3])
					I.icon_state = "blue_blocked"
				else
					I.icon_state = "red_arrows"
				. = SHUTTLE_DOCKER_BLOCKED

/obj/machinery/computer/shuttle_flight/proc/checkLandingTurf(turf/T, list/overlappers)
	// Too close to the map edge is never allowed
	if(!T || T.x <= 10 || T.y <= 10 || T.x >= world.maxx - 10 || T.y >= world.maxy - 10)
		return SHUTTLE_DOCKER_BLOCKED
	// If it's one of our shuttle areas assume it's ok to be there
	if(shuttle_port.shuttle_areas[T.loc])
		return SHUTTLE_DOCKER_LANDING_CLEAR
	. = SHUTTLE_DOCKER_LANDING_CLEAR
	// See if the turf is hidden from us
	var/list/hidden_turf_info
	if(!shuttleObject.stealth)
		hidden_turf_info = SSshuttle.hidden_shuttle_turfs[T]
		if(hidden_turf_info)
			. = SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT

	if(length(whitelist_turfs))
		var/turf_type = hidden_turf_info ? hidden_turf_info[2] : T.type
		if(!is_type_in_typecache(turf_type, whitelist_turfs))
			return SHUTTLE_DOCKER_BLOCKED

	for(var/obj/machinery/M in T.contents) //An inprecise check to prevent theft of important machines such the SM or the communication console.
		return SHUTTLE_DOCKER_BLOCKED

	// Checking for overlapping dock boundaries
	for(var/i in 1 to overlappers.len)
		var/obj/docking_port/mobile/shuttle = overlappers[i]
		if(istype(shuttle) && shuttle.undockable)
			return SHUTTLE_DOCKER_BLOCKED
		var/obj/docking_port/stationary/port = overlappers[i]
		if(port == my_port)
			continue
		if(port.delete_after) //Don't worry about it, we're landing on another ship, no ship will land on this port.
			continue
		var/port_hidden = !shuttleObject.stealth && port.hidden
		var/list/overlap = overlappers[port]
		var/list/xs = overlap[1]
		var/list/ys = overlap[2]
		if(xs["[T.x]"] && ys["[T.y]"])
			if(port_hidden)
				. = SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT
			else
				return SHUTTLE_DOCKER_BLOCKED

/obj/machinery/computer/shuttle_flight/proc/update_hidden_docking_ports(list/remove_images, list/add_images)
	if(!shuttleObject?.stealth && current_user && current_user.client)
		current_user.client.images -= remove_images
		current_user.client.images += add_images

/obj/machinery/computer/shuttle_flight/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(port && (shuttleId == initial(shuttleId) || override))
		shuttleId = port.id
		shuttlePortId = "[shuttleId]_custom"

/mob/camera/ai_eye/remote/shuttle_docker
	visible_icon = FALSE
	use_static = FALSE
	var/list/placement_images = list()
	var/list/placed_images = list()

/mob/camera/ai_eye/remote/shuttle_docker/Initialize(mapload, obj/machinery/computer/camera_advanced/origin)
	src.origin = origin
	return ..()

/mob/camera/ai_eye/remote/shuttle_docker/canZMove(direction, turf/source, turf/target, pre_move = TRUE)
	return TRUE

/mob/camera/ai_eye/remote/shuttle_docker/setLoc(destination)
	. = ..()
	var/obj/machinery/computer/shuttle_flight/console = origin
	console.checkLandingSpot()

/mob/camera/ai_eye/remote/shuttle_docker/update_remote_sight(mob/living/user)
	user.sight = BLIND|SEE_TURFS
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	user.sync_lighting_plane_alpha()
	return TRUE

/datum/action/innate/shuttledocker_rotate
	name = "Rotate"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_cycle_equip_off"

/datum/action/innate/shuttledocker_rotate/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/ai_eye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/shuttle_flight/origin = remote_eye.origin
	origin.rotateLandingSpot()

/datum/action/innate/shuttledocker_place
	name = "Place"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_zoom_off"

/datum/action/innate/shuttledocker_place/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/ai_eye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/shuttle_flight/origin = remote_eye.origin
	origin.placeLandingSpot(target)

/datum/action/innate/camera_jump/shuttle_docker
	name = "Jump to Location"
	button_icon_state = "camera_jump"

/datum/action/innate/camera_jump/shuttle_docker/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/ai_eye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/shuttle_flight/console = remote_eye.origin

	if(QDELETED(console.shuttleObject))
		return

	playsound(console, 'sound/machines/terminal_prompt_deny.ogg', 25, 0)

	var/list/L = list()
	for(var/V in SSshuttle.stationary)
		if(!V)
			stack_trace("SSshuttle.stationary have null entry!")
			continue
		var/obj/docking_port/stationary/S = V
		if(console.shuttleObject.docking_target.z_in_contents(S.z) && (S.id in console.valid_docks))
			L["(L.len)[S.name]"] = S

	playsound(console, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
	var/selected = input("Choose location to jump to", "Locations", null) as null|anything in L
	if(QDELETED(src) || QDELETED(target) || !isliving(target))
		return
	playsound(src, "terminal_type", 25, 0)
	if(selected)
		var/turf/T = get_turf(L[selected])
		if(T)
			playsound(console, 'sound/machines/terminal_prompt_confirm.ogg', 25, 0)
			remote_eye.setLoc(T)
			to_chat(target, "<span class='notice'>Jumped to [selected].</span>")
			C.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
			C.clear_fullscreen("flash", 3)
	else
		playsound(console, 'sound/machines/terminal_prompt_deny.ogg', 25, 0)
