/mob/living/silicon/ai/proc/get_camera_list()
	var/list/L = list()
	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		L.Add(C)

	camera_sort(L)

	var/list/T = list()

	for (var/obj/machinery/camera/C in L)
		if(!(is_station_level(C.z) || is_mining_level(C.z)))
			continue
		if (L.len)
			T["[C.c_tag][(C.can_use() ? null : " (Deactivated)")]"] = C

	return T

/mob/living/silicon/ai/proc/show_camera_list()
	var/list/cameras = get_camera_list()
	var/camera = tgui_input_list(src, "Choose which camera you want to view", "Cameras", cameras)
	switchCamera(cameras[camera])

/datum/trackable
	var/initialized = FALSE
	var/list/names = list()
	var/list/namecounts = list()
	var/list/humans = list()
	var/list/others = list()

/mob/living/silicon/ai/proc/trackable_mobs()
	track.initialized = TRUE
	track.names.Cut()
	track.namecounts.Cut()
	track.humans.Cut()
	track.others.Cut()

	if(usr.stat == DEAD)
		return list()

	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		if(!L.can_track(usr))
			continue

		var/name = L.name
		while(name in track.names)
			track.namecounts[name]++
			name = "[name] ([track.namecounts[name]])"
		track.names.Add(name)
		track.namecounts[name] = 1

		if(ishuman(L))
			track.humans[name] = WEAKREF(L)
		else
			track.others[name] = WEAKREF(L)

	var/list/targets = sort_list(track.humans) + sort_list(track.others)

	return targets

/mob/living/silicon/ai/verb/ai_camera_track(target_name in trackable_mobs())
	set name = "track"
	set hidden = 1 //Don't display it on the verb lists. This verb exists purely so you can type "track Oldman Robustin" and follow his ass

	if(!target_name)
		return

	if(!track.initialized)
		trackable_mobs()

	var/datum/weakref/target_ref = (isnull(track.humans[target_name]) ? track.others[target_name] : track.humans[target_name])
	if (!target_ref)
		return
	var/atom/target = target_ref.resolve()

	attempt_track(target)

/mob/living/silicon/ai/proc/attempt_track(mob/living/target)
	//If the AI has malf upgrades, allow instant tracking
	var/instant_track = !!malf_picker || issilicon(target) || isbot(target)

	// Check if target has maxed suit sensors
	var/has_maxed_sensors = FALSE
	var/on_camera = near_camera(target)

	if(!instant_track && ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/nanite_sensors = HAS_TRAIT(human_target, TRAIT_SUIT_SENSORS)
		if(!human_target.is_jammed(JAMMER_PROTECTION_SENSOR_NETWORK) && (nanite_sensors || HAS_TRAIT(human_target, TRAIT_NANITE_SENSORS)))
			var/obj/item/clothing/under/uniform = human_target.w_uniform
			if (nanite_sensors || uniform?.sensor_mode >= SENSOR_COORDS)
				has_maxed_sensors = TRUE

	// If they have maxed sensors, allow tracking regardless of camera coverage
	if(!target || (!on_camera && !has_maxed_sensors))
		to_chat(src, span_warning("Target is not near any active cameras and has no suit sensor beacon."))
		return

	// Start calculating track time
	var/track_time = instant_track ? 0 : 8 SECONDS

	// Check for light
	var/turf/target_location = get_turf(target)
	if (target_location.get_lumcount() > 0.4)
		track_time -= 2 SECONDS

	if (!instant_track && ishuman(target))
		var/mob/living/carbon/human/human_target = target

		// If they have maxed sensors and are on camera, track instantly
		if(has_maxed_sensors && on_camera)
			track_time = 0
		// If they have maxed sensors but NOT on camera
		else if(has_maxed_sensors && !on_camera)
			track_time = 2 SECONDS
		// Facial recognition requires visible face
		else if(human_target.get_face_name() != human_target.real_name)
			to_chat(src, span_warning("Facial recognition failed. Unable to acquire track."))
			return
		else
			// Face is visible, apply bonuses
			track_time -= 2 SECONDS // Face visible bonus
			// Check for ID
			if (human_target.get_id_name() == human_target.real_name)
				track_time -= 2 SECONDS

	if (!instant_track && !ishuman(target))
		// Animals are easy to track
		track_time -= 6 SECONDS

	//Require the target to remain still for track_time seconds in order to acquire the track.
	//Once track is acquired, it will hold and follow them while moving
	if (track_time > 0)
		var/message = has_maxed_sensors && !on_camera ? "Target has suit sensor beacon but is not on camera. Triangulating position..." : "Target has no suit sensor beacon, querying facial recognition network."
		to_chat(src, span_notice("[message] Query ETA: [track_time/10] seconds..."))
		var/turf/target_turf = get_turf(target)
		addtimer(CALLBACK(src, PROC_REF(track_if_not_moved), target, target_turf), track_time)
		return

	ai_start_tracking(target)

/mob/living/silicon/ai/proc/track_if_not_moved(mob/living/target, turf/T)
	if(get_turf(target) != T)
		to_chat(src, span_warning("Unable to locate target. Facial recognition subsystems report partial checks. Another attempt may succeed."))
		return
	ai_start_tracking(target)

/mob/living/silicon/ai/proc/ai_start_tracking(mob/living/target) //starts ai tracking
	if(!target || !target.can_track(src))
		to_chat(src, span_warning("Target is not near any active cameras."))
		return
	if(ai_tracking_target) //if there is already a tracking going when this gets called makes sure the old tracking gets stopped before we register the new signals
		ai_stop_tracking()
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(tracking_target_qdeleted))
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(ai_actual_track))
	ai_tracking_target = target
	eyeobj.setLoc(get_turf(target)) //on the first call of this we obviously need to jump to the target ourselfs else we would go there only after they moved once
	to_chat(src, span_notice("Now tracking [target.get_visible_name()] on camera."))

