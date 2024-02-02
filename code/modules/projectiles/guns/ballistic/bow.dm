/obj/item/gun/ballistic/bow
	name = "wooden bow"
	desc = "some sort of primitive projectile weapon. used to fire arrows."
	icon_state = "bow"
	icon_state_preview = "bow_unloaded"
	item_state = "bow"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY //need both hands to fire
	force = 5
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	fire_sound = 'sound/weapons/bowfire.ogg'
	slot_flags = ITEM_SLOT_BACK
	item_flags = NEEDS_PERMIT
	casing_ejector = FALSE
	internal_magazine = TRUE
	pin = null
	no_pin_required = TRUE
	var/bowstring = "string"
	var/string_cut = FALSE
	ammo_count_visible = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL //so ashwalkers can use it

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
		if (do_after(user, 1.5 SECONDS, I, IGNORE_USER_LOC_CHANGE))
			to_chat(user, "<span class='notice'>You draw back the bowstring.</span>")
			playsound(src, 'sound/weapons/bowdraw.ogg', 75, 0) //gets way too high pitched if the freq varies
			chamber_round()
			update_icon()

/obj/item/gun/ballistic/bow/shoot_with_empty_chamber()
	return

/obj/item/gun/ballistic/bow/chamber_round()
	chambered = magazine.get_round(1)
	stringmultiplier()

/obj/item/gun/ballistic/bow/process_chamber()
	chambered = null
	magazine.get_round(0)
	update_icon()

/obj/item/gun/ballistic/bow/attack_self(mob/living/user)
	if (chambered)
		var/obj/item/ammo_casing/AC = magazine.get_round(0)
		user.put_in_hands(AC)
		chambered = null
		to_chat(user, "<span class='notice'>You gently release the bowstring, removing the arrow.</span>")
	else if (get_ammo())
		var/obj/item/I = user.get_active_held_item()
		if(!is_wielded)
			balloon_alert(user, "You need both hands free to fire [src]!")
			return
		if (do_after(user, 1.5 SECONDS, I, IGNORE_USER_LOC_CHANGE))
			to_chat(user, "<span class='notice'>You draw back the bowstring.</span>")
			playsound(src, 'sound/weapons/bowdraw.ogg', 75, 0) //gets way too high pitched if the freq varies
			chamber_round()
	update_icon()

/obj/item/gun/ballistic/bow/attackby(obj/item/I, mob/user, params)
	if((istype(I, /obj/item/wirecutters) || I.sharpness) && !istype(I, /obj/item/ammo_casing/caseless/arrow))
		if(bowstring && !get_ammo())
			if(bowstring == "cable")
				new /obj/item/stack/cable_coil/red(get_turf(src),5)
			if(bowstring == "string")
				new /obj/item/weaponcrafting/silkstring(get_turf(src),1)
			if(bowstring == "ash")
				new /obj/item/stack/sheet/sinew(get_turf(src),2)
			if(bowstring == "energy")
				new /obj/item/weaponcrafting/energy_crystal(get_turf(src),1)
			bowstring = null
			update_icon()
			playsound(src, 'sound/items/wirecutter.ogg', 50, 1)
			string_cut = TRUE
	if(string_cut)
		if(istype(I, /obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/C = I
			if (C.use(5))
				bowstring = "cable"
				update_icon()
				string_cut = FALSE
			else
				to_chat(user, "<span class='warning'>Not enough cable!</span>")
		if(istype(I, /obj/item/weaponcrafting/silkstring))
			bowstring = "string"
			update_icon()
			qdel(I)
			string_cut = FALSE
		if(istype(I, /obj/item/stack/sheet/sinew))
			var/obj/item/stack/sheet/sinew/S = I
			if(S.use(2))
				bowstring = "ash"
				update_icon()
				string_cut = FALSE
			else
				to_chat(user, "<span class='warning'>Not enough sinew!</span>")
		if(istype(I, /obj/item/weaponcrafting/energy_crystal))
			bowstring = "energy"
			update_icon()
			qdel(I)
			string_cut = FALSE
		if(istype(I, /obj/item/ammo_casing/caseless/arrow))
			to_chat(user, "<span class='notice'>That bow has no drawstring!</span>")
			return
	if(magazine.attackby(I, user, params, 1))
		to_chat(user, "<span class='notice'>You notch the arrow.</span>")
		update_icon()
	if(I.is_hot() > 900 && get_ammo())
		var/obj/item/ammo_casing/caseless/arrow/cloth/AC = magazine.get_round(1)
		if(istype(AC, /obj/item/ammo_casing/caseless/arrow/cloth))
			if(!AC.lit && !AC.burnt)
				AC.ignite()
				update_icon()

//obj/item/gun/ballistic/bow/attack_obj(obj/O, mob/user)
//	if(istype(O, /obj/item/ammo_casing/caseless/arrow))
//		to_chat(user, "<span class='notice'>You notch the arrow swiftly.</span>")

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
	else
		return

/obj/item/gun/ballistic/bow/examine(mob/user)
	. = ..()
	if(bowstring)
		if(bowstring == "cable")
			. += "<span class='info'>The drawstring is improvised out of cable. It looks rather weak.</span>"
		if(bowstring == "string")
			. += "<span class='info'>The drawstring is made of silkstring. Standard Strength.</span>"
		if(bowstring == "ash")
			. += "<span class='info'>The drawstring is made of sinew. It looks pretty strong.</span>"
		if(bowstring == "energy")
			. += "<span class='info'>The drawstring is made of pure energy. As robust as it gets.</span>"
	else if(!bowstring == "energy")
		. += "<span class='info'>This bow has no drawstring. Not much of a bow, is it.</span>"

/obj/item/gun/ballistic/bow/can_shoot()
	return chambered

/obj/item/gun/ballistic/bow/ashen
	name = "Bone Bow"
	desc = "Some sort of primitive projectile weapon made of bone and wrapped sinew."
	icon_state = "ashenbow"
	item_state = "ashenbow"
	force = 8

/obj/item/gun/ballistic/bow/pipe
	name = "Pipe Bow"
	desc = "A crude projectile weapon made from cable coil, pipe and lots of bending."
	icon_state = "pipebow"
	item_state = "pipebow"
	bowstring = "cable"
	force = 7
	spread = 10

/obj/item/gun/ballistic/bow/energy
	name = "Energy Bow"
	desc = "A crude projectile weapon made from cable coil, pipe and lots of bending."
	icon_state = "energybow"
	bowstring = null
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	var/on = FALSE

/obj/item/gun/ballistic/bow/energy/AltClick(mob/user)
	. = ..()
	if(!string_cut)
		turn_on()

/obj/item/gun/ballistic/bow/energy/attack_self(mob/living/user)
	. = ..()
	if(!on && !string_cut)
		turn_on()

/obj/item/gun/ballistic/bow/energy/proc/turn_on()
	if(!on)
		on = TRUE
		force = 10
		damtype = BURN
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
	if(!string_cut)
		. += "<span class='info'>Press <B>Alt-Click</B> to turn the bow on and off.</span>"
	else
		. += "<span class='info'>This energy bow has been mutilated and lacks an <B>Energy Crystal</B>...</span>"

