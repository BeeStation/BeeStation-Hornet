#define PRC_FLAG_HL		(1<<0)								// Send half of current strength to the upper "left"
#define PRC_FLAG_L		(1<<1)								// Send the whole current strength to the upper "left": direct succession
#define PRC_FLAG_HR		(1<<2)								// Send half of current strength to the upper "right"
#define PRC_FLAG_R		(1<<3)								// Send the whole current strength to the upper "right": direct succession

/**
 * Crash Course: Understanding PRC_BEHAVIOR
 * We move forward, and in square-by-square manner, so we need a list 8 entries larger than the current one, and future squares are determined from the current square.
 * We move clockwise: "left" means intensity_new[i + j], "right" means intensity_new[i + j + 1]. `j` here is offset.
 * Most squares are on branch: It moves "left"(L) or "right"(R).
 * But, sometimes, a branch can't decide which way to go; then it splits(D) and merges(HL, HR).
 * Then there are squares not on branch; those don't go anywhere else(N).
 * But branchless squares still need to act radiation; does branchless square's does one time transient succession from both of immediate predecessors
 * ... in contrast to "on-branch" squares where there are only one meaningful predecessor.
 * Since we are calculating future squares, we need to see if there are any branchless squares needing our attention: (*STAR)
 * And, of course, branchless squares might have to draw from another preceding branchless squares. (NWL, NWR)
 */

#define PRC_BEHAVIOR_N			(1<<4)						// Not on branch, and both upper squares are on branch
															// So we don't calculate prc_behavior every time (setting to 0 would do that)
#define PRC_BEHAVIOR_NWL		PRC_FLAG_HL					// Not on branch, but will send half of its strength to the "left" since it also is not on branch
#define PRC_BEHAVIOR_NWR		PRC_FLAG_HR					// Not on branch, but will send half of its strength to the "left" since it also is not on branch
#define PRC_BEHAVIOR_L			PRC_FLAG_L					// On branch, going "left"
#define PRC_BEHAVIOR_LSTAR		(PRC_FLAG_L|PRC_FLAG_HR)	// On branch, going "left", but there's branchless square on the "right"
#define PRC_BEHAVIOR_R			PRC_FLAG_R					// On branch, going "right"
#define PRC_BEHAVIOR_RSTAR		(PRC_FLAG_R|PRC_FLAG_HL)	// On branch, going "left", but there's branchless square on the "left"
#define PRC_BEHAVIOR_D			(PRC_FLAG_L|PRC_FLAG_R)		// On branch, double successor.
#define PRC_BEHAVIOR_HL			PRC_FLAG_HL					// From one of the double successor; single successor on the "left"
#define PRC_BEHAVIOR_HLSTAR		(PRC_FLAG_HL|PRC_FLAG_HR)	// From one of the double successor; single successor on the "left", but there's branchless square on the "right"
#define PRC_BEHAVIOR_HR			PRC_FLAG_HR					// From one of the double successor; single successor on the "right"
#define PRC_BEHAVIOR_HRSTAR		(PRC_FLAG_HR|PRC_FLAG_HL)	// From one of the double successor; single successor on the "right", but there's branchless square on the "left"

/datum/radiation_wave
	var/source
	var/turf/master_turf //The center of the wave
	var/steps = 0 //How far we've moved
	var/intensity[8] //How strong it is, except the distance falloff
	var/range_modifier //Higher than 1 makes it drop off faster, 0.5 makes it drop off half etc
	var/can_contaminate
	var/static/list/prc_behavior_cache

/datum/radiation_wave/New(atom/_source, _intensity=0, _range_modifier=RAD_DISTANCE_COEFFICIENT, _can_contaminate=TRUE)

	source = "[_source] \[[REF(_source)]\]"

	master_turf = get_turf(_source)

	// Yes, it causes (8 / range_modifier ** 2) times the strength you gave to the radiation_pulse().
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

