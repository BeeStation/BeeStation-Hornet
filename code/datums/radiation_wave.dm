#define PRT_FLAG_HL		(1<<0)
#define PRT_FLAG_L		(1<<1)
#define PRT_FLAG_HR		(1<<2)
#define PRT_FLAG_R		(1<<3)

#define PRT_BEHAVIOR_N			(1<<4)
#define PRT_BEHAVIOR_NWL		PRT_FLAG_HL
#define PRT_BEHAVIOR_NWR		PRT_FLAG_HR
#define PRT_BEHAVIOR_L			PRT_FLAG_L
#define PRT_BEHAVIOR_LSTAR		(PRT_FLAG_L|PRT_FLAG_HR)
#define PRT_BEHAVIOR_R			PRT_FLAG_R
#define PRT_BEHAVIOR_RSTAR		(PRT_FLAG_R|PRT_FLAG_HL)
#define PRT_BEHAVIOR_D			(PRT_FLAG_L|PRT_FLAG_R)
#define PRT_BEHAVIOR_HL			PRT_FLAG_HL
#define PRT_BEHAVIOR_HLSTAR		(PRT_FLAG_HL|PRT_FLAG_HR)
#define PRT_BEHAVIOR_HR			PRT_FLAG_HR
#define PRT_BEHAVIOR_HRSTAR		(PRT_FLAG_HR|PRT_FLAG_HL)

/datum/radiation_wave
	var/source
	var/turf/master_turf //The center of the wave
	var/steps=0 //How far we've moved
	var/intensity[8] //How strong it is
	var/range_modifier //Higher than 1 makes it drop off faster, 0.5 makes it drop off half etc
	var/can_contaminate
	var/static/list/pseudo_raycasting_behavior_cache

/datum/radiation_wave/New(atom/_source, _intensity=0, _range_modifier=RAD_DISTANCE_COEFFICIENT, _can_contaminate=TRUE)

	source = "[_source] \[[REF(_source)]\]"

	master_turf = get_turf(_source)

	for(var/i in 1 to 8)
		intensity[i] = _intensity
	range_modifier = _range_modifier
	can_contaminate = _can_contaminate

	START_PROCESSING(SSradiation, src)

/datum/radiation_wave/Destroy()
	. = QDEL_HINT_IWILLGC
	intensity = null
	STOP_PROCESSING(SSradiation, src)
	..()

