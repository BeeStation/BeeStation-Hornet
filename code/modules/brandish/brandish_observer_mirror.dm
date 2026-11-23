
/// Ghosts using Observe see the watched player's heading, look-ahead and view
/// size. The mirror lives on the client so it cannot outlive a body transfer.
/datum/brandish_observe_mirror

/client
	var/datum/brandish_observe_mirror/brandish_mirror

/client/proc/clear_brandish_observe()
	if(!brandish_mirror)
		return
	clear_camera_effect(brandish_mirror)
	QDEL_NULL(brandish_mirror)
	if(!brandish_disconnecting)
		apply_default_client_dir()

/mob/proc/sync_brandish_observers()
	for(var/mob/dead/observer/watcher in observers)
		watcher.sync_brandish_observe()

/// Call whenever the observed target, its camera or its heading changes.
/mob/dead/observer/proc/sync_brandish_observe()
	if(!client)
		return
	var/client/watched = observetarget?.client
	var/datum/brandish_camera/camera = watched?.brandish_camera
	if(!camera || camera.body != observetarget)
		client.clear_brandish_observe()
		return
	if(!client.brandish_mirror)
		client.brandish_mirror = new
	if(client.dir != watched.dir)
		client.setDir(watched.dir)
	// Not local_only: the observer's eye is the watched body, not its own mob.
	client.set_camera_effect(client.brandish_mirror, watched.screen_view(), local_only = FALSE, offset_z = camera.lead_tiles * ICON_SIZE_Y)
