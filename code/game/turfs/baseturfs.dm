/// Take off the top layer turf and replace it with the next baseturf down
/turf/proc/ScrapeAway(amount=1, flags)
	if(!amount)
		return
	if(length(baseturfs))
		var/list/new_baseturfs = baseturfs.Copy()
		var/turf_type = new_baseturfs[max(1, new_baseturfs.len - amount + 1)]
		while(ispath(turf_type, /turf/baseturf_skipover))
			amount++
			if(amount > new_baseturfs.len)
				CRASH("The bottommost baseturf of a turf is a skipover [src]([type])")
			turf_type = new_baseturfs[max(1, new_baseturfs.len - amount + 1)]
		new_baseturfs.len -= min(amount, new_baseturfs.len - 1) // No removing the very bottom
		if(new_baseturfs.len == 1)
			new_baseturfs = new_baseturfs[1]
		return ChangeTurf(turf_type, new_baseturfs, flags)

	if(baseturfs == type)
		return src

	return ChangeTurf(baseturfs, baseturfs, flags) // The bottom baseturf will never go away

/// Places the given turf on the bottom of the turf stack.
/turf/proc/place_on_bottom(turf/bottom_turf)
	baseturfs = baseturfs_string_list(
		list(initial(bottom_turf.baseturfs), bottom_turf) + baseturfs,
		src,
	)

/// Places a turf at the top of the stack
/turf/proc/place_on_top(turf/added_layer, flags)
	var/list/turf/new_baseturfs = list()

	new_baseturfs.Add(baseturfs)
	if(isopenturf(src))
		new_baseturfs.Add(type)
	var/area/our_area = get_area(src)
	flags = our_area.place_on_top_react(new_baseturfs, added_layer, flags)

	return ChangeTurf(added_layer, new_baseturfs, flags)

/// Places a turf on top - for map loading
/turf/proc/load_on_top(turf/added_layer, flags)
	var/area/our_area = get_area(src)
	flags = our_area.place_on_top_react(list(baseturfs), added_layer, flags)

	if(flags & CHANGETURF_SKIP) // We haven't been initialized
		if(flags_1 & INITIALIZED_1)
			stack_trace("CHANGETURF_SKIP was used in a PlaceOnTop call for a turf that's initialized. This is a mistake. [src]([type])")
		assemble_baseturfs()

	var/turf/new_turf
	if(!length(baseturfs))
		baseturfs = list(baseturfs)

	var/list/old_baseturfs = baseturfs.Copy()
	if(!isclosedturf(src))
		old_baseturfs += type

	new_turf = ChangeTurf(added_layer, null, flags)
	new_turf.assemble_baseturfs(initial(added_layer.baseturfs)) // The baseturfs list is created like roundstart
	if(!length(new_turf.baseturfs))
		new_turf.baseturfs = list(baseturfs)

	// The old baseturfs are put underneath, and we sort out the unwanted ones
	new_turf.baseturfs = baseturfs_string_list(old_baseturfs + (new_turf.baseturfs - GLOB.blacklisted_automated_baseturfs), new_turf)
	return new_turf

// Copy an existing turf and put it on top
// Returns the new turf
/turf/proc/CopyOnTop(turf/copytarget, ignore_bottom = 1, depth = INFINITY, copy_air = FALSE, flags = null)
	var/list/new_baseturfs = list()
	new_baseturfs += baseturfs
	new_baseturfs += type

	if(depth)
		var/list/target_baseturfs
		if(length(copytarget.baseturfs))
			// with default inputs this would be Copy(clamp(2, -INFINITY, baseturfs.len))
			// Don't forget a lower index is lower in the baseturfs stack, the bottom is baseturfs[1]
			target_baseturfs = copytarget.baseturfs.Copy(clamp(1 + ignore_bottom, 1 + copytarget.baseturfs.len - depth, copytarget.baseturfs.len))
		else if(!ignore_bottom)
			target_baseturfs = list(copytarget.baseturfs)
		if(target_baseturfs)
			target_baseturfs -= new_baseturfs & GLOB.blacklisted_automated_baseturfs
			new_baseturfs += target_baseturfs

	var/turf/new_turf = copytarget.copyTurf(src, copy_air, flags)
	new_turf.baseturfs = baseturfs_string_list(new_baseturfs, new_turf)
	return new_turf

/// Replaces all instances of needle_type in baseturfs with replacement_type
/turf/proc/replace_baseturf(needle_type, replacement_type)
	if (islist(baseturfs))
		var/list/new_baseturfs = baseturfs.Copy()

		for(var/base_i in 1 to length(new_baseturfs))
			var/found_index = new_baseturfs.Find(needle_type)
			if (found_index == 0)
				break

			new_baseturfs[found_index] = replacement_type

		if (length(new_baseturfs))
			baseturfs = baseturfs_string_list(new_baseturfs, src)
	else if (baseturfs == needle_type)
		baseturfs = replacement_type

/// Removes all baseturfs that are found in the given typecache.
/turf/proc/remove_baseturfs_from_typecache(list/typecache)
	if (islist(baseturfs))
		var/list/new_baseturfs

		for (var/baseturf in baseturfs)
			if (!typecache[baseturf])
				continue

			new_baseturfs ||= baseturfs.Copy()
			new_baseturfs -= baseturf

		if (!isnull(new_baseturfs))
			baseturfs = baseturfs_string_list(new_baseturfs, src)
	else if (typecache[baseturfs])
		baseturfs = /turf/baseturf_bottom
