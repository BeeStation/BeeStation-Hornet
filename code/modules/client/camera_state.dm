/// Composes camera effects without restoring stale snapshots over newer settings.
/// Logical view requests remain owned by view_data/their original callers.
/datum/client_camera_state
	var/client/owner
	var/requested_view
	var/list/effects = list()
	var/base_x = 0
	var/base_y = 0
	var/base_w = 0
	var/base_z = 0

/datum/client_camera_state/New(client/viewer)
	owner = viewer
	requested_view = viewer ? viewer.view : world.view
	if(viewer)
		base_x = viewer.pixel_x
		base_y = viewer.pixel_y
		base_w = viewer.pixel_w
		base_z = viewer.pixel_z
	return ..()

/datum/client_camera_state/Destroy()
	owner = null
	effects = null
	return ..()

/datum/client_camera_state/proc/set_effect(source, view_override, offset_x, offset_y, local_only, offset_w, offset_z)
	var/key = REF(source)
	effects -= key
	effects[key] = list(view_override, offset_x, offset_y, local_only, offset_w, offset_z)
	apply()

/datum/client_camera_state/proc/remove_effect(source)
	if(!(REF(source) in effects))
		return
	effects -= REF(source)
	apply()

/// Pure composition also allows restoration/remote-eye rules to be unit tested.
/datum/client_camera_state/proc/resolve(self_eye, square_view)
	var/new_view = requested_view
	var/x = base_x
	var/y = base_y
	var/w = base_w
	var/z = base_z
	for(var/key in effects)
		var/list/effect = effects[key]
		if(effect[4] && !self_eye)
			continue
		if(!isnull(effect[1]))
			new_view = effect[1]
		x += effect[2]
		y += effect[3]
		w += effect[5]
		z += effect[6]
	if(square_view && self_eye)
		var/list/size = getviewsize(new_view)
		var/side = min(size[1], size[2])
		new_view = "[side]x[side]"
	return list(new_view, x, y, w, z)

/datum/client_camera_state/proc/apply()
	if(!owner || owner.brandish_disconnecting)
		return
	var/local_eye = owner.brandish_camera ? owner.brandish_has_local_eye() : owner.eye == owner.mob
	var/list/composed = resolve(local_eye, !!owner.brandish_camera)
	owner.pixel_x = composed[2]
	owner.pixel_y = composed[3]
	owner.pixel_w = composed[4]
	owner.pixel_z = composed[5]
	var/atom/movable/screen/fullscreen/near_light = owner.mob?.screens["lighting_backdrop_seenear"]
	near_light?.update_for_camera(owner)
	// Layout calls can yield to the client. Commit every camera coordinate first.
	if(owner.view != composed[1])
		owner.apply_camera_view(composed[1])

/client
	var/datum/client_camera_state/camera_state

/client/proc/ensure_camera_state()
	if(!camera_state)
		camera_state = new(src)
	return camera_state

/client/proc/set_camera_effect(datum/source, view_override = null, offset_x = 0, offset_y = 0, local_only = TRUE, offset_w = 0, offset_z = 0)
	ensure_camera_state()
	camera_state.set_effect(source, view_override, offset_x, offset_y, local_only, offset_w, offset_z)

/client/proc/clear_camera_effect(datum/source)
	camera_state?.remove_effect(source)

/// Transient jitter owns a separate effect, so a turn or mode change during
/// the shake cannot restore an obsolete camera position when it finishes.
/datum/camera_shake
	var/client/owner

/datum/camera_shake/New(client/viewer)
	owner = viewer
	return ..()

/datum/camera_shake/Destroy()
	owner?.clear_camera_effect(src)
	owner = null
	return ..()

/datum/camera_shake/proc/start(duration, strength)
	set waitfor = FALSE
	var/amplitude = strength * ICON_SIZE_ALL
	for(var/tick in 1 to duration)
		if(!owner)
			break
		owner.set_camera_effect(src, offset_w = rand(-amplitude, amplitude), offset_z = rand(-amplitude, amplitude), local_only = FALSE)
		sleep(1)
	qdel(src)
