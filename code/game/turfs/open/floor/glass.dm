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

	/// Color of starlight to use. Defaults to STARLIGHT_COLOR if not set
	var/starlight_colour

/turf/open/floor/glass/broken_states()
	return GLOB.glass_turf_damage

/turf/open/floor/glass/Initialize(mapload)
	icon_state = "" //Prevent the normal icon from appearing behind the smooth overlays
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/floor/glass/LateInitialize()
	setup_glow()

/turf/open/floor/glass/Destroy()
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_STARLIGHT_COLOUR_CHANGE)

/turf/open/floor/glass/proc/setup_glow()
	if(!ispath(get_z_base_turf(), /turf/open/space)) // We ain't the bottom brother
		return

	if(!starlight_colour)
		RegisterSignal(SSdcs, COMSIG_GLOB_STARLIGHT_COLOUR_CHANGE, PROC_REF(starlight_changed))
	else
		UnregisterSignal(SSdcs, COMSIG_GLOB_STARLIGHT_COLOUR_CHANGE)

	set_light(1.25, 1, starlight_colour || GLOB.starlight_colour, l_height = LIGHTING_HEIGHT_SPACE)

/turf/open/floor/glass/proc/starlight_changed(datum/source, new_colour, transition_time)
	set_light(l_color = new_colour)

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
