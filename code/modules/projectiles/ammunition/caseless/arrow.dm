/obj/item/ammo_casing/caseless/arrow
	name = "arrow of questionable material"
	desc = "You shouldn't be seeing this arrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow
	caliber = "arrow"
	icon_state = "arrow"
	w_class = WEIGHT_CLASS_NORMAL
	force = 4
	throwforce = 3 //good luck hitting someone with the pointy end of the arrow
	throw_speed = 3
	//Is this an arrow shaft that can be turned into other arrows?
	var/shaft_crafting = FALSE
	var/cloth_result = null
	var/shard_result = null
	var/bottle_result = null
	var/bone_result = null
	var/bamboo_result = null
	var/sharp_result = null

/obj/item/ammo_casing/caseless/arrow/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/gun/ballistic/bow))
		var/obj/item/gun/ballistic/bow/B = I
		if(B.bowstring == null)
			to_chat(user, "<span class='notice'>That bow has no bowstring!</span>")
			return TRUE
		else
			B.magazine.attackby(src, user, params, 1)
			to_chat(user, "<span class='notice'>You notch the arrow swiftly.</span>")
			I.update_icon()
			return TRUE
	if(shaft_crafting)
		if(user.do_afters)
			return TRUE
		else
			arrow_craft(I, user, params)
			return TRUE

/obj/item/ammo_casing/caseless/arrow/proc/arrow_craft(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/cotton/cloth))
		var/obj/item/stack/sheet/cotton/cloth/cloth = I
		if(cloth.amount < 2) //Is there less than two sheets of cotton?
			user.show_message("<span class='notice'>You need at least [2 - cloth.amount] unit\s of cloth before you can wrap it onto \the [src].</span>", MSG_VISUAL)
			return FALSE
		if(do_after(user, 1 SECONDS, I)) //Short do_after.
			cloth.use(2) //Remove two cotton from the stack.
			user.show_message("<span class='notice'>You wrap \the [cloth.name] onto the [src].</span>", MSG_VISUAL)
			new cloth_result(get_turf(src))
			qdel(src)
			return TRUE
	else if(istype(I, /obj/item/shard))
		if(do_after(user, 1 SECONDS, I))
			user.show_message("<span class='notice'>You create a glass arrow with \the [I.name].</span>", MSG_VISUAL)
			new shard_result(get_turf(src))
			qdel(I)
			qdel(src)
			return TRUE
	else if(istype(I, /obj/item/reagent_containers/food/drinks/bottle))
		if(do_after(user, 1 SECONDS, I))
			user.show_message("<span class='notice'>You create a bottle arrow with \the [I.name].</span>", MSG_VISUAL)
			new bottle_result(get_turf(src))
			qdel(I)
			qdel(src)
			return TRUE
	else if(istype(I, /obj/item/stack/sheet/bone))
		var/obj/item/stack/sheet/bone/bone = I
		if(bone.amount < 2)
			user.show_message("<span class='notice'>You need at least [2 - bone.amount] bone to create a bone point arrow.</span>", MSG_VISUAL)
			return FALSE
		if(do_after(user, 1 SECONDS, I))
			bone.use(2)
			user.show_message("<span class='notice'>You create a bone point arrow.</span>", MSG_VISUAL)
			new bone_result(get_turf(src))
			qdel(src)
			return TRUE
	else if(istype(I, /obj/item/stack/sheet/bamboo))
		var/obj/item/stack/sheet/bamboo/bamboo = I
		if(bamboo.amount < 2)
			user.show_message("<span class='notice'>You need at least [2 - bamboo.amount] bone to create a bamboo point arrow.</span>", MSG_VISUAL)
			return FALSE
		if(do_after(user, 1 SECONDS, I))
			bamboo.use(2)
			user.show_message("<span class='notice'>You create a bamboo point arrow.</span>", MSG_VISUAL)
			new bamboo_result(get_turf(src))
			qdel(src)
			return TRUE
	else if(I.is_sharp())
		if(do_after(user, 1 SECONDS, I))
			user.show_message("<span class='notice'>You sharpen \the [name].</span>", MSG_VISUAL)
			new sharp_result(get_turf(src))
			playsound(src, 'sound/effects/footstep/hardclaw1.ogg', 50, 1)
			qdel(src)
			return TRUE


///WOOD ARROWS///

/obj/item/ammo_casing/caseless/arrow/wood
	name = "wooden arrow shaft"
	desc = "An arrow shaft made out of wood. It can be fired as is, but not to great effect."
	icon_state = "arrow_wood"
	projectile_type = /obj/projectile/bullet/reusable/arrow/wood
	shaft_crafting = TRUE
	cloth_result = /obj/item/ammo_casing/caseless/arrow/cloth
	shard_result = /obj/item/ammo_casing/caseless/arrow/glass
	bottle_result = /obj/item/ammo_casing/caseless/arrow/bottle
	bone_result = /obj/item/ammo_casing/caseless/arrow/hollowpoint
	bamboo_result = /obj/item/ammo_casing/caseless/arrow/hollowpoint/bamboopoint
	sharp_result = /obj/item/ammo_casing/caseless/arrow/wood/sharp

