
/turf/open/floor/dock
	name = "dock floor"
	desc = "Strong enough to hold a shuttle."
	icon_state = "dock"
	floor_tile = /obj/item/stack/tile/dock
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	max_integrity = 500
	overfloor_placed = FALSE
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE

/turf/open/floor/dock/crowbar_act(mob/living/user, obj/item/I)
	return pry_tile(I, user)

/turf/open/floor/dock/drydock
	name = "dry dock floor"
	desc = "Heavy duty plating designed to support shuttle construction and maintenance."
	icon_state = "drydock"
	floor_tile = /obj/item/stack/tile/drydock

/turf/open/floor/dock/drydock/crowbar_act(mob/living/user, obj/item/I)
	for(var/obj/structure/lattice/lattice in contents)
		to_chat(user, span_warning("[lattice] is blocking [I]!"))
		return FALSE
	. = ..()

/turf/open/floor/dock/drydock/proc/CanBuildHere()
	for(var/i in 0 to length(baseturfs) - 1)
		var/BT = baseturfs[baseturfs.len - i]
		if(ispath(BT, /turf/open/floor/dock))
			return FALSE
		if(ispath(BT, /turf/baseturf_skipover/shuttle))
			return TRUE
	return TRUE

/turf/open/floor/dock/drydock/attackby(obj/item/C, mob/user, params)
	..()
	var/can_build = CanBuildHere()
	if(istype(C, /obj/item/stack/rods))
		if(!can_build)
			to_chat(user, span_warning("[src] can't support anything more!"))
			return
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
			new /obj/structure/lattice(locate(x, y, z))
		else
			to_chat(user, span_warning("You need one rod to build a lattice."))
		return
	if(istype(C, /obj/item/stack/tile/iron))
		if(!can_build)
			to_chat(user, span_warning("[src] can't support anything more!"))
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

/turf/open/floor/dock/drydock/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 33)

	if(!CanBuildHere())
		return FALSE

	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
			if(L)
				return list("mode" = RCD_FLOORWALL, "delay" = 10, "cost" = 1)
			else
				return list("mode" = RCD_FLOORWALL, "delay" = 10, "cost" = 3)
	return FALSE

/turf/open/floor/dock/drydock/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, span_notice("You build a floor."))
			PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
		if(RCD_DECONSTRUCT)
			if(ScrapeAway(flags = CHANGETURF_INHERIT_AIR) == src)
				return FALSE
			to_chat(user, span_notice("You deconstruct [src]."))
			return TRUE
	return FALSE
