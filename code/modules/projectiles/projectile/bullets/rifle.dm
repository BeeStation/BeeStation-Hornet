// 5.56mm (M-90gl Carbine)

/obj/projectile/bullet/a556
	name = "5.56mm bullet"
	damage = 30
	armour_penetration = 20 // Military rifle round, decent penetration
	bleed_force = BLEED_BULLET

// 7.62 (Nagant Rifle / Pipe Rifle)

/obj/projectile/bullet/a762
	name = "7.62 bullet"
	damage = 40
	armour_penetration = 30
	bleed_force = BLEED_BULLET

/obj/projectile/bullet/a762_enchanted
	name = "enchanted 7.62 bullet"
	damage = 14
	stamina = 80

/obj/projectile/bullet/a762/weak
	damage = 28
	bleed_force = BLEED_BULLET
