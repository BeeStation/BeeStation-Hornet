/obj/item/gun/ballistic/bow
	name = "wooden bow"
	desc = "A well balanced bow made out of wood."
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
	spread = 5 //The standard for bows, to allow for better bows and attachments to take effect
	var/obj/item/weaponcrafting/attachment/primary/bowstring = /obj/item/weaponcrafting/attachment/primary/silkstring
	//This tells us wether the string has been cut or is just off in the case of bows that have on and off states
	var/string_cut = FALSE
	var/obj/item/weaponcrafting/attachment/secondary/attachment = null
	///Time required to draw an arrow, in seconds
	var/drawtime = 1
	ammo_count_visible = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL //so ashwalkers can use it

/obj/item/gun/ballistic/bow/stringless
	bowstring = null

/obj/item/gun/ballistic/bow/afterattack(atom/target, mob/living/user, flag, params, aimed)
	. = ..()
	if(user.do_afters)
		return
	if(get_ammo())
		var/obj/item/I = user.get_active_held_item()
		if(do_after(user, drawtime SECONDS, I, IGNORE_USER_LOC_CHANGE))
			to_chat(user, "<span class='notice'>You draw back the bowstring.</span>")
			playsound(src, 'sound/weapons/bowdraw.ogg', 75, 0) //gets way too high pitched if the freq varies
			chamber_round()
			update_icon()

/obj/item/gun/ballistic/bow/shoot_with_empty_chamber(mob/living/user as mob|obj)
	return

/obj/item/gun/ballistic/bow/chamber_round()
	chambered = magazine.get_round(1)

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
		else if(do_after(user, drawtime SECONDS, I, IGNORE_USER_LOC_CHANGE) && !chambered)
			to_chat(user, "<span class='notice'>You draw back the bowstring.</span>")
			playsound(src, 'sound/weapons/bowdraw.ogg', 75, 0) //gets way too high pitched if the freq varies
			chamber_round()
	update_icon()

/obj/item/gun/ballistic/bow/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weaponcrafting/attachment/secondary) && !attachment)
		var/obj/item/weaponcrafting/attachment/secondary/A = I
		attachment = A
		force += A.force
		spread += A.spread
		sharpness = A.sharpness
		bleed_force = A.bleed_force
		update_icon()
		qdel(A) //THIS IS CAUSING A RUNTIME, LETS FIND A WAY
		return TRUE
	if(string_cut)
		if(istype(I, /obj/item/ammo_casing/caseless/arrow))
			to_chat(user, "<span class='notice'>That bow has no drawstring!</span>")
			return TRUE
		if(istype(I, /obj/item/weaponcrafting/attachment/primary))
			var/obj/item/weaponcrafting/attachment/primary/S = I
			user.transferItemToLoc(S, src) //NOT WORKING AAAAAAAAA
			bowstring = S
			damage_multiplier = S.damage_multiplier
			speed_multiplier = S.speed_multiplier
			update_icon()
			string_cut = FALSE
			return TRUE
	if((istype(I, /obj/item/wirecutters) || I.sharpness) && !istype(I, /obj/item/ammo_casing/caseless/arrow))
		if(attachment)
			new attachment(get_turf(src),1)
			attachment = null
			force = initial(force)
			spread = initial(spread)
			sharpness = initial(sharpness)
			bleed_force = initial(bleed_force)
			playsound(src, 'sound/items/wirecutter.ogg', 50, 1)
			update_icon()
			return TRUE
		if(bowstring)
			if(get_ammo())
				to_chat(user, "<span class='notice'>Release the arrow before trying to cut the string!</span>")
				return TRUE
			else
				new bowstring(get_turf(src),1)
				bowstring = null
				string_cut = TRUE
				damage_multiplier = 0
				speed_multiplier = 0
				playsound(src, 'sound/items/wirecutter.ogg', 50, 1)
				update_icon()
				return TRUE
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
		add_overlay("[initial(bowstring.icon_state)][get_ammo() ? (chambered ? "_firing" : "") : ""]")
	if(get_ammo())
		var/obj/item/ammo_casing/AC = magazine.get_round(1)
		if(istype(AC, /obj/item/ammo_casing/caseless/arrow/cloth))
			var/obj/item/ammo_casing/caseless/arrow/cloth/C = AC
			if(!C.lit && !C.burnt)
				add_overlay("[initial(C.icon_state)]_[(chambered ? "firing" : "loaded")]")
			else if(C.lit)
				add_overlay("[initial(C.icon_state)]lit_[(chambered ? "firing" : "loaded")]")
			else if(C.burnt)
				add_overlay("[initial(C.icon_state)]_[(chambered ? "firing" : "loaded")]")
		else if(istype(AC, /obj/item/ammo_casing/caseless/arrow))
			add_overlay("[initial(AC.icon_state)]_[(chambered ? "firing" : "loaded")]")
		else if(istype(AC, /obj/item/ammo_casing/caseless/arrow/sm))
			add_overlay("sm_[(chambered ? "firing" : "loaded")]")
		else
			add_overlay("arrow_[(chambered ? "firing" : "loaded")]") //if all else fails
	if(attachment)
		add_overlay("bow_[initial(attachment.icon_state)]")
	else
		return

