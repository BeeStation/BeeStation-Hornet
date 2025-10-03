/obj/item/ammo_box/magazine/recharge
	name = "power pack"
	desc = "A rechargeable, detachable battery that serves as a magazine for laser rifles."
	icon_state = "oldrifle-20"
	ammo_type = /obj/item/ammo_casing/caseless/laser
	caliber = list("laser")
	max_ammo = 20

/obj/item/ammo_box/magazine/recharge/update_icon()
	desc = "[initial(desc)] It has [stored_ammo.len] shot\s left."
	icon_state = "oldrifle-[round(ammo_count(),4)]"

/obj/item/ammo_box/magazine/recharge/attack_self() //No popping out the "bullets"
	return

/obj/item/ammo_box/magazine/recharge/emp_act(severity)
	. = ..()
	if (obj_flags & OBJ_EMPED)
		return
	obj_flags |= OBJ_EMPED
	playsound(src, 'sound/machines/capacitor_discharge.ogg', 60, TRUE)
	addtimer(CALLBACK(src, PROC_REF(emp_reset)), rand(1, 200 / severity))
	// Unload the gun we are inside
	if (isgun(loc))
		var/obj/item/gun/gun = loc
		QDEL_NULL(gun.chambered)

/obj/item/ammo_box/magazine/recharge/proc/emp_reset()
	obj_flags &= ~OBJ_EMPED
	playsound(src, 'sound/machines/capacitor_charge.ogg', 100, TRUE)

/obj/item/ammo_box/magazine/recharge/get_round(keep = FALSE)
	if (obj_flags & OBJ_EMPED)
		return null
	return ..()

/obj/item/ammo_box/magazine/recharge/service
	name = "energy pistol magazine"
	desc = "A rechargeable energy pack used by service pistols."
	icon_state = "officer-12"
	max_ammo = 12
	multiple_sprites = 1
	ammo_type = /obj/item/ammo_casing/caseless/laser/lesslethal

/obj/item/ammo_box/magazine/recharge/service/update_icon()
	..()
	icon_state = "officer-[CEILING(ammo_count(),3)]"
