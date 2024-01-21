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
	fadein = 3
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
/obj/emitter/snow_smoke
	alpha = 200
	particles = new/particles/electrified/snow_smoke

/obj/emitter/snow_smoke/Initialize(mapload)
	. = ..()
	add_filter("blur", 1, list(type="blur", size=1))

/particles/electrified/snow_smoke
    icon = 'icons/effects/particles/smoke.dmi'
    icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 2)

///Electrified
/obj/emitter/electrified
	particles = new/particles/electrified
	plane = ABOVE_LIGHTING_PLANE

/obj/emitter/electrified/Initialize(mapload)
    . = ..()
    add_filter("bloom" , 1 , list(type="bloom", size=3, offset = 0.5, alpha = 220))

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

///Electrified
/obj/emitter/spiral
	plane = ABOVE_LIGHTING_PLANE

/obj/emitter/spiral/proc/setup(_color)
	particles = new/particles/spiral(_color)

/particles/spiral
	count = 90
	spawning = 30
	lifespan = 3
	fade = 1
	fadein = 1
	rotation = generator("num", 0, 360, UNIFORM_RAND)
	spin = generator("num", 10, 20, UNIFORM_RAND)
	friction = 0.21
	color = "#94f3ff"
	scale = generator("box", list(1.2, 1.2, 1.2), list(1.8, 1.8, 1.8), UNIFORM_RAND)
	grow = list(-0.5, -0.5)
	icon = 'icons/effects/particles/misc.dmi'
	icon_state = list("line_1")

/particles/spiral/New(_color)
	. = ..()
	color = _color || color
