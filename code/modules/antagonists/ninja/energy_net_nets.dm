/**
 * # Energy Net
 *
 * Energy net which ensnares prey until it is destroyed.  Used by space ninjas.
 *
 * Energy net which keeps its target from moving until it is destroyed.  Used to send
 * players to a holding area in which they could never leave, but such feature has since
 * been removed.
 */
/obj/structure/energy_net
	name = "energy net"
	desc = "It's a net made of green energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "energynet"
	density = TRUE //Can't pass through.
	anchored = TRUE //Can't drag/grab the net.
	layer = ABOVE_ALL_MOB_LAYER
	//plane = ABOVE_GAME_PLANE
	max_integrity = 60 //How much health it has.
	can_buckle = TRUE
	buckle_lying = 0
	buckle_prevents_pull = TRUE
	//Who it is currently affecting, if anyone.
	var/mob/living/carbon/affecting
	//Who shot web. Will let this person know if the net was successful or failed.
	var/mob/living/carbon/master
	// seconds before teleportation. Could be extended I guess.
	var/check = 12.5
	//Well, is it?
	var/success = FALSE

/obj/structure/energy_net/Initialize(mapload)
	. = ..()
	var/image/underlay = image(icon, "energynet_underlay")
	underlay.layer = BELOW_MOB_LAYER
	underlay.plane = GAME_PLANE
	add_overlay(underlay)
	START_PROCESSING(SSobj, src)

/obj/structure/energy_net/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/energy_net/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BRUTE || damage_type == BURN)
		playsound(src, 'sound/weapons/slash.ogg', 80, TRUE)

/obj/structure/energy_net/atom_destruction(damage_flag)
	if(!success)
		if(!QDELETED(affecting))
			affecting.visible_message(span_notice("[affecting] is recovered from the energy net!"), span_notice("You are recovered from the energy net!"), span_hear("You hear a grunt."))
		if(!QDELETED(master))//As long as they still exist.
			to_chat(master, "<span class='userdanger'>ERROR</span>: unable to initiate transport protocol. Procedure terminated.")
	return ..()

/obj/structure/energy_net/process(delta_time)
	if(check > 0)
		check -= delta_time
		return

	success = TRUE
	qdel(src)
	if(ishuman(affecting))
		var/mob/living/carbon/human/affected_human = affecting
		var/list/target_contents = affected_human.get_equipped_items(INCLUDE_POCKETS) + affected_human.held_items
		for(var/obj/item/item in target_contents)
			if(item == affected_human.w_uniform || item == affected_human.shoes)
				ADD_TRAIT(item, TRAIT_NODROP, NINJA_KIDNAPPED_TRAIT)
				for (var/obj/item/subitem in item)
					affected_human.dropItemToGround(subitem)
				continue //So all they're left with are shoes and uniform.
			affected_human.dropItemToGround(item)

		// After we remove items, at least give them what they need to live.
		affected_human.dna.species.give_important_for_life(affected_human)

	playsound(affecting, 'sound/effects/sparks4.ogg', 50, 1)
	new /obj/effect/temp_visual/dir_setting/ninja/phase/out(affecting.drop_location(), affecting.dir)

	visible_message("[affecting] suddenly vanishes!")
	affecting.forceMove(pick(GLOB.holdingfacility)) //Throw mob in to the holding facility.
	to_chat(affecting, span_danger("You appear in a strange place!"))
	to_chat(affecting, span_hypnotext("You have been captured by a ninja! The portal that brought you here will collapse in 5 minutes and return you to the station."))

	if(!QDELETED(master))//As long as they still exist.
		to_chat(master, span_notice("<b>SUCCESS</b>: transport procedure of [affecting] complete."))
		// Give them a point towards their objective
		for (var/datum/antagonist/antag in master.mind?.antag_datums)
			for (var/datum/objective/capture/capture in antag.objectives)
				capture.register_capture(affecting)
	do_sparks(5, FALSE, affecting)
	playsound(affecting, 'sound/effects/phasein.ogg', 25, 1)
	playsound(affecting, 'sound/effects/sparks2.ogg', 50, 1)
	new /obj/effect/temp_visual/dir_setting/ninja/phase(affecting.drop_location(), affecting.dir)
	// Return the mob to the station after 5 minutes in prison
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(force_teleport_to_safe_location), affecting), 5 MINUTES)

/proc/force_teleport_to_safe_location(mob/living/target)
	// If you get gibbed or deleted, your soul will be trapped forever
	if (QDELETED(target))
		return
	// Drop any items acquired from the location
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		var/list/target_contents = target_human.get_equipped_items(INCLUDE_POCKETS) + target_human.held_items
		for(var/obj/item/item in target_contents)
			if(item == target_human.w_uniform || item == target_human.shoes)
				REMOVE_TRAIT(item, TRAIT_NODROP, NINJA_KIDNAPPED_TRAIT)
				// So no cheeky buggers can store stuff in their boots to bring it back
				for (var/obj/item/subitem in item)
					target_human.dropItemToGround(subitem)
				continue //So all they're left with are shoes and uniform.
			target_human.dropItemToGround(item)

		// After we remove items, at least give them what they need to live.
		target_human.dna.species.give_important_for_life(target_human)
	// Teleport
	var/turf/picked_station_level = get_random_station_turf()	//Don't want to limit this specifically to z 2 in case we get multi-z in rotation
	var/turf/safe_location = find_safe_turf(picked_station_level.z, extended_safety_checks = TRUE, dense_atoms = FALSE)
	do_teleport(target, safe_location, channel = TELEPORT_CHANNEL_FREE, bypass_area_restriction = TRUE)
	target.Unconscious(3 SECONDS)

/obj/structure/energy_net/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/energy_net/user_buckle_mob(mob/living/buckled_mob, mob/user, check_loc = TRUE)
	return//We only want our target to be buckled

/obj/structure/energy_net/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	return//The net must be destroyed to free the target
