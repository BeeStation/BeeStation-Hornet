/turf/open/floor
	//NOTE: Floor code has been refactored, many procs were removed and refactored
	//- you should use istype() if you want to find out whether a floor has a certain type
	//- floor_tile is now a path, and not a tile obj
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	base_icon_state = "floor"
	baseturfs = /turf/open/floor/plating
	max_integrity = 250

	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	thermal_conductivity = 0.04
	heat_capacity = 10000
	tiled_dirt = TRUE
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)

	overfloor_placed = TRUE

	var/icon_plating = "plating"
	var/broken = FALSE
	var/burnt = FALSE
	var/floor_tile = null //tile that this floor drops

	var/broken_icon = 'icons/turf/turf_damage.dmi'

	var/list/broken_states = list("damaged1")
	var/list/broken_dirt_states = list("damaged1")
	//Do we just swap the state to one of the damage states
	var/use_broken_literal = FALSE

	var/list/burnt_states = list("damaged1")
	//Do we just swap the state to one of the damage states
	var/use_burnt_literal = FALSE
	
	//Refs to overlays, for later removal
	var/list/damage_overlays = list()

	///The variant tiles we can choose from (name = chance, name = chance, name = chance)
	var/list/variants

/turf/open/floor/Initialize(mapload)

	if(broken)
		break_tile()
	if(burnt)
		burn_tile()
	
	. = ..()
	if(mapload && prob(33))
		MakeDirty()
	if(is_station_level(z))
		GLOB.station_turfs += src

	//Choose a variant
	if(variants)
		icon_state = pick_weight(variants)

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

/turf/open/floor/proc/break_tile()
	if(broken || use_broken_literal)
		if(use_broken_literal)
			icon_state = pick(broken_states)
		return
	var/damage_state
	if(length(broken_states))
		damage_state = pick(broken_states)
		//Pick a random mask for damage state
		var/icon/mask = icon(broken_icon, "broken_[damage_state]")
		//Build under-turf icon
		var/turf/base = pick(baseturfs - list(/turf/baseturf_bottom))
		var/icon/under_turf = icon(initial(base.icon), initial(base.icon_state))
		//Mask under turf by damage state
		under_turf.UseAlphaMask(mask)
		//Convert to MA so we can layer stuff better
		var/mutable_appearance/MA = new()
		MA.appearance = under_turf
		MA.layer = layer+0.1
		add_overlay(MA)
		damage_overlays += MA
	//Add some dirt 'n shit
	if(length(broken_dirt_states) && damage_state)
		var/mutable_appearance/dirt = mutable_appearance(broken_icon, "dirt_[damage_state]")
		add_overlay(dirt)
		damage_overlays += dirt

	broken = TRUE

/turf/open/floor/burn_tile()
	if(burnt || use_burnt_literal)
		if(use_burnt_literal)
			icon_state = pick(burnt_states)
		return
	if(length(burnt_states))
		var/burnt_state = pick(burnt_states)
		//Add some burnt shit
		var/icon/burnt_overlay = icon(broken_icon, "burnt_[burnt_state]")
		add_overlay(burnt_overlay)
		damage_overlays += burnt_overlay

	burnt = TRUE

/turf/open/floor/proc/make_plating()
	//Remove previous damage overlays
	for(var/i in damage_overlays)
		cut_overlay(i)
	return ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

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
	if(T.turf_type == type)
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
			to_chat(user, "<span class='notice'>You remove the broken plating.</span>")
	else
		if(user && !silent)
			to_chat(user, "<span class='notice'>You remove the floor tile.</span>")
		if(floor_tile && make_tile)
			new floor_tile(src)
	return make_plating()

