// 9mm (Stechkin APS)

/obj/projectile/bullet/c9mm
	name = "9mm bullet"
	damage = 20
	armour_penetration = 5 // Small caliber, minimal penetration
	bleed_force = BLEED_BULLET_LIGHT

/obj/projectile/bullet/c9mm_ap
	name = "9mm armor-piercing bullet"
	damage = 18
	armour_penetration = 40
	bleed_force = BLEED_BULLET_LIGHT

/obj/projectile/bullet/incendiary/c9mm
	name = "9mm incendiary bullet"
	damage = 10
	fire_stacks = 1

/obj/projectile/bullet/c9mm_hp
	name = "9mm hollow-point bullet"
	damage = 25
	armour_penetration = -40 // Hollow-points expand on impact, terrible against armour
	bleed_force = BLEED_BULLET_DEVASTATING
	organ_damage_multiplier = ORGAN_DAMAGE_MULT_HEAVY // Hollow-points mushroom inside, devastating to organs


// 10mm (Stechkin)

/obj/projectile/bullet/c10mm
	name = "10mm bullet"
	damage = 28
	armour_penetration = 10 // Moderate caliber, slight penetration
	bleed_force = BLEED_BULLET_MEDIUM

/obj/projectile/bullet/c10mm/improv
	name = "10mm bullet"
	damage = 25
	bleed_force = BLEED_BULLET_MEDIUM

/obj/projectile/bullet/c10mm_ap
	name = "10mm armor-piercing bullet"
	damage = 25
	armour_penetration = 40
	bleed_force = BLEED_BULLET_MEDIUM

/obj/projectile/bullet/c10mm_hp
	name = "10mm hollow-point bullet"
	damage = 35
	armour_penetration = -50
	bleed_force = BLEED_BULLET_DEVASTATING
	organ_damage_multiplier = ORGAN_DAMAGE_MULT_HEAVY // Hollow-points expand inside the body

/obj/projectile/bullet/incendiary/c10mm
	name = "10mm incendiary bullet"
	damage = 14
	fire_stacks = 2

// x200law (Secoff, NT proprietary)

/obj/projectile/bullet/x200law
	name = "x200 LAW bullet"
	damage = 20
	armour_penetration = -100 // This thing is made for spacecraft use. Penetration is terrible on purpose.
	bleed_force = BLEED_BULLET_LIGHT
