/turf/open/void
	name = "\proper void"
	icon = 'icons/turf/space.dmi'
	icon_state = "void"
	intact = 0

	temperature = T20C
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	light_power = -0.25
	bullet_bounce_sound = null

/turf/open/void/ReplaceWithLattice()
	return

/turf/open/void/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	return

/turf/open/void/singularity_act()
	return

/turf/open/void/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/void/can_have_cabling()
	return FALSE

/turf/open/void/is_transition_turf()
	return FALSE

/turf/open/void/acid_act(acidpwr, acid_volume)
	return FALSE

/turf/open/void/handle_slip()
	return
