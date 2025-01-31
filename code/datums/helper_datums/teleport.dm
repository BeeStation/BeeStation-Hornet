/**
 * Returns FALSE if we SHOULDN'T do_teleport() with the given arguments
 *
 * Arguments:
 * * teleatom: The atom to teleport
 * * dest_turf: The destination turf for the atom to go
 * * channel: Which teleport channel/type should we try to use (for blocking checks), defaults to TELEPORT_CHANNEL_BLUESPACE
 * * bypass_area_restriction: Should we ignore SOFT atom and area TRAIT_NO_TELEPORT restriction and other area-related restrictions? Defaults to FALSE
 * * teleport_mode: Teleport mode for religion/faction checks
 */
/proc/check_teleport(atom/movable/teleatom, turf/dest_turf, channel = TELEPORT_CHANNEL_BLUESPACE, bypass_area_restriction = FALSE, teleport_mode = TELEPORT_ALLOW_ALL)
	var/turf/cur_turf = get_turf(teleatom)

	if(!istype(dest_turf))
		stack_trace("Destination [dest_turf] is not a turf.")
		return FALSE
	if(!istype(cur_turf) || dest_turf.is_transition_turf())
		return FALSE

	// Checks bluespace anchors
	if(channel != TELEPORT_CHANNEL_WORMHOLE && channel != TELEPORT_CHANNEL_FREE && channel != TELEPORT_CHANNEL_GATEWAY)
		var/cur_zlevel = cur_turf.get_virtual_z_level()
		var/dest_zlevel = dest_turf.get_virtual_z_level()
		for (var/obj/machinery/bluespace_anchor/anchor as() in GLOB.active_bluespace_anchors)
			var/anchor_zlevel = anchor.get_virtual_z_level()
			// Not in range of our current turf or destination turf
			if((cur_zlevel != anchor_zlevel || get_dist(cur_turf, anchor) > anchor.range) && (dest_zlevel != anchor_zlevel || get_dist(dest_turf, anchor) > anchor.range))
				continue

			// Try to activate the anchor, this also does the effect
			if(!anchor.try_activate())
				continue

			// We're anchored, return false
			return FALSE

	// Checks antimagic
	if(ismob(teleatom))
		var/mob/tele_mob = teleatom
		if(channel == TELEPORT_CHANNEL_CULT && tele_mob.can_block_magic())
			return FALSE
		if(channel == TELEPORT_CHANNEL_MAGIC && tele_mob.can_block_magic())
			return FALSE
		if (channel == TELEPORT_CHANNEL_MAGIC_SELF && !tele_mob.can_cast_magic())
			return FALSE

	// Check for NO_TELEPORT restrictions
	if(!bypass_area_restriction)
		var/area/cur_area = cur_turf.loc
		var/area/dest_area = dest_turf.loc
		if(HAS_TRAIT(teleatom, TRAIT_NO_TELEPORT))
			return FALSE
		if(cur_area.teleport_restriction && cur_area.teleport_restriction != teleport_mode)
			return FALSE
		if(dest_area.teleport_restriction && dest_area.teleport_restriction != teleport_mode)
			return FALSE

	// Check for intercepting the teleport
	if(cur_turf.intercept_teleport(channel, cur_turf, dest_turf) == COMPONENT_BLOCK_TELEPORT)
		return FALSE
	if(dest_turf.intercept_teleport(channel, cur_turf, dest_turf) == COMPONENT_BLOCK_TELEPORT)
		return FALSE
	if(teleatom.intercept_teleport(channel, cur_turf, dest_turf) == COMPONENT_BLOCK_TELEPORT)
		return FALSE

	return TRUE

/**
 * Returns TRUE if the teleport has been successful
 *
 * Arguments:
 * * teleatom: atom to teleport
 * * destination: destination to teleport to
 * * precision: teleport precision (0 is most precise, the default)
 * * effectin: effect to show right before teleportation
 * * asoundin: soundfile to play before teleportation
 * * asoundout: soundfile to play after teleportation
 * * no_effects: disable the default effectin/effectout of sparks
 * * channel: Which teleport channel/type should we try to use (for blocking checks)
 * * ignore_check_teleport: Set this to true ONLY if you have already run check_teleport
 * * bypass_area_restriction: Should we ignore SOFT atom and area TRAIT_NO_TELEPORT restriction and other area-related restrictions? Defaults to FALSE
 * * no_wake: Whether or not we want a teleport wake to be created
 */
