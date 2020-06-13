/obj/item/projectile/bullet/shuttle/missile
	name = "missile"
	desc = "You should probably move rather than stare at this"
	damage = 0
	armour_penetration = 100
	dismemberment = 0
	ricochets_max = 0
	var/devastation = -1
	var/heavy = -1
	var/light_r = -1
	var/flash = -1
	var/fire = -1

/obj/item/projectile/bullet/shuttle/missile/on_hit(atom/target, blocked = FALSE)
	if(get_turf(target) != original)
		return FALSE
	explosion(target, devastation, heavy, light_r, flash, 0, flame_range = fire)
	qdel(src)
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/shuttle/missile/breach
	name = "breaching missile"
	desc = "putting holes in your hulls since 2042"
	devastation = -1
	heavy = 1
	light_r = 2
	flash = 1
	fire = 1

/obj/item/projectile/bullet/shuttle/missile/fire
	name = "incediary missile"
	desc = "an anti personnel weapon, for roasting your enemies"
	light_r = 3
	flash = 3
	fire = 4

/obj/item/projectile/bullet/shuttle/missile/mini
	name = "missile"
	desc = "a missile with a small payload"
	heavy = 1
	light_r = 3
	flash = 2
	fire = 2
