/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		if(is_adult)
			var/mob/living/simple_animal/slime/M = new(loc, colour)
			M.rabid = TRUE
			M.regenerate_icons()

			is_adult = FALSE
			maxHealth = 150
			for(var/datum/action/innate/slime/reproduce/R in actions)
				qdel(R)
			var/datum/action/innate/slime/evolve/E = new
			E.Grant(src)
			revive(HEAL_ALL)
			regenerate_icons()
			update_name()
			return

	if(buckled)
		Feedstop(silent = TRUE) //releases ourselves from the mob we fed on.

	GLOB.total_slimes--
	set_stat(DEAD)
	cut_overlays()

	return ..(gibbed)

/mob/living/simple_animal/slime/gib()
	death(TRUE)
	qdel(src)


/mob/living/simple_animal/slime/Destroy()
	for(var/obj/machinery/computer/camera_advanced/xenobio/X in GLOB.machines)
		if(src in X.stored_slimes)
			X.stored_slimes -= src
	if(stat != DEAD)
		GLOB.total_slimes--
	master = null
	return ..()
