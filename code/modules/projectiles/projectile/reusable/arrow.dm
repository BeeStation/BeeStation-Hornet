/obj/projectile/bullet/reusable/arrow
	name = "Wooden arrow"
	desc = "Woosh!"
	icon_state = "arrow"
	damage = 20
	armour_penetration = -20
	embedds = TRUE
	ammo_type = /obj/item/ammo_casing/caseless/arrow

///WOOD ARROWS///

/obj/projectile/bullet/reusable/arrow/wood
	name = "wooden arrow shaft"
	icon_state = "arrow_wood"
	damage = 10
	bleed_force = BLEED_TINY
	armour_penetration = 0
	embedds = FALSE
	ammo_type = /obj/item/ammo_casing/caseless/arrow/wood
	hitsound = 'sound/effects/hit_punch.ogg'

/obj/projectile/bullet/reusable/arrow/wood/sharp
	name = "sharp wood arrow shaft"
	damage = 15
	bleed_force = BLEED_CUT
	embedds = TRUE
	ammo_type = /obj/item/ammo_casing/caseless/arrow/wood/sharp
	shrapnel_type = /obj/item/ammo_casing/caseless/arrow/wood/sharp
	hitsound = 'sound/weapons/pierce.ogg'

/obj/projectile/bullet/reusable/arrow/cloth
	name = "cloth arrow"
	icon_state = "arrow_cloth"
	damage = 10
	bleed_force = 0
	armour_penetration = 10  //blunt force trauma
	embedds = FALSE
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 0.5
	light_on = FALSE
	light_color = LIGHT_COLOR_FIRE
	var/heat = 1500
	var/lit = FALSE
	var/burnt = FALSE
	ammo_type = /obj/item/ammo_casing/caseless/arrow/cloth
	hitsound = 'sound/effects/hit_punch.ogg'

/obj/projectile/bullet/reusable/arrow/cloth/fire()
	if(lit)
		damage_type = BURN
		damage = 10
		set_light_on(lit)
		update_overlays()
	else if(burnt)
		damage_type = initial(damage_type)
		damage = initial(damage)
		hitsound = initial(hitsound)
		update_overlays()
	. = .. ()

/obj/projectile/bullet/reusable/arrow/cloth/on_hit(atom/target, blocked)
	if(lit)
		lit = FALSE
		burnt = TRUE
		if(iscarbon(target) && !blocked)
			var/mob/living/carbon/M = target
			M.IgniteMob()
		if(name == "cloth arrow")
			ammo_type = /obj/item/ammo_casing/caseless/arrow/cloth/burnt
		else if(name == "bone cloth arrow")
			ammo_type = /obj/item/ammo_casing/caseless/arrow/cloth/burnt/bone
		else if(name == "bamboo cloth arrow")
			ammo_type = /obj/item/ammo_casing/caseless/arrow/cloth/burnt/bamboo
	. = ..()

/obj/projectile/bullet/reusable/arrow/cloth/update_overlays()
	. = .. ()
	cut_overlays()
	if(lit)
		add_overlay("[initial(icon_state)]_lit")
	else if(burnt)
		add_overlay("[initial(icon_state)]_burnt")


/obj/projectile/bullet/reusable/arrow/cloth/burnt
	name = "burnt cloth arrow"
	icon_state = "arrow_cloth_burnt"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/cloth/burnt

/obj/projectile/bullet/reusable/arrow/glass
	name = "glass arrow"
	icon_state = "arrow_glass"
	damage = 5
	embedds = FALSE
	armour_penetration = 5
	ammo_type = /obj/item/ammo_casing/caseless/arrow/wood //The glass breaks on impact
	shrapnel_type = /obj/item/shard
	hitsound = 'sound/effects/glass_step.ogg'

/obj/projectile/bullet/reusable/arrow/bottle
	name = "bottle arrow"
	icon_state = "arrow_bottle"
	damage = 5
	armour_penetration = 0
	embedds = FALSE
	hitsound = 'sound/effects/hit_punch.ogg'
	ammo_type = /obj/item/ammo_casing/caseless/arrow/wood

