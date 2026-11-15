CREATION_TEST_IGNORE_SELF(/turf/closed)

/turf/closed
	// Fixed mapped wall states (including legacy abductor/shuttle walls) need
	// the same world-art policy as neighbour-smoothed walls.
	brandish_icon_mode = "surface"
	abstract_type = /turf/closed
	layer = CLOSED_TURF_LAYER
	opacity = TRUE
	density = TRUE
	init_air = FALSE
	blocks_air = TRUE
	init_air = FALSE
	rad_insulation = RAD_MEDIUM_INSULATION
	pass_flags_self = PASSCLOSEDTURF

/turf/closed/Initialize(mapload)
	. = ..()

/turf/closed/AfterChange()
	. = ..()
	SSair.high_pressure_delta -= src

/turf/closed/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/closed/examine_descriptor(mob/user)
	return "wall"