/mob/living/silicon/ai/proc/tracking_target_qdeleted() //we wrap the ai_stop_tracking proc so we don't need to offset the arguments in ai_stop_tracking
	SIGNAL_HANDLER
	ai_stop_tracking()

/mob/living/silicon/ai/proc/ai_stop_tracking(reacquire_failed = FALSE) //stops ai tracking
	UnregisterSignal(ai_tracking_target, COMSIG_QDELETING)
	UnregisterSignal(ai_tracking_target, COMSIG_MOVABLE_MOVED)
	ai_tracking_target = null
	if(reacquire_timer)
		if(reacquire_failed) //edge case when someone might jump to another camera while the reacquire timer is running
			to_chat(src, span_warning("Unable to reacquire, cancelling track..."))
		else
			deltimer(reacquire_timer)
		reacquire_timer = null

/mob/living/silicon/ai/proc/ai_actual_track() //proc that gets called by the moved signal of the target
	SIGNAL_HANDLER
	if(ai_tracking_target.can_track(src))
		if(reacquire_timer)	//if we can track our target again but there is a timer running delete the timer and null the timer id
			deltimer(reacquire_timer)
			reacquire_timer = null
	else
		if(!reacquire_timer)
			reacquire_timer = addtimer(CALLBACK(src, PROC_REF(ai_stop_tracking), TRUE), 10 SECONDS, TIMER_STOPPABLE) //A timer for how long to wait before we stop tracking someone after loosing them
			to_chat(src, span_warning("Target is not near any active cameras. Attempting to reacquire..."))
		return

	eyeobj.setLoc(get_turf(ai_tracking_target))

/proc/near_camera(mob/living/M)
	if (!isturf(M.loc))
		return FALSE
	if(issilicon(M))
		var/mob/living/silicon/S = M
		if((QDELETED(S.builtInCamera) || !S.builtInCamera.can_use()) && !GLOB.cameranet.checkCameraVis(M))
			return FALSE
	else if(!GLOB.cameranet.checkCameraVis(M))
		return FALSE
	return TRUE

/obj/machinery/camera/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	if (!can_use())
		return
	user.switchCamera(src)

/proc/camera_sort(list/L)
	var/obj/machinery/camera/a
	var/obj/machinery/camera/b

	for (var/i = L.len, i > 0, i--)
		for (var/j = 1 to i - 1)
			a = L[j]
			b = L[j + 1]
			if (sorttext(a.c_tag, b.c_tag) < 0)
				L.Swap(j, j + 1)
	return L
