/// Anything above a lattice should go here.
/turf/open/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	base_icon_state = "floor"
	baseturfs = /turf/open/floor/plating
	max_integrity = 250

	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)

	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)

	thermal_conductivity = 0.02
	heat_capacity = 20000
	tiled_dirt = TRUE

	overfloor_placed = TRUE

	var/icon_plating = "plating"
	/// Path of the tile that this floor drops
	var/floor_tile = null

	/// Number of variant states
	var/variant_states = 0
	/// Probability of a variant occuring
	var/variant_probability = 0

/turf/open/floor/Initialize(mapload)
	. = ..()

	if (variant_probability && prob(variant_probability))
		icon_state = "[icon_state][rand(1, variant_states)]"

	if(mapload && prob(33))
		MakeDirty()

	if(is_station_level(z))
		GLOB.station_turfs += src

/turf/open/floor/Destroy()
	if(is_station_level(z))
		GLOB.station_turfs -= src
	return ..()

/turf/open/floor/is_shielded()
	for(var/obj/structure/A in contents)
		return 1

/turf/open/floor/update_icon()
	. = ..()
	update_visuals()

/turf/open/floor/attack_paw(mob/user)
	return attack_hand(user)

/turf/open/floor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user, modifiers)

/turf/open/floor/after_damage(damage_amount, damage_type, damage_flag)
	if (broken || burnt)
		return
	if (damage_flag == BURN)
		if (integrity < max_integrity * 0.5)
			burn_tile()
	else
		if (integrity < max_integrity * 0.5)
			break_tile()

/turf/open/floor/proc/break_tile_to_plating()
	var/turf/open/floor/plating/T = make_plating()
	if(!istype(T))
		return
	T.break_tile()

/// Things seem to rely on this actually returning plating. Override it if you have other baseturfs.
/turf/open/floor/proc/make_plating()
	//Remove previous damage overlays
	for(var/i in damage_overlays)
		remove_filter(i)
		damage_overlays -= i
	return ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

///For when the floor is placed under heavy load. Calls break_tile(), but exists to be overridden by floor types that should resist crushing force.
/turf/open/floor/proc/crush()
	break_tile()

/turf/open/floor/ChangeTurf(path, new_baseturf, flags)
	if(!isfloorturf(src))
		return ..() //fucking turfs switch the fucking src of the fucking running procs
	if(!ispath(path, /turf/open/floor))
		return ..()
	var/old_dir = dir
	var/turf/open/floor/W = ..()
	if (flags & CHANGETURF_SKIP)
		dir = old_dir
		return W
	W.setDir(old_dir)
	W.update_appearance()
	return W

/turf/open/floor/attackby(obj/item/object, mob/living/user, params)
	if(!object || !user)
		return TRUE
	if(..())
		return 1
	if(overfloor_placed && istype(object, /obj/item/stack/tile))
		try_replace_tile(object, user, params)
	return FALSE

/turf/open/floor/crowbar_act(mob/living/user, obj/item/I)
	if(overfloor_placed && pry_tile(I, user))
		return TRUE

/turf/open/floor/proc/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type && T.turf_dir == dir)
		return
	var/obj/item/CB = user.is_holding_tool_quality(TOOL_CROWBAR)
	if(!CB)
		return
	var/turf/open/floor/plating/P = pry_tile(CB, user, TRUE)
	if(!istype(P))
		return
	P.attackby(T, user, params)

/turf/open/floor/proc/pry_tile(obj/item/I, mob/user, silent = FALSE)
	I.play_tool_sound(src, 80)
	return remove_tile(user, silent)

/turf/open/floor/proc/remove_tile(mob/user, silent = FALSE, make_tile = TRUE)
	if(broken || burnt)
		broken = 0
		burnt = 0
		if(user && !silent)
			to_chat(user, span_notice("You remove the broken plating."))
	else
		if(user && !silent)
			to_chat(user, span_notice("You remove the floor tile."))
		if(floor_tile && make_tile)
			spawn_tile()
	return make_plating()

