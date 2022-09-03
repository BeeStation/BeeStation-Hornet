
//Travels through walls until it hits the target
/obj/item/projectile/bullet/shuttle
	name = "shuttle projectile"
	desc = "A projectile fired from someone else"
	icon_state = "84mm-hedp"
	movement_type = FLYING
	projectile_piercing = ALL
	range = 120
	reflectable = NONE

	//Turf damage factor
	//Values are between 0 and 10
	var/light_damage_factor = 11
	var/heavy_damage_factor = 11
	var/devestate_damage_factor = 11

	var/obj_damage = 0
	var/miss = FALSE
	var/force_miss = FALSE

/obj/item/projectile/bullet/shuttle/on_hit(atom/target, blocked)
	if(miss || force_miss)
		return
	//Damage turfs
	if (isturf(target))
		var/turf/T = target
		//Apply damage overlay
		if(impact_effect_type && !hitscan)
			new impact_effect_type(T, target.pixel_x + rand(-8, 8), target.pixel_y + rand(-8, 8))
		//Damage the turf
		switch (rand(0, 10))
			if(light_damage_factor to heavy_damage_factor - 1)
				T.ex_act(EXPLODE_LIGHT)
			if (heavy_damage_factor to devestate_damage_factor - 1)
				T.ex_act(EXPLODE_HEAVY)
			if (devestate_damage_factor to INFINITY)
				T.ex_act(EXPLODE_DEVASTATE)
		//Damage objects in the turf
		for(var/obj/object in T)
			object.obj_integrity -= damage
		return BULLET_ACT_HIT
	return ..()

/obj/item/projectile/bullet/shuttle/pixel_move(trajectory_multiplier, hitscanning)
	. = ..()
	if(get_turf(src) == get_turf(original))
		on_hit(get_turf(src))
