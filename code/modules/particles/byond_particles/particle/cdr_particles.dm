/particles/debris
	width = 124
	height = 124
	count = 16
	spawning = SPAWN_ALL_PARTICLES_INSTANTLY //spawn all instantly
	lifespan = 0.75 SECONDS
	fadein = 0.35 SECONDS
	fade = 0.1 SECONDS
	position = generator("box", list(-10, -10), list(10, 10), NORMAL_RAND)
	velocity = generator("circle", -15, 15, NORMAL_RAND)
	friction = 0
	gravity = list(0, 0)
	icon = 'icons/effects/particles/rocks.dmi'
	icon_state = list("rock1", "rock2", "rock3", "rock4", "rock5")
	rotation = generator("num", 0, 360, NORMAL_RAND)
