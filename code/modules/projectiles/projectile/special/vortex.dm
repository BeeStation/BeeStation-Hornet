/obj/item/projectile/energy/vortex
	name = "vortex beam"
	alpha = 0
	damage = 0
	damage_type = BURN
	reflectable = REFLECT_NORMAL
	nodamage = FALSE
	flag = "energy"
	range = 10
	projectile_phasing = ALL
	projectile_piercing = NONE

/obj/item/projectile/energy/vortex/Range()
	new /obj/effect/temp_visual/hierophant/blast/vortex(get_turf(src), firer, FALSE)
	return ..()
