// Thruster jet particles for orbital thrusters
/particles/thruster_jet
	width = 500
	height = 500
	count = 0
	spawning = 5
	lifespan = 8
	fade = 20
	velocity = list(0, 0)
	drift = generator("vector", list(-0.4, 0), list(0.4, 0))
	gravity = list(0, -3)
	color = "#FF8800"
	position = generator("vector", list(-8, -10, 0), list(8, -10, 0), NORMAL_RAND)
