/obj/emitter/fire
	alpha = 225
	particles = new/particles/fire

//I hate this, i loath everything about having to create an Init because the byond level filters doesn't allow multiple filters to be set at once if this ever gets fixed please ping me -Borbop
/obj/emitter/fire/Initialize(mapload)
	. = ..()
	add_filter("outline", 1, list(type = "outline", size = 3,  color = COLOR_MOSTLY_PURE_RED))
	add_filter("bloom", 2, list(type = "bloom", threshold = rgb(255,128,255), size = 6, offset = 4, alpha = 255))

/obj/emitter/fire_jet
	alpha = 225
	plane = ABOVE_LIGHTING_PLANE
	layer = ABOVE_MOB_LAYER
	vis_flags = NONE

/obj/emitter/fire_jet/Initialize(mapload)
	. = ..()
	add_filter("outline", 1, list(type = "outline", size = 2,  color = COLOR_MOSTLY_PURE_RED))
	add_filter("bloom", 2, list(type = "bloom", threshold = rgb(255,128,255), size = 6, offset = 3, alpha = 200))

/obj/emitter/fire_jet/left
	particles = new/particles/fire_jet/left

/obj/emitter/fire_jet/right
	particles = new/particles/fire_jet/right

/obj/emitter/fire_jet/single/left
	particles = new/particles/fire_jet/single/left

/obj/emitter/fire_jet/single/right
	particles = new/particles/fire_jet/single/right