/datum/radiation_wave/process(delta_time)
	// If master_turf is no more, then we can't know where to irradiate. This is a very bad situation.
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
	var/falloff = 1 / (distance * range_modifier) ** 2
	// Caching
	var/turf/cmaster_turf = master_turf
	// Original intensity it is using
	var/list/cintensity = intensity
	// New intensity that'll be written; always larger than the previous one
	var/list/intensity_new[(distance + 1) * 8]
	// "Class" it belongs to
	var/branchclass = 2 ** round(log(2, distance))
	// The secondary i, or the offset for i
	var/j

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
		if(xpos < 1 || xpos > world.maxx || ypos < 1 || ypos > world.maxy)
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
		 * This is what I call pseudo-raycasting (PRC). Real raycasting would be ridiculously expensive,
		 * So this is the solution I came up with. Don't try to understand it by seeing the code.
		 * You have been warned. If you find yourself really having to touch this cursed code,
		 * consider axing this away before contacting me via git-fu email digging.
		 *
		 * Therefore, I urge you not to hastily assume this code a culprit of your problem.
		 * This code is responsible just for *keeping the rads going forward* more reasonably
		 * in regard to obstruction and contamination cost. But, of course, if you are rewriting
		 * (notwithstanding how questionable rewriting something major of a mature codebase like
		 * every normal SS13 codebase is) the entire radiation code, then this code should be
		 * considered for deletion.
		 *
		 * On a side note, this implementation isn't very ideal. So please remove this instead of
		 * trying to improve it when its time has come. (i.e. another total overhaul)
		 *
		 * ~Xenomedes, Christmas 2020
		 */

		// Handling eight fundamental (read: perfectly straight) branches
		if((j = i / distance) == (j = round(j)))
			distance + 1 == branchclass * 2 \
			? (i == distance * 8 \
				? (intensity_new[j - 1] += (intensity_new[1] += ((intensity_new[(j += i)] = cintensity[i]) / 2)) && cintensity[i] / 2) \
				: (intensity_new[j - 1] += intensity_new[j + 1] = ((intensity_new[(j += i)] = cintensity[i]) / 2))) \
			: (intensity_new[i + j] = cintensity[i])
			continue

		var/list/cachecache

		if(!prc_behavior_cache)
			prc_behavior_cache = list()
		if(length(prc_behavior_cache) < distance)
			prc_behavior_cache.len++
			// We don't reserve spaces for fundamental branches
			var/L[distance - 1]
			// distance == 1 is where every ray is fundamental branch
			cachecache = prc_behavior_cache[distance - 1] = L
		else
			cachecache = prc_behavior_cache[distance - 1]

		// i % distance == 0 cases were already handled above
		var/prc_behavior = cachecache[i % distance]

		if(!prc_behavior)
			// Necessary local variables
			var/idx // index
			var/lp // loop position
			var/vl // velocity of loop
			var/bt // branch threshold

			// The actual behavior calculation
			cachecache[i % distance] = prc_behavior = distance & 1 \
				? ((lp = ((idx = i % distance) * (vl = distance - branchclass + 1)) % (distance + 1)) < (bt = branchclass - (idx - round(idx * vl / (distance + 1)))) \
					? (lp \
						? (lp + vl >= bt ? PRC_BEHAVIOR_LSTAR : PRC_BEHAVIOR_L) \
						: (vl >= bt ? PRC_BEHAVIOR_HLSTAR : PRC_BEHAVIOR_HL)) \
					: (lp > branchclass \
						? (lp - vl <= bt ? PRC_BEHAVIOR_NWL : (lp - bt > branchclass ? PRC_BEHAVIOR_NWR : PRC_BEHAVIOR_N)) \
						: (lp == branchclass \
							? (lp - vl <= bt ? PRC_BEHAVIOR_HRSTAR : PRC_BEHAVIOR_HR) \
							: (lp - vl <= bt ? PRC_BEHAVIOR_RSTAR : PRC_BEHAVIOR_R)))) \
				: ((lp = ((idx = i % distance) * (vl = distance - branchclass + 1)) % (distance + 1)) == (bt = branchclass - (idx - round(idx * vl / (distance + 1)))) \
					? PRC_BEHAVIOR_D \
					: (lp > branchclass \
						? (lp - vl <= bt ? PRC_BEHAVIOR_NWL : (lp - bt > branchclass ? PRC_BEHAVIOR_NWR : PRC_BEHAVIOR_N)) \
						: (lp < bt \
							? (lp + vl >= bt ? PRC_BEHAVIOR_LSTAR : PRC_BEHAVIOR_L) \
							: (lp - vl <= bt ? PRC_BEHAVIOR_RSTAR : PRC_BEHAVIOR_R))))

		prc_behavior & PRC_FLAG_HL \
		? (intensity_new[i + j] += cintensity[i] / 2) \
		: (prc_behavior & PRC_FLAG_L \
		? (intensity_new[i + j] = cintensity[i]) \
		: null)

		prc_behavior & PRC_FLAG_HR \
		? (intensity_new[i + j + 1] += cintensity[i] / 2) \
		: (prc_behavior & PRC_FLAG_R \
		? (intensity_new[i + j + 1] = cintensity[i]) \
		: null)

	if(futile)
		qdel(src)
		return

	// Now is time to move forward
	intensity = intensity_new
	steps += delta_time

/datum/radiation_wave/proc/check_obstructions(list/atoms, index)
	for(var/k in 1 to atoms.len)
		var/atom/thing = atoms[k]
		if(!thing)
			continue
		if (SEND_SIGNAL(thing, COMSIG_ATOM_RAD_WAVE_PASSING, src, index) & COMPONENT_RAD_WAVE_HANDLED)
			continue
		if (thing.rad_insulation != RAD_NO_INSULATION)
			intensity[index] *= thing.rad_insulation

// Returns post-radiation strength power scale of a ray
// If this proc returns a number lower than 1, it means that the some radiation was spent on contaminating something.
/datum/radiation_wave/proc/radiate(list/atoms, strength)
	// returning 1 means no radiation was spent on contamination
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

#undef PRC_FLAG_HL
#undef PRC_FLAG_L
#undef PRC_FLAG_HR
#undef PRC_FLAG_R
#undef PRC_BEHAVIOR_N
#undef PRC_BEHAVIOR_NWL
#undef PRC_BEHAVIOR_NWR
#undef PRC_BEHAVIOR_L
#undef PRC_BEHAVIOR_LSTAR
#undef PRC_BEHAVIOR_R
#undef PRC_BEHAVIOR_RSTAR
#undef PRC_BEHAVIOR_D
#undef PRC_BEHAVIOR_HL
#undef PRC_BEHAVIOR_HLSTAR
#undef PRC_BEHAVIOR_HR
#undef PRC_BEHAVIOR_HRSTAR
