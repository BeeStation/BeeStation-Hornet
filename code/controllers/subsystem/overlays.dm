SUBSYSTEM_DEF(overlays)
	name = "Overlay"
	flags = SS_TICKER
	wait = 1
	priority = FIRE_PRIORITY_OVERLAYS

	var/list/queue
	var/list/stats

	// If the overlay set currently being considered contains a manglable overlay.
	// This is only safe because SSoverlays can only ever consider one overlay list at a time with no interior sleeps. Professional on closed course, do not attempt.
	var/context_needs_automangle

/datum/controller/subsystem/overlays/PreInit()
	queue = list()
	stats = list()

/datum/controller/subsystem/overlays/Initialize()
	initialized = TRUE
	fire(mc_check = FALSE)
	return SS_INIT_SUCCESS


/datum/controller/subsystem/overlays/stat_entry()
	. = ..("Ov:[length(queue)]")


/datum/controller/subsystem/overlays/Shutdown()
	rustg_file_append(render_stats(stats), "[GLOB.log_directory]/overlay.log")


/datum/controller/subsystem/overlays/Recover()
	queue = SSoverlays.queue


/datum/controller/subsystem/overlays/fire(resumed = FALSE, mc_check = TRUE)
	var/list/queue = src.queue
	var/static/count = 0
	if (count)
		var/c = count
		count = 0 //so if we runtime on the Cut, we don't try again.
		queue.Cut(1,c+1)

	for (var/atom/atom_to_compile as anything in queue)
		count++
		if(!atom_to_compile)
			continue
		if(length(atom_to_compile.overlays) >= MAX_ATOM_OVERLAYS)
			//Break it real GOOD
			stack_trace("Too many overlays on [atom_to_compile.type] - [length(atom_to_compile.overlays)], refusing to update and cutting.")
			atom_to_compile.overlays.Cut()
			continue
		STAT_START_STOPWATCH
		COMPILE_OVERLAYS(atom_to_compile)
		UNSETEMPTY(atom_to_compile.add_overlays)
		UNSETEMPTY(atom_to_compile.remove_overlays)
		STAT_STOP_STOPWATCH
		STAT_LOG_ENTRY(stats, atom_to_compile.type)
		if(mc_check)
			if(MC_TICK_CHECK)
				break
		else
			CHECK_TICK
	if (count)
		queue.Cut(1,count+1)
		count = 0

/// Converts an overlay list into text for debug printing
/// Of note: overlays aren't actually mutable appearances, they're just appearances
/// Don't have access to that type tho, so this is the best you're gonna get
/proc/overlays2text(list/overlays)
	var/list/unique_overlays = list()
	// As anything because we're basically doing type coerrsion, rather then actually filtering for mutable apperances
	for(var/mutable_appearance/overlay as anything in overlays)
		var/key = "[overlay.icon]-[overlay.icon_state]-[overlay.dir]"
		unique_overlays[key] += 1
	var/list/output_text = list()
	for(var/key in unique_overlays)
		output_text += "([key]) = [unique_overlays[key]]"
	return output_text.Join("\n")

/proc/iconstate2appearance(icon, iconstate)
	var/static/image/stringbro = new()
	stringbro.icon = icon
	stringbro.icon_state = iconstate
	return stringbro.appearance

/proc/icon2appearance(icon)
	var/static/image/iconbro = new()
	iconbro.icon = icon
	return iconbro.appearance

// If the overlay has a planeset (e.g., emissive), mark for ZM mangle. This won't catch overlays on overlays, but the flag can just manually be set in that case.
#define ZM_AUTOMANGLE(target) if ((target):plane != FLOAT_PLANE) { SSoverlays.context_needs_automangle = TRUE; }

/atom/proc/build_appearance_list(old_overlays)
	var/static/image/appearance_bro = new()
	var/list/new_overlays = list()

	for (var/overlay in (islist(old_overlays) ? old_overlays : list(old_overlays)))
		if(!overlay)
			continue
		if (istext(overlay))
			new_overlays += iconstate2appearance(icon, overlay)
		else if(isicon(overlay))
			new_overlays += icon2appearance(overlay)
		else
			if(isloc(overlay))
				var/atom/A = overlay
				if (A.flags_1 & OVERLAY_QUEUED_1)
					COMPILE_OVERLAYS(A)
			appearance_bro.appearance = overlay //this works for images and atoms too!
			if(!ispath(overlay))
				var/image/I = overlay
				appearance_bro.dir = I.dir
			new_overlays += appearance_bro.appearance
	return new_overlays

