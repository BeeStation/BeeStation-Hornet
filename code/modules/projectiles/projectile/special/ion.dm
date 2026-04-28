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
	target.emp_act(EMP_LIGHT)
	return BULLET_ACT_HIT

/obj/projectile/ion/weak

/obj/projectile/ion/weak/on_hit(atom/target, blocked = FALSE)
	..()
	target.emp_act(EMP_HEAVY)
	return BULLET_ACT_HIT
