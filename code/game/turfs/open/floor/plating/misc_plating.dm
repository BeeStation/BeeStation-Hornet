
/turf/open/floor/plating/airless
	icon_state = "plating"
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plating/lavaland
	icon_state = "plating"
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/plating/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	tiled_dirt = FALSE
	max_integrity = 1800

/turf/open/floor/plating/abductor/Initialize(mapload)
	. = ..()
	icon_state = "alienpod[rand(1,9)]"


/turf/open/floor/plating/abductor2
	name = "alien plating"
	icon_state = "alienplating"
	tiled_dirt = FALSE
	max_integrity = 1800

/turf/open/floor/plating/abductor2/break_tile()
	return //unbreakable

/turf/open/floor/plating/abductor2/burn_tile()
	return //unburnable

/turf/open/floor/plating/abductor2/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ashplanet
	icon = MAP_SWITCH('icons/turf/floors/ash.dmi', 'icons/turf/mining.dmi')
	icon_state = "ash"
	base_icon_state = "ash"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	// This is static
	// Done like this to avoid needing to make it dynamic and save cpu time
	// 4 to the left, 4 down
	transform = MAP_SWITCH(TRANSLATE_MATRIX(MINERAL_WALL_OFFSET, MINERAL_WALL_OFFSET), matrix())
	gender = PLURAL
	name = "ash"
	desc = "The ground is covered in volcanic ash."
	baseturfs = /turf/open/floor/plating/ashplanet/wateryrock //I assume this will be a chasm eventually, once this becomes an actual surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	attachment_holes = FALSE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/floor/plating/ashplanet/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ashplanet/break_tile()
	return

/turf/open/floor/plating/ashplanet/burn_tile()
	return

/turf/open/floor/plating/ashplanet/ash
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ASH)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_ASH, SMOOTH_GROUP_CLOSED_TURFS)
	layer = HIGH_TURF_LAYER
	slowdown = 1

/turf/open/floor/plating/ashplanet/rocky
	gender = PLURAL
	name = "rocky ground"
	icon = MAP_SWITCH('icons/turf/floors/rocky_ash.dmi', 'icons/turf/mining.dmi')
	icon_state = "rockyash"
	base_icon_state = null
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ASH_ROCKY)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_ASH_ROCKY, SMOOTH_GROUP_CLOSED_TURFS)
	smoothing_flags = SMOOTH_CORNERS
	layer = MID_TURF_LAYER
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/ashplanet/wateryrock
	gender = PLURAL
	name = "wet rocky ground"
	icon = 'icons/turf/mining.dmi'
	icon_state = "wateryrock"
	smoothing_flags = NONE
	canSmoothWith = null
	base_icon_state = null
	slowdown = 2
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	// Disable smoothing and remove the offset matrix
	smoothing_flags = NONE
	transform = matrix()

/turf/open/floor/plating/ashplanet/wateryrock/Initialize(mapload)
	icon_state = "[icon_state][rand(1, 9)]"
	. = ..()


/turf/open/floor/plating/beach
	name = "beach"
	icon = 'icons/misc/beach.dmi'
	flags_1 = NONE
	attachment_holes = FALSE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	max_integrity = 100
	resistance_flags = INDESTRUCTIBLE
	max_integrity = 300

/turf/open/floor/plating/beach/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/beach/sand
	gender = PLURAL
	name = "sand"
	desc = "Surf's up."
	icon_state = "sand"
	baseturfs = /turf/open/floor/plating/beach/sand

/turf/open/floor/plating/beach/coastline_t
	name = "coastline"
	desc = "Tide's high tonight. Charge your batons."
	icon_state = "sandwater_t"
	baseturfs = /turf/open/floor/plating/beach/coastline_t

/turf/open/floor/plating/beach/coastline_b
	name = "coastline"
	icon_state = "sandwater_b"
	baseturfs = /turf/open/floor/plating/beach/coastline_b

/turf/open/floor/plating/beach/water
	gender = PLURAL
	name = "water"
	desc = "You get the feeling that nobody's bothered to actually make this water functional..."
	icon_state = "water"
	baseturfs = /turf/open/floor/plating/beach/water

/turf/open/floor/plating/beach/coastline_t/sandwater_inner
	icon_state = "sandwater_inner"
	baseturfs = /turf/open/floor/plating/beach/coastline_t/sandwater_inner

/turf/open/floor/plating/ironsand
	gender = PLURAL
	name = "iron sand"
	desc = "Like sand, but more <i>iron</i>."
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/ironsand/Initialize(mapload)
	. = ..()
	icon_state = "ironsand[rand(1,15)]"

/turf/open/floor/plating/ironsand/burn_tile()
	return

/turf/open/floor/plating/ironsand/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ice
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "ice-0"
	initial_gas_mix = FROZEN_ATMOS
	initial_temperature = 180
	planetary_atmos = TRUE
	baseturfs = /turf/open/floor/plating/ice
	slowdown = 1
	attachment_holes = FALSE
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/ice/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_PERMAFROST, INFINITY, 0, INFINITY, TRUE)

/turf/open/floor/plating/ice/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ice/smooth
	icon_state = "ice-255"
	base_icon_state = "ice"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ICE)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_ICE)

/turf/open/floor/plating/ice/colder
	initial_temperature = 140

/turf/open/floor/plating/ice/temperate
	initial_temperature = 255.37

/turf/open/floor/plating/ice/break_tile()
	return

/turf/open/floor/plating/ice/burn_tile()
	return


/turf/open/floor/plating/snowed
	name = "snowed-over plating"
	desc = "A section of heated plating, helps keep the snow from stacking up too high."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snowplating"
	initial_gas_mix = FROZEN_ATMOS
	initial_temperature = 180
	attachment_holes = FALSE
	planetary_atmos = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/snowed/cavern
	initial_gas_mix = "n2=82;plasma=24;TEMP=120"

/turf/open/floor/plating/snowed/smoothed
	planetary_atmos = TRUE
	icon = 'icons/turf/floors/snow_turf.dmi'
	icon_state = "snow_turf-0"
	base_icon_state = "snow_turf"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_SNOWED)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_SNOWED)

/turf/open/floor/plating/snowed/colder
	initial_temperature = 140

/turf/open/floor/plating/snowed/temperatre
	initial_temperature = 255.37

