/obj/item/gun/ballistic/bow
	name = "wooden bow"
	desc = "A well balanced Bow made out of wood."
	icon_state = "bow"
	icon_state_preview = "bow"
	item_state = "bow"
	worn_icon_state = "baguette"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY //need both hands to fire
	force = 5
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	load_sound = null
	fire_sound = 'sound/weapons/bowfire.ogg'
	slot_flags = ITEM_SLOT_BACK
	item_flags = NEEDS_PERMIT
	casing_ejector = FALSE
	internal_magazine = TRUE
	has_weapon_slowdown = FALSE
	sharpness = IS_BLUNT
	bleed_force = 0
	pin = null
	no_pin_required = TRUE
	var/bowstring = "string"
	var/string_cut = FALSE //This may seem like a useless var, but it actually checks if the string is there even if it "isnt" (the case of energy string which has an on and off function)
	var/attachment = null
	var/pulltime = 1
	// Rercharge time required for bows that create their own arrows, in seconds
	var/recharge_time = 1
	ammo_count_visible = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL //so ashwalkers can use it

/obj/item/gun/ballistic/bow/stringless
	bowstring = null

/obj/item/gun/ballistic/bow/proc/stringmultiplier()
	if(bowstring == "cable")
		damage_multiplier = 0.5
		speed_multiplier = 2
	if(bowstring == "string")
		damage_multiplier = 1
		speed_multiplier = 1.2
	if(bowstring == "ash")
		damage_multiplier = 1.2
		speed_multiplier = 0.8
	if(bowstring == "energy")
		damage_multiplier = 1.5
		speed_multiplier = 0.6
	else if(bowstring == null) //If for some reason you happen to be able to notch an arrow without a bowstring
		damage_multiplier = 0
		speed_multiplier = 0

/obj/item/gun/ballistic/bow/afterattack(atom/target, mob/living/user, flag, params, aimed)
	. = ..()
	if(get_ammo())
		var/obj/item/I = user.get_active_held_item()
		if (do_after(user, pulltime SECONDS, I, IGNORE_USER_LOC_CHANGE))
			to_chat(user, "<span class='notice'>You draw back the bowstring.</span>")
			playsound(src, 'sound/weapons/bowdraw.ogg', 75, 0) //gets way too high pitched if the freq varies
			chamber_round()
			update_icon()

/obj/item/gun/ballistic/bow/shoot_with_empty_chamber(mob/living/user as mob|obj)
	if(bowstring == "disabler")
		addtimer(CALLBACK(src, PROC_REF(recharge_bolt)), recharge_time SECONDS)
		to_chat(user, "<span class='notice'>The arrow is charging!</span>")
	return

/obj/item/gun/ballistic/bow/chamber_round()
	chambered = magazine.get_round(1)
	stringmultiplier()

/obj/item/gun/ballistic/bow/process_chamber()
	chambered = null
	magazine.get_round(0)
	update_icon()

/obj/item/gun/ballistic/bow/attack_self(mob/living/user)
	if (user.do_afters)
		return
	if(chambered && bowstring != "disabler")
		var/obj/item/ammo_casing/AC = magazine.get_round(0)
		user.put_in_hands(AC)
		chambered = null
		to_chat(user, "<span class='notice'>You gently release the bowstring, removing the arrow.</span>")
	else if(get_ammo())
		var/obj/item/I = user.get_active_held_item()
		if(!is_wielded)
			balloon_alert(user, "You need both hands free to fire [src]!")
			return TRUE
		else if (!chambered)
			return TRUE
		else if(do_after(user, pulltime SECONDS, I, IGNORE_USER_LOC_CHANGE) && !chambered)
			to_chat(user, "<span class='notice'>You draw back the bowstring.</span>")
			playsound(src, 'sound/weapons/bowdraw.ogg', 75, 0) //gets way too high pitched if the freq varies
			chamber_round()
	update_icon()

/obj/item/gun/ballistic/bow/proc/string_update(obj/item/I, mob/user, params)
	var/obj/item/gun/ballistic/bow/bow
	if(istype(I, /obj/item/ammo_casing/caseless/arrow))
		to_chat(user, "<span class='notice'>That bow has no drawstring!</span>")
		return TRUE
	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		if (C.use(5))
			bowstring = "cable"
			fire_sound = initial(bow.fire_sound)
		else
			to_chat(user, "<span class='warning'>Not enough cable!</span>")
	if(istype(I, /obj/item/weaponcrafting/silkstring))
		bowstring = "string"
		fire_sound = initial(bow.fire_sound)
		qdel(I)
	if(istype(I, /obj/item/stack/sheet/sinew))
		var/obj/item/stack/sheet/sinew/S = I
		if(S.use(2))
			bowstring = "ash"
			fire_sound = initial(bow.fire_sound)
		else
			to_chat(user, "<span class='warning'>Not enough sinew!</span>")
	if(istype(I, /obj/item/weaponcrafting/energy_crystal/syndicate))
		bowstring = "energy"
		fire_sound = initial(bow.fire_sound)
		qdel(I)
	if(istype(I, /obj/item/weaponcrafting/energy_crystal/disabler))
		bowstring = "disabler"
		fire_sound = 'sound/weapons/laser.ogg'
		qdel(I)
	string_cut = FALSE
	update_icon()