// The same as the above, but with ZM_AUTOMANGLE.
/atom/movable/build_appearance_list(old_overlays)
	var/static/image/appearance_bro = new()
	var/list/new_overlays = list()

	for (var/overlay in (islist(old_overlays) ? old_overlays : list(old_overlays)))
		if(!overlay)
			continue
		var/image/new_overlay
		if (istext(overlay))
			new_overlay = iconstate2appearance(icon, overlay)
		else if(isicon(overlay))
			new_overlay = icon2appearance(overlay)
		else
			if(isloc(overlay))
				var/atom/A = overlay
				if (A.flags_1 & OVERLAY_QUEUED_1)
					COMPILE_OVERLAYS(A)
			appearance_bro.appearance = overlay //this works for images and atoms too!
			if(!ispath(overlay))
				var/image/I = overlay
				appearance_bro.dir = I.dir
			new_overlay = appearance_bro.appearance
		if(new_overlay)
			new_overlays += new_overlay
			ZM_AUTOMANGLE(new_overlay)
	return new_overlays

#define NOT_QUEUED_ALREADY (!(flags_1 & OVERLAY_QUEUED_1))
#define QUEUE_FOR_COMPILE flags_1 |= OVERLAY_QUEUED_1; SSoverlays.queue += src;
/atom/proc/cut_overlays()
	LAZYINITLIST(remove_overlays)
	LAZYINITLIST(add_overlays)
	remove_overlays = overlays.Copy()
	add_overlays.Cut()

	//If not already queued for work and there are overlays to remove
	if(NOT_QUEUED_ALREADY && remove_overlays.len)
		QUEUE_FOR_COMPILE

// This one gets to be done the sane way because it shouldn't be as hot as the others.
/atom/movable/cut_overlays()
	..()
	zmm_flags &= ~ZMM_AUTOMANGLE

/atom/proc/cut_overlay(list/overlays)
	if(!overlays)
		return
	SSoverlays.context_needs_automangle = FALSE
	overlays = build_appearance_list(overlays)
	LAZYINITLIST(add_overlays) //always initialized after this point
	LAZYINITLIST(remove_overlays)
	var/a_len = add_overlays.len
	var/r_len = remove_overlays.len

	remove_overlays += overlays
	add_overlays -= overlays

	var/fa_len = add_overlays.len
	var/fr_len = remove_overlays.len


	//If not already queued and there is work to be done
	if(NOT_QUEUED_ALREADY && (fa_len != a_len || fr_len != r_len))
		QUEUE_FOR_COMPILE

/atom/movable/cut_overlay(list/overlays)
	..()
	// If we removed an automangle-eligible overlay and have automangle enabled, reevaluate automangling.
	if (!SSoverlays.context_needs_automangle || !(zmm_flags & ZMM_AUTOMANGLE))
		return

	var/list/cached_overlays = src.overlays.Copy()

	// If we cut some overlays but some are still left, we need to scan for AUTOMANGLE.
	if (LAZYLEN(cached_overlays))
		// need to scan overlays
		var/found = FALSE
		for (var/i in 1 to length(cached_overlays))
			var/image/I = cached_overlays[i]
			if (I.plane != FLOAT_PLANE)
				found = TRUE
				break
		if (!found)
			zmm_flags &= ~ZMM_AUTOMANGLE
	// None left, just unset the bit.
	else
		zmm_flags &= ~ZMM_AUTOMANGLE

/atom/proc/add_overlay(list/overlays)
	if(!overlays)
		return

	// the things I do for performance
	var/is_movable = istype(src, /atom/movable)

	SSoverlays.context_needs_automangle = FALSE
	overlays = build_appearance_list(overlays)
	if (SSoverlays.context_needs_automangle && is_movable)
		// This is a movable flag.
		src:zmm_flags |= ZMM_AUTOMANGLE

	LAZYINITLIST(add_overlays) //always initialized after this point
	var/a_len = add_overlays.len


	add_overlays += overlays
	var/fa_len = add_overlays.len
	if(NOT_QUEUED_ALREADY && fa_len != a_len)
		QUEUE_FOR_COMPILE

/atom/proc/copy_overlays(atom/other, cut_old)	//copys our_overlays from another atom
	if(!other)
		if(cut_old)
			cut_overlays()
		return

	var/list/cached_other = other.overlays.Copy()
	if(cached_other)
		if (istype(src, /atom/movable))
			for (var/i in 1 to length(cached_other))
				var/image/I = cached_other[i]
				if (I.plane != FLOAT_PLANE)
					src:zmm_flags |= ZMM_AUTOMANGLE
					break
		if(cut_old || !LAZYLEN(overlays))
			remove_overlays = overlays
		add_overlays = cached_other
		if(NOT_QUEUED_ALREADY)
			QUEUE_FOR_COMPILE
	else if(cut_old)
		cut_overlays()

#undef NOT_QUEUED_ALREADY
#undef QUEUE_FOR_COMPILE

//TODO: Better solution for these?
/image/proc/add_overlay(x)
	overlays |= x

/image/proc/cut_overlay(x)
	overlays -= x

/image/proc/cut_overlays(x)
	overlays.Cut()

/image/proc/copy_overlays(atom/other, cut_old)
	if(!other)
		if(cut_old)
			cut_overlays()
		return

	var/list/cached_other = other.overlays.Copy()
	if(cached_other)
		if(cut_old || !overlays.len)
			overlays = cached_other
		else
			overlays |= cached_other
	else if(cut_old)
		cut_overlays()

#undef ZM_AUTOMANGLE
