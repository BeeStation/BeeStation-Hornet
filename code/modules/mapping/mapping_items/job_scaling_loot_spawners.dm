/obj/effect/loot_jobscale
	icon = 'icons/effects/landmarks_spawners.dmi'
	icon_state = "random_loot"
	layer = OBJ_LAYER
	var/lootcount = 1		//how many items will be spawned
	var/lootdoubles = TRUE	//if the same item can be spawned twice
	var/list/loot			//a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)
	var/fan_out_items = FALSE //Whether the items should be distributed to offsets 0,1,-1,2,-2,3,-3.. This overrides pixel_x/y on the spawner itself

	var/list/jobs = list()
	var/minimum = 0
	var/maximum = INFINITY
	//1 item per person
	var/linear_scaling_rate = 1

/obj/effect/loot_jobscale/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_POST_START, PROC_REF(spawn_loot))

/obj/effect/loot_jobscale/proc/spawn_loot()
	//Count the number of jobs
	var/total = 0
	for (var/job_name in jobs)
		var/datum/job/located = SSjob.GetJob(job_name)
		total += located.current_positions
	total = CEILING(CLAMP(total * linear_scaling_rate, minimum, maximum), 1)
	lootcount = total
	if(!length(loot))
		qdel(src)
		return
	var/turf/T = get_turf(src)
	var/loot_spawned = 0
	while((lootcount-loot_spawned) && loot.len)
		var/lootspawn = pick_weight(loot)
		if(!lootdoubles)
			loot.Remove(lootspawn)

		if(lootspawn)
			var/atom/movable/spawned_loot = new lootspawn(T)
			if (!fan_out_items)
				if (pixel_x != 0)
					spawned_loot.pixel_x = pixel_x
				if (pixel_y != 0)
					spawned_loot.pixel_y = pixel_y
			else
				if (loot_spawned)
					spawned_loot.pixel_x = spawned_loot.pixel_y = ((!(loot_spawned%2)*loot_spawned/2)*-1)+((loot_spawned%2)*(loot_spawned+1)/2*1)
		loot_spawned++
	qdel(src)