/turf/open/floor/singularity_pull(S, current_size)
	..()
	if(current_size == STAGE_THREE)
		if(prob(30))
			if(floor_tile)
				new floor_tile(src)
				make_plating()
	else if(current_size == STAGE_FOUR)
		if(prob(50))
			if(floor_tile)
				new floor_tile(src)
				make_plating()
	else if(current_size >= STAGE_FIVE)
		if(floor_tile)
			if(prob(70))
				new floor_tile(src)
				make_plating()
		else if(prob(50))
			ReplaceWithLattice()

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
			return list("mode" = RCD_FLOORWALL, "delay" = 20, "cost" = 16)
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
			return list("mode" = RCD_WINDOWGRILLE, "delay" = 10, "cost" = 4)
		if(RCD_MACHINE)
			return list("mode" = RCD_MACHINE, "delay" = 20, "cost" = 25)
		if(RCD_COMPUTER)
			return list("mode" = RCD_COMPUTER, "delay" = 20, "cost" = 25)
	return FALSE

/turf/open/floor/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, "<span class='notice'>You build a wall.</span>")
			log_attack("[key_name(user)] has constructed a wall at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
			var/overlapping_lattice = locate(/obj/structure/lattice) in get_turf(src)
			if(overlapping_lattice)
				qdel(overlapping_lattice) // Don't need lattice burried under the wall, or in the case of catwalk - on top of it.
			PlaceOnTop(/turf/closed/wall)
			return TRUE
		if(RCD_LADDER)
			to_chat(user, "<span class='notice'>You build a ladder.</span>")
			var/obj/structure/ladder/L = new(src)
			L.anchored = TRUE
			return TRUE
		if(RCD_AIRLOCK)
			if(locate(/obj/machinery/door/airlock) in src)
				return FALSE
			to_chat(user, "<span class='notice'>You build an airlock.</span>")
			log_attack("[key_name(user)] has constructed an airlock at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
			var/obj/machinery/door/airlock/A = new the_rcd.airlock_type(src)
			A.electronics = new /obj/item/electronics/airlock(A)
			if(the_rcd.airlock_electronics)
				A.electronics.accesses = the_rcd.airlock_electronics.accesses.Copy()
				A.electronics.one_access = the_rcd.airlock_electronics.one_access
				A.electronics.unres_sides = the_rcd.airlock_electronics.unres_sides
			if(A.electronics.one_access)
				A.req_one_access = A.electronics.accesses
			else
				A.req_access = A.electronics.accesses
			if(A.electronics.unres_sides)
				A.unres_sides = A.electronics.unres_sides
			A.autoclose = TRUE
			A.update_icon()
			return TRUE
		if(RCD_DECONSTRUCT)
			var/previous_turf = initial(name)
			if(!ScrapeAway(flags = CHANGETURF_INHERIT_AIR))
				return FALSE
			to_chat(user, "<span class='notice'>You deconstruct [previous_turf].</span>")
			log_attack("[key_name(user)] has deconstructed [previous_turf] at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
			return TRUE
		if(RCD_WINDOWGRILLE)
			if(locate(/obj/structure/grille) in src)
				return FALSE
			to_chat(user, "<span class='notice'>You construct the grille.</span>")
			log_attack("[key_name(user)] has constructed a grille at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
			var/obj/structure/grille/G = new(src)
			G.anchored = TRUE
			return TRUE
		if(RCD_MACHINE)
			if(locate(/obj/structure/frame/machine) in src)
				return FALSE
			var/obj/structure/frame/machine/M = new(src)
			M.state = 2
			M.icon_state = "box_1"
			M.anchored = TRUE
			return TRUE
		if(RCD_COMPUTER)
			if(locate(/obj/structure/frame/computer) in src)
				return FALSE
			var/obj/structure/frame/computer/C = new(src)
			C.anchored = TRUE
			C.state = 1
			C.setDir(the_rcd.computer_dir)
			return TRUE

	return FALSE

///Autogenerates the variant list from 1 > max (name, name1, name2, name3)
/turf/open/floor/proc/auto_gen_variants(max)
	if(!max)
		return
	variants += list(icon_state = 1)
	for(var/i in 1 to max)
		variants += list("[icon_state][i]" = 1)
