//temporary visual effects
/obj/effect/temp_visual
	icon_state = "nothing"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/duration = 10 //in deciseconds
	var/randomdir = TRUE
	var/timerid
	/// Used in Projectile effects to keep the core of the effect white
	var/core_overlay

/obj/effect/temp_visual/Initialize(mapload)
	. = ..()
	if(randomdir)
		setDir(pick(GLOB.cardinals))
	if(core_overlay)
		update_appearance()

	timerid = QDEL_IN_STOPPABLE(src, duration)

/obj/effect/temp_visual/update_overlays()
	. = ..()
	if(core_overlay)
		var/mutable_appearance/ma = mutable_appearance(icon, core_overlay)
		ma.appearance_flags |= RESET_COLOR
		. += ma

/obj/effect/temp_visual/Destroy()
	. = ..()
	deltimer(timerid)

/obj/effect/temp_visual/singularity_act()
	return

/obj/effect/temp_visual/singularity_pull()
	return

/obj/effect/temp_visual/dir_setting
	randomdir = FALSE

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/temp_visual/dir_setting)

/obj/effect/temp_visual/dir_setting/Initialize(mapload, set_dir)
	if(set_dir)
		setDir(set_dir)
	. = ..()


