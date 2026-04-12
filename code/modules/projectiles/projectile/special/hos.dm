// Special HoS 3D-printed rounds

/obj/projectile/bullet/hos
	name = "3D printed ballistic round"
	damage = 20  // About same damage as 4.6x30

/obj/projectile/bullet/hos/pellet
	name = "3D printed plastic pellet"
	damage = 4
	stamina = 20
	armour_penetration = -15
	bleed_force = BLEED_TINY

/obj/projectile/bullet/shotgun_breaching/hos
	name = "3D printed breaching round"

/obj/projectile/bullet/shotgun_breaching/hos/on_hit(atom/target)
	..()
	if(isstructure(target) || ismachinery(target)) // 4 shots to fully destroy a door
		damage = 150
	else if(isturf(target)) // About 12 for a regular wall, about 30 for a reinforced wall
		damage = 50
