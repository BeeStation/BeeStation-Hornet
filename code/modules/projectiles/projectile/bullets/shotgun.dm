/obj/item/projectile/bullet/shotgun_slug
	name = "12g shotgun slug"
	damage = 60
	armour_penetration = -20

/obj/item/projectile/bullet/shotgun_beanbag
	name = "beanbag slug"
	damage = 5
	stamina = 55

/obj/item/projectile/bullet/incendiary/shotgun
	name = "incendiary slug"
	damage = 20

/obj/item/projectile/bullet/sleepy
	name = "soporific slug"
	damage = 0

/obj/item/projectile/bullet/sleepy/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && isliving(target))
		var/mob/living/L = target
		if(L.confused)
			L.Sleeping(50)
		else
			L.confused = 80
	return ..()

/obj/item/projectile/bullet/incendiary/shotgun/dragonsbreath
	name = "dragonsbreath pellet"
	damage = 5

/obj/item/projectile/bullet/shotgun_stunslug
	name = "stunslug"
	damage = 5
	paralyze = 100
	stutter = 5
	jitter = 20
	range = 7
	icon_state = "spark"
	color = "#FFFF00"

/obj/item/projectile/bullet/shotgun_meteorslug
	name = "meteorslug"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "dust"
	damage = 20
	paralyze = 20
	hitsound = 'sound/effects/meteorimpact.ogg'

/obj/item/projectile/bullet/shotgun_meteorslug/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ismovableatom(target))
		var/atom/movable/M = target
		var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
		M.safe_throw_at(throw_target, 3, 2)

/obj/item/projectile/bullet/shotgun_meteorslug/Initialize()
	. = ..()
	SpinAnimation()

/obj/item/projectile/bullet/shotgun_frag12
	name ="frag12 slug"
	damage = 25
	paralyze = 10

/obj/item/projectile/bullet/shotgun_frag12/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 0, 1)
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/pellet
	var/tile_dropoff = 0.75
	var/tile_dropoff_s = 0.5

/obj/item/projectile/bullet/pellet/shotgun_buckshot
	name = "buckshot pellet"
	damage = 9
	tile_dropoff = 0.5

/obj/item/projectile/bullet/pellet/shotgun_rubbershot
	name = "rubbershot pellet"
	damage = 3
	stamina = 9

/obj/item/projectile/bullet/pellet/shotgun_incapacitate
	name = "incapacitating pellet"
	damage = 1
	stamina = 5

/obj/item/projectile/bullet/pellet/Range()
	..()
	if(damage > 0)
		damage -= tile_dropoff
	if(stamina > 0)
		stamina -= tile_dropoff_s
	if(damage < 0 && stamina < 0)
		qdel(src)

/obj/item/projectile/bullet/pellet/shotgun_improvised
	tile_dropoff = 0.55		//Come on it does 6 damage don't be like that.
	damage = 6

/obj/item/projectile/bullet/pellet/shotgun_improvised/Initialize()
	. = ..()
	range = rand(1, 8)

/obj/item/projectile/bullet/pellet/shotgun_improvised/on_range()
	do_sparks(1, TRUE, src)
	..()

// Mech Scattershot

/obj/item/projectile/bullet/scattershot
	damage = 18

//Breaching Ammo

/obj/item/projectile/bullet/shotgun_breaching
	name = "12g breaching round"
	desc = "A breaching round designed to destroy airlocks and windows with only a few shots, but is ineffective against other targets."
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	damage = 10 //does shit damage to everything except doors and windows

/obj/item/projectile/bullet/shotgun_breaching/on_hit(atom/target)
	if(istype(target, /obj/structure/window) || istype(target, /obj/structure/grille) || istype(target, /obj/machinery/door) || istype(target, /obj/structure/door_assembly))
		damage = 500 //one shot to break a window or grille, or 3 shots to breach an airlock door
	..()
