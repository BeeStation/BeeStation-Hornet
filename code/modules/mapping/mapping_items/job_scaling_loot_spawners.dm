/obj/effect/spawner/lootdrop/job_scale
	late_spawn = TRUE
	var/list/jobs = list()
	var/minimum = 0
	var/maximum = INFINITY
	//1 item per person
	var/linear_scaling_rate = 1

/obj/effect/spawner/lootdrop/job_scale/late_spawn_loot()
	//Count the number of jobs
	var/total = 0
	for (var/job_name in jobs)
		var/datum/job/located = SSjob.GetJob(job_name)
		total += located.current_positions
	total = CEILING(CLAMP(total * linear_scaling_rate, minimum, maximum), 1)
	lootcount = total
	. = ..()