/proc/do_teleport(atom/movable/teleatom, atom/destination, precision=null, datum/effect_system/effectin=null, datum/effect_system/effectout=null, asoundin=null, asoundout=null, no_effects=FALSE, channel=TELEPORT_CHANNEL_BLUESPACE, bypass_area_restriction = FALSE, teleport_mode = TELEPORT_ALLOW_ALL, ignore_check_teleport = FALSE, no_wake = FALSE)
	// teleporting most effects just deletes them
	var/static/list/delete_atoms = typecacheof(list(
		/obj/effect,
	)) - typecacheof(list(
		/obj/effect/dummy/chameleon,
		/obj/effect/wisp,
		/obj/effect/mob_spawn,
		/obj/effect/warp_cube,
		/obj/effect/extraction_holder,
		/obj/effect/anomaly,
	))
	if(delete_atoms[teleatom.type])
		qdel(teleatom)
		return FALSE

	// argument handling
	// if the precision is not specified, default to 0, but apply BoH penalties
	if (isnull(precision))
		precision = 0
	switch(channel)
		if(TELEPORT_CHANNEL_BLUESPACE)
			if(istype(teleatom, /obj/item/storage/backpack/holding))
				precision = rand(1,100)

			var/list/bagholding = teleatom.GetAllContents(/obj/item/storage/backpack/holding)
			if(bagholding.len)
				precision = max(rand(1,100)*bagholding.len,100)
				if(isliving(teleatom))
					var/mob/living/MM = teleatom
					to_chat(MM, span_warning("The bluespace interface on your bag of holding interferes with the teleport!"))

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

	if(isobserver(teleatom))
		teleatom.abstract_move(destturf)
		return TRUE

	if(!ignore_check_teleport) // If we've already done it let's not check again
		if(!check_teleport(teleatom, destturf, channel, bypass_area_restriction, teleport_mode))
			return FALSE

	// If we leave behind a wake, then create that here.
	// Only leave a wake if we are going to a location that we can actually teleport to.
	if (!no_wake && (channel == TELEPORT_CHANNEL_BLUESPACE || channel == TELEPORT_CHANNEL_CULT || channel == TELEPORT_CHANNEL_MAGIC || channel == TELEPORT_CHANNEL_MAGIC_SELF))
		var/area/cur_area = curturf.loc
		var/area/dest_area = destturf.loc
		if(cur_area.teleport_restriction == TELEPORT_ALLOW_ALL && dest_area.teleport_restriction == TELEPORT_ALLOW_ALL && teleport_mode == TELEPORT_ALLOW_ALL)
			new /obj/effect/temp_visual/teleportation_wake(get_turf(teleatom), destturf)

	tele_play_specials(teleatom, curturf, effectin, asoundin)

	// Actually teleport them
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
	if (!istype(location) || isobserver(teleatom))
		return
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
		if(!is_turf_safe(F))
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

	if(do_teleport(affected_mob, pick(L), channel = TELEPORT_CHANNEL_MAGIC_SELF, no_effects = TRUE))
		affected_mob.say("SCYAR NILA [uppertext(thearea.name)]!", forced = "wizarditis teleport")

/obj/effect/temp_visual/teleportation_wake
	name = "slipspace wake"
	duration = 30 SECONDS
	randomdir = FALSE
	icon = 'icons/effects/effects.dmi'
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	hud_possible = list(DIAG_WAKE_HUD)
	var/turf/destination
	var/has_hud_icon = FALSE

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/temp_visual/teleportation_wake)

/obj/effect/temp_visual/teleportation_wake/Initialize(mapload, turf/destination)
	// Replace any portals on the current turf
	for (var/obj/effect/temp_visual/teleportation_wake/conflicting_portal in loc)
		if (conflicting_portal == src)
			continue
		conflicting_portal.destination = destination
		return INITIALIZE_HINT_QDEL
	. = ..()
	src.destination = destination
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	var/image/holder = hud_list[DIAG_WAKE_HUD]
	var/mutable_appearance/MA = new /mutable_appearance()
	MA.icon = 'icons/effects/effects.dmi'
	MA.icon_state = "bluestream"
	MA.layer = ABOVE_OPEN_TURF_LAYER
	MA.plane = GAME_PLANE
	holder.appearance = MA
	has_hud_icon = TRUE

/obj/effect/temp_visual/teleportation_wake/Destroy()
	if (has_hud_icon)
		for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
			diag_hud.remove_from_hud(src)
	return ..()

/obj/effect/temp_visual/portal_opening
	name = "Portal Opening"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	alpha = 0
	duration = 11 SECONDS

/obj/effect/temp_visual/portal_opening/Initialize(mapload)
	. = ..()
	transform = matrix() * 0
	animate(src, time = 10 SECONDS, transform = matrix(), alpha = 255)
	animate(time = 0.5 SECONDS, transform = matrix() * 0, alpha = 0)

