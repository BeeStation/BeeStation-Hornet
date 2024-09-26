/obj/item/ammo_casing/caseless/arrow
	name = "arrow of questionable material"
	desc = "You shouldn't be seeing this arrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow
	caliber = "arrow"
	icon_state = "arrow"
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 3 //good luck hitting someone with the pointy end of the arrow
	throw_speed = 3

/obj/item/ammo_casing/caseless/arrow/attackby(obj/item/I, mob/user, params)
	var/obj/item/gun/ballistic/bow/B = I
	if(istype(B, /obj/item/gun/ballistic/bow))
		B.magazine.attackby(src, user, 0, 1)
		to_chat(user, "<span class='notice'>You notch the arrow swiftly.</span>")

/obj/item/ammo_casing/caseless/arrow/wood
	name = "wooden arrow shaft"
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

/obj/item/ammo_casing/caseless/arrow/wood/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/cotton/cloth))
		var/obj/item/stack/sheet/cotton/cloth/cloth = I
		if(cloth.amount < 2) //Is there less than two sheets of cotton?
			user.show_message("<span class='notice'>You need at least [2 - cloth.amount] unit\s of cloth before you can wrap it onto \the [src].</span>", MSG_VISUAL)
			return FALSE
		if(do_after(user, 1 SECONDS, I)) //Short do_after.
			cloth.use(2) //Remove two cotton from the stack.
			user.show_message("<span class='notice'>You wrap \the [cloth.name] onto the [src].</span>", MSG_VISUAL)
			new /obj/item/ammo_casing/caseless/arrow/cloth(get_turf(src))
			qdel(src)
			return TRUE
	if(istype(I, /obj/item/shard))
		if(do_after(user, 1 SECONDS, I)) //Short do_after.
			user.show_message("<span class='notice'>You create a glass arrow with \the [I.name].</span>", MSG_VISUAL)
			new /obj/item/ammo_casing/caseless/arrow/glass(get_turf(src))
			qdel(src)
			return TRUE
	if(istype(I, /obj/item/reagent_containers/food/drinks/bottle))
		if(do_after(user, 1 SECONDS, I)) //Short do_after.
			user.show_message("<span class='notice'>You create a bottle arrow with \the [I.name].</span>", MSG_VISUAL)
			new /obj/item/ammo_casing/caseless/arrow/bottle(get_turf(src))
			qdel(src)
			return TRUE

/obj/item/ammo_casing/caseless/arrow/bone
	name = "bone arrow shaft"
	desc = "A pointy shaft carved out of bone. Not really technogically advanced, still, you don't want to get hit by this."
	icon_state = "arrow_bone"
	force = 6
	armour_penetration = -10
	projectile_type = /obj/projectile/bullet/reusable/arrow/wood
	embedding = list(embed_chance=60,
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

/obj/item/ammo_casing/caseless/arrow/cloth/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(lit && M.IgniteMob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
		log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")

/obj/item/ammo_casing/caseless/arrow/cloth/fire_act(exposed_temperature, exposed_volume)
	ignite()

/obj/item/ammo_casing/caseless/arrow/cloth/attackby(obj/item/I, mob/user, params)
	if(I.is_hot() > 900)
		ignite()

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
		damtype = BURN
		arrow.lit = TRUE
		force = 10
		hitsound = 'sound/items/welder.ogg'
		name = "lit [initial(name)]"
		desc = "An arrow with a 'tip' wrapped in cloth. Being hit with this is like being hit with a high velocity pillow. Except its on fire. Fear the pillow."
		attack_verb_continuous = list("burnt","singed")
		set_light_on(lit)
	update_overlays()

/obj/item/ammo_casing/caseless/arrow/cloth/proc/burnout()
	var/obj/projectile/bullet/reusable/arrow/cloth/arrow = BB
	if(lit)
		lit = FALSE
		burnt = TRUE
		arrow.burnt = TRUE
		arrow.lit = FALSE
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

/obj/item/ammo_casing/caseless/arrow/cloth/burnt/attackby(obj/item/I, mob/user)
	if(replace(I, user))
		return
	return ..()

/obj/item/ammo_casing/caseless/arrow/cloth/burnt/proc/replace(obj/item/stack/sheet/cotton/cloth/I, mob/user) //Proc for replacing the cotton on the arrow.
	if(!istype(I)) //Were we clicked on by a sheet of cotton?
		return FALSE
	if(I.amount < 2) //Is there less than two sheets of cotton?
		user.show_message("<span class='notice'>You need at least [2 - I.amount] unit\s of cloth before you can wrap \the [I] onto \the [src].</span>", MSG_VISUAL)
		return FALSE
	if(do_after(user, 1 SECONDS, I)) //Short do_after.
		I.use(2) //Remove two cotton from the stack.
		user.show_message("<span class='notice'>You wrap \the [I.name] onto the [src].</span>", MSG_VISUAL)
		new /obj/item/ammo_casing/caseless/arrow/cloth(get_turf(src)) //New arrow.
		qdel(src) //Delete the old, burnt arrow.
		return TRUE
	return FALSE

/obj/item/ammo_casing/caseless/arrow/glass
	name = "glass arrow"
	desc = "A crude 'arrow' with a glass shard as a tip. You don't want to be shot with this."
	icon_state = "arrow_glass"
	force = 10
	armour_penetration = 0
	sharpness = IS_SHARP
	attack_verb_continuous = list("stabbed", "slashed", "sliced", "cut")
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

/obj/item/ammo_casing/caseless/arrow/sm
	name = "SM arrow"
	desc = "Weaponized SM. Fear it."
	icon_state = "arrow_sm"
	force = 0
	throwforce = 0
	armour_penetration = 0
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.8
	light_on = TRUE
	light_color = LIGHT_COLOR_HOLY_MAGIC
	var/shard = TRUE
	projectile_type = /obj/projectile/bullet/reusable/arrow/sm

/obj/item/ammo_casing/caseless/arrow/sm/update_icon()
	. = ..()
	cut_overlays()
	if(shard)
		add_overlay("arrow_sm_shard")

/obj/structure/closet/arrows

/obj/structure/closet/arrows/PopulateContents()
	new /obj/item/gun/ballistic/bow/pipe(src)
	new /obj/item/gun/ballistic/bow/pipe(src)
	new /obj/item/ammo_casing/caseless/arrow/cloth(src)
	new /obj/item/ammo_casing/caseless/arrow/cloth(src)
	new /obj/item/ammo_casing/caseless/arrow/cloth(src)
	new /obj/item/ammo_casing/caseless/arrow/glass(src)
	new /obj/item/ammo_casing/caseless/arrow/glass(src)
	new /obj/item/ammo_casing/caseless/arrow/glass(src)
	new /obj/item/ammo_casing/caseless/arrow/wood(src)
	new /obj/item/ammo_casing/caseless/arrow/wood(src)
	new /obj/item/ammo_casing/caseless/arrow/wood(src)
	new /obj/item/lighter(src)
	new /obj/item/stack/sheet/cotton/cloth/fifty(src)
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

