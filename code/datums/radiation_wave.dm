/datum/radiation_wave
	var/source
	var/turf/master_turf //The center of the wave
	var/steps=0 //How far we've moved
	var/intensity[8] //How strong it was originaly
	var/range_modifier //Higher than 1 makes it drop off faster, 0.5 makes it drop off half etc
	var/can_contaminate

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
	// If none of the turfs could be irradiated, then the wave is ded
	var/ded = TRUE
	var/list/atoms = list()
	// The actual distance
	var/distance = steps + 1
	// Represents decreasing radiation power over distance
	var/falloff = 1 / (distance*range_modifier) ** 2
	// Caching
	var/turf/cmaster_turf = master_turf
	// Index for the intensity list
	var/index = 0
	// Original intensity it is using
	var/list/cintensity = intensity

	var/turf/place = locate(cmaster_turf.x - distance, cmaster_turf.y + distance, cmaster_turf.z)
	for(var/dir in list(EAST, SOUTH, WEST, NORTH))
		for(var/i in 1 to distance * 2)
			if(cintensity[++index])
				atoms = get_rad_contents(place)
				cintensity[index] *= radiate(atoms, FLOOR(cintensity[index] * falloff, 1))
				check_obstructions(atoms, index)
				ded = FALSE
			place = get_step(place, dir)
	
	if(ded)
		qdel(src)
		return

	raycast() // This proc is cursed

	steps++ // This moves the wave forward

/datum/radiation_wave/proc/raycast()

	var/distance = steps + 1
	var/falloff = 1 / distance ** 2
	
	// Index for new intensity list; I don't want to create ridiculous amount of additions
	var/index_new = 0
	// Index for soon-to-be-obsoleted-intensity list
	var/index_old = 1

	// The soon-to-be-obsoleted-intensity list
	var/list/intensity_old = intensity
	// New intensity that'll be written; always larger than the previous one
	var/list/intensity_new[(distance+1)*8]

	// The candidate before pruning
	var/candidate
	// The size of loop
	var/loopsize = distance + 2
	// "Class" it belongs to
	var/branchclass = 2**round(log(2,distance + 1))
	// Velocity of loop
	var/loopspeed = loopsize - branchclass
	// The looping variable
	var/loop
	// The "branch" it currently is on
	var/currentbranch

	// THIS REDUNDANCY IS INTENTIONAL
	for(var/clock in 1 to 8)
		intensity_new[++index_new] = intensity_old[index_old] * falloff > RAD_WAVE_MINIMUM ? intensity_old[index_old] : 0

		loop = 0
		currentbranch = 0
		for(var/i in 1 to distance)
			// Pure magic happens here
			candidate = ((loop += loopspeed) > loopsize ? (loop -= loopsize) : loop) >= branchclass ? \
							(loop == loopsize ? \
								intensity_old[index_old++] \
								: (intensity_old[index_old] + intensity_old[++index_old]) / 2) \
							: (loop == ++currentbranch ? \
								(index_old == (distance * 8) ? \
									(intensity_old[index_old]+intensity_old[1]) / 2 \
									: (intensity_old[index_old]+intensity_old[++index_old]) / 2) \
								: (loop > currentbranch ? \
									intensity_old[++index_old] \
									: intensity_old[index_old++]))

			if(candidate * falloff < RAD_WAVE_MINIMUM)
				intensity_new[++index_new] = 0
			else
				intensity_new[++index_new] = candidate

	intensity = intensity_new //THERE CAN BE ONLY ONE

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
		if(!is_contaminating)
			continue
		if(blacklisted[thing.type])
			continue
		// Insulating objects won't get contaminated
		if(SEND_SIGNAL(thing, COMSIG_ATOM_RAD_CONTAMINATING, strength) & COMPONENT_BLOCK_CONTAMINATION)
			continue
		if(ismob(thing))
			moblist += thing
		else
			atomlist += thing

	if(atomlist.len)
		. -= RAD_CONTAMINATION_BUDGET_SIZE
		var/affordance = min(FLOOR(contam_strength,RAD_COMPONENT_MINIMUM), atomlist.len)
		var/contam_strength_divided = contam_strength / affordance
		for(var/k in 1 to affordance)
			var/atom/poor_thing = atomlist[k]
			poor_thing.AddComponent(/datum/component/radioactive, contam_strength_divided, source)

	if(moblist.len)
		. -= RAD_CONTAMINATION_BUDGET_SIZE
		var/affordance = min(FLOOR(contam_strength,RAD_COMPONENT_MINIMUM), moblist.len)
		var/contam_strength_divided = contam_strength / affordance
		for(var/k in 1 to affordance)
			var/mob/poor_mob = moblist[k]
			poor_mob.AddComponent(/datum/component/radioactive, contam_strength_divided, source)
