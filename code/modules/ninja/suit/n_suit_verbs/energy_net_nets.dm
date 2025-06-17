/*
It will teleport people to a holding facility after 30 seconds. (Check the process() proc to change where teleport goes)
It is possible to destroy the net by the occupant or someone else.
*/

/obj/structure/energy_net
	name = "energy net"
	desc = "It's a net made of green energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "energynet"

	density = TRUE//Can't pass through.
	opacity = FALSE//Can see through.
	mouse_opacity = MOUSE_OPACITY_ICON//So you can hit it with stuff.
	anchored = TRUE//Can't drag/grab the net.
	layer = ABOVE_ALL_MOB_LAYER
	max_integrity = 25 //How much health it has.
	can_buckle = 1
	buckle_lying = 0
	buckle_prevents_pull = TRUE
	var/mob/living/carbon/affecting //Who it is currently affecting, if anyone.
	var/mob/living/carbon/master //Who shot web. Will let this person know if the net was successful or failed.
	var/check = 30 // seconds before teleportation. Could be extended I guess.
	var/success = FALSE


/obj/structure/energy_net/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/weapons/slash.ogg', 80, 1)
		if(BURN)
			playsound(src, 'sound/weapons/slash.ogg', 80, 1)

/obj/structure/energy_net/Destroy()
	if(!success)
		if(!QDELETED(affecting))
			affecting.visible_message("[affecting.name] was recovered from the energy net!", "You were recovered from the energy net!", span_italics("You hear a grunt."))
		if(!QDELETED(master))//As long as they still exist.
			to_chat(master, "[span_userdanger("ERROR")]: unable to initiate transport protocol. Procedure terminated.")
	return ..()

/obj/structure/energy_net/process(delta_time)
	if(QDELETED(affecting)||affecting.loc!=loc)
		qdel(src)//Get rid of the net.
		return

	if(check > 0)
		check -= delta_time
		return

	success = TRUE
	qdel(src)
	if(ishuman(affecting))
		var/mob/living/carbon/human/H = affecting
		for(var/obj/item/W in H)
			if(W == H.w_uniform)
				ADD_TRAIT(W, TRAIT_NODROP, NINJA_KIDNAPPED_TRAIT)
				for (var/obj/item/subitem in W)
					H.dropItemToGround(subitem)
				continue//So all they're left with are shoes and uniform.
			if(W == H.shoes)
				ADD_TRAIT(W, TRAIT_NODROP, NINJA_KIDNAPPED_TRAIT)
				for (var/obj/item/subitem in W)
					H.dropItemToGround(subitem)
				continue
			H.dropItemToGround(W)

		// After we remove items, at least give them what they need to live.
		H.dna.species.give_important_for_life(H)

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
		var/mob/living/carbon/human/H = target
		for(var/obj/item/W in H)
			if(W == H.w_uniform)
				REMOVE_TRAIT(W, TRAIT_NODROP, NINJA_KIDNAPPED_TRAIT)
				// So no cheeky buggers can store stuff in their boots to bring it back
				for (var/obj/item/subitem in W)
					H.dropItemToGround(subitem)
				continue//So all they're left with are shoes and uniform.
			if(W == H.shoes)
				REMOVE_TRAIT(W, TRAIT_NODROP, NINJA_KIDNAPPED_TRAIT)
				for (var/obj/item/subitem in W)
					H.dropItemToGround(subitem)
				continue
			H.dropItemToGround(W)
		// After we remove items, at least give them what they need to live.
		H.dna.species.give_important_for_life(H)
	// Teleport
	var/turf/picked_station_level = get_random_station_turf()	//Don't want to limit this specifically to z 2 in case we get multi-z in rotation
	var/turf/safe_location = find_safe_turf(picked_station_level.z, extended_safety_checks = TRUE, dense_atoms = FALSE)
	do_teleport(target, safe_location, channel = TELEPORT_CHANNEL_FREE, bypass_area_restriction = TRUE)
	target.Unconscious(3 SECONDS)

/obj/structure/energy_net/attack_paw(mob/user)
	return attack_hand()

/obj/structure/energy_net/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	return//We only want our target to be buckled

/obj/structure/energy_net/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	return//The net must be destroyed to free the target
