

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
	var/overheat = 0
	var/overheat_max = 40
	var/heat_diffusion = 0.5

/obj/item/minigunpack/Initialize()
	. = ..()
	gun = new(src)
	START_PROCESSING(SSobj, src)

/obj/item/minigunpack/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/minigunpack/process(delta_time)
	overheat = max(0, overheat - heat_diffusion * delta_time)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/minigunpack/attack_hand(var/mob/living/carbon/user)
	if(src.loc == user)
		if(!armed)
			if(user.get_item_by_slot(ITEM_SLOT_BACK) == src)
				armed = 1
				if(!user.put_in_hands(gun))
					armed = 0
					to_chat(user, "<span class='warning'>You need a free hand to hold the gun!</span>")
					return
				update_icon()
				user.update_inv_back()
		else
			to_chat(user, "<span class='warning'>You are already holding the gun!</span>")
	else
		..()

/obj/item/minigunpack/attackby(obj/item/W, mob/user, params)
	if(W == gun) //Don't need armed check, because if you have the gun assume its armed.
		user.dropItemToGround(gun, TRUE)
	else
		..()

/obj/item/minigunpack/dropped(mob/user)
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
		to_chat(user, "<span class='notice'>You attach the [gun.name] to the [name].</span>")
	else
		src.visible_message("<span class='warning'>The [gun.name] snaps back onto the [name]!</span>")
	update_icon()
	user.update_inv_back()

/obj/item/minigunpack/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='warning'>You break the heat sensor.</span>")
	overheat_max = 1000

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
	materials = list()
	automatic = 1
	fire_rate = 10
	weapon_weight = WEAPON_HEAVY
	ammo_type = list(/obj/item/ammo_casing/energy/laser)
	cell_type = /obj/item/stock_parts/cell/minigun
	can_charge = FALSE
	fire_sound = 'sound/weapons/laser.ogg'
	item_flags = NEEDS_PERMIT | SLOWS_WHILE_IN_HAND
	var/cooldown = 0
	var/obj/item/minigunpack/ammo_pack

/obj/item/gun/energy/minigun/Initialize()
	if(istype(loc, /obj/item/minigunpack)) //We should spawn inside an ammo pack so let's use that one.
		ammo_pack = loc
	else
		return INITIALIZE_HINT_QDEL //No pack, no gun

	return ..()

/obj/item/gun/energy/minigun/attack_self(mob/living/user)
	return

/obj/item/gun/energy/minigun/dropped(mob/user)
	if(ammo_pack)
		ammo_pack.attach_gun(user)
	else
		qdel(src)

/obj/item/gun/energy/minigun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(ammo_pack)
		if(obj_flags & EMAGGED)
			if(cooldown < world.time)
				cooldown = world.time + 50
				playsound(get_turf(src), 'sound/weapons/heavyminigunstart.ogg', 50, 0, 0)
				slowdown = 5
				sleep(15)
				if(ammo_pack.overheat < ammo_pack.overheat_max)
					ammo_pack.overheat += burst_size
					playsound(get_turf(src), 'sound/weapons/heavyminigunshoot.ogg', 60, 0, 0)
					..()
					playsound(get_turf(src), 'sound/weapons/heavyminigunstop.ogg', 50, 0, 0)
					slowdown = initial(slowdown)
				else
					to_chat(user, "The gun's heat sensor locked the trigger to prevent lens damage.")
		else
			..()

/obj/item/gun/energy/minigun/afterattack(atom/target, mob/living/user, flag, params)
	if(!ammo_pack || ammo_pack.loc != user)
		to_chat(user, "You need the backpack power source to fire the gun!")
	. = ..()

/obj/item/gun/energy/minigun/dropped(mob/living/user)
	ammo_pack.attach_gun(user)

/obj/item/gun/energy/minigun/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	fire_sound = null
	spread = 60
	recoil = 1
	burst_size = 120
	fire_delay = 0.2
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 30, 0, 0)
	to_chat(user, "<span class='colossus'>OVERDRIVE.</span>")
