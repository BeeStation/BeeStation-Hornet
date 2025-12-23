// Thruster jet particles for orbital thrusters
/particles/thruster_jet
	icon = 'icons/effects/particles/misc.dmi'
	icon_state = list("sparkle_1", "sparkle_2")
	width = 200
	height = 600
	count = 10000 // Dummy ammount to be scaled
	spawning = 50 // Dummy ammount to be scaled
	lifespan = 1 SECONDS
	fade = 0.5 SECONDS
	fadein = 0.5 SECONDS
	velocity = list(0, 0)
	drift = generator("vector", list(-0.4, 0), list(0.4, 0))
	gravity = list(0, -3)
	// Randomize color from bright cyan-blue-purple to deep purple
	color = generator("color", list("#b4ffff", "#8d64ff", "#dfa0ff"), list("#001eb3", "#00b4b7", "#4400AA"))
	// Spread particles in an oval pattern
	position = generator("box", list(-24, -6, 0), list(24, 14, 0), UNIFORM_RAND)
