/turf/open/floor/glass
	name = "glass floor"
	desc = "Don't jump on it, or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "glass-0"
	base_icon_state = "glass"
	baseturfs = /turf/open/openspace
	intact = TRUE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS)
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	floor_tile = /obj/item/stack/tile/glass
	broken_states = list("glass-damaged1", "glass-damaged2", "glass-damaged3")

	z_flags = Z_MIMIC_DEFAULTS

/*
/turf/open/floor/glass/setup_broken_states()
	return list("glass-damaged1", "glass-damaged2", "glass-damaged3")
*/

/turf/open/floor/glass/Initialize(mapload)
	icon_state = "" //Prevent the normal icon from appearing behind the smooth overlays
	..()
	return INITIALIZE_HINT_LATELOAD

/*
/turf/open/floor/glass/make_plating()
	return
*/

/turf/open/floor/glass/reinforced
	name = "reinforced glass floor"
	desc = "Do jump on it, it can take it."
	icon = 'icons/turf/floors/reinf_glass.dmi'
	icon_state = "reinf_glass-0"
	base_icon_state = "reinf_glass"
	floor_tile = /obj/item/stack/tile/rglass
	broken_states = list("reinf_glass-damaged1", "reinf_glass-damaged2", "reinf_glass-damaged3")

/*
/turf/open/floor/glass/reinforced/icemoon
	name = "reinforced glass floor"
	desc = "Do jump on it, it can take it."
	icon = 'icons/turf/floors/reinf_glass.dmi'
	icon_state = "reinf_glass-0"
	base_icon_state = "reinf_glass"
	floor_tile = /obj/item/stack/tile/rglass
	initial_gas = ICEMOON_DEFAULT_ATMOS
*/

/*
/turf/open/floor/glass/reinforced/setup_broken_states()
	return list("reinf_glass-damaged1", "reinf_glass-damaged2", "reinf_glass-damaged3")
*/
