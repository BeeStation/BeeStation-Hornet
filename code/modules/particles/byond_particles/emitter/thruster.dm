// Thruster jet emitter for orbital thrusters
/obj/emitter/thruster_jet
	alpha = 225
	particles = new /particles/thruster_jet

/obj/emitter/thruster_jet/Initialize(mapload)
	. = ..()
	add_filter("outline", 1, list(type = "outline", size = 2, color = "#FF3300"))
	add_filter("bloom", 2, list(type = "bloom", threshold = rgb(255,128,100), size = 6, offset = 3, alpha = 200))
