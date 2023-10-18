
/particles/sparkles
	color = generator("color", "#e4ab27", "#FF9933", UNIFORM_RAND)
	icon = 'icons/effects/particles/misc.dmi'
	icon_state = list("sparkle_1", "sparkle_2")
	count = 30
	spawning = 3
	lifespan = 5 SECONDS
	fade = 5 SECONDS
	drift = generator("sphere", 5, 5, NORMAL_RAND)
	friction = 0.5
