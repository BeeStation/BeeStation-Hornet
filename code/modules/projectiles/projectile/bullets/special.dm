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
	damage = 0
	stamina = 30 //Disabler is 28 damage
	eyeblur = 2
	range = 22

/obj/projectile/bullet/pepperball/on_hit(atom/target)
	if (iscarbon(target))
		var/mob/living/carbon/T = target
		if (T.is_eyes_covered())
			eyeblur = 0
			stamina -= 13
		if (T.is_mouth_covered())
			stamina -= 13
	..()
