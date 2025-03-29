CREATION_TEST_IGNORE_SUBTYPES(/turf/open/openspace)

/turf/open/openspace
	name = "open space"
	desc = "Watch your step!"
	icon_state = "invisible"
	baseturfs = /turf/open/openspace
	overfloor_placed = FALSE
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	allow_z_travel = TRUE
	resistance_flags = INDESTRUCTIBLE
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	/* PORT WITH JPS IMPROVEMENT PR
	pathing_pass_method = TURF_PATHING_PASS_PROC
	*/

	z_flags = Z_MIMIC_BELOW|Z_MIMIC_OVERWRITE

	var/can_cover_up = TRUE
	var/can_build_on = TRUE

	FASTDMM_PROP(\
		pipe_astar_cost = 100\
	)

/turf/open/openspace/cold
	initial_gas_mix = FROZEN_ATMOS

/turf/open/openspace/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/openspace/Initialize(mapload)
	. = ..()
	var/area/our_area = loc
	if(istype(our_area, /area/space))
		force_no_gravity = TRUE
	return INITIALIZE_HINT_LATELOAD

/turf/open/openspace/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return TRUE
	var/turf/B = GET_TURF_BELOW(src)
	if(B)
		return B.can_lay_cable()
	return FALSE

/turf/open/openspace/zAirIn()
	return TRUE

/turf/open/openspace/zAirOut()
	return TRUE

/turf/open/openspace/zPassIn(atom/movable/A, direction, turf/source, falling = FALSE)
	if(direction == DOWN)
		for(var/obj/O in contents)
			if(O.z_flags & Z_BLOCK_IN_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/O in contents)
			if(O.z_flags & Z_BLOCK_IN_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/openspace/zPassOut(atom/movable/A, direction, turf/destination, falling = FALSE)
	//Check if our current location has gravity
	if(falling && !A.has_gravity(src))
		return FALSE
	if(A.anchored)
		return FALSE
	if(direction == DOWN)
		for(var/obj/O in contents)
			if(O.z_flags & Z_BLOCK_OUT_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/O in contents)
			if(O.z_flags & Z_BLOCK_OUT_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/openspace/proc/CanCoverUp()
	return can_cover_up

/turf/open/openspace/proc/CanBuildHere()
	return can_build_on

/turf/open/openspace/attackby(obj/item/C, mob/user, params)
	..()
	if(!CanBuildHere())
		return
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		var/obj/structure/lattice/catwalk/W = locate(/obj/structure/lattice/catwalk, src)
		if(W)
			to_chat(user, span_warning("There is already a catwalk here!"))
			return
		if(L)
			if(R.use(1))
				to_chat(user, span_notice("You construct a catwalk."))
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				new/obj/structure/lattice/catwalk(src)
			else
				to_chat(user, span_warning("You need two rods to build a catwalk!"))
			return
		if(R.use(1))
			to_chat(user, span_notice("You construct a lattice."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
			ReplaceWithLattice()
		else
			to_chat(user, span_warning("You need one rod to build a lattice."))
		return
	if(istype(C, /obj/item/stack/tile/iron))
		if(!CanCoverUp())
			return
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/iron/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				to_chat(user, span_notice("You build a floor."))
				PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			else
				to_chat(user, span_warning("You need one floor tile to build a floor!"))
		else
			to_chat(user, span_warning("The plating is going to need some support! Place iron rods first."))

/turf/open/openspace/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(!CanBuildHere())
		return FALSE

	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
			if(L)
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 1)
			else
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 3)
	return FALSE

/turf/open/openspace/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_FLOORWALL)
		to_chat(user, span_notice("You build a floor."))
		log_attack("[key_name(user)] has constructed a floor over open space at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
		PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return FALSE

/turf/open/openspace/rust_heretic_act()
	return FALSE

//Returns FALSE if gravity is force disabled. True if grav is possible
/turf/open/openspace/check_gravity()
	var/turf/T = GET_TURF_BELOW(src)
	if(!T)
		return TRUE
	if(isspaceturf(T))
		return FALSE
	return TRUE

/turf/open/openspace/examine(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	return below?.examine(user)

/turf/open/openspace/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	..()
	if(!arrived.zfalling)
		zFall(arrived, old_loc = old_loc) // don't use try_start_zFall here, it needs to be sync
	// Make sure we didn't move from the above call
	if(get_turf(arrived) == src)
		SSzfall.add_openspace_inhabitant(arrived)

/turf/open/openspace/Exited(atom/movable/exiting, atom/newloc)
	..()
	SSzfall.remove_openspace_inhabitant(exiting)
