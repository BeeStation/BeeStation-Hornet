// C3D (Borgs)

/obj/projectile/bullet/c3d
	damage = 17

// Mech LMG

/obj/projectile/bullet/lmg
	damage = 17

// Mech FNX-99

/obj/projectile/bullet/incendiary/fnx99
	damage = 17

// Turrets

/obj/projectile/bullet/manned_turret
	damage = 17

/obj/projectile/bullet/syndicate_turret
	damage = 17

// 7.12x82mm (SAW)

/obj/projectile/bullet/mm712x82
	name = "7.12x82mm bullet"
	damage = 35
	armour_penetration = 15 // Full-size rifle round, moderate penetration
	bleed_force = BLEED_BULLET

/obj/projectile/bullet/mm712x82_ap
	name = "7.12x82mm armor-piercing bullet"
	damage = 30
	armour_penetration = 75
	bleed_force = BLEED_BULLET

/obj/projectile/bullet/mm712x82_hp
	name = "7.12x82mm hollow-point bullet"
	damage = 40
	armour_penetration = -60
	bleed_force = BLEED_BULLET_DEVASTATING
	organ_damage_multiplier = ORGAN_DAMAGE_MULT_HEAVY

/obj/projectile/bullet/incendiary/mm712x82
	name = "7.12x82mm incendiary bullet"
	damage = 17
	fire_stacks = 3

/obj/projectile/bullet/mm712x82_match
	name = "7.12x82mm match bullet"
	damage = 30
	ricochets_max = 2
	ricochet_chance = 60
	ricochet_auto_aim_range = 4
	ricochet_incidence_leeway = 35
