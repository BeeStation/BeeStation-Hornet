SUBSYSTEM_DEF(vis_overlays)
	name = "Vis contents overlays"
	wait = 1 MINUTES
	priority = FIRE_PRIORITY_VIS
	init_order = INIT_ORDER_VIS

	/// vis overlays that are shared to all stuff - typically airlocks
	var/list/shared_vis_overlays_cache
	/// vis overlays that are unique to specified stuff - avoid using this unless necessary
	var/list/unique_vis_overlays_cache
	/// vis overlays that is used to project half-transparent mob appearance
	var/list/mob_alpha_vis_overlays_cache

/datum/controller/subsystem/vis_overlays/Initialize()
	shared_vis_overlays_cache = list()
	unique_vis_overlays_cache = list()
	mob_alpha_vis_overlays_cache = list()
	return ..()

/datum/controller/subsystem/vis_overlays/fire(resumed = FALSE)
	handle_vis_overlay_cache()
	handle_mob_alpha_cache()

// standard vis_overlay handling part
/datum/controller/subsystem/vis_overlays/proc/handle_vis_overlay_cache()
	var/list/executing_vis_overlays = shared_vis_overlays_cache + unique_vis_overlays_cache // it works like Copy(), so the list object is unique
	while(executing_vis_overlays.len)
		var/cache_id = executing_vis_overlays[executing_vis_overlays.len]
		var/obj/effect/overlay/vis/overlay = executing_vis_overlays[cache_id]
		executing_vis_overlays.len--

		if(overlay.expiration_time < 0) // this is meant to be infinite
			continue

		if(length(overlay.vis_locs)) // current used. update time.
			overlay.last_used_world_time = world.time
			continue

		if(overlay.last_used_world_time < world.time + overlay.expiration_time) // not yet expired
			continue

		// Time expired - Removes these vis overlays from the cache
		if(shared_vis_overlays_cache[cache_id]) // shared
			shared_vis_overlays_cache -= cache_id
		if(unique_vis_overlays_cache[cache_id]) // unique
			unique_vis_overlays_cache -= cache_id
		qdel(overlay)

		if(MC_TICK_CHECK)
			return

// mob alpha handling part
// this exists to handle some cases where a mob doesn't exist in a container
// using a signal might work, but that needs more work
/datum/controller/subsystem/vis_overlays/proc/handle_mob_alpha_cache()
	var/list/executing_mob_alpha_overlays = mob_alpha_vis_overlays_cache.Copy()
	while(executing_mob_alpha_overlays.len)
		var/cache_id = executing_mob_alpha_overlays[executing_mob_alpha_overlays.len]
		var/obj/effect/overlay/vis/mob_alpha/overlay = executing_mob_alpha_overlays[cache_id]
		executing_mob_alpha_overlays.len--

		if(!length(overlay.vis_locs))
			continue

		for(var/obj/each_obj in overlay.vis_locs)
			each_obj.update_mob_alpha()