/turf/open/floor/proc/has_tile()
	return floor_tile

/turf/open/floor/proc/spawn_tile()
	if(!has_tile())
		return null
	return new floor_tile(src)

/turf/open/floor/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	..()
	var/sheer = FALSE
	switch(current_size)
		if(STAGE_THREE)
			if(prob(30))
				sheer = TRUE
		if(STAGE_FOUR)
			if(prob(50))
				sheer = TRUE
		if(STAGE_FIVE to INFINITY)
			if(floor_tile)
				if(prob(70))
					sheer = TRUE
			else if(prob(50) && (/turf/open/space in baseturfs))
				ReplaceWithLattice()
	if(sheer)
		if(has_tile())
			remove_tile(null, TRUE, TRUE, TRUE)

/turf/open/floor/narsie_act(force, ignore_mobs, probability = 20)
	. = ..()
	if(.)
		ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/ratvar_act(force, ignore_mobs)
	. = ..()
	if(.)
		ChangeTurf(/turf/open/floor/clockwork, flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/acid_melt()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			var/obj/structure/girder/girder = locate() in src
			if(girder)
				return girder.rcd_vals(user, the_rcd)
			return rcd_result_with_memory(
				list("mode" = RCD_FLOORWALL, "delay" = 2 SECONDS, "cost" = 16),
				src, RCD_MEMORY_WALL,
			)
		if(RCD_LADDER)
			return list("mode" = RCD_LADDER, "delay" = 25, "cost" = 16)
		if(RCD_AIRLOCK)
			if(the_rcd.airlock_glass)
				return list("mode" = RCD_AIRLOCK, "delay" = 50, "cost" = 20)
			else
				return list("mode" = RCD_AIRLOCK, "delay" = 50, "cost" = 16)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 33)
		if(RCD_WINDOWGRILLE)
			return rcd_result_with_memory(
				list("mode" = RCD_WINDOWGRILLE, "delay" = 1 SECONDS, "cost" = 4),
				src, RCD_MEMORY_WINDOWGRILLE,
			)
		if(RCD_MACHINE)
			return list("mode" = RCD_MACHINE, "delay" = 20, "cost" = 25)
		if(RCD_COMPUTER)
			return list("mode" = RCD_COMPUTER, "delay" = 20, "cost" = 25)
		if(RCD_FURNISHING)
			return list("mode" = RCD_FURNISHING, "delay" = the_rcd.furnish_delay, "cost" = the_rcd.furnish_cost)
	return FALSE

