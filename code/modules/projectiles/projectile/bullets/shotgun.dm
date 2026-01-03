/obj/projectile/bullet/shotgun_slug
	name = "12g shotgun slug"
	damage = 35 // single slug, high damage, low armour penetration, 3 slugs to crit unarmoured
	armour_penetration = 25

/obj/projectile/bullet/shotgun_gold
	name = "golden shotgun slug"
	damage = 28
	armour_penetration = 20

/obj/projectile/bullet/shotgun_bronze
	name = "bronze shotgun slug"
	damage = 5
	paralyze = 10
	stamina = 15
	stutter = 5
	armour_penetration = -15

/obj/projectile/bullet/shotgun_honk
	name = "honk shotgun slug"
	icon_state = "banana"
	damage = 1 // 1 damage because comedy.
	knockdown = 100
	armour_penetration = -5
	bleed_force = 0

/obj/projectile/bullet/shotgun_beanbag
	name = "beanbag slug"
	damage = 5
	stamina = 40
	jitter = 5
	armour_penetration = -10
	bleed_force = BLEED_TINY

/obj/projectile/bullet/incendiary/shotgun
	name = "incendiary slug"
	damage = 15

/obj/projectile/bullet/incendiary/shotgun/dragonsbreath
	name = "dragonsbreath pellet"
	damage = 4

/obj/projectile/bullet/shotgun_stunslug
	name = "stunslug"
	damage = 5
	paralyze = 25
	stamina = 25
	stutter = 5
	jitter = 5
	range = 8
	icon_state = "spark"
	color = "#FFFF00"

/obj/projectile/bullet/pellet
	var/tile_dropoff = 0.75
	var/tile_dropoff_s = 0.5
	ricochets_max = 1
	ricochet_chance = 50
	ricochet_decay_chance = 0.9
	bleed_force = BLEED_SCRATCH

/obj/projectile/bullet/pellet/shotgun_buckshot/armour_piercing
	name = "armour-piercing buckshot pellet"
	damage = 6
	tile_dropoff = 0.5
	armour_penetration = 60

/obj/projectile/bullet/pellet/shotgun_buckshot // Seperated to AP and normal buckshot
	name = "buckshot pellet"
	damage = 8
	tile_dropoff = 0.5
	armour_penetration = 20

/obj/projectile/bullet/pellet/shotgun_rubbershot
	name = "rubbershot pellet"
	damage = 3
	stamina = 12
	tile_dropoff = 0.5
	tile_dropoff_s = 0
	ricochets_max = 2
	ricochet_chance = 80
	ricochet_incidence_leeway = 60
	ricochet_decay_chance = 0.75
	armour_penetration = -15
	bleed_force = BLEED_TINY

/obj/projectile/bullet/pellet/shotgun_rubbershot/Range()
	if(damage <= 0 && tile_dropoff_s == 0)
		damage = 0
		tile_dropoff = 0
		tile_dropoff_s = 0.5
	..()

/obj/projectile/bullet/pellet/shotgun_incapacitate
	name = "incapacitating pellet"
	damage = 4
	stamina = 15

/obj/projectile/bullet/pellet/Range()
	..()
	if(damage > 0)
		damage -= tile_dropoff
	if(stamina > 0)
		stamina -= tile_dropoff_s
	if(damage < 0 && stamina < 0)
		qdel(src)

/obj/projectile/bullet/pellet/shotgun_metal
	tile_dropoff = 0.75
	damage = 8
	range = 6
	ricochets_max = 0
	shrapnel_type = /obj/item/shrapnel/bullet/shotgun

/obj/projectile/bullet/pellet/shotgun_glass
	tile_dropoff = 0.5
	damage = 6
	range = 8
	ricochets_max = 0
	shrapnel_type = /obj/item/shrapnel/bullet/shotgun/glass

/obj/projectile/bullet/pellet/shotgun_glass/Initialize(mapload)
	. = ..()

	if(prob(20)) //Each 'pellet' has a 20 percent chance to not shrapnel/attempt embedding
		shrapnel_type = null

// Mech Scattershot

/obj/projectile/bullet/scattershot
	damage = 18
	bleed_force = BLEED_SURFACE

//Breaching Ammo

/obj/projectile/bullet/shotgun_breaching
	name = "12g breaching round"
	desc = "A breaching round designed to destroy minor objects and windows with only a few shots, but is ineffective against other targets."
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	damage = 10 //does shit damage to everything except doors and windows
	bleed_force = BLEED_SURFACE

/obj/projectile/bullet/shotgun_breaching/on_hit(atom/target)
	if(isstructure(target) || ismachinery(target))
		damage = 500
	if (isturf(target))
		damage = 150 // 3 shots for normal walls 8 for rwalls
	..()
