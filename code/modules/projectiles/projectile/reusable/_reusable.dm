/obj/item/projectile/bullet/reusable
	name = "reusable bullet"
	desc = "How do you even reuse a bullet?"
	impact_effect_type = null
	embedding = null
	shrapnel_type = null

/obj/item/projectile/bullet/reusable/on_hit(atom/target, blocked = FALSE)
	. = ..()
	handle_drop()

/obj/item/projectile/bullet/reusable/on_range()
	handle_drop()
	..()

/obj/item/projectile/bullet/reusable/proc/handle_drop()
	if(!dropped)
		var/turf/T = get_turf(src)
		new ammo_type(T)
		dropped = TRUE
