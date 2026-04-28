
/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag"
	density = FALSE
	mob_storage_capacity = 2
	open_sound = 'sound/items/zip.ogg'
	close_sound = 'sound/items/zip.ogg'
	open_sound_volume = 15
	close_sound_volume = 15
	integrity_failure = 0
	material_drop = /obj/item/stack/sheet/cotton/cloth
	delivery_icon = null //unwrappable
	anchorable = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	drag_slowdown = 0
	door_anim_time = 0 // no animation
	var/foldedbag_path = /obj/item/bodybag
	var/obj/item/bodybag/foldedbag_instance = null
	var/tagged = 0 // so closet code knows to put the tag overlay back

/obj/structure/closet/body_bag/Destroy()
	// If we have a stored bag, and it's in nullspace (not in someone's hand), delete it.
	if (foldedbag_instance && !foldedbag_instance.loc)
		QDEL_NULL(foldedbag_instance)
	return ..()

/obj/structure/closet/body_bag/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/pen) || istype(I, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, span_notice("You scribble illegibly on [src]!"))
			return
		var/t = stripped_input(user, "What would you like the label to be?", name, null, 53)
		if(user.get_active_held_item() != I)
			return
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(t)
			name = "body bag - [t]"
			tagged = 1
			update_appearance()
		else
			name = "body bag"
		return
	else if(I.tool_behaviour == TOOL_WIRECUTTER)
		to_chat(user, span_notice("You cut the tag off [src]."))
		name = "body bag"
		tagged = 0
		update_appearance()

/obj/structure/closet/body_bag/update_overlays()
	. = ..()
	if(tagged)
		. += "bodybag_label"

/obj/structure/closet/body_bag/open(mob/living/user, force = FALSE, special_effects)
	. = ..()
	if(.)
		mouse_drag_pointer = MOUSE_INACTIVE_POINTER

/obj/structure/closet/body_bag/close(mob/living/user)
	. = ..()
	if(.)
		set_density(FALSE)
		mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr))
			return
		if(opened && !close())
			to_chat(usr, span_warning("You wrestle with [src], but it won't fold while unzipped."))
			return
		if(contents.len)
			to_chat(usr, span_warning("There are too many things inside of [src] to fold it up!"))
			return
		visible_message(span_notice("[usr] folds up [src]."))
		var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
		usr.put_in_hands(B)
		qdel(src)


/obj/structure/closet/body_bag/bluespace
	name = "bluespace body bag"
	desc = "A bluespace body bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bluebodybag"
	foldedbag_path = /obj/item/bodybag/bluespace
	mob_storage_capacity = 15
	max_mob_size = MOB_SIZE_LARGE

/obj/structure/closet/body_bag/bluespace/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr))
			return
		if(opened)
			to_chat(usr, span_warning("You wrestle with [src], but it won't fold while unzipped."))
			return
		if(contents.len >= mob_storage_capacity / 2)
			to_chat(usr, span_warning("There are too many things inside of [src] to fold it up!"))
			return
		for(var/obj/item/bodybag/bluespace/B in src)
			to_chat(usr, span_warning("You can't recursively fold bluespace body bags!") )
			return
		visible_message(span_notice("[usr] folds up [src]."))
		var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
		usr.put_in_hands(B)
		for(var/atom/movable/A in contents)
			A.forceMove(B)
			if(isliving(A))
				to_chat(A, span_userdanger("You're suddenly forced into a tiny, compressed space!"))
		qdel(src)

/*
/obj/structure/closet/body_bag/environmental/hardlight
	name = "hardlight bodybag"
	desc = "A hardlight bag for storing bodies. Resistant to space."
	icon_state = "holobag_med"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	foldedbag_path = null
	weather_protection = list(TRAIT_VOIDSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE)

/obj/structure/closet/body_bag/environmental/hardlight/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type in list(BRUTE, BURN))
		playsound(src, 'sound/weapons/egloves.ogg', 80, TRUE)

/obj/structure/closet/body_bag/environmental/prisoner/hardlight
	name = "hardlight prisoner bodybag"
	desc = "A hardlight bag for storing bodies. Resistant to space, can be sinched to prevent escape."
	icon_state = "holobag_sec"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	foldedbag_path = null
	weather_protection = list(TRAIT_VOIDSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE)

/obj/structure/closet/body_bag/environmental/prisoner/hardlight/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type in list(BRUTE, BURN))
		playsound(src, 'sound/weapons/egloves.ogg', 80, TRUE)
*/
