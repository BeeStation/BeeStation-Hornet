/turf/open/floor/plating/dirt
	gender = PLURAL
	name = "dirt"
	desc = "Upon closer examination, it's still dirt."
	icon = 'icons/turf/floors.dmi'
	icon_state = "dirt"
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	planetary_atmos = TRUE
	attachment_holes = FALSE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	resistance_flags = INDESTRUCTIBLE
	baseturfs = /turf/open/floor/plating/dirt
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ICE)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_ICE)

/turf/open/floor/plating/dirt/planetary
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/plating/dirt/grass
	desc = "You're almost positive this is real grass."
	icon = 'icons/turf/floors.dmi'
	icon_state = "grass"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	baseturfs = /turf/open/floor/plating/dirt

/turf/open/floor/plating/dirt/dark
	icon_state = "greenerdirt"

/turf/open/floor/plating/dirt/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/dirt/jungle
	slowdown = 0.5
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/floor/plating/dirt/jungle/dark
	icon_state = "greenerdirt"

/turf/open/floor/plating/dirt/jungle/wasteland //Like a more fun version of living in Arizona.
	name = "cracked earth"
	desc = "Looks a bit dry."
	icon = 'icons/turf/floors.dmi'
	icon_state = "wasteland"
	slowdown = 1
	variant_probability = 15
	variant_states = 13

/turf/open/floor/grass/jungle
	name = "jungle grass"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	desc = "Greener on the other side."
	color = "#0f9731"

/turf/open/floor/grass/jungle/Initialize(mapload)
	.=..()
	icon_state = "[initial(icon_state)][rand(1,3)]"

/turf/closed/mineral/random/jungle
	baseturfs = /turf/open/floor/plating/dirt/dark

/turf/closed/mineral/random/jungle/mineral_chances()
	return list(
		/obj/item/stack/ore/uranium = 5,
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/silver = 12,
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/iron = 40,
		/obj/item/stack/ore/titanium = 11,
		/obj/item/stack/ore/bluespace_crystal = 1,
	)

