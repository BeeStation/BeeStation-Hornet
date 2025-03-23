// 5.56mm (M-90gl Carbine)

/obj/projectile/bullet/a556
	name = "5.56mm bullet"
	damage = 35
	sharpness = SHARP_X

// 7.62 (Nagant Rifle / Pipe Rifle)

/obj/projectile/bullet/a762
	name = "7.62 bullet"
	damage = 40
	sharpness = SHARP_X

/obj/projectile/bullet/a762_enchanted
	name = "enchanted 7.62 bullet"
	damage = 20
	stamina = 80
	sharpness = SHARP_X

/obj/projectile/bullet/a762/improv
	//Possible damage range between 27 and 30
	damage = 30
	sharpness = SHARP_IV

/obj/projectile/bullet/a762/improv/Initialize(mapload)
	. = ..()
	//Actual damage of projectile is reduced by 0 to 3 damage
	damage -= (round(rand(0, 3), 1))

/obj/projectile/bullet/a762/improv/hotload
	//Possible damage between 32 and 35
	damage = 35
	speed = 0.7
	sharpness = SHARP_V