// mob-level gateway teleport checks
/mob/living/carbon/intercept_teleport(channel, turf/origin, turf/destination)
	. = ..()

	if(. == COMPONENT_BLOCK_TELEPORT || channel != TELEPORT_CHANNEL_GATEWAY)
		return

	// Checking for exile implants
	if(!isnull(implants))
		for(var/obj/item/implant/exile/baddie in implants)
			visible_message(span_warning("The portal bends inward, but [src] can't seem to pass through it!"), span_warning("The portal has detected your [baddie] and not letting you through!"))
			return COMPONENT_BLOCK_TELEPORT

	// Ashwalker check
	if(is_species(src, /datum/species/lizard/ashwalker))
		visible_message(span_warning("The portal bends inward, but [src] can't seem to pass through it!"), span_warning("You can seem to go through the portal!"))
		return COMPONENT_BLOCK_TELEPORT

/mob/living/simple_animal/hostile/megafauna/intercept_teleport(channel, turf/origin, turf/destination)
	. = ..()

	if(. == COMPONENT_BLOCK_TELEPORT || channel != TELEPORT_CHANNEL_GATEWAY)
		return

	visible_message(span_warning("The portal bends inward, but [src] can't seem to pass through it!"), span_warning("You can't seem to pass through the portal!"))
	return COMPONENT_BLOCK_TELEPORT

/mob/living/simple_animal/hostile/asteroid/elite/intercept_teleport(channel, turf/origin, turf/destination)
	. = ..()

	if(. == COMPONENT_BLOCK_TELEPORT || channel != TELEPORT_CHANNEL_GATEWAY)
		return

	visible_message(span_warning("The portal bends inward, but [src] can't seem to pass through it!"), span_warning("You can't seem to pass through the portal!"))
	return COMPONENT_BLOCK_TELEPORT

/mob/living/simple_animal/hostile/swarmer/intercept_teleport(channel, turf/origin, turf/destination)
	. = ..()

	if(. == COMPONENT_BLOCK_TELEPORT || channel != TELEPORT_CHANNEL_GATEWAY)
		return

	visible_message(span_warning("[src] stops just before entering the portal."), span_warning("Going back the way you came would not be productive. Aborting."))
	return COMPONENT_BLOCK_TELEPORT

/**
 * attempts to take AM through all turfs in a straight line between ``current_turf`` and ``target_turf``,
 * applying ``on_turf_cross`` for each turf and ``obj_damage`` to each structure encountered
 *
 * player-facing warnings and EMP/BoH effects should be handled externally from this proc
 *
 * required arguments:
 * * ``AM`` - movable atom to be dashed
 * * ``current_turf`` - source turf for the dash, not necessarily ``AM``'s
 * * ``target_turf`` - destination turf for the dash
 * optional parameters:
 * * ``obj_damage`` - damage applied to structures in its path (not mobs)
 * * ``phase`` - whether to go through structures or be impeded by them until they're broken
 * * ``teleport_channel`` - allows overriding of teleport channel used
 * * ``on_turf_cross`` - optional callback proc to call on each of the crossed turfs;
 * takes ``turf/T`` and returns ``TRUE`` if dash should continue, otherwise ``FALSE`` when it should be interrupted -
 * this however does not cause the dash to return a null value;
 * if the proc you wrap in a callback has multiple parameters, ``turf/T`` should be last, and will be passed from here
 *
 * returns: ``turf/landing_turf``, which represents where the dash ended, or ``null`` if the jaunt's teleport check failed
 */
/proc/do_dash(atom/movable/AM, turf/current_turf, turf/target_turf, obj_damage=0, phase=TRUE, teleport_channel=TELEPORT_CHANNEL_BLINK, datum/callback/on_turf_cross=null)
	// current loc
	if(!istype(current_turf) || is_away_level(current_turf.z) || is_centcom_level(current_turf.z))
		return

	// getline path
	var/turf/landing_turf = current_turf
	var/list/path = getline(current_turf, target_turf)
	path -= current_turf
	// iterate
	for (var/turf/checked_turf in path)
		// Step forward

		// Check if we can move here
		if(!check_teleport(AM, checked_turf, channel = teleport_channel))//If turf was not found or they're on z level 2 or >7 which does not currently exist. or if AM is not located on a turf
			break // stop moving forward
		// If it contains objects, try to break it
		if (obj_damage > 0) // should skip this if not needed
			for (var/obj/object in checked_turf.contents)
				if (object.density)
					object.take_damage(obj_damage)
		// check if we should stop due to obstacles
		if (!phase && checked_turf.is_blocked_turf(TRUE))
			break // stop moving forward
		// call on_turf_cross(checked_turf)
		if (on_turf_cross) // optional callback should be optional
			if (!on_turf_cross.Invoke(checked_turf))
				break // stop moving forward

		// increment our landing turf
		landing_turf = checked_turf

	do_teleport(AM, landing_turf, channel = teleport_channel)
	return landing_turf
