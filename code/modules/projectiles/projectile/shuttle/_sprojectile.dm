//Travels through walls until it hits the target
/obj/item/projectile/bullet/shuttle
	name = "shuttle projectile"
	desc = "A projectile fired from someone else"
	icon_state = "84mm-hedp"
	movement_type = FLYING
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

/obj/item/projectile/bullet/shuttle/can_hit_target(atom/target, direct_target, ignore_loc, cross_failed)
	// Never hit targets if we missed
	if (miss || force_miss)
		return FALSE
	. = ..()

/obj/item/projectile/bullet/shuttle/on_hit(atom/target, blocked)
	//Damage turfs
	if (isclosedturf(target))
		var/turf/T = target
		//Apply damage overlay
		if(impact_effect_type && !hitscan)
			new impact_effect_type(T, target.pixel_x + rand(-8, 8), target.pixel_y + rand(-8, 8))
		//Damage the turf
		var/selected_damage = rand(0, 10)
		if(selected_damage >= light_damage_factor && selected_damage <= heavy_damage_factor - 1)
			T.ex_act(EXPLODE_LIGHT)
		if (selected_damage >= heavy_damage_factor && selected_damage <= devestate_damage_factor - 1)
			T.ex_act(EXPLODE_HEAVY)
		if (selected_damage >= devestate_damage_factor)
			T.ex_act(EXPLODE_DEVASTATE)
		//Damage objects in the turf
		for(var/obj/object in T)
			object.take_damage(damage)
	return ..()
