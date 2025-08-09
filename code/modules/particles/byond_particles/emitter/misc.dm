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
	color = generator("color", "#ff0000", "#0000ff", UNIFORM_RAND)
	scale = list(0.7, 1)
	velocity = generator("box", list(-4, 15, -4), list(4, 10, 4), NORMAL_RAND)
	rotation = generator("num", 0, 360, UNIFORM_RAND)
	spin = generator("num", 5, 15, UNIFORM_RAND)
	icon = 'icons/effects/particles/misc.dmi'
	drift = generator("box", list(0.3, 0, 0.3), list(-0.3, 0, -0.3), NORMAL_RAND)
	icon_state = list("line_4")
