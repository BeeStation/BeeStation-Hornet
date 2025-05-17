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
	if (!client.show_screentips)
		return
	if (isnewplayer(client.mob))
		return
	// =====================================================
	// Initialise data
	// =====================================================
	var/screentip_message = "<span style='line-height: 0' class='maptext extremelybig'>[CENTER(capitalize(format_text(name)))]</span>"
	var/datum/screentip_cache/cache = GLOB.screentips_cache["[type]"]
	var/obj/item/held_item = client.mob.get_active_held_item()
	// =====================================================
	// Generate from cache
	// =====================================================
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
		// Caching doesn't take place if we are holding an item
		if (cache?.generated && (!held_item || GLOB.screentip_contextless_items["[held_item.type]"]))
			if (held_item?.tool_behaviour || client.show_extended_screentips)
				if (ishuman(client.mob) && !held_item)
					client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message][MAPTEXT("<span style='color:[SCREEN_TIP_NORMAL]'>[CENTER("[cache.attack_hand][cache.message][cache.tool_message]")]</span>")]</span>"
				else
					client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message][MAPTEXT("<span style='color:[SCREEN_TIP_NORMAL]'>[CENTER("[cache.message][cache.tool_message]")]</span>")]</span>"
			else
				if (ishuman(client.mob) && !held_item)
					client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message][MAPTEXT("<span style='color:[SCREEN_TIP_NORMAL]'>[CENTER("[cache.attack_hand][cache.message]")]</span>")]</span>"
				else
					client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message][MAPTEXT("<span style='color:[SCREEN_TIP_NORMAL]'>[CENTER("[cache.message]")]</span>")]</span>"
			// Temp: 516 bug
			if (client.byond_version == 516)
				client.mob.hud_used.screentip.maptext = replacetext(client.mob.hud_used.screentip.maptext, GLOB.lmb_icon, GLOB.lmb_icon_516)
				client.mob.hud_used.screentip.maptext = replacetext(client.mob.hud_used.screentip.maptext, GLOB.rmb_icon, GLOB.rmb_icon_516)
				client.mob.hud_used.screentip.maptext = replacetext(client.mob.hud_used.screentip.maptext, "<span valign='top'>", "<span valign='top' style='line-height: 0.8'>")
			// End Temp
			return
	// =====================================================
	// Build the context
	// =====================================================
	// Making a new context is faster than re-using it
	var/datum/screentip_context/context = new()
	context.user = client.mob
	context.held_item = held_item
	SEND_SIGNAL(src, COMSIG_ATOM_ADD_CONTEXT, context, client.mob)
	// Add direct interactions
	add_context_self(context, client.mob)
	// Add held item interactions
	if (held_item)
		held_item.add_context_interaction(context, client.mob, src)
	// =====================================================
	// Compile the screentip string
	// =====================================================
	var/screen_tip_message = "[context.access_context][context.generic_context]"
	// Should we display everything inline or with left and right side by side
	// Standard Click
	if (context.left_mouse_context && context.right_mouse_context)
		screen_tip_message += "<br>[context.left_mouse_context] | [context.right_mouse_context]"
	else if (context.left_mouse_context || context.right_mouse_context)
		screen_tip_message += "<br>[context.left_mouse_context][context.right_mouse_context]"
	// Control Click
	if (context.ctrl_left_mouse_context && context.ctrl_right_mouse_context)
		screen_tip_message += "<br>[context.ctrl_left_mouse_context] | [context.ctrl_right_mouse_context]"
	else if (context.ctrl_left_mouse_context || context.ctrl_right_mouse_context)
		screen_tip_message += "<br>[context.ctrl_left_mouse_context][context.ctrl_right_mouse_context]"
	// Shift Click
	if (context.shift_left_mouse_context && context.shift_right_mouse_context)
		screen_tip_message += "<br>[context.shift_left_mouse_context] | [context.shift_right_mouse_context]"
	else if (context.shift_left_mouse_context || context.shift_right_mouse_context)
		screen_tip_message += "<br>[context.shift_left_mouse_context][context.shift_right_mouse_context]"
	// Alt Click
	if (context.alt_left_mouse_context && context.alt_right_mouse_context)
		screen_tip_message += "<br>[context.alt_left_mouse_context] | [context.alt_right_mouse_context]"
	else if (context.alt_left_mouse_context || context.alt_right_mouse_context)
		screen_tip_message += "<br>[context.alt_left_mouse_context][context.alt_right_mouse_context]"
	// Ctrl-shift Click
	if (context.ctrl_shift_left_mouse_context && context.ctrl_shift_right_mouse_context)
		screen_tip_message += "<br>[context.ctrl_shift_left_mouse_context] | [context.ctrl_shift_right_mouse_context]"
	else if (context.ctrl_shift_left_mouse_context || context.ctrl_shift_right_mouse_context)
		screen_tip_message += "<br>[context.ctrl_shift_left_mouse_context][context.ctrl_shift_right_mouse_context]"
	var/tool_message = ""
	if (context.wirecutter)
		tool_message += "<br>[HINT_WIRECUTTERS] [context.wirecutter]"
	if (context.screwdriver)
		tool_message += "<br>[HINT_SCREWDRIVER] [context.screwdriver]"
	if (context.wrench)
		tool_message += "<br>[HINT_WRENCH] [context.wrench]"
	if (context.welder)
		tool_message += "<br>[HINT_WELDER] [context.welder]"
	if (context.crowbar)
		tool_message += "<br>[HINT_CROWBAR] [context.crowbar]"
	if (context.multitool)
		tool_message += "<br>[HINT_MULTITOOL] [context.multitool]"
	if (context.knife)
		tool_message += "<br>[HINT_KNIFE] [context.knife]"
	if (context.rolling_pin)
		tool_message += "<br>[HINT_ROLLING_PIN] [context.rolling_pin]"
	// Temp: 516 bug
	if (tool_message)
		context.cache_force_disabled = TRUE
	// End Temp

	// =====================================================
	// Set the screentip UI
	// =====================================================
	// Screentips only show if you are a silicon, carbon, or you explicitly request the mob type to show
	if (issilicon(client.mob) || iscarbon(client.mob) || context.relevant_type)
		if (held_item?.tool_behaviour || client.show_extended_screentips)
			client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message][MAPTEXT("<span style='color:[SCREEN_TIP_NORMAL]'>[CENTER("[screen_tip_message][tool_message]")]</span>")]</span>"
		else
			client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message][MAPTEXT("<span style='color:[SCREEN_TIP_NORMAL]'>[CENTER(screen_tip_message)]</span>")]</span>"
	else
		client.mob.hud_used.screentip.maptext = "<span valign='top'>[screentip_message]</span>"
	// Temp: 516 bug
	if (client.byond_version == 516)
		client.mob.hud_used.screentip.maptext = replacetext(client.mob.hud_used.screentip.maptext, GLOB.lmb_icon, GLOB.lmb_icon_516)
		client.mob.hud_used.screentip.maptext = replacetext(client.mob.hud_used.screentip.maptext, GLOB.rmb_icon, GLOB.rmb_icon_516)
		client.mob.hud_used.screentip.maptext = replacetext(client.mob.hud_used.screentip.maptext, "<span valign='top'>", "<span valign='top' style='line-height: 0.8'>")
	// End Temp
	// =====================================================
	// Populate the screentip cache to prevent unnecessary re-generation
	// =====================================================
	// If we asked to be cached, generate the cache
	if (context.cache_enabled && !context.cache_force_disabled && (!context.held_item || GLOB.screentip_contextless_items["[held_item.type]"]))
		// Try to find the parent cache item
		cache = GLOB.screentips_cache["[type]"]
		if (!cache)
			GLOB.screentips_cache["[type]"] = cache = new()
			cache.generated = FALSE
		// Go to the relevant cache item
		if (context.relevant_type)
			var/datum/screentip_cache/new_cache = new()
			if (!cache.cache_states)
				cache.cache_states = list()
			cache.cache_states[context.relevant_type] = new_cache
			cache = new_cache
		// Set the cache message
		cache.generated = TRUE
		cache.message = screen_tip_message
		cache.tool_message = tool_message
		SSscreentips.caches_generated ++
	// =====================================================
	// Cleanup references for the sake of managing hard-deletes
	// =====================================================
	context.user = null
	context.held_item = null

