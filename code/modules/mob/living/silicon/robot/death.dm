
/mob/living/silicon/robot/gib_animation()
	new /obj/effect/temp_visual/gib_animation(loc, "gibbed-r")

/mob/living/silicon/robot/dust(just_ash, drop_items, force)
	// You do not get MMI'd if you are dusted
	QDEL_NULL(mmi)
	return ..()

/mob/living/silicon/robot/dust_animation()
	new /obj/effect/temp_visual/dust_animation(loc, "dust-r")

/mob/living/silicon/robot/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		logevent("FATAL -- SYSTEM HALT")
		modularInterface.shutdown_computer()
	. = ..()

	locked = FALSE //unlock cover

	if(!QDELETED(builtInCamera) && builtInCamera.status)
		builtInCamera.toggle_cam(src, FALSE)

	toggle_headlamp(TRUE) //So borg lights are disabled when killed.
	uneq_all() // particularly to ensure sight modes are cleared
	update_icons()
	unbuckle_all_mobs(TRUE)
	SSblackbox.ReportDeath(src)

/mob/living/silicon/robot/gib(no_brain, no_organs, no_bodyparts)
	dump_into_mmi()
	return ..()
