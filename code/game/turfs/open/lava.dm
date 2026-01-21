///LAVA

/turf/open/lava
	name = "lava"
	desc = "Looks painful to step in. Don't mine down."
	icon_state = "lava"
	gender = PLURAL //"That's some lava."
	baseturfs = /turf/open/lava //lava all the way down
	slowdown = 2
	resistance_flags = INDESTRUCTIBLE

	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA
	bullet_bounce_sound = 'sound/items/welder2.ogg'

	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA
	/// How much fire damage we deal to living mobs stepping on us
	var/lava_damage = 20
	/// How many firestacks we add to living mobs stepping on us
	var/lava_firestacks = 20
	/// How much temperature we expose objects with
	var/temperature_damage = 10000
	/// mobs with this trait won't burn.
	var/immunity_trait = TRAIT_LAVA_IMMUNE
	/// objects with these flags won't burn.
	var/immunity_resistance_flags = LAVA_PROOF
	/// the temperature that this turf will attempt to heat/cool gasses too in a heat exchanger, in kelvin
	var/lava_temperature = 5000
	/// Lazy list of atoms that we've checked that can/cannot burn
	var/list/checked_atoms = null

/turf/open/lava/Destroy()
	checked_atoms = null
	for(var/mob/living/leaving_mob in contents)
		leaving_mob.RemoveElement(/datum/element/perma_fire_overlay)
		REMOVE_TRAIT(leaving_mob, TRAIT_NO_EXTINGUISH, TURF_TRAIT)
	return ..()

/turf/open/lava/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/lava/Melt()
	to_be_destroyed = FALSE
	return src

/turf/open/lava/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/open/lava/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(burn_stuff(arrived))
		START_PROCESSING(SSobj, src)

/turf/open/lava/Exited(atom/movable/gone, direction)
	. = ..()
	if(isliving(gone) && !islava(gone.loc))
		gone.RemoveElement(/datum/element/perma_fire_overlay)
		REMOVE_TRAIT(gone, TRAIT_NO_EXTINGUISH, TURF_TRAIT)

/turf/open/lava/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(burn_stuff(AM))
		START_PROCESSING(SSobj, src)

/turf/open/lava/process(seconds_per_tick)
	if(!burn_stuff(null, seconds_per_tick))
		checked_atoms = null
		return PROCESS_KILL

/turf/open/lava/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_FLOORWALL)
		return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 3)
	return FALSE

/turf/open/lava/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_FLOORWALL)
		to_chat(user, span_notice("You build a floor."))
		log_attack("[key_name(user)] has constructed a floor over lava at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
		PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return FALSE

/turf/open/lava/rust_heretic_act()
	return FALSE

/turf/open/lava/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	return

/turf/open/lava/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/lava/get_heat_capacity()
	. = 700000

/turf/open/lava/get_temperature()
	. = lava_temperature

/turf/open/lava/take_temperature(temp)

/turf/open/lava/proc/is_safe()
	//if anything matching this typecache is found in the lava, we don't burn things
	var/static/list/lava_safeties_typecache = typecacheof(list(
		/obj/structure/lattice/catwalk,
		/obj/structure/stone_tile,
	))
	var/list/found_safeties = typecache_filter_list(contents, lava_safeties_typecache)
	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)


///Generic return value of the can_burn_stuff() proc. Does nothing.
#define LAVA_BE_IGNORING 0
/// Another. Won't burn the target but will make the turf start processing.
#define LAVA_BE_PROCESSING 1
/// Burns the target and makes the turf process (depending on the return value of do_burn()).
#define LAVA_BE_BURNING 2

///Proc that sets on fire something or everything on the turf that's not immune to lava. Returns TRUE to make the turf start processing.
/turf/open/lava/proc/burn_stuff(atom/movable/to_burn, seconds_per_tick = 1)
	if(is_safe())
		return FALSE

	LAZYSETLEN(checked_atoms, 0)
	var/thing_to_check = src
	if (to_burn)
		thing_to_check = list(to_burn)
	for(var/atom/movable/burn_target as anything in thing_to_check)
		switch(cache_burn_check(burn_target))
			if(LAVA_BE_IGNORING)
				continue
			if(LAVA_BE_BURNING)
				if(!do_burn(burn_target, seconds_per_tick))
					continue
		. = TRUE

