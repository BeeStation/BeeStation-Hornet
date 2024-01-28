/obj/projectile/bullet/reusable/arrow
	name = "Wooden arrow"
	desc = "Woosh!"
	icon_state = "arrow"
	damage = 20
	armour_penetration = -20
	embedds = TRUE
	ammo_type = /obj/item/ammo_casing/caseless/arrow

/obj/projectile/bullet/reusable/arrow/wood
	name = "wood arrow"
	damage = 15
	armour_penetration = 0
	embedds = TRUE
	ammo_type = /obj/item/ammo_casing/caseless/arrow/wood
	shrapnel_type = /obj/item/ammo_casing/caseless/arrow/wood
	hitsound = 'sound/effects/hit_punch.ogg'

/obj/projectile/bullet/reusable/arrow/cloth
	name = "cloth arrow"
	damage = 10
	armour_penetration = 0
	embedds = FALSE
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.6
	light_on = FALSE
	light_color = LIGHT_COLOR_FIRE
	var/lit = FALSE
	var/burnt = FALSE
	ammo_type = /obj/item/ammo_casing/caseless/arrow/cloth
	hitsound = 'sound/effects/hit_punch.ogg'

/obj/projectile/bullet/reusable/arrow/cloth/fire()
	if(lit)
		damage_type = BURN
		damage = 10
		hitsound = 'sound/items/welder.ogg'
		set_light_on(lit)
		update_overlays()
	else if(burnt)
		damage_type = initial(damage_type)
		damage = initial(damage)
		hitsound = initial(hitsound)
		update_overlays()
	. = .. ()

/obj/projectile/bullet/reusable/arrow/cloth/on_hit(atom/target, blocked)
	. = ..()
	if(lit)
		lit = FALSE
		burnt = TRUE
		ammo_type = /obj/item/ammo_casing/caseless/arrow/cloth/burnt
		if(iscarbon(target) && !blocked)
			var/mob/living/carbon/M = target
			M.IgniteMob()

/obj/projectile/bullet/reusable/arrow/cloth/update_overlays()
	. = .. ()
	cut_overlays()
	if(lit)
		. += "arrow_cloth_lit"
	else if(burnt)
		. += "arrow_cloth_burnt"


/obj/projectile/bullet/reusable/arrow/cloth/burnt
	name = "burnt cloth arrow"
	damage = 10
	armour_penetration = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/cloth/burnt

/obj/projectile/bullet/reusable/arrow/glass
	name = "glass arrow"
	icon_state = "arrow_glass"
	damage = 5
	armour_penetration = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/glass
	shrapnel_type = /obj/item/ammo_casing/caseless/arrow/glass

/obj/projectile/bullet/reusable/arrow/ash
	name = "Ashen arrow"
	desc = "Fire Hardened arrow."
	damage = 25
	ammo_type = /obj/item/ammo_casing/caseless/arrow/ash

/obj/projectile/bullet/reusable/arrow/bone //AP for ashwalkers
	name = "Bone arrow"
	desc = "An arrow made from bone and sinew."
	damage = 25
	armour_penetration = 40
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone

/obj/projectile/bullet/reusable/arrow/bronze
	name = "Bronze arrow"
	desc = "Bronze tipped arrow"
	damage = 20
	armour_penetration = 10
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bronze