/obj/item/gun/ballistic/bow/examine(mob/user)
	. = ..()
	if(bowstring)
		. += initial(bowstring.added_description)
	if(!bowstring)
		. += "<span class='info'>This bow has no drawstring. Not much of a bow, is it.</span>"
	if(attachment)
		. += initial(attachment.added_description)

/obj/item/gun/ballistic/bow/can_shoot()
	return chambered

/obj/item/gun/ballistic/bow/ashen
	name = "bone bow"
	desc = "A bow carved out of bone. Well suited for melee combat, althought its robustness causes a slight delay in drawing."
	icon_state = "ashenbow"
	bowstring = /obj/item/weaponcrafting/attachment/primary/sinewstring
	force = 7
	drawtime = 1.2

/obj/item/gun/ballistic/bow/ashen/stringless
	bowstring = null

/obj/item/gun/ballistic/bow/bamboo
	name = "bamboo bow"
	desc = "A bow made out of bamboo. Easy to draw, can be fitted into a backpack when without a string. However, it is extremely weak at melee combat."
	icon_state = "bamboobow"
	bowstring = /obj/item/weaponcrafting/attachment/primary/bamboostring
	force = 2
	drawtime = 0.8

/obj/item/gun/ballistic/bow/bamboo/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(bowstring)
		w_class = WEIGHT_CLASS_BULKY
	else
		w_class = WEIGHT_CLASS_LARGE


/obj/item/gun/ballistic/bow/bamboo/stringless
	bowstring = null

/obj/item/gun/ballistic/bow/pvc
	name = "pvc bow"
	desc = "A bow crafted with PVC piping. It's rather innacurate and it requires more effort to draw than is usual."
	icon_state = "pvcbow"
	bowstring = /obj/item/weaponcrafting/attachment/primary/cablestring
	drawtime = 1.5
	force = 6
	spread = 10

/obj/item/gun/ballistic/bow/pvc/stringless
	bowstring = null

/obj/item/gun/ballistic/bow/syndicate //Not aviable ingame yet
	name = "Energy Bow"
	desc = "A bow of Syndicate design, meant to be concealed and activated at will."
	icon_state = "energybow"
	drawtime = 0.5
	bowstring = null
	w_class = WEIGHT_CLASS_NORMAL
	var/on = FALSE

/obj/item/gun/ballistic/bow/syndicate/AltClick(mob/user)
	. = ..()
	if(!string_cut && bowstring == /obj/item/weaponcrafting/attachment/primary/energy_crystal)
		turn_on()
	else
		return


/obj/item/gun/ballistic/bow/syndicate/attack_self(mob/living/user)
	. = ..()
	if(!on && !string_cut && bowstring == /obj/item/weaponcrafting/attachment/primary/energy_crystal)
		turn_on()

/obj/item/gun/ballistic/bow/syndicate/proc/turn_on()
	if(!on)
		on = TRUE
		bowstring = /obj/item/weaponcrafting/attachment/primary/energy_crystal
		w_class = WEIGHT_CLASS_BULKY
		update_icon()
		playsound(src, 'sound/weapons/saberon.ogg', 35, 1)
	else
		on = FALSE
		bowstring = null
		fire_sound = initial(fire_sound)
		w_class = initial(w_class)
		update_icon()
		playsound(src, 'sound/weapons/saberoff.ogg', 35, 1)

/obj/item/gun/ballistic/bow/energy/examine(mob/user)
	. = ..()
	if(!string_cut || bowstring == /obj/item/weaponcrafting/attachment/primary/energy_crystal)
		. += "<span class='info'>Press <B>Alt-Click</B> to turn the bow on and off.</span>"
	else
		. += "<span class='info'>This energy bow has been mutilated and lacks an <B>Energy Crystal</B>...</span>"