/obj/item/ammo_casing/caseless/arrow/wood/sharp
	name = "sharp wooden arrow shaft"
	desc = "An arrow shaft made out of wood that has been sharpened to be used as an improvised arrow."
	bleed_force = BLEED_SCRATCH
	armour_penetration = 0
	projectile_type = /obj/projectile/bullet/reusable/arrow/wood/sharp
	embedding = list(embed_chance=100,
	fall_chance = 1,
	jostle_chance = 10,
	ignore_throwspeed_threshold = FALSE,
	pain_stam_pct = 3,
	pain_mult = 0,
	jostle_pain_mult = 0,
	remove_pain_mult = 2,
	rip_time = 5) //This will always embed and hardly falls on its own, but does not deal any damage once inside

/obj/item/ammo_casing/caseless/arrow/cloth
	name = "cloth arrow"
	desc = "An arrow with a 'tip' wrapped in cloth. Being hit with this is like being hit with a high velocity pillow."
	icon_state = "arrow_cloth"
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
	. = ..()
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
		force += 2
		hitsound = 'sound/items/welder.ogg'
		name = "lit [initial(name)]"
		desc = "An arrow with a 'tip' wrapped in cloth. Being hit with this is like being hit with a high velocity pillow. Except its on fire. Fear the pillow."
		attack_verb_continuous = list("burnt","singed")
		set_light_on(lit)
	update_overlays()
	arrow.update_overlays()

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

/obj/item/ammo_casing/caseless/arrow/cloth/update_overlays()
	. = .. ()
	cut_overlays()
	if(lit)
		add_overlay("[initial(icon_state)]_lit")
	if(burnt)
		add_overlay("[initial(icon_state)]_burnt")

/obj/item/ammo_casing/caseless/arrow/cloth/burnt
	name = "burnt cloth arrow"
	desc = "An arrow with a 'tip' wrapped in burnt cloth. Being hit with this is like being hit with a high velocity pillow. Full of ash."
	icon_state = "arrow_cloth_burnt"
	burnt = TRUE
	projectile_type = /obj/projectile/bullet/reusable/arrow/cloth/burnt

/obj/item/ammo_casing/caseless/arrow/cloth/burnt/attackby(obj/item/I, mob/user)
	. = ..()
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
		new cloth_result(get_turf(src)) //New arrow.
		qdel(src) //Delete the old, burnt arrow.
		return TRUE
	return FALSE

/obj/item/ammo_casing/caseless/arrow/glass
	name = "glass arrow"
	desc = "A crude 'arrow' with a glass shard for a tip. Upon impact, the glass will inevitably fall out of the shaft and remain lodged on the targets flesh."
	icon_state = "arrow_glass"
	sharpness = IS_SHARP
	bleed_force = BLEED_SURFACE
	attack_verb_continuous = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	projectile_type = /obj/projectile/bullet/reusable/arrow/glass
	embedding = list(embed_chance=100,
	fall_chance = 10,
	jostle_chance = 35,
	ignore_throwspeed_threshold = FALSE,
	pain_stam_pct = 1,
	pain_mult = 0.25,
	jostle_pain_mult = 2,
	remove_pain_mult = 0.5,
	rip_time = 5) //the small shard will be lodged in your chest cavity hurting you with every 3 steps until it falls off

/obj/item/ammo_casing/caseless/arrow/bottle
	name = "bottle arrow"
	desc = "A tiny bottle tied with string to an arrow shaft. Cute, if not filled with acid."
	icon_state = "arrow_bottle"
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

/obj/item/ammo_casing/caseless/arrow/hollowpoint
	name = "bone point wooden arrow"
	desc = "An arrow with an hollow bone point. Able to inject its contects onto its target."
	icon_state = "arrow_bonepoint"
	embedding = list(embed_chance=100,
	fall_chance = 5,
	jostle_chance = 10,
	ignore_throwspeed_threshold = FALSE,
	pain_stam_pct = 1,
	pain_mult = 1,
	jostle_pain_mult = 1,
	remove_pain_mult = 2,
	rip_time = 5)
	projectile_type = /obj/projectile/bullet/reusable/arrow/hollowpoint
	var/reagent_amount = 5

/obj/item/ammo_casing/caseless/arrow/hollowpoint/Initialize(mapload)
	. = ..()
	create_reagents(reagent_amount, OPENCONTAINER)

/obj/item/ammo_casing/caseless/arrow/hollowpoint/on_reagent_change(changetype)
	. = ..()
	update_icon()

