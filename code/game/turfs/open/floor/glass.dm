/turf/open/floor/glass
	name = "glass floor"
	desc = "Don't jump on it, or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "glass-0"
	base_icon_state = "glass"
	baseturfs = /turf/baseturf_bottom
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS)
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	floor_tile = /obj/item/stack/tile/glass
	overfloor_placed = FALSE

	z_flags = Z_MIMIC_DEFAULTS

/turf/open/floor/glass/broken_states()
	return GLOB.glass_turf_damage

/turf/open/floor/glass/AfterChange()
	var/turf/base = READ_BASETURF(src)
	if(ispath(base, /turf/baseturf_bottom))
		base = get_z_base_turf()

	luminosity = initial(base.luminosity)
	fullbright_type = initial(base.fullbright_type)
	set_light_power(initial(base.light_power))

	var/area/A = loc
	if(IS_DYNAMIC_LIGHTING(A) && fullbright_type == FULLBRIGHT_STARLIGHT)
		overlays += GLOB.starfloor_overlay

	return ..()

/turf/open/floor/glass/Initialize(mapload)
	icon_state = "" //Prevent the normal icon from appearing behind the smooth overlays
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/floor/glass/make_plating()
	return

/turf/open/floor/glass/reinforced
	name = "Reinforced glass floor"
	desc = "Do jump on it, it can take it."
	icon = 'icons/turf/floors/reinf_glass.dmi'
	icon_state = "reinf_glass-0"
	base_icon_state = "reinf_glass"
	floor_tile = /obj/item/stack/tile/rglass

/*
/turf/open/floor/glass/reinforced/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
*/

/turf/open/floor/glass/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/glass/reinforced/broken_states()
	return GLOB.reinfglass_turf_damage

/turf/open/floor/glass/plasma
	name = "plasma glass floor"
	desc = "Studies by the Nanotrasen Materials Safety Division have not yet determined if this is safe to jump on, do so at your own risk."
	icon = 'icons/turf/floors/plasma_glass.dmi'
	icon_state = "plasma_glass-0"
	base_icon_state = "plasma_glass"
	floor_tile = /obj/item/stack/tile/glass/plasma
	heat_capacity = INFINITY

/turf/open/floor/glass/reinforced/plasma
	name = "reinforced plasma glass floor"
	desc = "Do jump on it, jump on it while in a mecha, it can take it."
	icon = 'icons/turf/floors/reinf_plasma_glass.dmi'
	icon_state = "reinf_plasma_glass-0"
	base_icon_state = "reinf_plasma_glass"
	floor_tile = /obj/item/stack/tile/rglass/plasma
	heat_capacity = INFINITY
