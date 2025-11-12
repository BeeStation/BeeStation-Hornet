/* Alien shit!
 * Contains:
 *		structure/alien
 *		Resin
 *		Weeds
 *		Egg
 */


/obj/structure/alien
	icon = 'icons/mob/alien.dmi'
	max_integrity = 100

/obj/structure/alien/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BRUTE)
				damage_amount *= 0.25
			if(BURN)
				damage_amount *= 2
	. = ..()

/obj/structure/alien/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', 100, 1)

/*
 * Generic alien stuff, not related to the purple lizards but still alien-like
 */

/obj/structure/alien/gelpod
	name = "gelatinous mound"
	desc = "A mound of jelly-like substance encasing something inside."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "gelmound"

/obj/structure/alien/gelpod/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new/obj/effect/mob_spawn/human/corpse/damaged(get_turf(src))
	qdel(src)

/*
 * Resin
 */
/obj/structure/alien/resin
	name = "resin"
	desc = "Looks like some kind of thick resin."
	icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi' //See code/modules/bitmask_smoothing/code for all code pertaining to new smooth objects
	icon_state = "resin_wall-0"
	base_icon_state = "resin_wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_RESIN)
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	max_integrity = 200
	var/resintype = null
	can_atmos_pass = ATMOS_PASS_DENSITY


/obj/structure/alien/resin/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE, TRUE)

/obj/structure/alien/resin/Destroy()
	air_update_turf(TRUE, FALSE)
	. = ..()

/obj/structure/alien/resin/Move()
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/alien/resin/wall
	name = "resin wall"
	desc = "Thick resin solidified into a wall."
	icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi' //See code/modules/bitmask_smoothing/code for all code pertaining to new smooth objects
	icon_state = "resin_wall-0" //same as resin, but consistency ho!
	base_icon_state = "resin_wall"
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN, SMOOTH_GROUP_ALIEN_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_WALLS)

/obj/structure/alien/resin/membrane
	name = "resin membrane"
	desc = "Resin just thin enough to let light pass through."
	icon = 'icons/obj/smooth_structures/alien/resin_membrane.dmi'
	icon_state = "resin_membrane-0"
	base_icon_state = "resin_membrane"
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN, SMOOTH_GROUP_ALIEN_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_WALLS)
	opacity = FALSE
	max_integrity = 160

/obj/structure/alien/resin/attack_paw(mob/user)
	return attack_hand(user)

/*
 * Weeds
 */

#define NODERANGE 3

/obj/structure/alien/weeds
	gender = PLURAL
	name = "resin floor"
	desc = "A thick resin surface covers the floor."
	anchored = TRUE
	density = FALSE
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	icon = MAP_SWITCH('icons/obj/smooth_structures/alien/weeds1.dmi', 'icons/mob/alien.dmi')
	icon_state = "weeds1-0"
	base_icon_state = "weeds"
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-4, -4), matrix())
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN, SMOOTH_GROUP_ALIEN_WEEDS)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_WEEDS)
	max_integrity = 15
	var/last_expand = 0 //last world.time this weed expanded
	var/growth_cooldown_low = 150
	var/growth_cooldown_high = 200
	var/static/list/blacklisted_turfs

#ifdef UNIT_TESTS //Used to make sure all results of randomizing the icon can be tested.

/obj/structure/alien/weeds/unit_test
	icon = 'icons/obj/smooth_structures/alien/weeds1.dmi'
	base_icon_state = "weeds1"
	icon_state = "weeds1-0"

/obj/structure/alien/weeds/unit_test_two
	icon = 'icons/obj/smooth_structures/alien/weeds2.dmi'
	base_icon_state = "weeds2"
	icon_state = "weeds2-0"

/obj/structure/alien/weeds/unit_test_three
	icon = 'icons/obj/smooth_structures/alien/weeds3.dmi'
	base_icon_state = "weeds3"
	icon_state = "weeds3-0"

#endif //UNIT_TESTS

/obj/structure/alien/weeds/Initialize(mapload)
	. = ..()

	if(!blacklisted_turfs)
		blacklisted_turfs = typecacheof(list(
			/turf/open/space,
			/turf/open/chasm,
			/turf/open/lava,
			/turf/open/openspace,
		))


	last_expand = world.time + rand(growth_cooldown_low, growth_cooldown_high)

	if(base_icon_state == "weeds")
		switch(rand(1,3))
			if(1)
				icon = 'icons/obj/smooth_structures/alien/weeds1.dmi'
				base_icon_state = "weeds1"
			if(2)
				icon = 'icons/obj/smooth_structures/alien/weeds2.dmi'
				base_icon_state = "weeds2"
			if(3)
				icon = 'icons/obj/smooth_structures/alien/weeds3.dmi'
				base_icon_state = "weeds3"

	AddElement(/datum/element/atmos_sensitive)

/obj/structure/alien/weeds/proc/expand()
	var/turf/U = get_turf(src)
	if(is_type_in_typecache(U, blacklisted_turfs))
		qdel(src)
		return FALSE

	for(var/turf/T in U.get_atmos_adjacent_turfs())
		if((locate(/obj/structure/alien/weeds) in T))
			continue

		if(is_type_in_typecache(T, blacklisted_turfs))
			continue

		new /obj/structure/alien/weeds(T)
	return TRUE

/obj/structure/alien/weeds/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/structure/alien/weeds/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0, 0)

