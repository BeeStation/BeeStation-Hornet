SUBSYSTEM_DEF(vis_overlays)
	name = "Vis contents overlays"
	wait = 1 MINUTES
	priority = FIRE_PRIORITY_VIS

	var/list/vis_overlay_cache
	var/list/unique_vis_overlays
	/// vis overlays that is used to project half-transparent mob appearance
	var/list/mob_alpha_vis_overlays
	var/list/currentrun

/datum/controller/subsystem/vis_overlays/Initialize()
	vis_overlay_cache = list()
	unique_vis_overlays = list()
	mob_alpha_vis_overlays = list()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/vis_overlays/fire(resumed = FALSE)
	if(!resumed)
		currentrun = vis_overlay_cache.Copy()
	var/list/current_run = currentrun

	while(current_run.len)
		var/key = current_run[current_run.len]
		var/obj/effect/overlay/vis/overlay = current_run[key]
		current_run.len--
		if(!overlay.unused && !length(overlay.vis_locs))
			overlay.unused = world.time
		else if(overlay.unused && overlay.unused + overlay.cache_expiration < world.time)
			vis_overlay_cache -= key
			unique_vis_overlays -= overlay
			qdel(overlay)
		if(MC_TICK_CHECK)
			return

//the "thing" var can be anything with vis_contents which includes images
/datum/controller/subsystem/vis_overlays/proc/add_vis_overlay(atom/movable/thing, icon, iconstate, layer, plane, dir, alpha = 255, add_appearance_flags = NONE, unique = FALSE, invisibility = -1)
	var/obj/effect/overlay/vis/overlay
	if(!unique)
		. = "[icon]|[iconstate]|[layer]|[plane]|[dir]|[alpha]|[add_appearance_flags]|[invisibility]"
		overlay = vis_overlay_cache[.]
		if(!overlay)
			overlay = _create_new_vis_overlay(icon, iconstate, layer, plane, dir, alpha, add_appearance_flags, invisibility)
			vis_overlay_cache[.] = overlay
		else
			overlay.unused = 0
	else
		overlay = _create_new_vis_overlay(icon, iconstate, layer, plane, dir, alpha, add_appearance_flags, invisibility)
		overlay.cache_expiration = -1
		var/cache_id = "[FAST_REF(overlay)]@{[world.time]}"
		unique_vis_overlays += overlay
		vis_overlay_cache[cache_id] = overlay
		. = overlay
	thing.vis_contents += overlay

	if(!isatom(thing)) // Automatic rotation is not supported on non atoms
		return

	if(!thing.managed_vis_overlays)
		thing.managed_vis_overlays = list(overlay)
		RegisterSignal(thing, COMSIG_ATOM_DIR_CHANGE, PROC_REF(rotate_vis_overlay))
	else
		thing.managed_vis_overlays += overlay

/datum/controller/subsystem/vis_overlays/proc/_create_new_vis_overlay(icon, iconstate, layer, plane, dir, alpha, add_appearance_flags, invisibility = -1)
	var/obj/effect/overlay/vis/overlay = new
	overlay.icon = icon
	overlay.icon_state = iconstate
	overlay.layer = layer
	overlay.plane = plane
	overlay.dir = dir
	overlay.alpha = alpha
	overlay.appearance_flags |= add_appearance_flags
	if(invisibility > -1)
		overlay.invisibility = invisibility
	return overlay

/datum/controller/subsystem/vis_overlays/proc/remove_vis_overlay(atom/movable/thing, list/overlays)
	thing.vis_contents -= overlays
	if(!isatom(thing))
		return
	thing.managed_vis_overlays -= overlays
	if(!length(thing.managed_vis_overlays))
		thing.managed_vis_overlays = null
		UnregisterSignal(thing, COMSIG_ATOM_DIR_CHANGE)

