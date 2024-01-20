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

///Electrified
/obj/emitter/electrified
	particles = new/particles/electrified
	plane = ABOVE_LIGHTING_PLANE

/particles/electrified
	count = 10
	spawning = 1
	lifespan = 10
	fade = 2
	fadein = 1
	position = generator("box", list(-5, -5, -5), list(5, 5, 5), UNIFORM_RAND)
	velocity = generator("box", list(-3, -3, -3), list(3, 3, 3), UNIFORM_RAND)
	rotation = generator("num", 0, 360, UNIFORM_RAND)
	friction = 0.21
	color = "#94f3ff"
	scale = list(0.14, 0.14)
	grow = list(0.1, 0.1)
	icon = 'icons/effects/particles/misc.dmi'
	icon_state = list("static_1")