//the "thing" var can be anything with vis_contents which includes images
/datum/controller/subsystem/vis_overlays/proc/add_vis_overlay(atom/movable/thing, icon, iconstate, layer, plane, dir, alpha = 255, invisibility = -1, add_appearance_flags = NONE, add_vis_flags = NONE, unique = FALSE)
	var/obj/effect/overlay/vis/overlay
	var/cache_id = ""

	// shared vis appearance
	if(!unique)
		cache_id = "[icon]|[iconstate]|[layer]|[plane]|[dir]|[alpha]|[invisibility]|[add_appearance_flags]|[add_vis_flags]"
		overlay = shared_vis_overlays_cache[cache_id]
		if(!overlay)
			overlay = _create_new_vis_overlay(icon, iconstate, layer, plane, dir, alpha, invisibility, add_appearance_flags, add_vis_flags)
			shared_vis_overlays_cache[cache_id] = overlay
			overlay.vis_cache_id = cache_id
		overlay.last_used_world_time = world.time
		overlay.expiration_time = 10 MINUTES // shared ones will be used often

	// unique - avoid using this
	else
		overlay = _create_new_vis_overlay(icon, iconstate, layer, plane, dir, alpha, invisibility, add_appearance_flags, add_vis_flags)
		cache_id = "[FAST_REF(overlay)]@{[world.time]}"
		unique_vis_overlays_cache[cache_id] = overlay
		overlay.vis_cache_id = cache_id
		overlay.last_used_world_time = world.time
		overlay.expiration_time = 0 // This will be removed immediately for every subsystem fire

	if(!overlay)
		CRASH("Failed to create a vis overlay. overlay variable is null.")

	thing.vis_contents += overlay

	// Atoms is valid for automatic rotation
	// Non-atoms (/image) are not valid for automatic rotation
	if(!isatom(thing))
		return overlay

	if(!thing.managed_vis_overlays)
		thing.managed_vis_overlays = list(overlay)
		RegisterSignal(thing, COMSIG_ATOM_DIR_CHANGE, PROC_REF(rotate_vis_overlay))
	else
		thing.managed_vis_overlays += overlay

	return overlay

/datum/controller/subsystem/vis_overlays/proc/_create_new_vis_overlay(icon, iconstate, layer, plane, dir, alpha, invisibility = -1, add_appearance_flags, add_vis_flags)
	var/obj/effect/overlay/vis/overlay = new
	overlay.icon = icon
	overlay.icon_state = iconstate
	overlay.layer = layer
	overlay.plane = plane
	overlay.dir = dir
	overlay.alpha = alpha
	if(invisibility > -1) // -1 means "do not chnage"
		overlay.invisibility = invisibility
	overlay.appearance_flags |= add_appearance_flags
	overlay.vis_flags |= add_vis_flags
	return overlay

/datum/controller/subsystem/vis_overlays/proc/remove_vis_overlay(atom/movable/thing, list/overlays_to_remove)
	for(var/obj/effect/overlay/vis/overlay in overlays_to_remove)
		thing.vis_contents -= overlay

		if(!isatom(thing))
			continue
		thing.managed_vis_overlays -= overlay

	if(!isatom(thing) || length(thing.managed_vis_overlays))
		return

	thing.managed_vis_overlays = null
	UnregisterSignal(thing, COMSIG_ATOM_DIR_CHANGE)

/datum/controller/subsystem/vis_overlays/proc/rotate_vis_overlay(atom/thing, old_dir, new_dir)
	SIGNAL_HANDLER

	if(old_dir == new_dir)
		return
	var/rotation = dir2angle(old_dir) - dir2angle(new_dir)
	var/list/overlays_to_remove = list()
	for(var/obj/effect/overlay/vis/overlay in thing.managed_vis_overlays)
		if(istype(overlay, /obj/effect/overlay/vis/mob_alpha)) // mob alpha should be handled differently. We don't remove this.
			continue
		if(isatom(thing) && overlay.vis_flags & VIS_INHERIT_DIR) // we don't need to turn it because it's already rotated by the vis flag.
			continue

		if(shared_vis_overlays_cache[overlay.vis_cache_id])
			add_vis_overlay(thing, overlay.icon, overlay.icon_state, overlay.layer, overlay.plane, turn(overlay.dir, rotation), overlay.alpha, overlay.invisibility, overlay.appearance_flags, overlay.vis_flags)
			overlays_to_remove += overlay
		if(unique_vis_overlays_cache[overlay.vis_cache_id])
			overlay.dir = turn(overlay.dir, rotation)

	remove_vis_overlay(thing, overlays_to_remove)


/// just add_vis_overlay() but only visible to observers
/// This is automatically removed by Destroy()
/datum/controller/subsystem/vis_overlays/proc/add_obj_alpha(atom/movable/thing, icon=null, iconstate=null, alpha=150)
	add_vis_overlay(thing, icon || thing.icon, iconstate || thing.icon_state, thing.layer+0.1, thing.plane, 0, alpha=alpha, invisibility=INVISIBILITY_OBSERVER, add_appearance_flags=RESET_ALPHA, add_vis_flags=VIS_INHERIT_DIR)

