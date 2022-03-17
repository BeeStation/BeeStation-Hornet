/obj/item/projectile/lean
	name = "lean blast"
	icon_state = "leancutter"
	damage_type = BRUTE
	damage = 10
	range = 4
	dismemberment = 20
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	var/mine_range = 3 //mines this many additional tiles of rock
	tracer_type = /obj/effect/projectile/tracer/lean_cutter
	muzzle_type = /obj/effect/projectile/muzzle/lean_cutter
	impact_type = /obj/effect/projectile/impact/lean_cutter

/obj/item/projectile/lean/on_hit(atom/target)
	. = ..()
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled(firer)
		if(mine_range)
			mine_range--
			range++
		if(range > 0)
			return BULLET_ACT_FORCE_PIERCE

/obj/item/projectile/lean/adv
	damage = 14
	range = 5
	mine_range = 5

/obj/item/projectile/lean/adv/mech
	damage = 20
	range = 9
	mine_range = 3

/obj/item/projectile/lean/turret
	//Between normal and advanced for damage, made a beam so not the turret does not destroy glass
	name = "lean beam"
	damage = 24
	range = 7
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
