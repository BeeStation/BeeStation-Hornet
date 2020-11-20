/obj/effect/displacement
	icon = 'icons/effects/displacements.dmi'
	icon_state = "none"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/alias = "*displacement_rt" // * at the start means the render target is invisible
	var/duration = 0 // in deciseconds, 0 means forever
	var/timerid
	var/rt_name
	var/atom/movable/parent

/obj/effect/displacement/Initialize(mapload, atom/movable/AM)
	. = ..()
	parent = AM
	rt_name = "[alias][ref(src)]"
	render_target = rt_name
	AM.add_filter(rt_name, 2, list("type" = "displace", "size" = 256, "render_source"=rt_name))
	if(duration)
		timerid = QDEL_IN(src, duration)

/obj/effect/displacement/Destroy()
	. = ..()
	if(!QDELETED(parent))
		parent.remove_filter(rt_name)
	if(timerid)
		deltimer(timerid)

/obj/effect/displacement/singularity_act()
	return

/obj/effect/displacement/singularity_pull()
	return

/obj/effect/displacement/ex_act()
	return

/obj/effect/displacement/dust
	icon_state = "dust"
	alias = "*dust_rt"
	duration = 14
