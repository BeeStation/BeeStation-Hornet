/obj/item/gun/ballistic/bow
	name = "wooden bow"
	desc = "some sort of primitive projectile weapon. used to fire arrows."
	icon_state = "bow"
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
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL //so ashwalkers can use it

/obj/item/gun/ballistic/bow/shoot_with_empty_chamber()
	return

/obj/item/gun/ballistic/bow/chamber_round()
	chambered = magazine.get_round(1)

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
		if (do_mob(user,I,10))
			to_chat(user, "<span class='notice'>You draw back the bowstring.</span>")
			playsound(src, 'sound/weapons/bowdraw.ogg', 75, 0) //gets way too high pitched if the freq varies
			chamber_round()
	update_icon()

/obj/item/gun/ballistic/bow/attackby(obj/item/I, mob/user, params)
	if (magazine.attackby(I, user, params, 1))
		to_chat(user, "<span class='notice'>You notch the arrow.</span>")
		update_icon()

/obj/item/gun/ballistic/bow/update_icon()
	icon_state = "[initial(icon_state)]_[get_ammo() ? (chambered ? "firing" : "loaded") : "unloaded"]"

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
	desc = "A crude projectile weapon made from silk string, pipe and lots of bending."
	icon_state = "pipebow"
	item_state = "pipebow"
	force = 7
