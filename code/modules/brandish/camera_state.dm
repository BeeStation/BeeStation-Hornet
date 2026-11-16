/// Composes camera effects without restoring stale snapshots over newer settings.
/// Logical view requests remain owned by view_data/their original callers.
/// BYOND rotates the world rectangle with client.dir. Quarter turns exchange
/// its axes; the same transform converts the applied rectangle back to screen.
/proc/camera_view_for_direction(view_size, facing)
	if(facing != EAST && facing != WEST)
		return view_size
	var/list/size = getviewsize(view_size)
	if(size[1] == size[2])
		return view_size
	return "[size[2]]x[size[1]]"

/// Screen/HUD dimensions. client.view itself remains the native world rectangle
/// for view(), visibility, AI camera coverage and other world-space queries.
/client/proc/screen_view()
	return camera_view_for_direction(view, dir)

/datum/client_camera_state
	var/client/owner
	var/requested_view
	var/list/effects = list()
	var/base_x = 0
	var/base_y = 0
	var/base_w = 0
	var/base_z = 0
	/// Effects belong to the body that requested them, even after client transfer.
	var/mob/effect_body
	var/effect_epoch = 0

/datum/client_camera_state/New(client/viewer)
	owner = viewer
	requested_view = viewer ? viewer.screen_view() : world.view
	if(viewer)
		base_x = viewer.pixel_x
		base_y = viewer.pixel_y
		base_w = viewer.pixel_w
		base_z = viewer.pixel_z
	return ..()

/datum/client_camera_state/Destroy()
	if(effect_body)
		UnregisterSignal(effect_body, list(COMSIG_MOB_LOGOUT, COMSIG_QDELETING))
	effect_body = null
	owner = null
	effects = null
	return ..()

/datum/client_camera_state/proc/set_effect(source, view_override, offset_x, offset_y, local_only, offset_w, offset_z)
	bind_effect_body()
	var/key = REF(source)
	effects -= key
	effects[key] = list(view_override, offset_x, offset_y, local_only, offset_w, offset_z)
	apply()

/// Bind once per controlling body, rather than making every zoom source infer
/// which client it previously affected from a mob's current client pointer.
/datum/client_camera_state/proc/bind_effect_body()
	if(!owner || effect_body == owner.mob)
		return
	if(effect_body)
		clear_body_effects()
	effect_body = owner.mob
	if(effect_body)
		RegisterSignals(effect_body, list(COMSIG_MOB_LOGOUT, COMSIG_QDELETING), PROC_REF(on_body_lost))

/datum/client_camera_state/proc/on_body_lost(datum/source)
	SIGNAL_HANDLER
	clear_body_effects()

/datum/client_camera_state/proc/clear_body_effects()
	if(effect_body)
		UnregisterSignal(effect_body, list(COMSIG_MOB_LOGOUT, COMSIG_QDELETING))
	effect_body = null
	effect_epoch++
	effects.Cut()
	// Legacy OFF-mode client animations also belong to the previous body.
	if(!owner || owner.brandish_disconnecting)
		return
	animate(owner, tag = CLIENT_CAMERA_ANIMATION)
	// view_data belongs to this client too; release transient zoom dimensions.
	owner?.view_size?.resetToDefault()
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
		if(effect[BRANDISH_EFFECT_LOCAL_ONLY] && !self_eye)
			continue
		if(!isnull(effect[BRANDISH_EFFECT_VIEW]))
			new_view = effect[BRANDISH_EFFECT_VIEW]
		x += effect[BRANDISH_EFFECT_WORLD_X]
		y += effect[BRANDISH_EFFECT_WORLD_Y]
		w += effect[BRANDISH_EFFECT_SCREEN_X]
		z += effect[BRANDISH_EFFECT_SCREEN_Y]
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
	owner.pixel_x = composed[BRANDISH_RESULT_WORLD_X]
	owner.pixel_y = composed[BRANDISH_RESULT_WORLD_Y]
	owner.pixel_w = composed[BRANDISH_RESULT_SCREEN_X]
	owner.pixel_z = composed[BRANDISH_RESULT_SCREEN_Y]
	var/atom/movable/screen/fullscreen/near_light = owner.mob?.screens["lighting_backdrop_seenear"]
	near_light?.update_for_camera(owner)
	// Layout calls can yield to the client. Commit every camera coordinate first.
	owner.apply_camera_view(composed[BRANDISH_RESULT_VIEW])
	// A watched player's zoom changes the view without changing heading.
	if(owner?.mob?.observers)
		owner.mob.sync_brandish_observers()

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
	var/mob/body
	var/epoch

/datum/camera_shake/New(client/viewer)
	owner = viewer
	body = viewer?.mob
	viewer?.ensure_camera_state().bind_effect_body()
	epoch = viewer?.camera_state?.effect_epoch
	return ..()

/datum/camera_shake/Destroy()
	owner?.clear_camera_effect(src)
	owner = null
	body = null
	return ..()

/datum/camera_shake/proc/start(duration, strength)
	set waitfor = FALSE
	var/amplitude = strength * ICON_SIZE_ALL
	for(var/tick in 1 to duration)
		if(!owner || owner.mob != body || owner.camera_state?.effect_epoch != epoch)
			break
		owner.set_camera_effect(src, offset_w = rand(-amplitude, amplitude), offset_z = rand(-amplitude, amplitude), local_only = FALSE)
		sleep(1)
	qdel(src)

/// Apply an already composed view. Camera effects must use change_view/effects.
/client/proc/apply_camera_view(new_size)
	if (isnull(new_size))
		CRASH("change_view called without argument.")

	var/applied_view = camera_view_for_direction(new_size, dir)
	if(view == applied_view)
		return
	view = applied_view
	SEND_SIGNAL(src, COMSIG_VIEW_SET, applied_view)
	apply_clickcatcher()
	mob?.reload_fullscreen()
	if (isliving(mob))
		var/mob/living/M = mob
		M.update_damage_hud()
	attempt_auto_fit_viewport()

/// Reproject cached screen offsets when only the camera heading changes.
/client/proc/rotate_camera_parallax(old_dir, new_dir)
	for(var/atom/movable/screen/parallax_layer/layer as anything in parallax_layers)
		var/list/world_offset = camera_screen_to_world(layer.offset_x, layer.offset_y, old_dir)
		var/list/screen_offset = camera_world_to_screen(world_offset[1], world_offset[2], new_dir)
		layer.offset_x = screen_offset[1]
		layer.offset_y = screen_offset[2]
		layer.screen_loc = "CENTER-7:[round(layer.offset_x, 1)],CENTER-7:[round(layer.offset_y, 1)]"
		animate(layer)
		layer.transform = matrix()
	if(length(parallax_layers))
		mob?.hud_used?.set_parallax_movedir(parallax_movedir, TRUE, force = TRUE)
