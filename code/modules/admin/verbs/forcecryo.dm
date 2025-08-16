/proc/force_cryo_ckey(target_ckey, instant = FALSE)
	var/mob/living/target = get_ckey_last_living(target_ckey, healthy = TRUE)
	if(!target)
		return
	var/method = instant ? GLOBAL_PROC_REF(instant_force_cryo) : GLOBAL_PROC_REF(force_cryo)
	INVOKE_ASYNC(GLOBAL_PROC, method, target)

/proc/force_cryo(mob/living/target)
	if(!istype(target))
		return
	var/obj/machinery/cryopod/pod_loc = target.loc
	if(istype(pod_loc) && pod_loc.occupant == target)
		pod_loc.despawn_occupant()
		return
	var/turf/target_turf = get_turf(target)
	target.ghostize(can_reenter_corpse = FALSE)
	// unbuckle them from everything and release them from any pulls
	target.unbuckle_all_mobs(force = TRUE)
	target.stop_pulling()
	target.pulledby?.stop_pulling()
	target.buckled?.unbuckle_mob(target, force = TRUE)
	// ensure that they don't move / get moved and cause any weirdness
	target.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	target.Stun(INFINITY, ignore_canstun = TRUE)
	target.move_resist = INFINITY
	target.set_anchored(TRUE)
	ADD_TRAIT(target, TRAIT_GODMODE, TRAIT_GENERIC)
	// ensure they're on a turf
	target.forceMove(target_turf)
	// send a fancy centcom pod, so nobody ICly questions this
	var/obj/structure/closet/supplypod/force_cryo/cryo_express = new
	cryo_express.target = target
	new /obj/effect/pod_landingzone(target_turf, cryo_express)

/proc/instant_force_cryo(mob/living/target)
	if(!istype(target))
		return
	// unbuckle them from everything, and release them from any pulls
	target.pulledby?.stop_pulling()
	target.buckled?.unbuckle_mob(target, force = TRUE)
	for(var/obj/machinery/cryopod/pod in GLOB.machines)
		if(!is_station_level(pod.z) || !QDELETED(pod.occupant) || pod.panel_open)
			continue
		pod.close_machine(target)
		pod.despawn_occupant()
		return
	message_admins(span_danger("Failed to force-cryo [ADMIN_LOOKUPFLW(target)] (no valid cryopods)"))
	log_admin("Failed to force-cryo [key_name(target)] (no valid cryopods)")

/obj/structure/closet/supplypod/force_cryo
	name = "\improper CentCom employee retrieval pod"
	desc = "A pod used by Central Command to retrieve certain employees from the station for long-term cryogenic storage."
	style = STYLE_CENTCOM
	bluespace = TRUE
	reversing = TRUE
	specialised = TRUE
	explosionSize = list(0, 0, 0, 0)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	reverse_delays = list(POD_TRANSIT = 0.5 SECONDS, POD_FALLING = 0.5 SECONDS, POD_OPENING = 0.5 SECONDS, POD_LEAVING = 1.5 SECONDS)
	var/mob/living/target

/obj/structure/closet/supplypod/force_cryo/insert(mob/living/to_insert, atom/movable/holder)
	if(!insertion_allowed(to_insert))
		return FALSE
	// make SURE they aren't buckled or being pulled.
	to_insert.pulledby?.stop_pulling()
	to_insert.buckled?.unbuckle_mob(target, force = TRUE)
	to_insert.forceMove(holder)
	return TRUE

/obj/structure/closet/supplypod/force_cryo/insertion_allowed(atom/to_insert)
	return to_insert == target

/obj/structure/closet/supplypod/force_cryo/preOpen()
	// if we're going back to centcom, now we just cryo them
	if(!reversing && !QDELETED(target))
		target.moveToNullspace()
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(instant_force_cryo), target)
		qdel(src)
		return
	return ..()
