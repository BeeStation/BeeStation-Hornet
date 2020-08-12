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
	damage = 25
	speed = 0.3
	movement_type = FLYING | UNSTOPPABLE
	armour_penetration = 40

/obj/item/projectile/bullet/shuttle/ballistic/guass/uranium
	icon_state = "gaussradioactive"
	name = "uranium-coated guass round"
	irradiate = 200
	slur = 50
	knockdown = 80
