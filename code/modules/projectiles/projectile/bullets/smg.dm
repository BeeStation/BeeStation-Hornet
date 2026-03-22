// .45 (M1911 & C20r)

/obj/projectile/bullet/c45
	name = ".45 bullet"
	damage = 28
	armour_penetration = 10 // Heavier pistol round, slight penetration
	bleed_force = BLEED_BULLET_MEDIUM

// 4.6x30mm (Autorifles)

/obj/projectile/bullet/c46x30mm
	name = "4.6x30mm bullet"
	damage = 17
	armour_penetration = 15 // PDW round, designed for moderate armour penetration
	bleed_force = BLEED_BULLET_LIGHT

/obj/projectile/bullet/c46x30mm_ap
	name = "4.6x30mm armor-piercing bullet"
	damage = 14
	armour_penetration = 40
	bleed_force = BLEED_BULLET_LIGHT

/obj/projectile/bullet/incendiary/c46x30mm
	name = "4.6x30mm incendiary bullet"
	damage = 10
	fire_stacks = 1

//Slightly worse disabler, but fully automatic
/obj/projectile/bullet/c46x30mm_rubber
	name = "4.6x30mm rubber bullet"
	damage = 3
	stamina = 18
	ricochets_max = 2
	ricochet_chance = 110
	ricochet_incidence_leeway = 55
	ricochet_decay_chance = 0.8
	ricochet_decay_damage = 0.85
	armour_penetration = -15
	bleed_force = BLEED_SCRATCH
	organ_damage_multiplier = 0 // Rubber, non-lethal
