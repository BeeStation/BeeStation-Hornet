
/// The atom that we are currently hovering over
/client/var/atom/hovered_atom = null
/// The atom that we are currently hovering over
/client/var/hover_queued = FALSE
/// The next in the queue for screentip processing
/client/var/client/screentip_next = null

/client/Destroy()
	SSscreentips.on_client_disconnected(src)
	return ..()
