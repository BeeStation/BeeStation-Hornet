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
	var/client/hoverer = usr.client
	// Change reference
	if (hoverer.hovered_atom)
		hoverer.hovered_atom.hovered_user_count --
	// If someone is connected to us in the queue, then we don't need to requeue
	if (hoverer.hover_queued)
		hoverer.hovered_atom = src
		hovered_user_count ++
		return
	hoverer.hovered_atom = src
	hoverer.hover_queued = TRUE
	hovered_user_count ++
	hoverer.screentip_next = SSscreentips.head
	SSscreentips.head = hoverer

/// Called when a client mouses over this atom
/atom/proc/on_mouse_enter(client/client)
	var/screentip_message = "<span class='big' style='line-height: 0.5'>[MAPTEXT(CENTER(capitalize(format_text(name))))]</span>"
	var/datum/screentip_cache/cache = GLOB.screentips_cache["[type]"]
	var/obj/item/held_item = client.mob.get_active_held_item()
	if (cache)
		var/most_restrictive_type = null
		// Find the most restrictive cache type
		for (var/mob_type in cache.cache_states)
			if (istype(client.mob, mob_type))
				if (!most_restrictive_type)
					most_restrictive_type = mob_type
				else if (ispath(mob_type, most_restrictive_type))
					most_restrictive_type = mob_type
		// If we have a cache type, use that instead
		if (most_restrictive_type)
			cache = cache.cache_states[most_restrictive_type]
		// Make sure that the item we are holding is also cachable
		// The assoc value might be null if we haven't generated the cache for this yet
		if (cache?.generated && (!held_item || GLOB.screentip_contextless_items["[held_item.type]"]))
#ifdef DEBUG
			screentip_message = "<span class='big' style='line-height: 0.5'>[MAPTEXT(CENTER(capitalize(format_text(name)) + " (Using Cache)"))]</span>"
#endif
			if (ishuman(client.mob) && client.mob.get_active_held_item() == null)
				client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message][cache.attack_hand][cache.message]</span>"
			else
				client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message][cache.message]</span>"
			return
	var/datum/screentip_context/context = client.screentip_context
	context.relevant = FALSE
	context.user = client.mob
	context.held_item = held_item
	context.access_context = ""
	context.left_mouse_context = ""
	context.tool_icon_context = ""
	context.shift_left_mouse_context = ""
	context.ctrl_left_mouse_context = ""
	context.alt_left_mouse_context = ""
	context.ctrl_shift_left_mouse_context = ""
	context.cache_enabled = FALSE
	SEND_SIGNAL(src, COMSIG_ATOM_ADD_CONTEXT, context, client.mob)
	// Add direct interactions
	add_context_self(context, client.mob)
	// Add held item interactions
	if (held_item)
		held_item.add_context_interaction(context, client.mob, src)
	if (context.relevant)
		client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message][context.access_context][context.left_mouse_context][context.ctrl_left_mouse_context][context.shift_left_mouse_context][context.alt_left_mouse_context][context.ctrl_shift_left_mouse_context][context.tool_icon_context]</span>"
	else
		client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message]</span>"
	// If we asked to be cached, generate the cache
	if (context.cache_enabled)
		// Try to find the parent cache item
		cache = GLOB.screentips_cache["[type]"]
		if (!cache)
			GLOB.screentips_cache["[type]"] = cache = new()
			cache.generated = FALSE
		// Go to the relevant cache item
		if (context.relevant_type)
			var/datum/screentip_cache/new_cache = new()
			cache.cache_states[context.relevant_type] = new_cache
			cache = new_cache
		// Set the cache message
		cache.generated = TRUE
		cache.message = "[context.access_context][context.left_mouse_context][context.ctrl_left_mouse_context][context.shift_left_mouse_context][context.alt_left_mouse_context][context.ctrl_shift_left_mouse_context][context.tool_icon_context]"
		SSscreentips.caches_generated ++
	// Cleanup references for the sake of managing hard-deletes
	context.user = null
	context.held_item = null

/// Refresh the screentips for any clients looking at this atom
/atom/proc/refresh_screentips()
	if (hovered_user_count == 0)
		return
	for (var/client/client in GLOB.clients)
		if (client.hovered_atom != src)
			continue
		on_mouse_enter(client)

/// Refresh the screentips for the mob holding this item
/obj/item/proc/refresh_holder_screentips()
	if (!istype(loc, /mob/living))
		return
	var/mob/living/holder = loc
	if (!holder.client)
		return
	holder.client.hovered_atom?.on_mouse_enter(holder.client)

/// Add context tips
/atom/proc/add_context_self(datum/screentip_context/context, mob/user)
	// Do not call parent if you don't want to have the thing disabled
	context.use_cache()

/// Generate context tips for when we are using this item
/obj/item/proc/add_context_interaction(datum/screentip_context/context, mob/user, atom/target)
	// We have no context interaction, inform the cache
	GLOB.screentip_contextless_items["[type]"] = TRUE
