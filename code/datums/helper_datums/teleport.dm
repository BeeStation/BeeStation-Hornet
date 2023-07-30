// teleatom: atom to teleport
// destination: destination to teleport to
// precision: teleport precision (0 is most precise, the default)
// effectin: effect to show right before teleportation
// effectout: effect to show right after teleportation
// asoundin: soundfile to play before teleportation
// asoundout: soundfile to play after teleportation
// no_effects: disable the default effectin/effectout of sparks
// forced: whether or not to ignore no_teleport
/proc/do_teleport(atom/movable/teleatom, atom/destination, precision=null, datum/effect_system/effectin=null, datum/effect_system/effectout=null, asoundin=null, asoundout=null, no_effects=FALSE, channel=TELEPORT_CHANNEL_BLUESPACE, forced = FALSE, teleport_mode = TELEPORT_MODE_DEFAULT, commit = TRUE)
	// teleporting most effects just deletes them
	var/static/list/delete_atoms = typecacheof(list(
		/obj/effect,
		)) - typecacheof(list(
		/obj/effect/dummy/chameleon,
		/obj/effect/wisp,
		/obj/effect/mob_spawn,
		/obj/effect/warp_cube,
		/obj/effect/extraction_holder,
		))
	if(delete_atoms[teleatom.type])
		qdel(teleatom)
		return FALSE

	//Check bluespace anchors
	if(channel != TELEPORT_CHANNEL_FREE && channel != TELEPORT_CHANNEL_WORMHOLE)
		for (var/obj/machinery/bluespace_anchor/anchor as() in GLOB.active_bluespace_anchors)
			//Not nearby
			if (anchor.get_virtual_z_level() != teleatom.get_virtual_z_level() || (get_dist(teleatom, anchor) > anchor.range && get_dist(destination, anchor) > anchor.range))
				continue
			//Check it
			if(!anchor.try_activate())
				continue
			do_sparks(5, FALSE, teleatom)
			playsound(anchor, 'sound/magic/repulse.ogg', 80, TRUE)
			if(ismob(teleatom))
				to_chat(teleatom, "<span class='warning'>You feel like you are being held in place.</span>")
			//Anchored...
			return FALSE

	// argument handling
	// if the precision is not specified, default to 0, but apply BoH penalties
	if (isnull(precision))
		precision = 0
	switch(channel)
		if(TELEPORT_CHANNEL_BLUESPACE)
			if(istype(teleatom, /obj/item/storage/backpack/holding))
				precision = rand(1,100)

			var/static/list/bag_cache = typecacheof(/obj/item/storage/backpack/holding)
			var/list/bagholding = typecache_filter_list(teleatom.GetAllContents(), bag_cache)
			if(bagholding.len)
				precision = max(rand(1,100)*bagholding.len,100)
				if(isliving(teleatom))
					var/mob/living/MM = teleatom
					to_chat(MM, "<span class='warning'>The bluespace interface on your bag of holding interferes with the teleport!</span>")

	// if effects are not specified and not explicitly disabled, sparks
	if ((!effectin || !effectout) && !no_effects)
		var/datum/effect_system/spark_spread/sparks = new
		sparks.set_up(5, 1, teleatom)
		if (!effectin)
			effectin = sparks
		if (!effectout)
			effectout = sparks

	// perform the teleport
	var/turf/curturf = get_turf(teleatom)
	var/turf/destturf = get_teleport_turf(get_turf(destination), precision)

	if(!destturf || !curturf || destturf.is_transition_turf())
		return FALSE

	var/area/A = get_area(curturf)
	var/area/B = get_area(destturf)
	if(!forced && (HAS_TRAIT(teleatom, TRAIT_NO_TELEPORT)))
		return FALSE

	//Either area has teleport restriction and teleport mode isn't allowed in that area
	if(!forced && ((A.teleport_restriction && A.teleport_restriction != teleport_mode) || (B.teleport_restriction && B.teleport_restriction != teleport_mode)))
		return FALSE

	if(SEND_SIGNAL(destturf, COMSIG_ATOM_INTERCEPT_TELEPORT, channel, curturf, destturf))
		return FALSE

	if(isobserver(teleatom))
		teleatom.abstract_move(destturf)
		return TRUE

	if (!commit)
		return TRUE

	tele_play_specials(teleatom, curturf, effectin, asoundin)
	var/success = teleatom.forceMove(destturf)
	if (success)
		log_game("[key_name(teleatom)] has teleported from [loc_name(curturf)] to [loc_name(destturf)]")
		tele_play_specials(teleatom, destturf, effectout, asoundout)
		if(ismegafauna(teleatom))
			message_admins("[teleatom] [ADMIN_FLW(teleatom)] has teleported from [ADMIN_VERBOSEJMP(curturf)] to [ADMIN_VERBOSEJMP(destturf)].")

	if(ismob(teleatom))
		var/mob/M = teleatom
		M.cancel_camera()

	teleatom.teleport_act()

	return TRUE

