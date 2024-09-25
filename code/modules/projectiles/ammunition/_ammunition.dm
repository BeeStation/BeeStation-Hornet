/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron = 500)
	//What sound should play when this ammo is fired
	var/fire_sound = null
	//Which kind of guns it can be loaded into
	var/caliber = null
	//The bullet type to create when New() is called
	var/projectile_type = null
	//The loaded bullet
	var/obj/projectile/BB = null
	//Pellets for spreadshot
	var/pellets = 1
	//Variance for inaccuracy fundamental to the casing
	var/variance = 0
	//Randomspread for automatics
	var/randomspread = 0
	//Delay for energy weapons
	var/delay = 0
	//the visual effect appearing when the ammo is fired.
	var/firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect
	var/heavy_metal = TRUE
	//pacifism check for boolet, set to FALSE if bullet is non-lethal
	var/harmful = TRUE
	var/click_cooldown_override = 0
	var/exists = TRUE

/obj/item/ammo_casing/spent
	name = "spent bullet casing"
	BB = null

/obj/item/ammo_casing/Initialize(mapload)
	. = ..()
	if(projectile_type)
		BB = new projectile_type(src)
	pixel_x = base_pixel_x + rand(-10, 10)
	pixel_y = base_pixel_y + rand(-10, 10)
	setDir(pick(GLOB.alldirs))
	update_icon()

/obj/item/ammo_casing/Destroy()
	var/turf/T = get_turf(src)
	if(T && !BB && is_station_level(T.z))
		SSblackbox.record_feedback("tally", "station_mess_destroyed", 1, name)
	QDEL_NULL(BB)
	return ..()

/obj/item/ammo_casing/update_icon()
	..()
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"
	desc = "[initial(desc)][BB ? "" : " This one is spent."]"

//proc to magically refill a casing with a new projectile
/obj/item/ammo_casing/proc/newshot() //For energy weapons, syringe gun, shotgun shells and wands (!).
	if(!BB)
		BB = new projectile_type(src, src)

/obj/item/ammo_casing/attackby(obj/item/I, mob/user, params)
	//Regular boxes of ammo can sweep shells up from the floor, magazines that get insert into guns do not though
	if(istype(I, /obj/item/ammo_box) && !istype(I, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/box = I
		if(isturf(loc))
			var/boolets = 0
			for(var/obj/item/ammo_casing/bullet in loc)
				if (box.stored_ammo.len >= box.max_ammo)
					break
				if (bullet.BB)
					if (box.give_round(bullet, 0))
						boolets++
				else
					continue
			if (boolets > 0)
				box.update_icon()
				to_chat(user, "<span class='notice'>You collect [boolets] shell\s. [box] now contains [box.stored_ammo.len] shell\s.</span>")
			else
				to_chat(user, "<span class='warning'>You fail to collect anything!</span>")
	else
		return ..()

/obj/item/ammo_casing/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(heavy_metal)
		bounce_away(FALSE, NONE)
	. = ..()

/obj/item/ammo_casing/proc/bounce_away(still_warm = FALSE, bounce_delay = 3)
	update_icon()
	SpinAnimation(10, 1)
	var/turf/T = get_turf(src)
	if(still_warm && T && T.bullet_sizzle)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/items/welder.ogg', 20, 1), bounce_delay) //If the turf is made of water and the shell casing is still hot, make a sizzling sound when it's ejected.
	else if(T?.bullet_bounce_sound)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, T.bullet_bounce_sound, 60, 1), bounce_delay) //Soft / non-solid turfs that shouldn't make a sound when a shell casing is ejected over them.
