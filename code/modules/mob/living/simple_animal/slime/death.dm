/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed && life_stage == SLIME_LIFE_STAGE_ADULT)
		var/mob/living/simple_animal/slime/new_slime = new(drop_location(), slime_type.type)
		new_slime.rabid = TRUE
		new_slime.regenerate_icons()

		//revives us as a baby
		set_life_stage(SLIME_LIFE_STAGE_BABY)
		revive(HEAL_ALL)
		regenerate_icons()
		update_name()
		return

	if(buckled)
		stop_feeding(silent = TRUE) //releases ourselves from the mob we fed on.

	GLOB.total_slimes--
	set_stat(DEAD)
	cut_overlays()

	return ..(gibbed)

/mob/living/simple_animal/slime/gib()
	death(TRUE)
	qdel(src)


/mob/living/simple_animal/slime/Destroy()
	for(var/obj/machinery/computer/camera_advanced/xenobio/X as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/camera_advanced/xenobio))
		if(src in X.stored_slimes)
			X.stored_slimes -= src
	if(stat != DEAD)
		GLOB.total_slimes--
	master = null
	return ..()