/obj/projectile/bullet/reusable/arrow/bottle/Initialize(mapload)
	. = ..()
	create_reagents(30, NO_REACT)

/obj/projectile/bullet/reusable/arrow/bottle/on_hit(atom/target, blocked)
	. = ..()
	chem_splash(get_turf(src), 1, list(reagents))
	playsound(src, "shatter", 75, 1)
	new /obj/item/broken_bottle(get_turf(src))

/obj/projectile/bullet/reusable/arrow/hollowpoint
	name = "bone point wooden arrow"
	icon_state = "arrow_bonepoint"
	damage = 15
	armour_penetration = 5
	embedds = TRUE
	bleed_force = BLEED_CUT
	ammo_type = /obj/projectile/bullet/reusable/arrow/hollowpoint
	shrapnel_type = /obj/item/ammo_casing/caseless/arrow/hollowpoint

/obj/projectile/bullet/reusable/arrow/hollowpoint/Initialize(mapload)
	. = ..()
	create_reagents(5, NO_REACT)

/obj/projectile/bullet/reusable/arrow/hollowpoint/on_hit(atom/target, blocked)
	. = ..()
	var/mob/living/L
	if(!istype(target, L))
		return
	//if(!target.can_inject(user, 1))
	//	amount_inject = 5
	reagents.reaction(target,INJECT,5)
	reagents.trans_to(target,5)

/obj/projectile/bullet/reusable/arrow/hollowpoint/bamboopoint
	name = "bamboo point wooden arrow"
	icon_state = "arrow_bamboopoint"
	damage = 10
	armour_penetration = 5
	embedds = TRUE
	bleed_force = BLEED_CUT
	ammo_type = /obj/projectile/bullet/reusable/arrow/hollowpoint/bamboopoint
	shrapnel_type = /obj/item/ammo_casing/caseless/arrow/hollowpoint/bamboopoint


///BONE ARROWS///

/obj/projectile/bullet/reusable/arrow/bone
	name = "bone arrow shaft"
	damage = 12
	bleed_force = 0
	armour_penetration = 10
	embedds = FALSE
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone
	hitsound = 'sound/effects/hit_punch.ogg'

/obj/projectile/bullet/reusable/arrow/bone/sharp
	name = "sharp bone arrow shaft"
	damage = 17
	bleed_force = BLEED_SCRATCH
	embedds = TRUE
	ammo_type = /obj/item/ammo_casing/caseless/arrow/wood/sharp
	shrapnel_type = /obj/item/ammo_casing/caseless/arrow/wood/sharp
	hitsound = 'sound/weapons/pierce.ogg'

/obj/projectile/bullet/reusable/arrow/cloth/bone
	name = "bone cloth arrow"
	damage = 12
	bleed_force = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/cloth/bone

/obj/projectile/bullet/reusable/arrow/cloth/burnt/bone
	name = "burnt bone cloth arrow"
	bleed_force = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/cloth/burnt/bone

/obj/projectile/bullet/reusable/arrow/glass/bone
	name = "glass bone arrow"
	damage = 7
	bleed_force = BLEED_SURFACE
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone

/obj/projectile/bullet/reusable/arrow/bottle/bone
	name = "bone bottle arrow"
	damage = 7
	bleed_force = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone

/obj/projectile/bullet/reusable/arrow/hollowpoint/bone
	name = "bone point arrow"
	damage = 17
	armour_penetration = 5
	bleed_force = BLEED_SURFACE
	ammo_type = /obj/projectile/bullet/reusable/arrow/hollowpoint/bone
	shrapnel_type = /obj/item/ammo_casing/caseless/arrow/hollowpoint/bone

/obj/projectile/bullet/reusable/arrow/hollowpoint/bamboopoint/bone
	name = "bamboo point bone arrow"
	damage = 12
	armour_penetration = 10
	embedds = TRUE
	bleed_force = BLEED_SURFACE
	ammo_type = /obj/projectile/bullet/reusable/arrow/hollowpoint/bamboopoint/bone
	shrapnel_type = /obj/item/ammo_casing/caseless/arrow/hollowpoint/bamboopoint/bone

