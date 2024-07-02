/obj/emitter/sparks
	particles = new/particles/drill_sparks
	plane = ABOVE_LIGHTING_PLANE

/obj/emitter/sparks/fire
	alpha = 225
	particles = new/particles/fire_sparks

/obj/emitter/sparks/flare
	particles = new/particles/flare_sparks

/obj/emitter/sparks/flare/Initialize(mapload)
	. = ..()
	add_filter("bloom" , 1 , list(type="bloom", size=3, offset = 0.5, alpha = 220))
