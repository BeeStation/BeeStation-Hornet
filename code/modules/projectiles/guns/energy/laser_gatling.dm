

//The ammo/gun is stored in a back slot item
/obj/item/minigunpack
	name = "backpack power source"
	desc = "The massive external power source for the laser gatling gun."
	icon = 'icons/obj/guns/minigun.dmi'
	icon_state = "holstered"
	item_state = "backpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	var/obj/item/gun/energy/minigun/gun
	var/armed = 0 //whether the gun is attached, 0 is attached, 1 is the gun is wielded.

/obj/item/minigunpack/Initialize(mapload)
	. = ..()
	gun = new(src)

/obj/item/minigunpack/Destroy()
	if(!QDELETED(gun))
		qdel(gun)
	gun = null
	return ..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/minigunpack/attack_hand(var/mob/living/carbon/user)
	if(src.loc == user)
		if(!armed)
			if(user.get_item_by_slot(ITEM_SLOT_BACK) == src)
				armed = 1
				if(!user.put_in_hands(gun))
					armed = 0
					to_chat(user, span_warning("You need a free hand to hold the gun!"))
					return
				update_icon()
				user.update_inv_back()
		else
			to_chat(user, span_warning("You are already holding the gun!"))
	else
		..()

/obj/item/minigunpack/attackby(obj/item/W, mob/user, params)
	if(W == gun) //Don't need armed check, because if you have the gun assume its armed.
		user.dropItemToGround(gun, TRUE)
	else
		..()

/obj/item/minigunpack/dropped(mob/user)
	..()
	if(armed)
		user.dropItemToGround(gun, TRUE)

/obj/item/minigunpack/MouseDrop(atom/over_object)
	. = ..()
	if(armed)
		return
	if(iscarbon(usr))
		var/mob/M = usr

		if(!over_object)
			return

		if(!M.incapacitated())

			if(istype(over_object, /atom/movable/screen/inventory/hand))
				var/atom/movable/screen/inventory/hand/H = over_object
				M.putItemFromInventoryInHandIfPossible(src, H.held_index)


/obj/item/minigunpack/update_icon()
	if(armed)
		icon_state = "notholstered"
	else
		icon_state = "holstered"

/obj/item/minigunpack/proc/attach_gun(var/mob/user)
	if(!gun)
		gun = new(src)
	gun.forceMove(src)
	armed = 0
	if(user)
		to_chat(user, span_notice("You attach the [gun.name] to the [name]."))
	else
		src.visible_message(span_warning("The [gun.name] snaps back onto the [name]!"))
	update_icon()
	user.update_inv_back()

/obj/item/stock_parts/cell/minigun
	name = "Minigun gun fusion core"
	maxcharge = 500000
	self_recharge = 0

/obj/item/gun/energy/minigun
	name = "laser gatling gun"
	desc = "An advanced laser cannon with an incredible rate of fire. Requires a bulky backpack power source to use."
	icon = 'icons/obj/guns/minigun.dmi'
	icon_state = "minigun_spin"
	item_state = "minigun"
	flags_1 = CONDUCT_1
	slowdown = 1
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	custom_materials = null
	automatic = 1
	fire_rate = 10
	weapon_weight = WEAPON_HEAVY
	ammo_type = list(/obj/item/ammo_casing/energy/laser)
	cell_type = /obj/item/stock_parts/cell/minigun
	can_charge = FALSE
	fire_sound = 'sound/weapons/laser.ogg'
	item_flags = NEEDS_PERMIT | SLOWS_WHILE_IN_HAND
	full_auto = TRUE
	var/cooldown
	var/last_fired
	var/spin = 0
	var/current_heat = 0
	var/overheat = 80 //8 second cooldown
	var/obj/item/minigunpack/ammo_pack

/obj/item/gun/energy/minigun/Initialize(mapload)
	if(istype(loc, /obj/item/minigunpack)) //We should spawn inside an ammo pack so let's use that one.
		ammo_pack = loc
	else
		return INITIALIZE_HINT_QDEL //No pack, no gun

	return ..()

/obj/item/gun/energy/minigun/Destroy()
	if(!QDELETED(ammo_pack))
		qdel(ammo_pack)
	ammo_pack = null
	return ..()

/obj/item/gun/energy/minigun/attack_self(mob/living/user)
	return

/obj/item/gun/energy/minigun/dropped(mob/user)
	..()
	if(ammo_pack)
		ammo_pack.attach_gun(user)
	else
		qdel(src)

/obj/item/gun/energy/minigun/fire_shot_at(mob/living/user, atom/target, message, params, zone_override, aimed)
	if(ammo_pack)
		if(cooldown < world.time)
			if(current_heat >= overheat) //We've been firing too long, shut it down
				to_chat(user, span_warning("[src]'s heat sensor locked the trigger to prevent lens damage."))
				shoot_with_empty_chamber(user)
				stop_firing()
			if(spin >= 12) //full rate of fire
				fire_effect(TRUE)
				..()
			else if(spin >= 6 && spin % 2) //Starting to fire rounds
				fire_effect(TRUE)
				..()
			else if(spin < 6 && spin % 2) //Just starting to spin, no rounds fired
				fire_effect()
			else if(spin >= 6) //Full spin sound between shots
				fire_effect()
			spin++
			last_fired = world.time
		else
			to_chat(user, span_warning("[src] is not ready to fire again yet!"))
	else
		to_chat(user, span_warning("There is no power supply for [src]"))
	return FALSE

/obj/item/gun/energy/minigun/proc/stop_firing()
	if(current_heat) //Don't play the sound or apply cooldown unless it has actually fired at least once
		playsound(get_turf(src), 'sound/weapons/heavyminigunstop.ogg', 50, 0, 0)
		cooldown = world.time + max(current_heat, 2 SECONDS) //2 to 8 seconds depending on how hot it was. At least 1.5 seconds is required to prevent overlapping conflicts with spinups and spindowns.
		current_heat = 0
	spin = 0

/obj/item/gun/energy/minigun/proc/check_firing()
	if(last_fired + 4 <= world.time)
		stop_firing()

/obj/item/gun/energy/minigun/proc/fire_effect(heating)
	playsound(get_turf(src), 'sound/weapons/heavyminigunstart.ogg', 40, 0, 0)
	addtimer(CALLBACK(src, PROC_REF(check_firing),), 5)
	if(heating)
		current_heat += 2

/obj/item/gun/energy/minigun/afterattack(atom/target, mob/living/user, flag, params)
	if(!ammo_pack || ammo_pack.loc != user)
		to_chat(user, span_warning("You need the backpack power source to fire the gun!"))
	. = ..()