/datum/radiation_wave/process()
	if(!master_turf)
		qdel(src)
		return
	// If none of the turfs could be irradiated, then the wave should no longer exist
	var/futile = TRUE
	// Cache of unlucky atoms
	var/list/atoms = list()
	// The actual distance
	var/distance = steps + 1
	// Represents decreasing radiation power over distance
	var/falloff = 1 / (distance*range_modifier) ** 2
	// Caching
	var/turf/cmaster_turf = master_turf
	// Original intensity it is using
	var/list/cintensity = intensity
	// New intensity that'll be written; always larger than the previous one
	var/list/intensity_new[(distance+1)*8]
	// "Class" it belongs to
	var/branchclass = 2**round(log(2,distance))

	// These variable are going to be *very* handy
	var/j // secondary i
	var/idx // index
	var/lp // loop position
	var/vl // velocity of loop
	var/bt // branch threshold

	var/trc = "TheRadCost ## Intensity One: [cintensity[1]], Dist: [distance], Current Falloff: [falloff], "
	var/raycasting_cost
	var/total_step_cost = TICK_USAGE

	for(var/i in 1 to distance * 8)
		//Culls invalid intensities
		if(cintensity[i] * falloff < RAD_WAVE_MINIMUM)
			continue
		var/xpos
		var/ypos
		switch(i / distance)
			if(0 to 2)
				//Yes it starts one step off of what you'd expect. Blame BYOND.
				xpos = cmaster_turf.x + distance
				ypos = cmaster_turf.y + distance - i
			if(2 to 4)
				xpos = cmaster_turf.x + distance * 3 - i
				ypos = cmaster_turf.y - distance
			if(4 to 6)
				xpos = cmaster_turf.x - distance
				ypos = cmaster_turf.y - distance * 5 + i
			if(6 to 8)
				xpos = cmaster_turf.x - distance * 7 + i
				ypos = cmaster_turf.y + distance
		//Culls invalid coords
		if(xpos < 1 || xpos > world.maxx)
			continue
		if(ypos < 1 || ypos > world.maxy)
			continue

		//The radiation is considered alive
		futile = FALSE
		var/turf/place = locate(xpos, ypos, cmaster_turf.z)
		atoms = get_rad_contents(place)

		//Actual radiation spending
		cintensity[i] *= radiate(atoms, cintensity[i] * falloff)

		//Obstruction handling
		check_obstructions(atoms, i)

		/*
		 * This is what I call pseudo-casting. Real raycasting would be ridiculously expensive,
		 * So this is the solution I came up with. Don't try to understand it by seeing the code.
		 * You have been warned. If you find yourself having to touch this cursed code,
		 * consider axing this away before contacting me via git-fu email digging. 
		 *
		 * On a side note, this implementation isn't ideal. So please remove this instead of
		 * trying to improve it when its time has come.
		 *
		 * ~Xenomedes, Christmas 2020
		 */
		
		var/cost_start_rt = TICK_USAGE

		if((j = i / distance) == (j = round(j)))
			distance + 1 == branchclass * 2 \
			? (i == distance * 8 \
				? (intensity_new[j - 1] += (intensity_new[1] += ((intensity_new[(j += i)] = cintensity[i]) / 2)) && cintensity[i] / 2) \
				: (intensity_new[j - 1] += intensity_new[j + 1] = ((intensity_new[(j += i)] = cintensity[i]) / 2))) \
			: (intensity_new[i + j] = cintensity[i])
			raycasting_cost += TICK_USAGE - cost_start_rt
			continue
		
		if(!pseudo_raycasting_behavior_cache)
			pseudo_raycasting_behavior_cache = list()
		if(!pseudo_raycasting_behavior_cache[distance - 1])
			var/L[distance - 1]
			pseudo_raycasting_behavior_cache[distance - 1] = L
		
		var/prt_behavior = pseudo_raycasting_behavior_cache[distance][i % distance + 1]

		if(!prt_behavior)
			pseudo_raycasting_behavior_cache[distance - 1][i % distance + 1] = prt_behavior = distance & 1 \
				? ((lp = ((idx = i % distance) * (vl = distance - branchclass + 1)) % (distance + 1)) < (bt = branchclass - (idx - round(idx * vl / (distance + 1)))) \
					? (lp \
						? (lp + vl >= bt ? PRT_BEHAVIOR_LSTAR : PRT_BEHAVIOR_L) \
						: (vl >= bt ? PRT_BEHAVIOR_HLSTAR : PRT_BEHAVIOR_HL)) \
					: (lp > branchclass \
						? (lp - vl <= bt ? PRT_BEHAVIOR_NWL : (lp - bt > branchclass ? PRT_BEHAVIOR_NWR : PRT_BEHAVIOR_N)) \
						: (lp == branchclass \
							? (lp - vl <= bt ? PRT_BEHAVIOR_HRSTAR : PRT_BEHAVIOR_HR) \
							: (lp - vl <= bt ? PRT_BEHAVIOR_RSTAR : PRT_BEHAVIOR_R)))) \
				: ((lp = ((idx = i % distance) * (vl = distance - branchclass + 1)) % (distance + 1)) == (bt = branchclass - (idx - round(idx * vl / (distance + 1)))) \
					? PRT_BEHAVIOR_D \
					: (lp > branchclass \
						? (lp - vl <= bt ? PRT_BEHAVIOR_NWL : (lp - bt > branchclass ? PRT_BEHAVIOR_NWR : PRT_BEHAVIOR_N)) \
						: (lp < bt \
							? (lp + vl >= bt ? PRT_BEHAVIOR_LSTAR : PRT_BEHAVIOR_L) \
							: (lp - vl <= bt ? PRT_BEHAVIOR_RSTAR : PRT_BEHAVIOR_R))))
		
		prt_behavior & PRT_FLAG_HL \
		? (intensity_new[i + j] += cintensity[i] / 2) \
		: (prt_behavior & PRT_FLAG_L \
		? (intensity_new[i + j] = cintensity[i]) \
		: null)

		prt_behavior & PRT_FLAG_HR \
		? (intensity_new[i + j + 1] += cintensity[i] / 2) \
		: (prt_behavior & PRT_FLAG_R \
		? (intensity_new[i + j + 1] = cintensity[i]) \
		: null)

		raycasting_cost += TICK_USAGE - cost_start_rt

	if(futile)
		qdel(src)
		return

	// Now is time to move forward
	intensity = intensity_new
	steps++

	total_step_cost = TICK_USAGE - total_step_cost
	trc += "RTC: [raycasting_cost / 2] TC: [total_step_cost / 2]"
	log_mapping(trc)