/// Wrapper for can_burn_stuff that checks if something can be burnt and caches the result
/turf/open/lava/proc/cache_burn_check(atom/movable/burn_target)
	var/check_result = checked_atoms[burn_target.weak_reference]
	if(isnull(check_result))
		check_result = can_burn_stuff(burn_target)
		checked_atoms[WEAKREF(burn_target)] = check_result
	return check_result

/turf/open/lava/proc/can_burn_stuff(atom/movable/burn_target)
	if(QDELETED(burn_target))
		return LAVA_BE_IGNORING
	if((burn_target.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || burn_target.throwing || !burn_target.has_gravity()) //you're flying over it.
		return LAVA_BE_IGNORING
	if(isobj(burn_target))
		var/obj/burn_obj = burn_target
		if((burn_obj.resistance_flags & immunity_resistance_flags))
			return LAVA_BE_PROCESSING
		return LAVA_BE_BURNING

	if (!isliving(burn_target))
		return LAVA_BE_IGNORING

	if(HAS_TRAIT(burn_target, immunity_trait))
		return LAVA_BE_PROCESSING

	var/mob/living/burn_living = burn_target
	var/atom/movable/burn_buckled = burn_living.buckled
	if(burn_buckled && cache_burn_check(burn_buckled) != LAVA_BE_BURNING)
		return LAVA_BE_PROCESSING

	if(iscarbon(burn_living))
		var/mob/living/carbon/burn_carbon = burn_living
		var/obj/item/clothing/burn_suit = burn_carbon.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		var/obj/item/clothing/burn_helmet = burn_carbon.get_item_by_slot(ITEM_SLOT_HEAD)
		if(burn_suit?.clothing_flags & LAVAPROTECT && burn_helmet?.clothing_flags & LAVAPROTECT)
			return LAVA_BE_PROCESSING

	return LAVA_BE_BURNING

#undef LAVA_BE_IGNORING
#undef LAVA_BE_PROCESSING
#undef LAVA_BE_BURNING

/turf/open/lava/proc/do_burn(atom/movable/burn_target, seconds_per_tick = 1)
	if(QDELETED(burn_target))
		return FALSE

	if(isobj(burn_target))
		var/obj/burn_obj = burn_target
		if(burn_obj.resistance_flags & ON_FIRE) // already on fire; skip it.
			return TRUE
		if(!(burn_obj.resistance_flags & FLAMMABLE))
			burn_obj.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
		if(burn_obj.resistance_flags & FIRE_PROOF)
			burn_obj.resistance_flags &= ~FIRE_PROOF
		if(burn_obj.get_armor_rating(FIRE) > 50) //obj with 100% fire armor still get slowly burned away.
			burn_obj.set_armor_rating(FIRE, 50)
		burn_obj.fire_act(temperature_damage, 1000 * seconds_per_tick)
		if(istype(burn_obj, /obj/structure/closet))
			for(var/burn_content in burn_target)
				burn_stuff(burn_content)
		return TRUE

	if(isliving(burn_target))
		var/mob/living/burn_living = burn_target
		if(!HAS_TRAIT_FROM(burn_living, TRAIT_NO_EXTINGUISH, TURF_TRAIT))
			burn_living.AddElement(/datum/element/perma_fire_overlay)
			ADD_TRAIT(burn_living, TRAIT_NO_EXTINGUISH, TURF_TRAIT)
		burn_living.adjust_fire_stacks(lava_firestacks * seconds_per_tick)
		burn_living.ignite_mob()
		burn_living.adjustFireLoss(lava_damage * seconds_per_tick)
		return TRUE

	return FALSE

/turf/open/lava/airless
	initial_gas_mix = AIRLESS_ATMOS


/turf/open/lava/can_cross_safely(atom/movable/crossing)
	return /*HAS_TRAIT(src, TRAIT_LAVA_STOPPED) || HAS_TRAIT(crossing, immunity_trait ) ||*/ HAS_TRAIT(crossing, TRAIT_MOVE_FLYING)

/turf/open/lava/smooth
	name = "lava"
	baseturfs = /turf/open/lava/smooth
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "lava-255"
	base_icon_state = "lava"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_LAVA)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_LAVA)

/turf/open/lava/smooth/echo
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	luminosity = 2
	light_range = 5
	light_color = "#ff5100"

/turf/open/lava/smooth/cold
	initial_gas_mix = FROZEN_ATMOS

/turf/open/lava/smooth/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface

/turf/open/lava/smooth/airless
	initial_gas_mix = AIRLESS_ATMOS
