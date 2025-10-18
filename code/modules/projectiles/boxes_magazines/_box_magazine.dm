//Boxes of ammo
/obj/item/ammo_box
	name = "ammo box (null_reference_exception)"
	desc = "A box of ammo."
	icon = 'icons/obj/ammo.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	inhand_icon_state = "syringe_kit"
	worn_icon_state = "ammobox"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron = 30000)
	throwforce = 2
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	override_notes = TRUE
	var/list/stored_ammo = list()
	var/ammo_type = /obj/item/ammo_casing
	var/max_ammo = 7
	var/multiple_sprites = 0
	var/list/caliber = list()
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
		top_off(starting=TRUE)
	update_icon()

/obj/item/ammo_box/add_weapon_description()
	AddElement(/datum/element/weapon_description, attached_proc = PROC_REF(add_notes_box))

/obj/item/ammo_box/proc/add_notes_box()
	var/list/readout = list()

	if(length(caliber) && max_ammo)
		var/caliber_list = jointext(caliber, ", ")
		readout += "Up to [span_warning("[max_ammo] rounds of: [caliber_list]")] can be found within this magazine. \
		\nAccidentally discharging any of these projectiles may void your insurance contract."

	var/obj/item/ammo_casing/mag_ammo = get_round(TRUE)

	if(istype(mag_ammo))
		readout += "\n[mag_ammo.add_notes_ammo()]"

	return readout.Join("\n")


/**
  * top_off is used to refill the magazine to max, in case you want to increase the size of a magazine with VV then refill it at once
  *
  * Arguments:
  * * load_type - if you want to specify a specific ammo casing type to load, enter the path here, otherwise it'll use the basic [/obj/item/ammo_box/var/ammo_type]. Must be a compatible round
  * * starting - Relevant for revolver cylinders, if FALSE then we mind the nulls that represent the empty cylinders (since those nulls don't exist yet if we haven't initialized when this is TRUE)
  */
/obj/item/ammo_box/proc/top_off(load_type, starting=FALSE)
	if(!load_type)
		load_type = ammo_type

	var/obj/item/ammo_casing/round_check = load_type
	// Check if this ammo type's caliber is allowed
	if(!starting)
		if(length(caliber))
			if(!(initial(round_check.caliber) in caliber))
				stack_trace("Tried loading unsupported ammocasing type [load_type] into ammo box [type].")
				return
		else if(load_type != ammo_type)
			stack_trace("Tried loading unsupported ammocasing type [load_type] into ammo box [type].")
			return

	for(var/i in max(1, stored_ammo.len + 1) to max_ammo)
		stored_ammo += new round_check(src)
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
	if(!R)
		return FALSE

	if(length(caliber))
		if(!(R.caliber in caliber))
			return FALSE
	else if(R.type != ammo_type)
		return FALSE

	if(stored_ammo.len < max_ammo)
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
		if (length(user.progressbars))
			return
		var/obj/item/ammo_box/AM = A
		while (length(AM.stored_ammo))
			if(!multiload)
				if(!do_after(user, 4, src, IGNORE_USER_LOC_CHANGE))
					break
			//If the box you're loading from is empty, break.
			if (!length(AM.stored_ammo))
				break
			var/obj/item/ammo_casing/AC = AM.stored_ammo[1]
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
			to_chat(user, span_notice("You loaded [num_loaded] shell\s into \the [src]!"))
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
		to_chat(user, span_notice("You remove a round from [src]!"))
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
		to_chat(user, span_notice("You flatten the empty [src]!"))
		var/obj/item/paper/unfolded = new /obj/item/paper
		unfolded.forceMove(loc)
		qdel(src)
		user.put_in_hands(unfolded)
		return

	..()
