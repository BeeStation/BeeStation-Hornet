// AI EYE
//
// An invisible (no icon) mob that the AI controls to look around the station with.
// It streams chunks as it moves around, which will show it what the AI can and cannot see.
/mob/camera/ai_eye
	name = "Inactive AI Eye"

	icon_state = "ai_camera"
	icon = 'icons/mob/cameramob.dmi'
	invisibility = INVISIBILITY_MAXIMUM
	hud_possible = list(ANTAG_HUD, AI_DETECT_HUD = HUD_LIST_LIST)
	var/list/visibleCameraChunks = list()
	var/mob/living/silicon/ai/ai = null
	var/use_static = TRUE
	var/static_visibility_range = 16
	var/ai_detector_visible = TRUE
	var/ai_detector_color = COLOR_RED

/mob/camera/ai_eye/Initialize(mapload)
	. = ..()
	GLOB.ai_eyes += src
	update_ai_detect_hud()
	setLoc(loc, TRUE)

/mob/camera/ai_eye/proc/set_relay_speech(relay)
	if(relay)
		become_hearing_sensitive()
	else
		REMOVE_TRAIT(src, TRAIT_HEARING_SENSITIVE, TRAIT_GENERIC)

/mob/camera/ai_eye/proc/update_ai_detect_hud()
	var/datum/atom_hud/ai_detector/hud = GLOB.huds[DATA_HUD_AI_DETECT]
	var/list/old_images = hud_list[AI_DETECT_HUD]
	if(!ai_detector_visible)
		hud.remove_from_hud(src)
		QDEL_LIST(old_images)
		return

	if(!length(hud.hudusers))
		return //no one is watching, do not bother updating anything

	hud.remove_from_hud(src)

	var/static/list/vis_contents_opaque = list()
	var/obj/effect/overlay/ai_detect_hud/hud_obj = vis_contents_opaque[ai_detector_color]

	if(!hud_obj)
		hud_obj = new /obj/effect/overlay/ai_detect_hud()
		hud_obj.color = ai_detector_color
		vis_contents_opaque[ai_detector_color] = hud_obj

	var/list/new_images = list()
	var/list/turfs = get_visible_turfs()
	for(var/T in turfs)
		var/image/I = (old_images.len > new_images.len) ? old_images[new_images.len + 1] : image(null, T)
		I.loc = T
		I.vis_contents += hud_obj
		new_images += I
	for(var/i in (new_images.len + 1) to old_images.len)
		qdel(old_images[i])
	hud_list[AI_DETECT_HUD] = new_images
	hud.add_to_hud(src)

/mob/camera/ai_eye/proc/get_visible_turfs()
	if(!isturf(loc))
		return list()
	var/client/C = GetViewerClient()
	var/view = C ? getviewsize(C.view) : getviewsize(world.view)
	var/turf/lowerleft = locate(max(1, x - (view[1] - 1)/2), max(1, y - (view[2] - 1)/2), z)
	var/turf/upperright = locate(min(world.maxx, lowerleft.x + (view[1] - 1)), min(world.maxy, lowerleft.y + (view[2] - 1)), lowerleft.z)
	return block(lowerleft, upperright)

// Use this when setting the ai_eye's location.
// It will also stream the chunk that the new loc is in.

/mob/camera/ai_eye/proc/setLoc(destination, force_update = FALSE)
	if(ai)
		if(!isturf(ai.loc))
			return
		destination = get_turf(destination)
		if(!force_update && (destination == get_turf(src)) )
			return //we are already here!
		if (destination)
			abstract_move(destination)
		else
			moveToNullspace()
		if(use_static)
			ai.camera_visibility(src)
		if(ai.client && !ai.multicam_on)
			ai.client.eye = src
		update_ai_detect_hud()
		//Holopad
		if(istype(ai.current_holopad, /obj/machinery/holopad))
			ai.current_holopad.move_hologram(ai, destination)
		if(ai.camera_light_on)
			ai.light_cameras()
		if(ai.master_multicam)
			ai.master_multicam.refresh_view()

//it uses setLoc not forceMove, talks to the sillycone and not the camera mob
/mob/camera/ai_eye/zMove(dir, feedback = FALSE, feedback_to = ai)
	if(dir != UP && dir != DOWN)
		return FALSE
	var/turf/source = get_turf(src)
	var/turf/target = get_step_multiz(src, dir)
	if(!target)
		if(feedback)
			to_chat(feedback_to, "<span class='warning'>There's nowhere to go in that direction!</span>")
		return FALSE
	if(!canZMove(dir, source, target))
		if(feedback)
			to_chat(feedback_to, "<span class='warning'>You couldn't move there!</span>")
		return FALSE
	setLoc(target, TRUE)
	return TRUE

