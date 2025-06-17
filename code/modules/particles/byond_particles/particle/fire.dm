/particles/embers
	color = generator("color", "#FF2200", "#FF9933", UNIFORM_RAND)
	spawning = 0.5
	count = 30
	lifespan = 30
	fade = 5
	position = generator("vector", list(-3,6,0), list(3,6,0), NORMAL_RAND)
	gravity = list(0, 0.2, 0)
	color_change = 0
	friction = 0.2
	drift = generator("vector", list(0.25,0,0), list(-0.25,0,0), UNIFORM_RAND)
	#ifndef SPACEMAN_DMM
	fadein = 10
	#endif

///GENERIC FIRE EFEFCT
/particles/fire
	width = 500
	height = 500
	count = 3000
	spawning = 3
	lifespan = 10
	fade = 10
	velocity = list(0, 0)
	position = generator("vector", list(-9,3,0), list(9,3,0), NORMAL_RAND)
	drift = generator("vector", list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.65)
	color = "white"

/particles/fire_jet
	width = 500
	height = 500
	count = 0
	spawning = 1
	lifespan = 4
	fade = 20
	velocity = list(0, 0)
	drift = generator("vector", list(-0.3, 0), list(0.3, 0))
	gravity = list(0, -2)
	color = "white"

/particles/fire_jet/left
	position = generator("vector", list(-4.35,-6,0), list(-4.65,-6,0), NORMAL_RAND)

/particles/fire_jet/right
	position = generator("vector", list(4.35 - 2,-6,0), list(4.65 - 2,-6,0), NORMAL_RAND)

/particles/fire_jet/single/left
	position = generator("vector", list(-7.85,-6,0), list(-8.15,-6,0), NORMAL_RAND)

/particles/fire_jet/single/right
	position = generator("vector", list(7.85 - 2,-6,0), list(8.15 - 2,-6,0), NORMAL_RAND)
