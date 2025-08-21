/obj/item/ammo_box/magazine/internal/cylinder
	name = "revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = list("357")
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/get_round(keep = FALSE)
	rotate()

	var/obj/item/ammo_casing/b = stored_ammo[1]
	if(!keep)
		stored_ammo[1] = null

	return b

/obj/item/ammo_box/magazine/internal/cylinder/proc/rotate()
	var/obj/item/ammo_casing/b = stored_ammo[1]
	stored_ammo.Cut(1, 2)
	stored_ammo.Insert(0, b)

/obj/item/ammo_box/magazine/internal/cylinder/proc/spin()
	for(var/i in 1 to rand(0, max_ammo * 2))
		rotate()

/obj/item/ammo_box/magazine/internal/cylinder/ammo_list(drop_list = FALSE)
	var/list/L = list()
	for(var/i in 1 to stored_ammo.len)
		var/obj/item/ammo_casing/bullet = stored_ammo[i]
		if(bullet)
			L.Add(bullet)
			if(drop_list)
				stored_ammo[i] = null
	return L

/obj/item/ammo_box/magazine/internal/cylinder/give_round(obj/item/ammo_casing/R, replace_spent = FALSE)
	if(!R)
		return FALSE

	if(length(caliber))
		if(!(R.caliber in caliber))
			return FALSE
	else if(R.type != ammo_type)
		return FALSE

	for(var/i in 1 to stored_ammo.len)
		var/obj/item/ammo_casing/bullet = stored_ammo[i]
		if(!bullet) // empty chamber
			stored_ammo[i] = R
			R.forceMove(src)
			return TRUE

	return FALSE

/obj/item/ammo_box/magazine/internal/cylinder/top_off(load_type, starting=FALSE)
	if(starting) // nulls don't exist yet
		return ..()

	if(!load_type)
		load_type = ammo_type

	for(var/i in 1 to max_ammo)
		if(!give_round(new load_type(src)))
			break
	update_appearance()

/obj/item/ammo_box/magazine/internal/cylinder/mime
	name = "fingergun cylinder"
	ammo_type = /obj/item/ammo_casing/caseless/mime
	caliber = list("mime")
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/mime/lethal
	ammo_type = /obj/item/ammo_casing/caseless/mime/lethal
	max_ammo = 3 //Because that's how many this is supposed to have from what I gather
