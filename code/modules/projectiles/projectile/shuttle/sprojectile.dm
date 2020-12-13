//Travels through walls until it hits the target
/obj/item/projectile/bullet/shuttle
	name = "shuttle projectile"
	desc = "A projectile fired from someone else"
	icon_state = "84mm-hedp"
	movement_type = FLYING | UNSTOPPABLE
	range = 120
	reflectable = NONE

	var/obj_damage = 0
	var/miss = FALSE
	var/force_miss = FALSE

/obj/item/projectile/bullet/shuttle/on_hit(atom/target, blocked)
	if(miss || force_miss)
		return
	. = ..()

/obj/item/projectile/bullet/shuttle/pixel_move(trajectory_multiplier, hitscanning)
	. = ..()
	if(get_turf(src) == get_turf(original))
		on_hit(get_turf(src))