///BAMBOO ARROWS///

/obj/projectile/bullet/reusable/arrow/bamboo
	name = "bamboo arrow shaft"
	damage = 8
	bleed_force = 0
	armour_penetration = 10
	embedds = FALSE
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bamboo
	hitsound = 'sound/effects/hit_punch.ogg'

/obj/projectile/bullet/reusable/arrow/bamboo/sharp
	name = "sharp bamboo arrow shaft"
	damage = 13
	bleed_force = BLEED_CUT
	embedds = TRUE
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bamboo/sharp
	shrapnel_type = /obj/item/ammo_casing/caseless/arrow/bamboo/sharp
	hitsound = 'sound/weapons/pierce.ogg'

/obj/projectile/bullet/reusable/arrow/cloth/bamboo
	name = "bamboo cloth arrow"
	damage = 8
	armour_penetration = 20
	bleed_force = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/cloth/bamboo

/obj/projectile/bullet/reusable/arrow/cloth/burnt/bamboo
	name = "burnt bamboo cloth arrow"
	bleed_force = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/cloth/burnt/bamboo

/obj/projectile/bullet/reusable/arrow/glass/bamboo
	name = "glass bamboo arrow"
	damage = 3
	bleed_force = BLEED_DEEP_WOUND
	ammo_type = /obj/projectile/bullet/reusable/arrow/bamboo

/obj/projectile/bullet/reusable/arrow/bottle/bamboo
	name = "bone bottle arrow"
	damage = 3
	bleed_force = BLEED_TINY
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bamboo

/obj/projectile/bullet/reusable/arrow/hollowpoint/bamboo
	name = "bone point bamboo arrow"
	damage = 8
	armour_penetration = 10
	bleed_force = BLEED_SURFACE
	ammo_type = /obj/projectile/bullet/reusable/arrow/hollowpoint/bamboo
	shrapnel_type = /obj/item/ammo_casing/caseless/arrow/hollowpoint/bamboo

/obj/projectile/bullet/reusable/arrow/hollowpoint/bamboopoint/bamboo
	name = "bamboo point arrow"
	damage = 8
	armour_penetration = 15
	embedds = TRUE
	bleed_force = BLEED_CUT
	ammo_type = /obj/projectile/bullet/reusable/arrow/hollowpoint/bamboopoint/bamboo
	shrapnel_type = /obj/item/ammo_casing/caseless/arrow/hollowpoint/bamboopoint/bamboo

/obj/projectile/bullet/reusable/arrow/sm
	name = "SM arrow"
	desc = "Weaponized SM. Fear it."
	icon_state = "arrow_sm"
	damage = 0
	armour_penetration = 0
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 1
	light_on = TRUE
	light_color = LIGHT_COLOR_HOLY_MAGIC
	ammo_type = /obj/item/ammo_casing/caseless/arrow/sm

/obj/projectile/bullet/reusable/arrow/sm/on_hit(atom/target, blocked)
	. = ..()
	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/T = target
		if(!blocked)
			consume(T)
			//else
			//	var/obj/item/bodypart/limbhit = T.check_limb_hit(def_zone)   THIS BITCH STILL BROKEN RAHHHHHHHH
			//	limbhit.dismember()
			//	playsound(src, 'sound/effects/supermatter.ogg', 75, 1)
			//	radiation_pulse(src, 500, 2)
		else
			handle_drop()


/obj/projectile/bullet/reusable/arrow/sm/proc/consume(atom/movable/AM, mob/user)
	if(ismob(AM))
		var/mob/victim = AM
		victim.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
		victim.dust()
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(victim)].", "supermatter")
	else
		investigate_log("has consumed [AM].", "supermatter")
		qdel(AM)
	if(user)
		user.visible_message("<span class='danger'>As [AM] is hit with with \the [src], both flash into dust and silence fills the room...</span>",\
			"<span class='italics'>Everything suddenly goes silent.</span>")
		user.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
		user.dust()
	radiation_pulse(src, 500, 2)
	playsound(src, 'sound/effects/supermatter.ogg', 75, 1)
	QDEL_NULL(src)

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
