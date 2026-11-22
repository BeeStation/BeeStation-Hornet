/mob/living/simple_animal/borer/proc/update_cortical_link()
	var/mob/living/target
	if(!QDELING(src) && stat != DEAD)
		if(host)
			if(host.stat != DEAD && !QDELING(host))
				target = host
		else
			target = src
	if(link_outline && (QDELETED(link_outline) || link_outline.target != target))
		var/datum/atom_hud/alternate_appearance/basic/cortical_link/old_outline = link_outline
		link_outline = null
		if(!QDELETED(old_outline))
			old_outline.borers -= src
			if(!length(old_outline.borers))
				qdel(old_outline)
	if(target)
		if(!link_outline)
			link_outline = target.alternate_appearances?["cortical_link"]
			if(!link_outline)
				link_outline = target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/cortical_link, "cortical_link", image(loc = target), NONE)
			link_outline.borers |= src
		link_outline.refresh_appearance()
	update_cortical_link_sight()

/// Membership follows the borer's mind, never the human displaced into the backseat.
/mob/proc/update_cortical_link_sight()
	for(var/datum/atom_hud/alternate_appearance/basic/cortical_link/outline as anything in GLOB.active_alternate_appearances)
		if(istype(outline))
			outline.check_hud(src)

/datum/antagonist/borer/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	old_body?.update_cortical_link_sight()
	new_body?.update_cortical_link_sight()

/datum/antagonist/borer/on_removal()
	. = ..()
	owner.current?.update_cortical_link_sight()

/// A private hollow outline rendered from the mob's full appearance.
/datum/atom_hud/alternate_appearance/basic/cortical_link
	var/list/mob/living/simple_animal/borer/borers = list()
	var/last_appearance

/datum/atom_hud/alternate_appearance/basic/cortical_link/New(key, image/new_image, options)
	target = new_image.loc
	. = ..(key, new_image, NONE)
	transfer_overlays = TRUE
	RegisterSignals(target, list(COMSIG_ATOM_UPDATED_ICON, COMSIG_CARBON_APPLY_OVERLAY, COMSIG_CARBON_REMOVE_OVERLAY, COMSIG_ATOM_DIR_CHANGE, COMSIG_LIVING_POST_UPDATE_TRANSFORM), PROC_REF(queue_refresh))
	RegisterSignal(target, COMSIG_MOB_STATCHANGE, PROC_REF(on_target_stat_change))
	refresh_appearance()

/datum/atom_hud/alternate_appearance/basic/cortical_link/Destroy()
	for(var/mob/living/simple_animal/borer/borer as anything in borers)
		if(borer.link_outline == src)
			borer.link_outline = null
	borers.Cut()
	. = ..()
	last_appearance = null

/datum/atom_hud/alternate_appearance/basic/cortical_link/add_atom_to_hud(atom/new_target)
	. = ..()
	// A list keeps update_transform from repositioning this like an overhead status icon.
	new_target.hud_list[appearance_key] = list(image)

/datum/atom_hud/alternate_appearance/basic/cortical_link/mobShouldSee(mob/viewer)
	if(!isliving(viewer) || viewer.stat == DEAD || viewer == target)
		return FALSE
	var/datum/antagonist/borer/antag = viewer.mind?.has_antag_datum(/datum/antagonist/borer)
	if(!antag)
		return FALSE
	var/mob/living/simple_animal/borer/self_borer = antag.borer_ref?.resolve()
	return target != self_borer && target != self_borer?.host

// Avoid accumulating HUD sources when appearance or mind updates recheck the same viewer.
/datum/atom_hud/alternate_appearance/basic/cortical_link/show_to(mob/new_viewer)
	if(!hud_users_all_z_levels[new_viewer])
		return ..()

/datum/atom_hud/alternate_appearance/basic/cortical_link/track_mob(mob/new_viewer)
	if(new_viewer != target)
		RegisterSignal(new_viewer, COMSIG_MOB_STATCHANGE, PROC_REF(check_hud))

/datum/atom_hud/alternate_appearance/basic/cortical_link/untrack_mob(mob/former_viewer)
	if(former_viewer != target)
		UnregisterSignal(former_viewer, COMSIG_MOB_STATCHANGE)

/// POST_OVERLAY_CHANGE calls this after additions/removals, including clothing and held items.
/datum/atom_hud/alternate_appearance/basic/cortical_link/copy_overlays(atom/other, cut_old)
	refresh_appearance()

/// Direction signals precede the assignment; coalesce updates until the appearance is complete.
/datum/atom_hud/alternate_appearance/basic/cortical_link/proc/queue_refresh()
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(refresh_appearance)), 0, TIMER_UNIQUE)

/datum/atom_hud/alternate_appearance/basic/cortical_link/proc/refresh_appearance()
	if(!target || !image)
		return
	if(last_appearance == target.appearance)
		return
	last_appearance = target.appearance
	image.appearance = copy_appearance_filter_overlays(target.appearance)
	// Anchoring to the mob keeps BYOND's glide interpolation, rather than jumping between turfs.
	image.loc = target
	// Images inherit their loc's pixel offsets, including the animated grab/drag displacement.
	image.pixel_x = 0
	image.pixel_y = 0
	image.pixel_w = 0
	image.pixel_z = 0
	image.plane = PIPECRAWL_IMAGES_PLANE
	image.layer = ABOVE_MOB_LAYER
	image.appearance_flags = KEEP_TOGETHER | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	image.invisibility = 0
	image.alpha = 160
	image.color = null
	image.blend_mode = BLEND_OVERLAY
	image.render_source = null
	image.render_target = null
	image.maptext = null
	// Blacken the body, outline it, then use the edge's blue channel as alpha to erase the interior.
	var/static/list/edge_alpha = list(
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 1,
		0, 0, 0, 0,
		0, 0, 0, 0,
	)
	image.filters = list(color_matrix_filter(COLOR_BLACK), outline_filter(size = 1, color = "#c792ea"), color_matrix_filter(edge_alpha))

/datum/atom_hud/alternate_appearance/basic/cortical_link/proc/on_target_stat_change()
	SIGNAL_HANDLER
	check_hud(target)
	for(var/mob/living/simple_animal/borer/borer as anything in borers.Copy())
		borer.update_cortical_link()

// Link outlines track real mobs rather than openspace projections.
/datum/atom_hud/alternate_appearance/basic/cortical_link/mimic(atom/movable/openspace/mimic/mimic)
	return
