CREATION_TEST_IGNORE_SUBTYPES(/turf/baseturf_skipover)

// This is a typepath to just sit in baseturfs and act as a marker for other things.
/turf/baseturf_skipover
	name = "Baseturf skipover placeholder"
	desc = "This shouldn't exist"
	can_underlay = FALSE

/turf/baseturf_skipover/Initialize(mapload)
	. = ..()
	stack_trace("[src]([type]) was instanced which should never happen. Changing into the next baseturf down...")
	ScrapeAway()

/turf/baseturf_skipover/shuttle
	name = "Shuttle baseturf skipover"
	desc = "Acts as the bottom of the shuttle, if this isn't here the shuttle floor is broken through."

CREATION_TEST_IGNORE_SUBTYPES(/turf/baseturf_bottom)

/turf/baseturf_bottom
	name = "Z-level baseturf placeholder"
	desc = "Marker for z-level baseturf, usually resolves to space."
	baseturfs = /turf/baseturf_bottom
	can_underlay = FALSE