/turf/open/floor/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			var/obj/structure/girder/girder = locate() in src
			if(girder)
				return girder.rcd_act(user, the_rcd, passed_mode)
			to_chat(user, span_notice("You build a wall."))
			log_attack("[key_name(user)] has constructed a wall at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
			var/overlapping_lattice = locate(/obj/structure/lattice) in get_turf(src)
			if(overlapping_lattice)
				qdel(overlapping_lattice) // Don't need lattice burried under the wall, or in the case of catwalk - on top of it.
			PlaceOnTop(/turf/closed/wall)
			return TRUE
		if(RCD_LADDER)
			to_chat(user, span_notice("You build a ladder."))
			var/obj/structure/ladder/L = new(src)
			L.set_anchored(TRUE)
			return TRUE
		if(RCD_AIRLOCK)
			for(var/obj/machinery/door/door in src)
				if(door.sub_door)
					continue
				to_chat(user, span_notice("There is another door here!"))
				return FALSE
			if(ispath(the_rcd.airlock_type, /obj/machinery/door/window))
				to_chat(user, span_notice("You build a windoor."))
				var/obj/machinery/door/window/new_window = new the_rcd.airlock_type(src, user.dir, the_rcd.airlock_electronics?.unres_sides)
				if(the_rcd.airlock_electronics)
					new_window.name = the_rcd.airlock_electronics.passed_name || initial(new_window.name)
					if(the_rcd.airlock_electronics.one_access)
						new_window.req_one_access = the_rcd.airlock_electronics.accesses.Copy()
					else
						new_window.req_access = the_rcd.airlock_electronics.accesses.Copy()
				new_window.autoclose = TRUE
				new_window.update_icon()
				return TRUE
			to_chat(user, span_notice("You build an airlock."))
			log_attack("[key_name(user)] has constructed an airlock at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
			var/obj/machinery/door/airlock/new_airlock = new the_rcd.airlock_type(src)
			new_airlock.electronics = new /obj/item/electronics/airlock(new_airlock)
			if(the_rcd.airlock_electronics)
				new_airlock.electronics.accesses = the_rcd.airlock_electronics.accesses.Copy()
				new_airlock.electronics.one_access = the_rcd.airlock_electronics.one_access
				new_airlock.electronics.unres_sides = the_rcd.airlock_electronics.unres_sides
				new_airlock.electronics.passed_name = the_rcd.airlock_electronics.passed_name
				new_airlock.electronics.passed_cycle_id = the_rcd.airlock_electronics.passed_cycle_id
			if(new_airlock.electronics.one_access)
				new_airlock.req_one_access = new_airlock.electronics.accesses
			else
				new_airlock.req_access = new_airlock.electronics.accesses
			if(new_airlock.electronics.unres_sides)
				new_airlock.unres_sides = new_airlock.electronics.unres_sides
			if(new_airlock.electronics.passed_name)
				new_airlock.name = new_airlock.electronics.passed_name
			if(new_airlock.electronics.passed_cycle_id)
				new_airlock.closeOtherId = new_airlock.electronics.passed_cycle_id
				new_airlock.update_other_id()
			new_airlock.autoclose = TRUE
			new_airlock.update_appearance()
			return TRUE
		if(RCD_DECONSTRUCT)
			var/previous_turf = initial(name)
			if(!ScrapeAway(flags = CHANGETURF_INHERIT_AIR))
				return FALSE
			to_chat(user, span_notice("You deconstruct [previous_turf]."))
			log_attack("[key_name(user)] has deconstructed [previous_turf] at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
			return TRUE
		if(RCD_WINDOWGRILLE)
			if(locate(/obj/structure/grille) in src)
				return FALSE
			to_chat(user, span_notice("You construct the grille."))
			log_attack("[key_name(user)] has constructed a grille at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
			var/obj/structure/grille/new_grille = new(src)
			new_grille.set_anchored(TRUE)
			return TRUE
		if(RCD_MACHINE)
			if(locate(/obj/structure/frame/machine) in src)
				return FALSE
			var/obj/structure/frame/machine/new_machine = new(src)
			new_machine.state = 2
			new_machine.icon_state = "box_1"
			new_machine.set_anchored(TRUE)
			return TRUE
		if(RCD_COMPUTER)
			if(locate(/obj/structure/frame/computer) in src)
				return FALSE
			var/obj/structure/frame/computer/new_computer = new(src)
			new_computer.set_anchored(TRUE)
			new_computer.state = 1
			new_computer.setDir(the_rcd.computer_dir)
			return TRUE
		if(RCD_FURNISHING)
			if(locate(the_rcd.furnish_type) in src)
				return FALSE
			var/atom/new_furnish = new the_rcd.furnish_type(src)
			new_furnish.setDir(user.dir)
			return TRUE

	return FALSE

/turf/open/floor/material
	name = "floor"
	icon_state = "materialfloor"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	floor_tile = /obj/item/stack/tile/material

/turf/open/floor/material/has_tile()
	return LAZYLEN(custom_materials)

/turf/open/floor/material/spawn_tile()
	. = ..()
	if(.)
		var/obj/item/stack/tile = .
		tile.set_mats_per_unit(custom_materials, 1)
