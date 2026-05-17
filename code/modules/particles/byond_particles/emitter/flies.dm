/obj/emitter/flies
	particles = new/particles/flies

/particles/flies
	position = generator("box", list(-5, -5, -5), list(5, 5, 5), NORMAL_RAND)
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = list("pest_particle")
	count = 4
	spawning = 4
	spin = generator("num", 30, 40, NORMAL_RAND)
	rotation = generator("num", 0, 360, NORMAL_RAND)
	lifespan = 8 SECONDS
	fade = 1
	fadein = 1