/// identical to procs above, but mob alpha version
/// This is also used to update appearance because it called cut_overlays() and add_oversay()
/// Returning value is mob_owner_ref instead of overlay type, and it's used not to strip vis_overlay to remove_mob_alpha()
/datum/controller/subsystem/vis_overlays/proc/add_mob_alpha(atom/movable/thing, mob/target_mob, alpha=150, invisibility=INVISIBILITY_OBSERVER)
	var/obj/effect/overlay/vis/mob_alpha/overlay
	var/cache_id = "[REF(target_mob)]|[alpha]|[invisibility]"

	// similar to add_vis_overlay(), but should work different
	overlay = mob_alpha_vis_overlays_cache[cache_id]
	if(!overlay)
		overlay = _create_mob_alpha(FLY_LAYER, target_mob.plane, target_mob.dir, alpha, invisibility=invisibility, add_appearance_flags=RESET_ALPHA, add_vis_flags=NONE)
		mob_alpha_vis_overlays_cache[cache_id] = overlay
		overlay.vis_cache_id = cache_id
		overlay.mob_owner_ref = "[REF(target_mob)]"

	if(!overlay)
		CRASH("Failed to create a mob alpha vis overlay. overlay variable is null.")

	// this is the point of mob alpha vis overlay
	// 1. copy the appearance of "target mob", add_overlay() to vis_overlay
	// 2. vis_overlay is added to "thing"
	// 3. vis_overlay invisibility level is 95
	// so, the mob's appearance on a closet is only visible to observers
	overlay.cut_overlays()
	overlay.add_overlay(target_mob)

	thing.vis_contents += overlay

	// Atoms is valid for automatic rotation
	// Non-atoms (/image) are not valid for automatic rotation
	if(!isatom(thing))
		return overlay.mob_owner_ref

	if(!thing.managed_vis_overlays)
		thing.managed_vis_overlays = list(overlay)
		RegisterSignal(thing, COMSIG_ATOM_DIR_CHANGE, PROC_REF(rotate_vis_overlay))
		// mob alpha overlay doesn't support dir rotation, but it should register signal because add_vis_overlay() needs this
	else
		thing.managed_vis_overlays += overlay

	return overlay.mob_owner_ref

/// Basically purges everything in a thing, but skip it when target overlay is in exception_mobs
/datum/controller/subsystem/vis_overlays/proc/remove_mob_alpha(atom/movable/thing, list/exception_mobs=list())
	for(var/obj/effect/overlay/vis/mob_alpha/overlay in thing.managed_vis_overlays)
		if(overlay.mob_owner_ref in exception_mobs)
			continue
		thing.vis_contents -= overlay
		if(isatom(thing))
			thing.managed_vis_overlays -= overlay

		if(length(overlay.vis_locs)) // it's still used by somwhere
			continue

		mob_alpha_vis_overlays_cache -= overlay.vis_cache_id
		qdel(overlay)

	if(!isatom(thing) || length(thing.managed_vis_overlays))
		return

	thing.managed_vis_overlays = null
	UnregisterSignal(thing, COMSIG_ATOM_DIR_CHANGE)

/datum/controller/subsystem/vis_overlays/proc/_create_mob_alpha(layer, plane, dir, alpha, invisibility, add_appearance_flags, add_vis_flags)
	var/obj/effect/overlay/vis/mob_alpha/overlay = new
	overlay.icon = null
	overlay.icon_state = null
	overlay.layer = layer
	overlay.plane = plane
	overlay.dir = dir
	overlay.alpha = alpha
	if(invisibility > -1)
		overlay.invisibility = invisibility
	overlay.appearance_flags |= add_appearance_flags
	overlay.vis_flags |= add_vis_flags
	return overlay
