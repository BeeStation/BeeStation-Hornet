///ATOM PROCS

/*
These are for byonds native particle system as they are limited to a single object instance
this creates dummy objects to store the particles in useful for objects that have multiple
particles like bonfires.
*/

/atom
	///list of all particle emitters
	var/list/emitters

/atom/Destroy()
	. = ..()
	QDEL_LIST_ASSOC_VAL(emitters)

/// priority is in descending order so 10 is the highest 1 is the lowest
/atom/proc/add_emitter(obj/emitter/updatee, particle_key, priority = 10, lifespan = null, burst_mode = FALSE)

	priority = clamp(priority, 1, 10)

	if(!particle_key)
		CRASH("add_emitter called without a key ref.")

	if(!src.loc)
		CRASH("add_emitter called on a turf without a loc, avoid this!.")

	var/obj/emitter/new_emitter = new updatee

	new_emitter.layer += (priority / 100)
	new_emitter.vis_locs |= src
	LAZYSET(emitters, particle_key, new_emitter)
	if(lifespan || burst_mode)
		if(burst_mode)
			remove_emitter(particle_key, TRUE)
		else
			addtimer(CALLBACK(src, PROC_REF(remove_emitter), particle_key), lifespan)

	return new_emitter

/atom/proc/remove_emitter(particle_key, burst_mode = FALSE)
	if(!particle_key)
		CRASH("remove_emitter called without a key ref.")

	var/obj/emitter/removed_emitter = LAZYACCESS(emitters, particle_key)
	if(isnull(removed_emitter))
		return
	if(!burst_mode)
		removed_emitter.particles.spawning = 0 //this way it gracefully dies out instead
	addtimer(CALLBACK(src, PROC_REF(handle_deletion), particle_key), removed_emitter.particles.lifespan)

/atom/proc/handle_deletion(particle_key)
	var/obj/emitter/removed_emitter = LAZYACCESS(emitters, particle_key)

	if(!removed_emitter)
		return
	removed_emitter.vis_locs -= src

	LAZYREMOVE(emitters, particle_key)
	qdel(removed_emitter)
