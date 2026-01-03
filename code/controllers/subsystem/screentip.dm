SUBSYSTEM_DEF(screentips)
	name = "screentips"
	wait = 1
	// Allocated a relatively small amount of processing time
	priority = FIRE_PRIORITY_SCREENTIPS
	flags = SS_NO_INIT | SS_TICKER
	// Head of the scanning loop
	var/client/head = null
	/// Diagnostics/Performance tracking: Keep track of how many atoms had to dereference their user
	var/deleted_hovered_atoms = 0
	var/caches_generated = 0

/datum/controller/subsystem/screentips/fire(resumed)
	while (head != null && !MC_TICK_CHECK)
		if (QDELETED(head.hovered_atom))
			head.hover_queued = FALSE
			head = head.screentip_next
			continue
		head.hovered_atom.on_mouse_enter(head)
		head.hover_queued = FALSE
		head = head.screentip_next

/datum/controller/subsystem/screentips/proc/on_client_disconnected(client/target)
	SHOULD_NOT_SLEEP(TRUE)
	var/client/current = head
	if (current == target)
		head = current.screentip_next
		return
	while (current != null)
		var/client/next = current.screentip_next
		if (next != target)
			current = next
			continue
		current.screentip_next = next.screentip_next
		return