/proc/tele_play_specials(atom/movable/teleatom, atom/location, datum/effect_system/effect, sound)
	if (location && !isobserver(teleatom))
		if (sound)
			playsound(location, sound, 60, 1)
		if (effect)
			effect.attach(location)
			effect.start()

// Safe location finder
/proc/find_safe_turf(zlevel, list/zlevels, extended_safety_checks = FALSE, dense_atoms = TRUE)
	if(!zlevels)
		if (zlevel)
			zlevels = list(zlevel)
		else
			zlevels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	var/cycles = 1000
	for(var/cycle in 1 to cycles)
		// DRUNK DIALLING WOOOOOOOOO
		var/x = rand(1, world.maxx)
		var/y = rand(1, world.maxy)
		var/z = pick(zlevels)
		var/random_location = locate(x,y,z)

		if(!isfloorturf(random_location))
			continue
		var/turf/open/floor/F = random_location
		if(!F.air)
			continue

		var/datum/gas_mixture/A = F.air
		var/trace_gases
		for(var/id in A.get_gases())
			if(id in GLOB.hardcoded_gases)
				continue
			trace_gases = TRUE
			break

		// Can most things breathe?
		if(trace_gases)
			continue
		if(A.get_moles(GAS_O2) < 16)
			continue
		if(A.get_moles(GAS_PLASMA))
			continue
		if(A.get_moles(GAS_CO2) >= 10)
			continue

		// Aim for goldilocks temperatures and pressure
		if((A.return_temperature() <= 270) || (A.return_temperature() >= 360))
			continue
		var/pressure = A.return_pressure()
		if((pressure <= 20) || (pressure >= 550))
			continue

		if(extended_safety_checks)
			if(islava(F)) //chasms aren't /floor, and so are pre-filtered
				var/turf/open/lava/L = F
				if(!L.is_safe())
					continue

		// Check that we're not warping onto a table or window
		if(!dense_atoms)
			var/density_found = FALSE
			for(var/atom/movable/found_movable in F)
				if(found_movable.density)
					density_found = TRUE
					break
			if(density_found)
				continue

		// DING! You have passed the gauntlet, and are "probably" safe.
		return F

/proc/get_teleport_turfs(turf/center, precision = 0)
	if(!precision)
		return list(center)
	//Return only open turfs unless none are available
	var/list/safe_turfs = list()
	var/list/posturfs = list()
	for(var/turf/T as() in RANGE_TURFS(precision, center))
		if(T.is_transition_turf())
			continue // Avoid picking these.
		var/area/A = T.loc
		if(!A.teleport_restriction)
			posturfs.Add(T)
			if(isopenturf(T))
				safe_turfs += T
	if(length(safe_turfs))
		return safe_turfs
	return posturfs

/proc/get_teleport_turf(turf/center, precision = 0)
	return safepick(get_teleport_turfs(center, precision))

/proc/wizarditis_teleport(mob/living/carbon/affected_mob)
	var/list/theareas = get_areas_in_range(80, affected_mob)
	for(var/area/space/S in theareas)
		theareas -= S

	if(!length(theareas))
		return

	var/area/thearea = pick(theareas)

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(T.get_virtual_z_level() != affected_mob.get_virtual_z_level())
			continue
		if(isspaceturf(T))
			continue
		if(T.density)
			continue

		var/clear = TRUE
		for(var/obj/O in T)
			if(O.density)
				clear = FALSE
				break
		if(clear)
			L+=T

	if(!L)
		return

	if(do_teleport(affected_mob, pick(L), channel = TELEPORT_CHANNEL_MAGIC, no_effects = TRUE))
		affected_mob.say("SCYAR NILA [uppertext(thearea.name)]!", forced = "wizarditis teleport")