/obj/item/ammo_casing/caseless/arrow/hollowpoint/update_icon()
	. = ..()
	cut_overlays()
	if(reagents)
		if(reagents.total_volume)
			add_overlay("hollowpoint_full")

/obj/item/ammo_casing/caseless/arrow/hollowpoint/bamboopoint
	name = "bamboo point wooden arrow"
	desc = "An arrow with an hollow bamboo point. Able to inject its contects onto its target."
	icon_state = "arrow_bamboopoint"
	embedding = list(embed_chance=100,
	fall_chance = 5,
	jostle_chance = 10,
	ignore_throwspeed_threshold = FALSE,
	pain_stam_pct = 1,
	pain_mult = 1,
	jostle_pain_mult = 1,
	remove_pain_mult = 0,
	rip_time = 2)
	projectile_type = /obj/projectile/bullet/reusable/arrow/hollowpoint/bamboopoint
	reagent_amount = 7

///BONE ARROWS///

/obj/item/ammo_casing/caseless/arrow/bone
	name = "bone arrow shaft"
	desc = "An arrow shaft carved out of bone. Arrows made with this material will generally be more painful but cause less bleeding."
	icon_state = "bonearrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow/bone
	shaft_crafting = TRUE
	cloth_result = /obj/item/ammo_casing/caseless/arrow/cloth/bone
	shard_result = /obj/item/ammo_casing/caseless/arrow/glass/bone
	bottle_result = /obj/item/ammo_casing/caseless/arrow/bottle/bone
	bone_result = /obj/item/ammo_casing/caseless/arrow/hollowpoint/bone
	bamboo_result = /obj/item/ammo_casing/caseless/arrow/hollowpoint/bamboopoint/bone
	sharp_result = /obj/item/ammo_casing/caseless/arrow/bone/sharp

/obj/item/ammo_casing/caseless/arrow/bone/sharp
	name = "sharp bone arrow shaft"
	desc = "A sharpened bone arrow shaft. Able to piece flesh and remain lodged, causing pain until removed."
	bleed_force = BLEED_TINY
	projectile_type = /obj/projectile/bullet/reusable/arrow/bone/sharp
	embedding = list(embed_chance=100,
	fall_chance = 5,
	jostle_chance = 10,
	ignore_throwspeed_threshold = FALSE,
	pain_stam_pct = 1,
	pain_mult = 1,
	jostle_pain_mult = 1,
	remove_pain_mult = 2,
	rip_time = 5) //I don't know if you ever saw something poorly carved out of bone, but let me tell you, its got worse splinters than wood. Now imagine that in your liver.

/obj/item/ammo_casing/caseless/arrow/cloth/bone
	name = "cloth bone arrow"
	icon_state = "bonearrow_cloth"
	projectile_type = /obj/projectile/bullet/reusable/arrow/cloth/bone

/obj/item/ammo_casing/caseless/arrow/cloth/burnt/bone
	name = "burnt cloth bone arrow"
	icon_state = "bonearrow_cloth_burnt"
	burnt = TRUE
	projectile_type = /obj/projectile/bullet/reusable/arrow/cloth/burnt/bone

/obj/item/ammo_casing/caseless/arrow/glass/bone
	name = "bone glass arrow"
	icon_state = "bonearrow_glass"
	projectile_type = /obj/projectile/bullet/reusable/arrow/glass/bone

/obj/item/ammo_casing/caseless/arrow/bottle/bone
	name = "bone bottle arrow"
	icon_state = "bonearrow_bottle"
	projectile_type = /obj/projectile/bullet/reusable/arrow/bottle/bone

/obj/item/ammo_casing/caseless/arrow/hollowpoint/bone
	name = "bone point arrow"
	icon_state = "bonearrow_bonepoint"
	projectile_type = /obj/projectile/bullet/reusable/arrow/hollowpoint/bone

/obj/item/ammo_casing/caseless/arrow/hollowpoint/bamboopoint/bone
	name = "bamboo point bone arrow"
	icon_state = "bonearrow_bamboopoint"
	projectile_type = /obj/projectile/bullet/reusable/arrow/hollowpoint/bamboopoint/bone

///BAMBOO ARROWS///

/obj/item/ammo_casing/caseless/arrow/bamboo
	name = "bamboo arrow shaft"
	desc = "An arrow shaft made out of bamboo. It is suitable to make lighter arrows that pierce their target better than other materials at the cost of damage."
	icon_state = "bambooarrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow/bamboo
	shaft_crafting = TRUE
	cloth_result = /obj/item/ammo_casing/caseless/arrow/cloth/bamboo
	shard_result = /obj/item/ammo_casing/caseless/arrow/glass/bamboo
	bottle_result = /obj/item/ammo_casing/caseless/arrow/bottle/bamboo
	bone_result = /obj/item/ammo_casing/caseless/arrow/hollowpoint/bamboo
	bamboo_result = /obj/item/ammo_casing/caseless/arrow/hollowpoint/bamboopoint/bamboo/
	sharp_result = /obj/item/ammo_casing/caseless/arrow/bamboo/sharp

