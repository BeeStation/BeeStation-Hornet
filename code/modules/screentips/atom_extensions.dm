/**
 * This proc sucks, simply defining it means that a lot of information is going
 * to be communicated between the client and the server.
 * I have experimented with doing this clientside by using skin, but transparent elements
 * only render for a single frame before being removed.
 *
 * This will be very hot regardless of what is in this loop, and will appear on the profiler.
 * There is unfortunately nothing we can do about this until skin.dmf supports transparent background
 * labels.
 *
 * This may seem like a lot compared to a dictionary set, but this avoids the expensive operation
 * of dictionary indexing as it doesn't require hashing and just needs some super cheap
 * variable accesses
 */
/atom/MouseEntered(location, control, params)
	SHOULD_CALL_PARENT(TRUE)
#ifdef SPACEMAN_DMM
	// We don't actually want to call the parent of this one but
	// this technically has a parent that we need to call
	..()
#endif
	// If someone is connected to us in the queue, then we don't need to requeue
	if (usr.client.hovered_atom)
		usr.client.hovered_atom = src
		return
	// Holds a hard-reference for a single frame
	usr.client.hovered_atom = src
	usr.client.screentip_next = SSscreentips.head
	SSscreentips.head = usr.client

/// Called when a client mouses over this atom
/atom/proc/on_mouse_enter(client/client)
	var/screentip_message = "<span class='big' style='line-height: 0.5'>[MAPTEXT(CENTER(capitalize(name)))]</span>"
	var/datum/screentip_cache/cache = GLOB.screentips_cache["[type]"]
	if (cache)
#ifdef DEBUG
		screentip_message = "<span class='big' style='line-height: 0.5'>[MAPTEXT(CENTER(capitalize(name) + "(Using Cache)"))]</span>"
#endif
		if (ishuman(client.mob) && client.mob.get_active_held_item() == null)
			client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message][cache.attack_hand]</span>"
		else
			client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message]</span>"
	else
		var/datum/screentip_context/context = client.screentip_context
		context.relevant = ishuman(client.mob)
		context.user = client.mob
		context.held_item = client.mob?.get_active_held_item()
		context.access_context = ""
		context.left_mouse_context = ""
		context.tool_icon_context = ""
		context.shift_left_mouse_context = ""
		context.ctrl_left_mouse_context = ""
		context.alt_left_mouse_context = ""
		context.ctrl_shift_left_mouse_context = ""
		SEND_SIGNAL(src, COMSIG_ATOM_ADD_CONTEXT, context, client.mob)
		add_context_self(context, client.mob)
		if (context.relevant)
			client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message][context.access_context][context.left_mouse_context][context.ctrl_left_mouse_context][context.shift_left_mouse_context][context.alt_left_mouse_context][context.ctrl_shift_left_mouse_context][context.tool_icon_context]</span>"
		else
			client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message]</span>"
		// Cleanup references for the sake of managing hard-deletes
		context.user = null
		context.held_item = null

/// Indicates that this atom uses contexts, in any form
/atom/proc/register_context()

/// Add context tips
/atom/proc/add_context_self(datum/screentip_context/context, mob/user)
	return

/// Generate context tips for when we are using this item
/obj/item/proc/add_context_interaction(datum/screentip_context/context, mob/user, atom/target)
	return

/// Add context tips for when we are doing something
/mob/proc/add_context_interaction(datum/screentip_context/context, atom/target)
	return
