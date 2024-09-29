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
	var/bowstring = "leather"
	var/string_cut = FALSE //This may seem like a useless var, but it actually checks if the string is there even if it "isnt" (the case of energy string which has an on and off function)
	var/attachment = null
	var/pulltime = 1
	// Rercharge time required for bows that create their own arrows, in seconds
	ammo_count_visible = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL //so ashwalkers can use it

/obj/item/gun/ballistic/bow/stringless
	bowstring = null

/obj/item/gun/ballistic/bow/proc/stringmultiplier()
	if(bowstring == "cable")
		damage_multiplier = 0.5
		speed_multiplier = 2
	if(bowstring == "bamboo")
		damage_multiplier = 1
		speed_multiplier = 1.4
	if(bowstring == "leather" || bowstring == "silk")
		damage_multiplier = 1
		speed_multiplier = 1.2
	if(bowstring == "sinew")
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
	if(user.do_afters)
		return
	if(get_ammo())
		var/obj/item/I = user.get_active_held_item()
		if(do_after(user, pulltime SECONDS, I, IGNORE_USER_LOC_CHANGE))
			to_chat(user, "<span class='notice'>You draw back the bowstring.</span>")
			playsound(src, 'sound/weapons/bowdraw.ogg', 75, 0) //gets way too high pitched if the freq varies
			chamber_round()
			update_icon()

/obj/item/gun/ballistic/bow/shoot_with_empty_chamber(mob/living/user as mob|obj)
	return

/obj/item/gun/ballistic/bow/chamber_round()
	chambered = magazine.get_round(1)
	stringmultiplier()

/obj/item/gun/ballistic/bow/process_chamber()
	chambered = null
	magazine.get_round(0)
	update_icon()

/obj/item/gun/ballistic/bow/attack_self(mob/living/user)
	if(user.do_afters)
		return
	if(chambered)
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
	if(istype(I, /obj/item/stack/sheet/bamboo))
		var/obj/item/stack/sheet/bamboo/B = I
		if (B.use(2))
			bowstring = "bamboo"
			fire_sound = initial(bow.fire_sound)
		else
			to_chat(user, "<span class='warning'>Not enough bamboo!</span>")
	if(istype(I, /obj/item/weaponcrafting/leatherstring))
		bowstring = "leather"
		fire_sound = initial(bow.fire_sound)
		qdel(I)
	if(istype(I, /obj/item/weaponcrafting/silkstring))
		bowstring = "silk"
		fire_sound = initial(bow.fire_sound)
		qdel(I)
	if(istype(I, /obj/item/stack/sheet/sinew))
		var/obj/item/stack/sheet/sinew/S = I
		if(S.use(2))
			bowstring = "sinew"
			fire_sound = initial(bow.fire_sound)
		else
			to_chat(user, "<span class='warning'>Not enough sinew!</span>")
	if(istype(I, /obj/item/weaponcrafting/energy_crystal/syndicate))
		bowstring = "energy"
		fire_sound = initial(bow.fire_sound)
		qdel(I)
	string_cut = FALSE
	update_icon()

/obj/item/gun/ballistic/bow/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weaponcrafting/attachment) && !attachment)
		if(istype(I, /obj/item/weaponcrafting/attachment/bowfangs/bone))
			attachment = "bone_fangs"
			force += 3
			spread += 3
			sharpness = IS_BLUNT
			bleed_force = BLEED_SCRATCH
			update_icon()
			qdel(I)
			return TRUE
		if(istype(I, /obj/item/weaponcrafting/attachment/bowfangs))
			attachment = "fangs"
			force += 2
			spread += 2
			sharpness = IS_SHARP_ACCURATE
			bleed_force = BLEED_CUT
			update_icon()
			qdel(I)
			return TRUE
		if(istype(I, /obj/item/weaponcrafting/attachment/scope))
			attachment = "scope"
			spread -= 5
			update_icon()
			qdel(I)
			return TRUE
		if(istype(I, /obj/item/weaponcrafting/attachment/accelerators))
			attachment = "accelerators"
			speed_multiplier -= 0.3
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
			if(attachment == "scope")
				new /obj/item/weaponcrafting/attachment/scope(get_turf(src),1)
			if(attachment == "accelerators")
				new /obj/item/weaponcrafting/attachment/accelerators(get_turf(src),1)
			attachment = null
			force = initial(force)
			sharpness = initial(sharpness)
			bleed_force = initial(bleed_force)
			update_icon()
			return
		if(bowstring && !get_ammo())
			if(bowstring == "cable")
				new /obj/item/stack/cable_coil/red(get_turf(src),5)
			if(bowstring == "leather")
				new /obj/item/weaponcrafting/leatherstring(get_turf(src),1)
			if(bowstring == "bamboo")
				new /obj/item/stack/sheet/bamboo(get_turf(src),2)
			if(bowstring == "silk")
				new /obj/item/weaponcrafting/silkstring(get_turf(src),1)
			if(bowstring == "sinew")
				new /obj/item/stack/sheet/sinew(get_turf(src),2)
			if(bowstring == "energy")
				new /obj/item/weaponcrafting/energy_crystal/syndicate(get_turf(src),1)
			bowstring = null
			string_cut = TRUE
			playsound(src, 'sound/items/wirecutter.ogg', 50, 1)
			update_icon()
			return
	if(magazine.attackby(I, user, params, 1))
		to_chat(user, "<span class='notice'>You notch the arrow.</span>")
		update_icon()
	if(I.is_hot() > 900 && get_ammo()) //You can set a cloth arrow alight while it is notched
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
		else
			add_overlay("arrow_[(chambered ? "firing" : "loaded")]")
	if(attachment)
		if(attachment == "fangs")
			add_overlay("bow_fangs")
		else if(attachment == "bone_fangs")
			add_overlay("bow_fangs_bone")
		else if(attachment == "scope")
			add_overlay("scope")
		else if(attachment == "accelerators")
			add_overlay("accelerators")
	else
		return

/obj/item/gun/ballistic/bow/examine(mob/user)
	. = ..()
	switch(bowstring)
		if("cable")
			. += "<span class='info'>The drawstring is improvised out of cable. It looks rather weak.</span>"
		if("leather")
			. += "<span class='info'>The drawstring is made of leather. Standard strength.</span>"
		if("bamboo")
			. += "<span class='info'>The drawstring is made of bamboo fiber. Close to standard strength.</span>"
		if("silk")
			. += "<span class='info'>The drawstring is made of silkstring. Standard strength.</span>"
		if("sinew")
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
	bowstring = "sinew"
	force = 7

/obj/item/gun/ballistic/bow/bamboo
	name = "Bone Bow"
	desc = "Some sort of primitive projectile weapon made of bone and wrapped sinew."
	icon_state = "ashenbow"
	item_state = "ashenbow"
	bowstring = "bamboo"

/obj/item/gun/ballistic/bow/ashen/stringless
	bowstring = null

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
