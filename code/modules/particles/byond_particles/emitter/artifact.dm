/*
	Particles for artifacts
*/

///Sonar
/obj/emitter/sonar
	particles = new/particles/sonar
	plane = ABOVE_LIGHTING_PLANE

/obj/emitter/sonar/out
	particles = new/particles/sonar/out

/particles/sonar
	width = 100
	height = 100
	count = 3
	spawning = 0.15
	lifespan = 15
	fade = 3
	#ifndef SPACEMAN_DMM // Waiting on next release of DreamChecker
	fadein = 3
	#endif
	friction = 0.25
	color = "#0081ff"
	scale = list(2, 2)
	grow = list(-0.1, -0.1)
	icon = 'icons/effects/particles/misc.dmi'
	icon_state = list("circle_1")

/particles/sonar/out
	color = "#55ff00"
	scale = list(0.5, 0.5)
	grow = list(0.1, 0.1)

///Snow smoke, idk
/obj/emitter/snow
	alpha = 200
	particles = new/particles/snow

/particles/snow
	icon = 'icons/effects/particles/weather.dmi'
	icon_state = list("snow_1" = 1, "snow_2" = 1, "snow_3" = 2)
	color = "#b8fffd"
	count = 10
	spawning = 1
	lifespan = 10
	fade = 4
	#ifndef SPACEMAN_DMM
	fadein = 4
	#endif
	position = generator("box", list(-15, 10, -15), list(15, 12, 15), UNIFORM_RAND)
	velocity = list(0, -2, 0)
	gravity = list(0, 0.1, 0)
	drift = generator("box", list(-0.2, 0, -0.2), list(0.2, 0, 0.2), UNIFORM_RAND)

///Electrified
/obj/emitter/electrified
	particles = new/particles/electrified
	plane = ABOVE_LIGHTING_PLANE
	blend_mode = BLEND_ADD

/obj/emitter/electrified/Initialize(mapload)
	. = ..()
	add_filter("bloom" , 1 , list(type="bloom", size=1, offset = 0.1, alpha = 255))

/particles/electrified
	count = 10
	spawning = 1
	lifespan = 10
	fade = 2
	#ifndef SPACEMAN_DMM
	fadein = 1
	#endif
	position = generator("box", list(-5, -5, -5), list(5, 5, 5), UNIFORM_RAND)
	velocity = generator("box", list(-3, -3, -3), list(3, 3, 3), UNIFORM_RAND)
	rotation = generator("num", 0, 360, UNIFORM_RAND)
	friction = 0.21
	color = "#94f3ff"
	scale = list(0.14, 0.14)
	grow = list(0.08, 0.08)
	icon = 'icons/effects/particles/misc.dmi'
	icon_state = list("static_1", "static_2")

///Calibartion spiral thing
/obj/emitter/spiral
	plane = ABOVE_LIGHTING_PLANE
	blend_mode = BLEND_ADD

/obj/emitter/spiral/New(loc, ...)
	. = ..()
	add_filter("blur", 1, gauss_blur_filter(0.7))

/obj/emitter/spiral/proc/setup(_color)
	particles = new/particles/spiral(_color)

/particles/spiral
	count = 90
	spawning = 30
	lifespan = 3
	fade = 1
	#ifndef SPACEMAN_DMM
	fadein = 1
	#endif
	rotation = generator("num", 0, 360, UNIFORM_RAND)
	spin = generator("num", 8, 10, UNIFORM_RAND)
	friction = 0.21
	color = "#94f3ff"
	scale = generator("box", list(1.5, 1.5, 1.5), list(2, 2, 2), UNIFORM_RAND)
	grow = list(-0.5, -0.5)
	icon = 'icons/effects/particles/misc.dmi'
	icon_state = list("line_1", "line_2", "line_3")

/particles/spiral/New(_color)
	. = ..()
	color = _color || color