/// Refresh the screentips for any clients looking at this atom
/atom/proc/refresh_screentips()
	if (hovered_user_count == 0)
		return
	for (var/client/client in GLOB.clients)
		if (client.hovered_atom != src)
			continue
		if (client.hover_queued)
			return
		client.hover_queued = TRUE
		client.screentip_next = SSscreentips.head
		SSscreentips.head = client

/// Refresh the screentips for the mob holding this item
/obj/item/proc/refresh_holder_screentips()
	if (!istype(loc, /mob/living))
		return
	var/mob/living/holder = loc
	if (!holder.client)
		return
	var/client/screentip_client = holder.client
	if (!screentip_client)
		return
	if (!screentip_client.hovered_atom)
		return
	// If someone is connected to us in the queue, then we don't need to requeue
	if (screentip_client.hover_queued)
		return
	screentip_client.hover_queued = TRUE
	screentip_client.screentip_next = SSscreentips.head
	SSscreentips.head = screentip_client

/mob/proc/refresh_self_screentips()
	if (!client)
		return
	if (!client.hovered_atom)
		return
	// If someone is connected to us in the queue, then we don't need to requeue
	if (client.hover_queued)
		return
	client.hover_queued = TRUE
	client.screentip_next = SSscreentips.head
	SSscreentips.head = client

/// Add context tips
/atom/proc/add_context_self(datum/screentip_context/context, mob/user)
	// Do not call parent if you don't want to have the thing disabled
	context.use_cache()

/// Generate context tips for when we are using this item
/obj/item/proc/add_context_interaction(datum/screentip_context/context, mob/user, atom/target)
	// We have no context interaction, inform the cache
	GLOB.screentip_contextless_items["[type]"] = TRUE
