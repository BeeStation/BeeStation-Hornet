//Boxes of ammo
/obj/item/ammo_box
	name = "ammo box (null_reference_exception)"
	desc = "A box of ammo."
	icon = 'icons/obj/ammo.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron = 30000)
	throwforce = 2
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	var/list/stored_ammo = list()
	var/ammo_type = /obj/item/ammo_casing
	var/max_ammo = 7
	var/multiple_sprites = 0
	var/caliber
	var/multiload = FALSE //Only specific magazines have multi-load enabled. This includes all internal mags/cylinders
	var/start_empty = FALSE
	var/list/bullet_cost
	var/list/base_cost// override this one as well if you override bullet_cost

/obj/item/ammo_box/Initialize(mapload)
	. = ..()
	if (!bullet_cost)
		for (var/material in custom_materials)
			var/material_amount = custom_materials[material]
			LAZYSET(base_cost, material, (material_amount * 0.10))

			material_amount *= 0.90 // 10% for the container
			material_amount /= max_ammo
			LAZYSET(bullet_cost, material, material_amount)
	if(!start_empty)
		for(var/i in 1 to max_ammo)
			stored_ammo += new ammo_type(src)
	update_icon()

/obj/item/ammo_box/proc/get_round(keep = FALSE)
	if (!stored_ammo.len)
		return null
	else
		var/b = stored_ammo[stored_ammo.len]
		stored_ammo -= b
		if (keep)
			stored_ammo.Insert(1,b)
		return b

/obj/item/ammo_box/proc/give_round(obj/item/ammo_casing/R)
	// Boxes don't have a caliber type, magazines do. Not sure if it's intended or not, but if we fail to find a caliber, then we fall back to ammo_type.
	if(!R || (caliber && R.caliber != caliber) || (!caliber && R.type != ammo_type))
		return FALSE

	if (stored_ammo.len < max_ammo)
		stored_ammo += R
		R.forceMove(src)
		return TRUE
	return FALSE

/obj/item/ammo_box/proc/can_load(mob/user)
	return TRUE

/obj/item/ammo_box/attackby(obj/item/A, mob/user, params, silent = FALSE)
	var/num_loaded = 0
	if(!can_load(user))
		return
	if(istype(A, /obj/item/ammo_box))
		var/obj/item/ammo_box/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			//If the box you're loading from is empty, break.
			if(!AM.stored_ammo)
				break
			if(!multiload)
				if(!do_after(user, 4, src, IGNORE_USER_LOC_CHANGE))
					break
			var/did_load = give_round(AC)
			if(did_load)
				AM.stored_ammo -= AC
				num_loaded++
				if(!silent && !multiload)
					playsound(src, 'sound/weapons/bulletinsert.ogg', 60, TRUE)
			if(!did_load)
				break
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		if(give_round(AC))
			user.transferItemToLoc(AC, src, TRUE)
			num_loaded++

	if(num_loaded)
		if(!silent)
			to_chat(user, "<span class='notice'>You loaded [num_loaded] shell\s into \the [src]!</span>")
			if(istype(A, /obj/item/ammo_casing))
				playsound(src, 'sound/weapons/bulletinsert.ogg', 60, TRUE)
		A.update_icon()
		update_icon()
	return num_loaded

/obj/item/ammo_box/attack_self(mob/user)
	var/obj/item/ammo_casing/A = get_round()
	if(A)
		A.forceMove(drop_location())
		if(!user.is_holding(src) || !user.put_in_hands(A))	//incase they're using TK
			A.bounce_away(FALSE, NONE)
		playsound(src, 'sound/weapons/bulletinsert.ogg', 60, TRUE)
		to_chat(user, "<span class='notice'>You remove a round from [src]!</span>")
		update_icon()

/obj/item/ammo_box/update_icon()
	var/shells_left = stored_ammo.len
	switch(multiple_sprites)
		if(1)
			icon_state = "[initial(icon_state)]-[shells_left]"
		if(2)
			icon_state = "[initial(icon_state)]-[shells_left ? "[max_ammo]" : "0"]"
	desc = "[initial(desc)] There [(shells_left == 1) ? "is" : "are"] [shells_left] shell\s left!"
	if(length(bullet_cost))
		var/temp_materials = custom_materials.Copy()
		for (var/material in bullet_cost)
			var/material_amount = bullet_cost[material]
			material_amount = (material_amount*stored_ammo.len) + base_cost[material]
			temp_materials[material] = material_amount
		set_custom_materials(temp_materials)

//Behavior for magazines
/obj/item/ammo_box/magazine/proc/ammo_count(countempties = TRUE)
	var/boolets = 0
	for(var/obj/item/ammo_casing/bullet in stored_ammo)
		if(bullet && (bullet.BB || countempties))
			boolets++
	return boolets

/obj/item/ammo_box/magazine/proc/ammo_list(drop_list = FALSE)
	var/list/L = stored_ammo.Copy()
	if(drop_list)
		stored_ammo.Cut()
	return L

/obj/item/ammo_box/magazine/proc/empty_magazine()
	var/turf_mag = get_turf(src)
	for(var/obj/item/ammo in stored_ammo)
		ammo.forceMove(turf_mag)
		stored_ammo -= ammo

/obj/item/ammo_box/magazine/handle_atom_del(atom/A)
	stored_ammo -= A
	update_icon()

//Behavior for ammo pouches (disposable paper ammo box)
/obj/item/ammo_box/pouch
	icon_state = "bagobullets"
	bullet_cost = null
	base_cost = null

/obj/item/ammo_box/pouch/attack_self(mob/user)
	//If it's out of ammo, use it in hand to return the sheet of paper and 'destroy' the ammo box
	if(!stored_ammo.len)
		to_chat(user, "<span class='notice'>You flatten the empty [src]!</span>")
		var/obj/item/paper/unfolded = new /obj/item/paper
		unfolded.forceMove(loc)
		qdel(src)
		user.put_in_hands(unfolded)
		return

	..()