/obj/item/ammo_casing/caseless/arrow/bamboo/sharp
	name = "sharp bamboo arrow shaft"
	desc = "A sharpened bamboo arrow shaft. Able to piece flesh and remain lodged, causing pain until removed."
	bleed_force = BLEED_SURFACE
	projectile_type = /obj/projectile/bullet/reusable/arrow/bamboo/sharp
	embedding = list(embed_chance=100,
	fall_chance = 0,
	jostle_chance = 10,
	ignore_throwspeed_threshold = FALSE,
	pain_stam_pct = 1,
	pain_mult = 0.5,
	jostle_pain_mult = 1,
	remove_pain_mult = 1,
	rip_time = 1)

/obj/item/ammo_casing/caseless/arrow/cloth/bamboo
	name = "cloth bamboo arrow"
	icon_state = "bambooarrow_cloth"
	projectile_type = /obj/projectile/bullet/reusable/arrow/cloth/bamboo

/obj/item/ammo_casing/caseless/arrow/cloth/burnt/bamboo
	name = "burnt cloth bamboo arrow"
	icon_state = "bambooarrow_cloth_burnt"
	burnt = TRUE
	projectile_type = /obj/projectile/bullet/reusable/arrow/cloth/burnt/bamboo

/obj/item/ammo_casing/caseless/arrow/glass/bamboo
	name = "glass bamboo arrow"
	icon_state = "bambooarrow_glass"
	projectile_type = /obj/projectile/bullet/reusable/arrow/glass/bamboo

/obj/item/ammo_casing/caseless/arrow/bottle/bamboo
	name = "bamboo bottle arrow"
	icon_state = "bambooarrow_bottle"
	projectile_type = /obj/projectile/bullet/reusable/arrow/bottle/bamboo

/obj/item/ammo_casing/caseless/arrow/hollowpoint/bamboo
	name = "bamboo point arrow"
	icon_state = "bambooarrow_bonepoint"
	embedding = list(embed_chance=100,
	fall_chance = 0,
	jostle_chance = 10,
	ignore_throwspeed_threshold = FALSE,
	pain_stam_pct = 1,
	pain_mult = 0.5,
	jostle_pain_mult = 1,
	remove_pain_mult = 1,
	rip_time = 1)
	projectile_type = /obj/projectile/bullet/reusable/arrow/hollowpoint/bamboo

/obj/item/ammo_casing/caseless/arrow/hollowpoint/bamboopoint/bamboo
	name = "bamboo point arrow"
	icon_state = "bambooarrow_bamboopoint"
	projectile_type = /obj/projectile/bullet/reusable/arrow/hollowpoint/bamboopoint/bamboo

/obj/item/ammo_casing/caseless/arrow/sm //Adminbus for now
	name = "SM arrow"
	desc = "Weaponized SM. Fear it."
	icon_state = "arrow_sm"
	force = 0
	throwforce = 0
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.8
	light_on = TRUE
	light_color = LIGHT_COLOR_HOLY_MAGIC
	var/shard = new /obj/machinery/power/supermatter_crystal/shard //This was meant to be craftable, using the shard but it isnt for now
	projectile_type = /obj/projectile/bullet/reusable/arrow/sm

/obj/item/ammo_casing/caseless/arrow/sm/update_icon()
	. = ..()
	cut_overlays()
	if(shard)
		add_overlay("arrow_sm_shard")

/obj/structure/closet/arrows //Test closet

/obj/structure/closet/arrows/PopulateContents()
	new /obj/item/gun/ballistic/bow/syndicate(src)
	new /obj/item/gun/ballistic/bow/pvc(src)
	new /obj/item/gun/ballistic/bow(src)
	new /obj/item/ammo_casing/caseless/arrow/cloth(src)
	new /obj/item/ammo_casing/caseless/arrow/cloth/bamboo(src)
	new /obj/item/ammo_casing/caseless/arrow/glass(src)
	new /obj/item/ammo_casing/caseless/arrow/glass/bone(src)
	new /obj/item/lighter(src)
	new /obj/item/stack/sheet/cotton/cloth/fifty(src)
	new /obj/item/stack/sheet/wood/fifty(src)
	..()

/obj/item/ammo_casing/caseless/arrow/ash
	name = "ashen arrow"
	desc = "An arrow made from wood, hardened by fire"
	icon_state = "ashenarrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow/ash

/obj/item/ammo_casing/caseless/arrow/bronze
	name = "bronze arrow"
	desc = "An arrow made from wood. tipped with bronze."
	icon_state = "bronzearrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow/bronze

