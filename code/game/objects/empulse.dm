/proc/empulse(turf/epicenter, heavy_range, light_range, log=0, magic=FALSE, holy=FALSE)
	if(!epicenter)
		return

	if(!isturf(epicenter))
		epicenter = get_turf(epicenter.loc)

	if(log)
		message_admins("EMP with size ([heavy_range], [light_range]) in [ADMIN_VERBOSEJMP(epicenter)] ")
		log_game("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] ")

	if(heavy_range > 1)
		new /obj/effect/temp_visual/emp/pulse(epicenter)

	if(heavy_range > light_range)
		light_range = heavy_range

	var/list/empulse_atoms = list()

	for(var/turf/T as() in spiral_range_turfs(light_range, epicenter))
		//Blessing protects from holy EMPS
		if(holy && T.is_holy())
			continue
		for(var/atom/A as() in T)
			//Magic check.
			if(ismob(A))
				var/mob/M = A
				if(M.anti_magic_check(magic, holy, TRUE, T==epicenter))
					continue
			empulse_atoms += A
		empulse_atoms += T

	for(var/atom/A as() in empulse_atoms)
		var/distance = get_dist(epicenter, A)
		if(distance < 0)
			distance = 0
		if(distance < heavy_range)
			A.emp_act(EMP_HEAVY)
		else if(distance == heavy_range)
			if(prob(50))
				A.emp_act(EMP_HEAVY)
			else
				A.emp_act(EMP_LIGHT)
		else if(distance <= light_range)
			A.emp_act(EMP_LIGHT)
	return 1
