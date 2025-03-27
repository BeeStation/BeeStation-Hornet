/obj/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	armor_flag = ENERGY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ion

/obj/projectile/ion/on_hit(atom/target, blocked = FALSE)
	..()
	empulse(target, 1, 1)
	return BULLET_ACT_HIT

/obj/projectile/ion/weak

/obj/projectile/ion/weak/on_hit(atom/target, blocked = FALSE)
	..()
	empulse(target, 0, 0)
	return BULLET_ACT_HIT
