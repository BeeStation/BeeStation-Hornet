/obj/item/projectile/bullet/shuttle/beam
	name = "beam"
	desc = "A heavy damage laser that will deal good damage to people and machines, but does little to penetrate hull, especially that which is reflective."
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 40
	light_range = 2
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "laser"
	eyeblur = 2
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED
	ricochets_max = 50	//Honk!
	ricochet_chance = 0

//Penetrates the first layer of hull, then bounces around a lot on the inside.
/obj/item/projectile/bullet/shuttle/beam/check_ricochet()
	if(ricochet_chance < 80)
		ricochet_chance += 20
	return ..()

/obj/item/projectile/bullet/shuttle/beam/on_hit(atom/target, blocked)
	var/turf/T = target
	if(istype(T))
		if(T.flags_1 & CHECK_RICOCHET_1)
			return ..()
		T.ex_act(EXPLODE_LIGHT)
		qdel(src)
		return BULLET_ACT_HIT
	. = ..()

/obj/item/projectile/bullet/shuttle/beam/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/bullet/shuttle/beam/laser/heavy
	damage = 65
