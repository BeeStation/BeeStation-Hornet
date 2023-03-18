/obj/item/projectile/bullet/shuttle/ballistic
	name = "bullet"
	desc = "Will kill you."
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	hitsound_wall = "ricochet"
	flag = "bullet"
	eyeblur = 2
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	ricochets_max = 2
	ricochet_chance = 20
	nodamage = FALSE
	hitsound_wall = "ricochet"

/obj/item/projectile/bullet/shuttle/ballistic/guass
	icon_state = "guassstrong"
	name = "guass round"
	damage = 50
	armour_penetration = 40
	projectile_piercing = ALL

/obj/item/projectile/bullet/shuttle/ballistic/guass/on_hit(atom/target, blocked)
	var/turf/T = target
	//Make it so it can damage turfs
	if(istype(T))
		if(impact_effect_type && !hitscan)
			new impact_effect_type(T, target.pixel_x + rand(-8, 8), target.pixel_y + rand(-8, 8))
		//Boom
		explosion(T, 0, 0, 1, 0, flame_range = 2, adminlog = FALSE)
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/obj/item/projectile/bullet/shuttle/ballistic/guass/uranium
	icon_state = "gaussradioactive"
	name = "uranium-coated guass round"
	irradiate = 200
	damage = 80
	slur = 50
	knockdown = 80

/obj/item/projectile/bullet/shuttle/ballistic/point_defense
	name = "point defense round"
	damage = 15
	eyeblur = 0
	light_damage_factor = 7
	heavy_damage_factor = 10
