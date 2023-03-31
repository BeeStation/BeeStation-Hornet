/obj/item/projectile/bullet/spidernet
	name = "sticky webbing"
	icon_state = "spidernet"
	damage = 0

/obj/item/projectile/bullet/spidernet/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.Knockdown(6 SECONDS)
	else if(isliving(target)) //we do NOT want to apply this effect to carbons
		var/mob/living/L = target
		L.Immobilize(6 SECONDS)
	return ..()
