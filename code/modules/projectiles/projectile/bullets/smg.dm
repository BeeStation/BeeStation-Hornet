// .45 (M1911 & C20r)

/obj/projectile/bullet/c45
	name = ".45 bullet"
	damage = 30

// 4.6x30mm (Autorifles)

/obj/projectile/bullet/c46x30mm
	name = "4.6x30mm bullet"
	damage = 20

/obj/projectile/bullet/c46x30mm_ap
	name = "4.6x30mm armor-piercing bullet"
	damage = 15
	armour_penetration = 40

/obj/projectile/bullet/incendiary/c46x30mm
	name = "4.6x30mm incendiary bullet"
	damage = 10
	fire_stacks = 1

//Slightly worse disabler, but fully automatic
/obj/projectile/bullet/c46x30mm_rubber
	name = "4.6x30mm rubber bullet"
	damage = 4
	stamina = 18
	ricochets_max = 2
	ricochet_chance = 110
	ricochet_incidence_leeway = 55
	ricochet_decay_chance = 0.8
	ricochet_decay_damage = 0.85
	armour_penetration = -15