/mob/camera/ai_eye/canZMove(direction, turf/source, turf/target, pre_move = TRUE) //cameras do not respect these FLOORS you speak so much of
	return TRUE

/mob/camera/ai_eye/Move()
	return 0

/mob/camera/ai_eye/proc/GetViewerClient()
	if(ai)
		return ai.client
	return null

/mob/camera/ai_eye/Destroy()
	if(ai)
		transfer_observers_to(ai) // eye mob is destroyed for some reason...
		ai.all_eyes -= src
		ai = null
	for(var/V in visibleCameraChunks)
		var/datum/camerachunk/c = V
		c.remove(src)
	GLOB.ai_eyes -= src
	if(ai_detector_visible)
		var/datum/atom_hud/ai_detector/hud = GLOB.huds[DATA_HUD_AI_DETECT]
		hud.remove_from_hud(src)
		var/list/L = hud_list[AI_DETECT_HUD]
		QDEL_LIST(L)
	return ..()

/mob/camera/ai_eye/proc/move_camera_by_click(var/atom/target)
	if((ai.multicam_on || (ai.client.eye == src)) && (get_virtual_z_level() == target.get_virtual_z_level()))
		if(ai.ai_tracking_target)
			ai.ai_stop_tracking()
		if (isturf(target.loc) || isturf(target))
			setLoc(target)

// This will move the ai_eye. It will also cause lights near the eye to light up, if toggled.
// This is handled in the proc below this one.

/client/proc/AIMove(n, direct, mob/living/silicon/ai/user)

	var/initial = initial(user.sprint)
	var/max_sprint = 50

	if(user.cooldown && user.cooldown < world.timeofday) // 3 seconds
		user.sprint = initial

	for(var/i = 0; i < max(user.sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(user.eyeobj, direct))
		if(step)
			user.eyeobj.setLoc(step)

	user.cooldown = world.timeofday + 5
	if(user.acceleration)
		user.sprint = min(user.sprint + 0.5, max_sprint)
	else
		user.sprint = initial

	if(user.ai_tracking_target && !user.reacquire_timer)
		user.ai_stop_tracking()

// Return to the Core.
/mob/living/silicon/ai/proc/view_core()
	if(istype(current_holopad, /obj/machinery/holopad))
		current_holopad.clear_holo(src)
	else
		current_holopad = null
	if(ai_tracking_target)
		ai_stop_tracking()
	unset_machine()

	if(isturf(loc) && (QDELETED(eyeobj) || !eyeobj.loc))
		to_chat(src, "ERROR: Eyeobj not found. Creating new eye...")
		create_eye()

	transfer_observers_to(eyeobj) // ai core to eyemob
	eyeobj.setLoc(loc)

/mob/living/silicon/ai/proc/create_eye()
	if(!eyeobj || QDELETED(eyeobj))
		eyeobj = new /mob/camera/ai_eye()
		all_eyes += eyeobj
		eyeobj.ai = src
		eyeobj.setLoc(loc)
		eyeobj.name = "[name] (AI Eye)"
		eyeobj.real_name = eyeobj.name
		set_eyeobj_visible(TRUE)
		transfer_observers_to(eyeobj)

/mob/living/silicon/ai/proc/set_eyeobj_visible(state = TRUE)
	if(!eyeobj)
		return
	eyeobj.mouse_opacity = state ? MOUSE_OPACITY_ICON : initial(eyeobj.mouse_opacity)
	eyeobj.invisibility = state ? INVISIBILITY_OBSERVER : initial(eyeobj.invisibility)

/mob/living/silicon/ai/verb/toggle_acceleration()
	set category = "AI Commands"
	set name = "Toggle Camera Acceleration"

	if(incapacitated())
		return
	acceleration = !acceleration
	to_chat(usr, "Camera acceleration has been toggled [acceleration ? "on" : "off"].")

/mob/camera/ai_eye/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	if(speaker && ai && !radio_freq && speaker != ai && near_camera(speaker))
		ai.relay_speech(message, speaker, message_language, raw_message, radio_freq, spans, message_mods)

/obj/effect/overlay/ai_detect_hud
	name = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = ""
	alpha = 100
	layer = ABOVE_ALL_MOB_LAYER
	plane = GAME_PLANE
