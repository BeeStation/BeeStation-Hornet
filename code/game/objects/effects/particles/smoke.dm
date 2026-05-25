/particles/smoke
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 2)
	width = 100
	height = 100
	count = 1000
	spawning = 4
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	velocity = list(0, 0.4, 0)
	position = list(6, 0, 0)
	drift = generator("sphere", 0, 2, NORMAL_RAND)
	friction = 0.2
	gravity = list(0, 0.95)
	grow = 0.05

/particles/smoke/steam
	icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 2)
	fade = 1.5 SECONDS

/particles/smoke/steam/mild
	spawning = 1
	velocity = list(0, 0.3, 0)
	friction = 0.25

/particles/smoke/cig
	icon_state = list("steam_1" = 2, "steam_2" = 1, "steam_3" = 1)
	count = 1
	spawning = 0.05 // used to pace it out roughly in time with breath ticks
	position = list(-6, -2, 0)
	gravity = list(0, 0.75, 0)
	lifespan = 0.75 SECONDS
	fade = 0.75 SECONDS
	velocity = list(0, 0.2, 0)
	scale = 0.5
	grow = 0.01
	friction = 0.5
	color = "#d0d0d09d"

/particles/smoke/cig/big
	icon_state = list("steam_1" = 1, "steam_2" = 2, "steam_3" = 2)
	gravity = list(0, 0.5, 0)
	velocity = list(0, 0.1, 0)
	lifespan = 1 SECONDS
	fade = 1 SECONDS
	grow = 0.1
	scale = 0.75
	spawning = 1
	friction = 0.75