//Weed nodes
/obj/structure/alien/weeds/node
	name = "glowing resin"
	desc = "Blue bioluminescence shines from beneath the surface."
	icon = MAP_SWITCH('icons/obj/smooth_structures/alien/weednode.dmi', 'icons/mob/alien.dmi')
	icon_state = "weednode-0"
	base_icon_state = "weednode"
	light_color = LIGHT_COLOR_BLUE
	light_power = 0.5
	var/lon_range = 4
	var/node_range = NODERANGE

/obj/structure/alien/weeds/node/Initialize(mapload)
	. = ..()
	set_light(lon_range)
	var/obj/structure/alien/weeds/W = locate(/obj/structure/alien/weeds) in loc
	if(W && W != src)
		qdel(W)
	START_PROCESSING(SSobj, src)

/obj/structure/alien/weeds/node/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/alien/weeds/node/process()
	for(var/obj/structure/alien/weeds/W in range(node_range, src))
		if(W.last_expand <= world.time)
			if(W.expand())
				W.last_expand = world.time + rand(growth_cooldown_low, growth_cooldown_high)

#undef NODERANGE


/*
 * Egg
 */

//for the status var
#define BURSTING "bursting"
#define BURST "burst"
#define GROWING "growing"
#define GROWN "grown"
#define MIN_GROWTH_TIME 900	//time it takes to grow a hugger
#define MAX_GROWTH_TIME 1500

/obj/structure/alien/egg
	name = "egg"
	desc = "A large mottled egg."
	var/base_icon = "egg"
	icon_state = "egg_growing"
	density = FALSE
	anchored = TRUE
	max_integrity = 100
	integrity_failure = 0.05
	var/status = GROWING	//can be GROWING, GROWN or BURST; all mutually exclusive
	layer = MOB_LAYER
	var/obj/item/clothing/mask/facehugger/child
	///Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor

/obj/structure/alien/egg/Initialize(mapload)
	. = ..()
	update_icon()
	if(status == GROWING || status == GROWN)
		child = new(src)
	if(status == GROWING)
		addtimer(CALLBACK(src, PROC_REF(Grow)), rand(MIN_GROWTH_TIME, MAX_GROWTH_TIME))
	proximity_monitor = new(src, status == GROWN ? 1 : 0)
	if(status == BURST)
		atom_integrity = integrity_failure * max_integrity
	AddElement(/datum/element/atmos_sensitive)

/obj/structure/alien/egg/update_icon()
	..()
	switch(status)
		if(GROWING)
			icon_state = "[base_icon]_growing"
		if(GROWN)
			icon_state = "[base_icon]"
		if(BURST)
			icon_state = "[base_icon]_hatched"

/obj/structure/alien/egg/attack_paw(mob/living/user)
	return attack_hand(user)

/obj/structure/alien/egg/attack_alien(mob/living/carbon/alien/user)
	return attack_hand(user)

/obj/structure/alien/egg/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.get_organ_by_type(/obj/item/organ/alien/plasmavessel))
		switch(status)
			if(BURSTING)
				to_chat(user, span_notice("The egg is in process of hatching."))
				return
			if(BURST)
				to_chat(user, span_notice("You clear the hatched egg."))
				playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
				qdel(src)
				return
			if(GROWING)
				to_chat(user, span_notice("The child is not developed yet."))
				return
			if(GROWN)
				to_chat(user, span_notice("You retrieve the child."))
				Burst(kill=FALSE)
				return
	else
		to_chat(user, span_notice("It feels slimy."))
		user.changeNext_move(CLICK_CD_MELEE)


/obj/structure/alien/egg/proc/Grow()
	status = GROWN
	update_icon()
	proximity_monitor.set_range(1)

//drops and kills the hugger if any is remaining
/obj/structure/alien/egg/proc/Burst(kill = TRUE)
	if(status == GROWN || status == GROWING)
		proximity_monitor.set_range(0)
		status = BURSTING
		update_icon()
		flick("egg_opening", src)
		addtimer(CALLBACK(src, PROC_REF(finish_bursting), kill), 15)

/obj/structure/alien/egg/proc/finish_bursting(kill = TRUE)
	status = BURST
	update_icon()
	if(child)
		child.forceMove(get_turf(src))
		// TECHNICALLY you could put non-facehuggers in the child var
		if(istype(child))
			if(kill)
				child.Die()
			else
				for(var/mob/living/carbon/C in ohearers(1,src))
					if(CanHug(C))
						child.Leap(C)
						break

/obj/structure/alien/egg/atom_break(damage_flag)
	. = ..()
	if(!(flags_1 & NODECONSTRUCT_1))
		if(status != BURST)
			Burst(kill=TRUE)

/obj/structure/alien/egg/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 500

/obj/structure/alien/egg/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0, 0)

/obj/structure/alien/egg/HasProximity(atom/movable/AM)
	if(status == GROWN)
		if(!CanHug(AM))
			return

		var/mob/living/carbon/C = AM
		if(C.stat == CONSCIOUS && C.get_organ_by_type(/obj/item/organ/body_egg/alien_embryo))
			return

		Burst(kill=FALSE)

/obj/structure/alien/egg/grown
	status = GROWN
	icon_state = "egg"

/obj/structure/alien/egg/burst
	status = BURST
	icon_state = "egg_hatched"

/obj/structure/alien/egg/troll

/obj/structure/alien/egg/troll/finish_bursting(kill = TRUE)
	qdel(child)
	new /obj/item/paper/troll(get_turf(src))

#undef BURSTING
#undef BURST
#undef GROWING
#undef GROWN
#undef MIN_GROWTH_TIME
#undef MAX_GROWTH_TIME
