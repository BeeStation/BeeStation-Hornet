// Honker

/obj/projectile/bullet/honker
	name = "banana"
	damage = 0
	paralyze = 60
	movement_type = FLYING
	projectile_piercing = ALL
	nodamage = TRUE
	hitsound = 'sound/items/bikehorn.ogg'
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana"
	range = 200

/obj/projectile/bullet/honker/Initialize(mapload)
	. = ..()
	SpinAnimation()

// Mime

/obj/projectile/bullet/mime
	damage = 20

/obj/projectile/bullet/mime/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.silent = max(M.silent, 10)

/obj/projectile/bullet/pepperball
	name = "pepperball"
	icon_state = "pepperball"
	damage = 35 //Disabler is 28 damage, flat AP
	var/tile_dropoff = 1
	damage_type = STAMINA
	armour_penetration = -20
	range = 22

/obj/projectile/bullet/pepperball/Range()
	..()
	if(damage > 0)
		damage -= tile_dropoff

	if(damage < 0)
		qdel(src)