/datum/controller/subsystem/vis_overlays/proc/rotate_vis_overlay(atom/thing, old_dir, new_dir)
	SIGNAL_HANDLER

	if(old_dir == new_dir)
		return
	var/rotation = dir2angle(old_dir) - dir2angle(new_dir)
	var/list/overlays_to_remove = list()
	for(var/i in thing.managed_vis_overlays - unique_vis_overlays)
		if(istype(i, /obj/effect/overlay/vis/mob_alpha))
			continue
		var/obj/effect/overlay/vis/overlay = i
		add_vis_overlay(thing, overlay.icon, overlay.icon_state, overlay.layer, overlay.plane, turn(overlay.dir, rotation), overlay.alpha, overlay.appearance_flags, invisibility=overlay.invisibility)
		overlays_to_remove += overlay
	for(var/i in thing.managed_vis_overlays & unique_vis_overlays)
		if(istype(i, /obj/effect/overlay/vis/mob_alpha))
			continue
		var/obj/effect/overlay/vis/overlay = i
		overlay.dir = turn(overlay.dir, rotation)
	remove_vis_overlay(thing, overlays_to_remove)


/// just add_vis_overlay() but only visible to observers
/datum/controller/subsystem/vis_overlays/proc/add_obj_alpha(atom/movable/thing, icon=null, iconstate=null, alpha=150)
	add_vis_overlay(thing, icon || thing.icon, iconstate || thing.icon_state, thing.layer+0.1, thing.plane, thing.dir, alpha=alpha, add_appearance_flags=RESET_ALPHA, invisibility=INVISIBILITY_OBSERVER)

/// identical to procs above, but mob alpha version
/datum/controller/subsystem/vis_overlays/proc/add_mob_alpha(atom/movable/thing, mob/target_mob, alpha=150, invisibility=INVISIBILITY_OBSERVER)
	var/obj/effect/overlay/vis/mob_alpha/overlay
	var/mob_alpha_id = "[REF(target_mob)]|[alpha]|[invisibility]"
	overlay = mob_alpha_vis_overlays[mob_alpha_id]
	if(!overlay)
		overlay = _create_mob_alpha(FLY_LAYER, target_mob.plane, target_mob.dir, alpha, add_appearance_flags=RESET_ALPHA, invisibility=invisibility)
		mob_alpha_vis_overlays[mob_alpha_id] = overlay
		overlay.mob_alpha_id = mob_alpha_id
		overlay.mob_owner_ref = "[REF(target_mob)]"
	overlay.cut_overlays()
	overlay.add_overlay(target_mob)

	if(overlay in thing.vis_contents) // don't do this again
		return overlay.mob_owner_ref

	overlay.use_count++
	thing.vis_contents += overlay

	// copy-pasta from the above
	if(!isatom(thing))
		return overlay.mob_owner_ref

	if(!thing.managed_vis_overlays)
		thing.managed_vis_overlays = list(overlay)
		// RegisterSignal(thing, COMSIG_ATOM_DIR_CHANGE, PROC_REF(rotate_vis_overlay))
		// mob alpha overlay doesn't support dir rotation
	else
		thing.managed_vis_overlays += overlay

	return overlay.mob_owner_ref

/datum/controller/subsystem/vis_overlays/proc/remove_mob_alpha(atom/movable/thing, list/exception_mobs=list())
	for(var/obj/effect/overlay/vis/mob_alpha/overlay in thing.managed_vis_overlays)
		if(overlay.mob_owner_ref in exception_mobs)
			continue
		thing.vis_contents -= overlay
		overlay.use_count--
		if(overlay.use_count) // only remove it when it's used in nowhere
			continue
		mob_alpha_vis_overlays -= overlay.mob_alpha_id
		if(isatom(thing))
			thing.managed_vis_overlays -= overlay
		qdel(overlay)

	if(isatom(thing) && !length(thing.managed_vis_overlays))
		thing.managed_vis_overlays = null
		// UnregisterSignal(thing, COMSIG_ATOM_DIR_CHANGE)

/datum/controller/subsystem/vis_overlays/proc/_create_mob_alpha(layer, plane, dir, alpha, add_appearance_flags, invisibility = -1)
	var/obj/effect/overlay/vis/mob_alpha/overlay = new
	overlay.icon = null
	overlay.icon_state = null
	overlay.layer = layer
	overlay.plane = plane
	overlay.dir = dir
	overlay.alpha = alpha
	overlay.appearance_flags |= add_appearance_flags
	if(invisibility > -1)
		overlay.invisibility = invisibility
	return overlay
