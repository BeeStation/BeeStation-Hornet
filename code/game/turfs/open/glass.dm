/turf/open/floor/glass
	name = "Glass floor"
	desc = "Dont jump on it, or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "glass-0"
	base_icon_state = "glass"
	baseturfs = /turf/open/openspace
	intact = TRUE //fuck it yall can remove them, can't really fix the plating though :/
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS)
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	floor_tile = /obj/item/stack/tile/glass

/turf/open/floor/glass/Initialize()
	icon_state = "" //Prevent the normal icon from appearing behind the smooth overlays
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/floor/glass/Destroy()
	. = ..()
	RemoveElement(/datum/element/turf_z_transparency)
	for(var/obj/object in src)
		if(object.level == 1 && (object.flags_1 & INITIALIZED_1))
			object.plane = initial(object.plane)

/turf/open/floor/glass/levelupdate()
	for(var/obj/object in src)
		if(object.level == 1 && (object.flags_1 & INITIALIZED_1))
			if(istype(object, /obj/machinery/atmospherics/components/unary/vent_pump) || istype(object, /obj/machinery/atmospherics/components/unary/vent_scrubber))
				return
			object.plane = OPENSPACE_PLANE

/turf/open/floor/glass/LateInitialize()
	. = ..()
	AddElement(/datum/element/turf_z_transparency, TRUE)

/turf/open/floor/glass/reinforced
	name = "Reinforced glass floor"
	desc = "Do jump on it, it can take it."
	icon = 'icons/turf/floors/reinf_glass.dmi'
	icon_state = "reinf_glass-0"
	base_icon_state = "reinf_glass"
	floor_tile = /obj/item/stack/tile/rglass

/turf/open/floor/glass/plasma
	name = "plasma glass floor"
	desc = "Studies by the Nanotrasen Materials Safety Division have not yet determined if this is safe to jump on, do so at your own risk."
	icon = 'icons/turf/floors/plasma_glass.dmi'
	icon_state = "plasma_glass-0"
	base_icon_state = "plasma_glass"
	floor_tile = /obj/item/stack/tile/glass/plasma

/turf/open/floor/glass/reinforced/plasma
	name = "reinforced plasma glass floor"
	desc = "Do jump on it, jump on it while in a mecha, it can take it."
	icon = 'icons/turf/floors/reinf_plasma_glass.dmi'
	icon_state = "reinf_plasma_glass-0"
	base_icon_state = "reinf_plasma_glass"
	floor_tile = /obj/item/stack/tile/rglass/plasma
