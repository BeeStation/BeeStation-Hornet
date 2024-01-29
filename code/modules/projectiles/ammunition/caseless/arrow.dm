/obj/item/ammo_casing/caseless/arrow
	name = "arrow of questionable material"
	desc = "You shouldn't be seeing this arrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow
	caliber = "arrow"
	icon_state = "arrow"
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 3 //good luck hitting someone with the pointy end of the arrow
	throw_speed = 3

/obj/item/ammo_casing/caseless/arrow/wood
	name = "wooden arrow"
	desc = "A pointy stick carved out of wood. Not really technogically advanced. Don't expect it to pierce any armour... or flesh..."
	icon_state = "arrow_wood"
	force = 5
	armour_penetration = -20
	projectile_type = /obj/projectile/bullet/reusable/arrow/wood
	embedding = list(embed_chance=50,
	fall_chance = 0,
	jostle_chance = 10,
	ignore_throwspeed_threshold = FALSE,
	pain_stam_pct = 1,
	pain_mult = 1,
	jostle_pain_mult = 2,
	remove_pain_mult = 2,
	rip_time = 1.5)

/obj/item/ammo_casing/caseless/arrow/cloth
	name = "cloth arrow"
	desc = "An arrow with a 'tip' wrapped in cloth. Being hit with this is like being hit with a high velocity pillow."
	icon_state = "arrow_cloth"
	force = 5
	armour_penetration = 0
	heat = 1500
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.6
	light_on = FALSE
	light_color = LIGHT_COLOR_FIRE
	var/lit = FALSE
	var/burnt = FALSE
	projectile_type = /obj/projectile/bullet/reusable/arrow/cloth

/obj/item/ammo_casing/caseless/arrow/cloth/fire_act(exposed_temperature, exposed_volume)
	ignite()

/obj/item/ammo_casing/caseless/arrow/cloth/attackby(obj/item/I, mob/user, params)
	if(I.heat > 900)
		ignite()

/obj/item/ammo_casing/caseless/arrow/cloth/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(lit && M.IgniteMob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
		log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")

/obj/item/ammo_casing/caseless/arrow/cloth/is_hot()
	return lit * heat

/obj/item/ammo_casing/caseless/arrow/cloth/extinguish()
	burnout()
	return ..()

/obj/item/ammo_casing/caseless/arrow/cloth/proc/ignite()
	var/obj/projectile/bullet/reusable/arrow/cloth/arrow = BB
	if(!lit && !burnt)
		playsound(src, "sound/items/match_strike.ogg", 15, TRUE)
		lit = TRUE
		arrow.lit = TRUE
		damtype = BURN
		force = 10
		hitsound = 'sound/items/welder.ogg'
		name = "lit [initial(name)]"
		desc = "An arrow with a 'tip' wrapped in cloth. Being hit with this is like being hit with a high velocity pillow. Except its on fire. Fear the pillow."
		attack_verb = list("burnt","singed")
		set_light_on(lit)
	update_overlays()

/obj/item/ammo_casing/caseless/arrow/cloth/proc/burnout()
	var/obj/projectile/bullet/reusable/arrow/cloth/arrow = BB
	if(lit)
		lit = FALSE
		arrow.lit = FALSE
		burnt = TRUE
		arrow.burnt = TRUE
		damtype = initial(damtype)
		force = initial(force)
		name = "burnt [initial(name)]"
		desc = "An arrow with a 'tip' wrapped in burnt cloth. Being hit with this is like being hit with a high velocity pillow. Full of ash."
		set_light_on(lit)
	update_overlays()
	arrow.update_overlays()

/obj/item/ammo_casing/caseless/arrow/cloth/update_overlays()
	. = .. ()
	cut_overlays()
	if(lit)
		add_overlay("arrow_cloth_lit")
	if(burnt)
		add_overlay("arrow_cloth_burnt")

/obj/item/ammo_casing/caseless/arrow/cloth/burnt
	name = "burnt cloth arrow"
	desc = "An arrow with a 'tip' wrapped in burnt cloth. Being hit with this is like being hit with a high velocity pillow. Full of ash."
	icon_state = "arrow_cloth_burnt"
	force = 5
	armour_penetration = 0
	burnt = TRUE
	projectile_type = /obj/projectile/bullet/reusable/arrow/cloth/burnt

/obj/item/ammo_casing/caseless/arrow/glass
	name = "glass arrow"
	desc = "A crude 'arrow' with a glass shard as a tip. You don't want to be shot with this."
	icon_state = "arrow_glass"
	force = 10
	armour_penetration = 0
	sharpness = IS_SHARP
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	projectile_type = /obj/projectile/bullet/reusable/arrow/glass
	embedding = list(embed_chance=100,
	fall_chance = 10,
	jostle_chance = 10,
	ignore_throwspeed_threshold = FALSE,
	pain_stam_pct = 1,
	pain_mult = 0.25,
	jostle_pain_mult = 2,
	remove_pain_mult = 1,
	rip_time = 5)

/obj/item/ammo_casing/caseless/arrow/bottle
	name = "bottle arrow"
	desc = "A tiny bottle tied with string to an arrow. Cute, if not filled with acid."
	icon_state = "arrow_bottle"
	force = 5
	armour_penetration = 0
	projectile_type = /obj/projectile/bullet/reusable/arrow/bottle
	var/reagent_amount = 30

/obj/item/ammo_casing/caseless/arrow/bottle/Initialize(mapload)
	. = ..()
	create_reagents(reagent_amount, OPENCONTAINER)

/obj/item/ammo_casing/caseless/arrow/bottle/on_reagent_change(changetype)
	. = ..()
	update_icon()

/obj/item/ammo_casing/caseless/arrow/bottle/update_icon()
	. = ..()
	cut_overlays()
	add_overlay("arrow_bottle_0")
	if(reagents)
		if(reagents.total_volume == 10)
			add_overlay("arrow_bottle_10")
		else if(reagents.total_volume == 20)
			add_overlay("arrow_bottle_20")
		else if(reagents.total_volume == 30)
			add_overlay("arrow_bottle_30")

/obj/structure/closet/arrows

/obj/structure/closet/arrows/PopulateContents()
	new /obj/item/gun/ballistic/bow/pipe(src)
	new /obj/item/gun/ballistic/bow/pipe(src)
	new /obj/item/ammo_casing/caseless/arrow/glass(src)
	new /obj/item/ammo_casing/caseless/arrow/cloth(src)
	new /obj/item/ammo_casing/caseless/arrow/glass(src)
	new /obj/item/ammo_casing/caseless/arrow/glass(src)
	new /obj/item/ammo_casing/caseless/arrow/cloth(src)
	new /obj/item/ammo_casing/caseless/arrow/wood(src)
	new /obj/item/ammo_casing/caseless/arrow/wood(src)
	new /obj/item/ammo_casing/caseless/arrow/wood(src)
	..()

/obj/item/ammo_casing/caseless/arrow/ash
	name = "ashen arrow"
	desc = "An arrow made from wood, hardened by fire"
	icon_state = "ashenarrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow/ash

/obj/item/ammo_casing/caseless/arrow/bone
	name = "bone arrow"
	desc = "An arrow made of bone and sinew. The tip is sharp enough to pierce goliath hide."
	icon_state = "bonearrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow/bone

/obj/item/ammo_casing/caseless/arrow/bronze
	name = "bronze arrow"
	desc = "An arrow made from wood. tipped with bronze."
	icon_state = "bronzearrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow/bronze

