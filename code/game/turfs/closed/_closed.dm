CREATION_TEST_IGNORE_SELF(/turf/closed)

/turf/closed
	layer = CLOSED_TURF_LAYER
	opacity = TRUE
	density = TRUE
	init_air = FALSE
	pass_flags_self = PASSCLOSEDTURF

/turf/closed/Initialize(mapload)
	. = ..()

/turf/closed/AfterChange()
	. = ..()
	SSair.high_pressure_delta -= src

/turf/closed/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE
