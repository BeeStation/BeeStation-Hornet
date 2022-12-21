/obj/item/projectile/bullet/shuttle/missile
	name = "missile"
	desc = "You should probably move rather than stare at this."
	damage = 0
	armour_penetration = 100
	dismemberment = 0
	ricochets_max = 0
	pass_flags = ALL
	var/devastation = -1
	var/heavy = -1
	var/light_r = -1
	var/flash = -1
	var/fire = -1

/obj/item/projectile/bullet/shuttle/missile/on_hit(atom/target, blocked = FALSE)
	if(get_turf(target) != original && istype(target, /obj/structure/emergency_shield))
		return FALSE
	explosion(target, devastation, heavy, light_r, flash, 0, flame_range = fire)
	qdel(src)
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/shuttle/missile/breach
	name = "breaching missile"
	desc = "Putting holes in your hulls since 2042."
	devastation = -1
	heavy = 2
	light_r = 4
	flash = 5
	fire = 1

/obj/item/projectile/bullet/shuttle/missile/fire
	name = "incediary missile"
	desc = "An anti-personnel weapon, for roasting your enemies harder than any diss-track ever could."
	light_r = 2
	flash = 5
	fire = 4

/obj/item/projectile/bullet/shuttle/missile/mini
	name = "missile"
	desc = "A missile with a small payload."
	heavy = 1
	light_r = 3
	flash = 4
	fire = 2

/obj/item/projectile/bullet/shuttle/missile/mini/examine(mob/user)
	. = ..()
	if (in_range(src, user))
		. += "It has a label on it that reads <b>'Caution: This missile is extremely underwhelming.'</b>"
	else
		. += "It has a small label on the side, but you are too far away to read it."