/datum/radiation_wave/proc/check_obstructions(list/atoms, index)

	for(var/k in 1 to atoms.len)
		var/atom/thing = atoms[k]
		if(!thing)
			continue
		if (SEND_SIGNAL(thing, COMSIG_ATOM_RAD_WAVE_PASSING, src, index) & COMPONENT_RAD_WAVE_HANDLED)
			continue
		if (thing.rad_insulation != RAD_NO_INSULATION)
			intensity[index] *= thing.rad_insulation

/datum/radiation_wave/proc/radiate(list/atoms, strength)
	. = 1
	var/list/moblist = list()
	var/list/atomlist = list()
	var/contam_strength = strength * (RAD_CONTAMINATION_STR_COEFFICIENT * RAD_CONTAMINATION_BUDGET_SIZE) // The budget for each list
	var/is_contaminating = contam_strength > RAD_COMPONENT_MINIMUM && can_contaminate
	for(var/k in 1 to atoms.len)
		var/atom/thing = atoms[k]
		if(!thing)
			continue
		thing.rad_act(strength)

		// This list should only be for types which don't get contaminated but you want to look in their contents
		// If you don't want to look in their contents and you don't want to rad_act them:
		// modify the ignored_things list in __HELPERS/radiation.dm instead
		var/static/list/blacklisted = typecacheof(list(
			/turf,
			/obj/structure/cable,
			/obj/machinery/atmospherics,
			/obj/item/ammo_casing,
			/obj/item/implant,
			/obj/singularity
			))
		// Insulating objects won't get contaminated
		if(!is_contaminating || blacklisted[thing.type] || SEND_SIGNAL(thing, COMSIG_ATOM_RAD_CONTAMINATING, strength) & COMPONENT_BLOCK_CONTAMINATION)
			continue
		if(ismob(thing))
			moblist += thing
		else
			atomlist += thing

	// We don't randomly choose one from the list since that can result in zero meaningful contamination
	
	if(atomlist.len)
		. -= RAD_CONTAMINATION_BUDGET_SIZE
		var/affordance = min(round(contam_strength / RAD_COMPONENT_MINIMUM), atomlist.len)
		var/contam_strength_divided = contam_strength / affordance
		for(var/k in 1 to affordance)
			var/atom/poor_thing = atomlist[k]
			poor_thing.AddComponent(/datum/component/radioactive, contam_strength_divided, source)

	if(moblist.len)
		. -= RAD_CONTAMINATION_BUDGET_SIZE
		var/affordance = min(round(contam_strength / RAD_COMPONENT_MINIMUM), moblist.len)
		var/contam_strength_divided = contam_strength / affordance
		for(var/k in 1 to affordance)
			var/mob/poor_mob = moblist[k]
			poor_mob.AddComponent(/datum/component/radioactive, contam_strength_divided, source)

#undef PRT_FLAG_HL
#undef PRT_FLAG_L
#undef PRT_FLAG_HR
#undef PRT_FLAG_R
#undef PRT_BEHAVIOR_N
#undef PRT_BEHAVIOR_NWL
#undef PRT_BEHAVIOR_NWR
#undef PRT_BEHAVIOR_L
#undef PRT_BEHAVIOR_LSTAR
#undef PRT_BEHAVIOR_R
#undef PRT_BEHAVIOR_RSTAR
#undef PRT_BEHAVIOR_D
#undef PRT_BEHAVIOR_HL
#undef PRT_BEHAVIOR_HLSTAR
#undef PRT_BEHAVIOR_HR	
#undef PRT_BEHAVIOR_HRSTAR