/obj/item/gun/ballistic/bow/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weaponcrafting/attachment) && !attachment)
		if(istype(I, /obj/item/weaponcrafting/attachment/bowfangs/bone))
			attachment = "bone_fangs"
			force += 3
			sharpness = IS_BLUNT
			bleed_force = BLEED_SCRATCH
			update_icon()
			qdel(I)
			return TRUE
		if(istype(I, /obj/item/weaponcrafting/attachment/bowfangs))
			attachment = "fangs"
			force += 2
			sharpness = IS_SHARP_ACCURATE
			bleed_force = BLEED_CUT
			update_icon()
			qdel(I)
			return TRUE
	if(string_cut)
		string_update(I, user, params)
		return TRUE
	if((istype(I, /obj/item/wirecutters) || I.sharpness) && !istype(I, /obj/item/ammo_casing/caseless/arrow))
		if(attachment)
			if(attachment == "fangs")
				new /obj/item/weaponcrafting/attachment/bowfangs(get_turf(src),1)
			if(attachment == "bone_fangs")
				new /obj/item/weaponcrafting/attachment/bowfangs/bone(get_turf(src),1)
			attachment = null
			force = initial(force)
			sharpness = initial(sharpness)
			bleed_force = initial(bleed_force)
			update_icon()
			return
		if(bowstring && !get_ammo())
			if(bowstring == "cable")
				new /obj/item/stack/cable_coil/red(get_turf(src),5)
			if(bowstring == "string")
				new /obj/item/weaponcrafting/silkstring(get_turf(src),1)
			if(bowstring == "ash")
				new /obj/item/stack/sheet/sinew(get_turf(src),2)
			if(bowstring == "energy")
				new /obj/item/weaponcrafting/energy_crystal/syndicate(get_turf(src),1)
			if(bowstring == "disabler")
				new /obj/item/weaponcrafting/energy_crystal/disabler(get_turf(src),1)
			bowstring = null
			string_cut = TRUE
			playsound(src, 'sound/items/wirecutter.ogg', 50, 1)
			update_icon()
			return
	if(bowstring == "disabler")
		return //we return at this point to avoid trying to load arrows into energy bows
	if(magazine.attackby(I, user, params, 1))
		to_chat(user, "<span class='notice'>You notch the arrow.</span>")
		update_icon()
	if(I.is_hot() > 900 && get_ammo())
		var/obj/item/ammo_casing/caseless/arrow/cloth/AC = magazine.get_round(1)
		if(istype(AC, /obj/item/ammo_casing/caseless/arrow/cloth))
			if(!AC.lit && !AC.burnt)
				AC.ignite()
				update_icon()

/obj/item/gun/ballistic/bow/update_icon()
	cut_overlays()
	if(bowstring)
		add_overlay("[bowstring][get_ammo() ? (chambered ? "_firing" : "") : ""]")
	if(get_ammo())
		var/obj/item/ammo_casing/AC = magazine.get_round(1)
		if(istype(AC, /obj/item/ammo_casing/caseless/arrow/wood))
			add_overlay("wood_[(chambered ? "firing" : "loaded")]")
		else if(istype(AC, /obj/item/ammo_casing/caseless/arrow/glass))
			add_overlay("glass_[(chambered ? "firing" : "loaded")]")
		else if(istype(AC, /obj/item/ammo_casing/caseless/arrow/cloth))
			var/obj/item/ammo_casing/caseless/arrow/cloth/C = AC
			if(!C.lit && !C.burnt)
				add_overlay("cloth_[(chambered ? "firing" : "loaded")]")
			else if(C.lit)
				add_overlay("clothlit_[(chambered ? "firing" : "loaded")]")
			else if(C.burnt)
				add_overlay("clothburnt_[(chambered ? "firing" : "loaded")]")
		else if(istype(AC, /obj/item/ammo_casing/caseless/arrow/bottle))
			add_overlay("bottle_[(chambered ? "firing" : "loaded")]")
		else if(istype(AC, /obj/item/ammo_casing/caseless/arrow/sm))
			add_overlay("sm_[(chambered ? "firing" : "loaded")]")
		else if(istype(AC, /obj/item/ammo_casing/caseless/arrow/energy/disabler))
			add_overlay("arrow_disabler_[(chambered ? "firing" : "loaded")]")
		else
			add_overlay("arrow_[(chambered ? "firing" : "loaded")]")
	if(attachment)
		if(attachment == "fangs")
			add_overlay("bow_fangs")
		else if(attachment == "bone_fangs")
			add_overlay("bow_fangs_bone")
	else
		return

