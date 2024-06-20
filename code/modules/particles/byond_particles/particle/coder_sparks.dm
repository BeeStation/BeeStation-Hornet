
/particles/coder_sparks
	icon = 'icons/effects/particles/misc.dmi'
	icon_state = list("zero", "one")
	color = generator("color", "#00ff00", "#11ff7c", UNIFORM_RAND)
	count = 16
	spawning = 4
	lifespan = 4 SECONDS
	fade = 8 SECONDS
	drift = generator("circle", 4, 4, NORMAL_RAND)
	friction = 0.6


