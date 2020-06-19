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
	ricochet_chance = 50
	var/ignore_ricochet_chance = 70

/obj/item/projectile/bullet/shuttle/beam/Initialize()
	. = ..()
	if(prob(ignore_ricochet_chance))
		ricochet_chance = 0

/obj/item/projectile/bullet/shuttle/beam/on_hit(atom/target, blocked)
	if(miss)
		return
	var/turf/T = target
	//Make it so it can damage turfs
	if(istype(T))
		if(impact_effect_type && !hitscan)
			new impact_effect_type(T, target.pixel_x + rand(-8, 8), target.pixel_y + rand(-8, 8))
		T.ex_act(EXPLODE_LIGHT)
		for(var/obj/object in T)
			object.obj_integrity -= damage
		qdel(src)
		return BULLET_ACT_HIT
	return ..()

/obj/item/projectile/bullet/shuttle/beam/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/bullet/shuttle/beam/laser/heavy
	damage = 65
