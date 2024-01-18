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
	icon_state = list("circle")

/particles/sonar/out
	color = "#55ff00"
	scale = list(0.5, 0.5)
	grow = list(0.1, 0.1)