/obj/item/gun/ballistic/bow/examine(mob/user)
	. = ..()
	switch(bowstring)
		if("cable")
			. += "<span class='info'>The drawstring is improvised out of cable. It looks rather weak.</span>"
		if("string")
			. += "<span class='info'>The drawstring is made of silkstring. Standard Strength.</span>"
		if("ash")
			. += "<span class='info'>The drawstring is made of sinew. It looks pretty strong.</span>"
		if("energy")
			. += "<span class='info'>The drawstring is made of pure energy. As robust as it gets.</span>"
		if(null)
			. += "<span class='info'>This bow has no drawstring. Not much of a bow, is it.</span>"

/obj/item/gun/ballistic/bow/can_shoot()
	return chambered

/obj/item/gun/ballistic/bow/ashen
	name = "Bone Bow"
	desc = "Some sort of primitive projectile weapon made of bone and wrapped sinew."
	icon_state = "ashenbow"
	item_state = "ashenbow"
	bowstring = "ash"
	force = 7
	spread = 5

/obj/item/gun/ballistic/bow/pipe
	name = "Pipe Bow"
	desc = "A crude projectile weapon made from cable coil, pipe and lots of bending."
	icon_state = "pipebow"
	item_state = "pipebow"
	bowstring = "cable"
	pulltime = 1.5
	force = 6
	spread = 10

/obj/item/gun/ballistic/bow/syndicate //This was /bow/energy but I'm trying to make a clear distinction between energy bows (that produce their own arrows) and normal bows
	name = "Energy Bow"
	desc = "A crude projectile weapon made from cable coil, pipe and lots of bending."
	icon_state = "energybow"
	pulltime = 0.5
	bowstring = null
	w_class = WEIGHT_CLASS_NORMAL
	var/on = FALSE

/obj/item/gun/ballistic/bow/syndicate/AltClick(mob/user)
	. = ..()
	if(!string_cut || bowstring == "energy")
		turn_on()
	else
		return


/obj/item/gun/ballistic/bow/syndicate/attack_self(mob/living/user)
	. = ..()
	if(!on && !string_cut)
		turn_on()

/obj/item/gun/ballistic/bow/syndicate/proc/turn_on()
	if(!on)
		on = TRUE
		bowstring = "energy"
		hitsound = 'sound/weapons/edagger.ogg'
		w_class = WEIGHT_CLASS_BULKY
		update_icon()
		playsound(src, 'sound/weapons/saberon.ogg', 35, 1)
	else
		on = FALSE
		force = initial(force)
		damtype = initial(damtype)
		bowstring = null
		hitsound = initial(hitsound)
		w_class = initial(w_class)
		update_icon()
		playsound(src, 'sound/weapons/saberoff.ogg', 35, 1)

/obj/item/gun/ballistic/bow/energy/examine(mob/user)
	. = ..()
	if(!string_cut || bowstring == "energy")
		. += "<span class='info'>Press <B>Alt-Click</B> to turn the bow on and off.</span>"
	else
		. += "<span class='info'>This energy bow has been mutilated and lacks an <B>Energy Crystal</B>...</span>"

/obj/item/gun/ballistic/bow/energy/sec
	name = "Security Energy Bow"
	desc = "A NT made bow made for secutiry forces with the intention of giving them an multi-purpose weapon for survival conditions."
	icon_state = "secbow"
	bowstring = "disabler"
	fire_sound = 'sound/weapons/laser.ogg'
	recharge_time = 1
	mag_type = /obj/item/ammo_box/magazine/internal/bow/energy/disabler
	//Coding a energy gun bow would be absolutely a pain, I don't know how to do so, so for now they will recharge on their own like clockwork bows.

/obj/item/ammo_box/magazine/internal/bow/energy
	ammo_type = /obj/item/ammo_casing/caseless/arrow/energy
	start_empty = FALSE

/obj/item/ammo_box/magazine/internal/bow/energy/disabler
	ammo_type = /obj/item/ammo_casing/caseless/arrow/energy/disabler

/obj/item/ammo_casing/caseless/arrow/energy
	name = "energy bolt"
	desc = "An arrow made of pure energy."
	icon_state = "arrow_redlight"
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy
	projectile_type = /obj/projectile/energy/arrow

/obj/item/ammo_casing/caseless/arrow/energy/disabler
	desc = "A disabling arrow made of energy."
	icon_state = "arrow_redlight"
	projectile_type = /obj/projectile/energy/arrow/disabler

/obj/projectile/energy/arrow/disabler
	name = "energy bolt"
	icon_state = "omnilaser"
	damage = 40
	damage_type = STAMINA
	hitsound = 'sound/weapons/tap.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/item/gun/ballistic/bow/energy/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
	. = ..()
	//if(mag_type == /obj/item/ammo_box/magazine/internal/bow/energy/disabler)
	addtimer(CALLBACK(src, PROC_REF(recharge_bolt)), recharge_time SECONDS)

/obj/item/gun/ballistic/bow/proc/recharge_bolt()
	if(magazine.get_round(TRUE))
		return
	if(bowstring == "disabler")
		var/obj/item/ammo_casing/caseless/arrow/energy/disabler/DA = new
		magazine.give_round(DA)
		update_icon()
