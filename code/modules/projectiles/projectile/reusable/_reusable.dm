/obj/projectile/bullet/reusable
	name = "reusable bullet"
	desc = "How do you even reuse a bullet?"
	var/ammo_type = /obj/item/ammo_casing/caseless
	var/dropped = FALSE
	//This actually checks if you want a copy of this projectile to spawn on hit. If this is set to false, but it actually embeds the only thing thats gonna happen is it will drop twice.
	var/embedds = FALSE
	impact_effect_type = null

/obj/projectile/bullet/reusable/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!embedds)
		handle_drop()
	else if(embedds && !iscarbon(target))
		handle_drop()

/obj/projectile/bullet/reusable/on_range()
	handle_drop()
	..()

/obj/projectile/bullet/reusable/proc/handle_drop()
	if(!dropped)
		var/turf/T = get_turf(src)
		new ammo_type(T)
		dropped = TRUE
