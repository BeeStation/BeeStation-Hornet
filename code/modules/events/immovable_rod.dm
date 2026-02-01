/*
Immovable rod random event.
The rod will spawn at some location outside the station, and travel in a straight line to the opposite side of the station
Everything solid in the way will be ex_act()'d
In my current plan for it, 'solid' will be defined as anything with density == 1

--NEOFite
*/

/datum/round_event_control/immovable_rod
	name = "Immovable Rod"
	typepath = /datum/round_event/immovable_rod
	min_players = 15
	max_occurrences = 5
	var/atom/special_target
	can_malf_fake_alert = TRUE


/datum/round_event_control/immovable_rod/admin_setup(mob/admin)
	if(!check_rights(R_FUN))
		return

	var/aimed = alert("Aimed at current location?","Sniperod", "Yes", "No")
	if(aimed == "Yes")
		special_target = get_turf(usr)

/datum/round_event/immovable_rod
	announceWhen = 5

/datum/round_event/immovable_rod/announce(fake)
	priority_announce("What the fuck was that?!", "General Alert", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/immovable_rod/start()
	var/datum/round_event_control/immovable_rod/C = control
	var/startside = pick(GLOB.cardinals)
	var/z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
	var/turf/startT = aimbotDebrisStartLoc(startside, z)
	var/turf/endT = aimbotDebrisFinishLoc(startside, z)
	var/atom/rod = new /obj/effect/immovablerod(startT, endT, C.special_target)
	announce_to_ghosts(rod)

/obj/effect/immovablerod
	name = "immovable rod"
	desc = "What the fuck is that?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	move_force = INFINITY
	move_resist = INFINITY
	pull_force = INFINITY
	density = TRUE
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	var/mob/living/wizard
	var/z_original = 0
	var/previous_distance = 1000
	var/destination
	var/notify = TRUE
	var/atom/special_target

/obj/effect/immovablerod/Initialize(mapload, atom/end, aimed_at)
	..()
	SSaugury.register_doom(src, 2000)
	z_original = get_virtual_z_level()
	destination = end
	special_target = aimed_at
	AddElement(/datum/element/point_of_interest)
	ADD_TRAIT(src, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT)

	var/special_target_valid = FALSE
	if(special_target)
		var/turf/T = get_turf(special_target)
		if(T.get_virtual_z_level() == z_original)
			special_target_valid = TRUE
	if(special_target_valid)
		destination = special_target
		SSmove_manager.home_onto(src, special_target)
		previous_distance = get_dist(src, special_target)
	else if(end && end.get_virtual_z_level() == z_original)
		SSmove_manager.home_onto(src, destination)
		previous_distance = get_dist(src, destination)

/obj/effect/immovablerod/Destroy()
	SSaugury.unregister_doom(src)
	. = ..()

/obj/effect/immovablerod/Topic(href, href_list)
	if(href_list["orbit"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.check_orbitable(src)

/obj/effect/immovablerod/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	if(!loc || QDELETED(src))
		return ..()
	//Moved more than 10 tiles in 1 move.
	var/cur_dist = get_dist(src, destination)
	if((get_virtual_z_level() != z_original) || (loc == destination) || (FLOOR(cur_dist - previous_distance, 1) > 10))
		qdel(src)
	previous_distance = cur_dist
	if(special_target && loc == get_turf(special_target))
		complete_trajectory()
	return ..()

/obj/effect/immovablerod/proc/complete_trajectory()
	//We hit what we wanted to hit, time to go
	special_target = null
	destination = get_edge_target_turf(src, dir)
	SSmove_manager.home_onto(src, destination)

/obj/effect/immovablerod/singularity_act()
	return

/obj/effect/immovablerod/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	return

/obj/effect/immovablerod/Bump(atom/clong)
	if(prob(10))
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		audible_message(span_danger("You hear a CLANG!"))

	if(clong && prob(25))
		x = clong.x
		y = clong.y

	if(special_target && clong == special_target)
		complete_trajectory()

	if(isturf(clong))
		if(clong.density)
			var/turf/hit_turf = clong
			hit_turf.take_damage(hit_turf.integrity, armour_penetration = 100)
	else if (isobj(clong))
		if(clong.density)
			var/obj/hit_obj = clong
			hit_obj.take_damage(hit_obj.get_integrity(), armour_penetration = 100)
	else if(isliving(clong))
		penetrate(clong)
	else if(istype(clong, type))
		var/obj/effect/immovablerod/other = clong
		visible_message(span_danger("[src] collides with [other]!"))
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(2, get_turf(src))
		smoke.start()
		qdel(src)
		qdel(other)

/obj/effect/immovablerod/Process_Spacemove()
	return TRUE

/obj/effect/immovablerod/proc/penetrate(mob/living/L)
	L.visible_message(span_danger("[L] is penetrated by an immovable rod!") , span_userdanger("The rod penetrates you!") , span_danger("You hear a CLANG!"))
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.adjustBruteLoss(160)
	if(L && (L.density || prob(10)))
		EX_ACT(L, EXPLODE_HEAVY)

/obj/effect/immovablerod/attack_hand(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		if(U.job in list(JOB_NAME_RESEARCHDIRECTOR))
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
			for(var/mob/M in urange(8, src))
				if(!M.stat)
					shake_camera(M, 2, 3)
			if(wizard)
				U.visible_message(span_boldwarning("[src] transforms into [wizard] as [U] suplexes them!"), span_warning("As you grab [src], it suddenly turns into [wizard] as you suplex them!"))
				to_chat(wizard, span_boldwarning("You're suddenly jolted out of rod-form as [U] somehow manages to grab you, slamming you into the ground!"))
				wizard.Stun(60)
				wizard.apply_damage(25, BRUTE)
				qdel(src)
			else
				U.client.give_award(/datum/award/achievement/misc/feat_of_strength, U) //rod-form wizards would probably make this a lot easier to get so keep it to regular rods only
				U.visible_message(span_boldwarning("[U] suplexes [src] into the ground!"), span_warning("You suplex [src] into the ground!"))
				new /obj/structure/festivus/anchored(drop_location())
				new /obj/effect/anomaly/flux(drop_location())
				qdel(src)
