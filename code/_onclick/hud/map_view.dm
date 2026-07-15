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

	/// Weakrefs of all our client viewers
	var/list/datum/weakref/viewers = list()
	/// Our plane master controller thing
	var/datum/remote_view/remote_view

/atom/movable/screen/map_view/Destroy()
	for(var/datum/weakref/client_ref in viewers)
		hide_from_client(client_ref.resolve())
	QDEL_NULL(remote_view)
	viewers = null
	return ..()

/atom/movable/screen/map_view/proc/generate_view(map_key)
	assigned_map = map_key
	set_position(1, 1)
	remote_view = new(assigned_map)

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

/atom/movable/screen/map_view/proc/display_to_client(client/show_to)
	var/datum/weakref/client_ref = WEAKREF(show_to)
	if(client_ref in viewers)
		return

	show_to.register_map_obj(src)
	remote_view.join(show_to)

	viewers |= client_ref

/atom/movable/screen/map_view/proc/hide_from(mob/hide_from)
	hide_from_client(hide_from?.client)

/atom/movable/screen/map_view/proc/hide_from_client(client/hide_from)
	if(!hide_from)
		return

	hide_from.clear_map(assigned_map)
	remote_view.leave(hide_from)

	viewers -= WEAKREF(hide_from)
