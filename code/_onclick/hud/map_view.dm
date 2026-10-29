/**
 * A screen object, which acts as a container for turfs and other things
 * you want to show on the map, which you usually attach to "vis_contents".
 */
INITIALIZE_IMMEDIATE(/atom/movable/screen/map_view)
/atom/movable/screen/map_view
	name = "screen"
	// Map view has to be on the lowest plane to enable proper lighting
	layer = GAME_PLANE
	plane = GAME_PLANE
	del_on_map_removal = FALSE

	// Weakrefs of all our hud viewers -> a weakref to the hud datum they last used
	var/list/datum/weakref/viewers_to_huds = list()

/atom/movable/screen/map_view/Destroy()
	for(var/datum/weakref/client_ref in viewers_to_huds)
		remove_viewer(client_ref)
	viewers_to_huds = null
	return ..()

/atom/movable/screen/map_view/proc/generate_view(map_key)
	assigned_map = map_key
	set_position(1, 1)

/**
 * Generates and displays the map view to a client
 * Make sure you at least try to pass tgui_window if map view needed on UI,
 * so it will wait a signal from TGUI, which tells windows is fully visible.
 *
 * * show_to - Mob which needs map view
 * * window - Optional. TGUI window which needs map view
 */
/atom/movable/screen/map_view/proc/display_to(mob/show_to, datum/tgui_window/window)
	if(window && !window.visible)
		RegisterSignal(window, COMSIG_TGUI_WINDOW_VISIBLE, PROC_REF(display_on_ui_visible))
	else
		display_to_client(show_to.client)

/atom/movable/screen/map_view/proc/display_on_ui_visible(datum/tgui_window/window, client/show_to)
	SIGNAL_HANDLER
	display_to_client(show_to)
	UnregisterSignal(window, COMSIG_TGUI_WINDOW_VISIBLE)

/// Displays the map view to a client, and returns the plane master group made for it
/atom/movable/screen/map_view/proc/display_to_client(client/show_to)
	// Store this info in a client -> hud pattern, so ghosts closing the window nukes the right group
	var/datum/weakref/client_ref = WEAKREF(show_to)
	var/datum/hud/viewer_hud = show_to.mob?.hud_used

	var/datum/weakref/hud_ref = viewers_to_huds[client_ref]
	var/datum/hud/existing_hud = hud_ref?.resolve()
	if(existing_hud)
		if(existing_hud == viewer_hud)
			return existing_hud.get_plane_group(PLANE_GROUP_POPUP_WINDOW(src))
		// We changed mobs since, that group is on a hud we no longer see
		delete_viewer_group(show_to, existing_hud)

	show_to.register_map_obj(src)

	viewers_to_huds[client_ref] = WEAKREF(viewer_hud)
	if(!viewer_hud)
		return null
	var/datum/plane_master_group/popup/pop_planes = new(PLANE_GROUP_POPUP_WINDOW(src), assigned_map)
	pop_planes.set_hud(viewer_hud)
	return pop_planes

/atom/movable/screen/map_view/proc/hide_from(mob/hide_from)
	if(hide_from?.client)
		hide_from_client(hide_from.client)
		return
	// The client has moved on, find it by the hud we gave it
	var/datum/hud/old_hud = hide_from?.hud_used
	if(!old_hud)
		return
	for(var/datum/weakref/client_ref in viewers_to_huds)
		var/datum/weakref/hud_ref = viewers_to_huds[client_ref]
		if(hud_ref?.resolve() == old_hud)
			remove_viewer(client_ref)

/atom/movable/screen/map_view/proc/hide_from_client(client/hide_from)
	if(!hide_from)
		return

	var/datum/weakref/client_ref = WEAKREF(hide_from)
	if(client_ref in viewers_to_huds)
		remove_viewer(client_ref)
	else
		hide_from.clear_map(assigned_map)

/// Forgets a viewer, clearing our map from their client and deleting their plane group
/atom/movable/screen/map_view/proc/remove_viewer(datum/weakref/client_ref)
	var/datum/weakref/hud_ref = viewers_to_huds[client_ref]
	viewers_to_huds -= client_ref
	var/client/viewer = client_ref.resolve()
	viewer?.clear_map(assigned_map)
	var/datum/hud/viewer_hud = hud_ref?.resolve()
	if(viewer_hud)
		delete_viewer_group(viewer, viewer_hud)

/// Deletes the plane group we made on a viewer's hud
/atom/movable/screen/map_view/proc/delete_viewer_group(client/viewer, datum/hud/viewer_hud)
	var/datum/plane_master_group/popup/pop_planes = viewer_hud.get_plane_group(PLANE_GROUP_POPUP_WINDOW(src))
	if(!pop_planes)
		return
	if(viewer && viewer != viewer_hud.mymob.client)
		pop_planes.hide_from_client(viewer)
	qdel(pop_planes)
