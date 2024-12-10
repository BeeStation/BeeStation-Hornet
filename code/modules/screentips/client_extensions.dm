
/// The atom that we are currently hovering over
/client/var/atom/hovered_atom = null
/// The next in the queue for screentip processing
/client/var/client/screentip_next = null
/// We will get duplicates in the chain that we need to skip
/client/var/client/screentip_last_process = 0
/// We will get duplicates in the chain that we need to skip
/client/var/datum/screentip_context/screentip_context = new()

/client/Destroy()
	SSscreentips.on_client_disconnected(src)
	return ..()
