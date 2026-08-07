/obj/emitter/stink_lines
	particles = new/particles/stink_lines

//Confetti
/obj/emitter/confetti
	particles = new/particles/confetti

/particles/confetti
	width = 100
	height = 100
	count = 15
	spawning = 15
	lifespan = 20
	fade = 1
	#ifndef SPACEMAN_DMM
	fadein = 3
	#endif
	friction = 0.15
	gravity = list(0, -1, 0)
	color = generator("color", COLOR_RED, COLOR_BLUE, UNIFORM_RAND)
	scale = list(0.7, 1)
	velocity = generator("box", list(-4, 15, -4), list(4, 10, 4), NORMAL_RAND)
	rotation = generator("num", 0, 360, UNIFORM_RAND)
	spin = generator("num", 5, 15, UNIFORM_RAND)
	icon = 'icons/effects/particles/misc.dmi'
	drift = generator("box", list(0.3, 0, 0.3), list(-0.3, 0, -0.3), NORMAL_RAND)
	icon_state = list("line_4")

/obj/emitter/confetti/taser
	particles = new/particles/confetti/taser

/particles/confetti/taser
	color = generator("color", "#ffea00", "#ff00bf", UNIFORM_RAND)

/*
	Plant confetti
*/
//leaves
/obj/emitter/confetti/leaves
	particles = new/particles/confetti/leaves("#64A344")

/obj/emitter/confetti/leaves/proc/set_colour(colour = "#64A344")
	QDEL_NULL(particles)
	particles = new/particles/confetti/leaves(colour)

/particles/confetti/leaves
	icon_state = list("leaf_1", "leaf_2", "leaf_3")
	color = "#FFF"
	velocity = generator("box", list(-10, 10, -10), list(10, 10, 10), NORMAL_RAND)
	position =  generator("box", list(-10, 5, -10), list(10, -5, 10), NORMAL_RAND)
	friction = 0.5

/particles/confetti/leaves/New(_colour)
	. = ..()
	color = _colour

//dust
/obj/emitter/plant_dust/Initialize(mapload, time, _color)
	. = ..()
	particles = new/particles/confetti/plant_dust
	add_filter("blur", 1, list(type="blur", size=1.5))

/particles/confetti/plant_dust
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 2)
	velocity = generator("box", list(-5, -5, -5), list(5, 5, 5), NORMAL_RAND)
	friction = 0.23
	gravity = list(0, 0, 0)
	color = "#ffffff50"
