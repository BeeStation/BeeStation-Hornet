/particles/cdr_collapse
	icon = 'icons/effects/96x96.dmi'
	icon_state = list("orb_particle")
	width = 96
	height = 96
	color = generator("color", "#77fff1", "#a9d8ff", UNIFORM_RAND)
	rotation = generator(GEN_NUM, 0, 360, UNIFORM_RAND)
	spawning = 3
	count = 200
	lifespan = 20
	fade = 2
	position = list(0, 0)
	gravity = list(0, 0)
	scale = list(0.8, 0.8)
	grow = list(-0.5, -0.5)
	#ifndef SPACEMAN_DMM
	fadein = 1
	#endif
