/atom/movable/var/list/dynamic_vis_contents
/atom/movable/dynamic_visual
	//parent_type = /atom/movable // I hate long typepath
	name = "dynamic visual atom"
	desc = "You shouldn't see this."
	appearance_flags = RESET_ALPHA | KEEP_APART | TILE_BOUND | PIXEL_SCALE
	vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_ID | VIS_INHERIT_DIR | VIS_UNDERLAY

/atom/movable/proc/add_dynavis(key, invisibility_level=INVISIBILITY_OBSERVER)
	var/atom/movable/dynamic_visual/dyvis = new()
	var/current_alpha = alpha
	var/alpha_check = appearance_flags & RESET_ALPHA
	if(!alpha_check)
		appearance_flags |= RESET_ALPHA
	alpha = 120
	dyvis.add_overlay(src)
	alpha = current_alpha
	if(!alpha_check)
		appearance_flags &= ~RESET_ALPHA
	dyvis.invisibility = invisibility_level
	vis_contents += dyvis

	LAZYINITLIST(dynamic_vis_contents)
	dynamic_vis_contents[key] = dyvis

/atom/movable/proc/remove_dynavis(key)
	var/dynavis = dynamic_vis_contents[key]
	LAZYREMOVE(dynamic_vis_contents, key)
	vis_contents -= dynavis
	qdel(dynavis)

/atom/movable/proc/cut_dynavis()
	for(var/each_key in dynamic_vis_contents)
		var/dynavis = dynamic_vis_contents[each_key]
		dynamic_vis_contents -= each_key
		vis_contents -= dynavis
		qdel(dynavis)
	dynamic_vis_contents = null
