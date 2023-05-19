
/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag"
	density = FALSE
	mob_storage_capacity = 2
	var/foldable_storage_capacity = 0 // how many items can this hold folded
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
	var/tagged = FALSE // so closet code knows to put the tag overlay back

/obj/structure/closet/body_bag/Destroy()
	// If we have a stored bag, and it's in nullspace (not in someone's hand), delete it.
	if (foldedbag_instance && !foldedbag_instance.loc)
		QDEL_NULL(foldedbag_instance)
	return ..()

/obj/structure/closet/body_bag/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/pen) || istype(I, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>You scribble illegibly on [src]!</span>")
			return
		var/t = stripped_input(user, "What would you like the label to be?", name, null, 53)
		if(user.get_active_held_item() != I)
			return
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(t)
			name = "body bag - \"[t]\""
			tagged = TRUE
			update_icon()
		else
			name = "body bag"
		return
	else if(I.tool_behaviour == TOOL_WIRECUTTER)
		to_chat(user, "<span class='notice'>You cut the tag off [src].</span>")
		name = "body bag"
		tagged = FALSE
		update_icon()

/obj/structure/closet/body_bag/update_icon()
	..()
	if (tagged)
		add_overlay("bodybag_label")

/obj/structure/closet/body_bag/open(mob/living/user)
	. = ..()
	if(.)
		mouse_drag_pointer = MOUSE_INACTIVE_POINTER

/obj/structure/closet/body_bag/close()
	. = ..()
	if(.)
		set_density(FALSE)
		mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/structure/closet/body_bag/proc/folding_allowed()
	if(!ishuman(usr))
		return FALSE
	if(opened)
		to_chat(usr, "<span class='warning'>You wrestle with [src], but it won't fold while unzipped.</span>")
		return FALSE
	if(contents.len > foldable_storage_capacity)
		to_chat(usr, "<span class='warning'>There are too many things inside of [src] to fold it up!</span>")
		return FALSE
	return TRUE

/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)) && folding_allowed())
		visible_message("<span class='notice'>[usr] folds up [src].</span>")
		var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
		usr.put_in_hands(B)
		qdel(src)

/obj/structure/closet/body_bag/bluespace
	name = "bluespace body bag"
	desc = "A bluespace body bag designed for the storage and instant transportation of cadavers to your local morgue."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bluebodybag"
	foldedbag_path = /obj/item/bodybag/bluespace
	mob_storage_capacity = 10
	foldable_storage_capacity = 2
	max_mob_size = MOB_SIZE_LARGE

/obj/structure/closet/body_bag/bluespace/folding_allowed()
	if(..())
		for(var/obj/item/bodybag/bluespace/B in src)
			to_chat(usr, "<span class='warning'>You can't recursively fold bluespace body bags!</span>" )
			return FALSE
		return TRUE
	return FALSE

/obj/structure/closet/body_bag/bluespace/MouseDrop(over_object, src_location, over_location)
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)) && folding_allowed())
		var/list/trays = list()
		for(var/obj/structure/bodycontainer/morgue/M as() in GLOB.morgue_trays)
			if(M.get_virtual_z_level() == get_virtual_z_level())
				trays += M // Don't allow teleportation between zlevels

		if(!length(trays))
			for(var/atom/movable/A in contents)
				if(isliving(A))
					to_chat(usr, "<span class='warning'>You try to fold [src], but there were no morgues for [A] to be delievered to!</span>")
					return

		// teleport our living mobs
		for(var/mob/living/target in contents)
			var/obj/structure/bodycontainer/morgue/M = pick(trays)

			if(is_centcom_level(M.z))
				to_chat(usr, "<span class='warning'>You try to fold [src], but some other-worldly force prevents you from delievering [target] to a morgue!</span>")
				return

			target.forceMove(M)
			to_chat(target, "<span class='userdanger'>You're suddenly forced into a tiny, compressed space! You have warped into [M]!</span>")
			target.Knockdown(30)

			if(M.connected.loc != M)
				M.close() // close our trays if they are opened
			else
				M.update_icon()
			playsound(M, 'sound/machines/ping.ogg', 60, TRUE)
			M.visible_message("<span class='notice'>[M] pings.</span>")
			contents -= target

		// prevent a situation where you can put a bodybag recursively inside of itself
		for(var/obj/item/storage/S in contents)
			SEND_SIGNAL(S, COMSIG_TRY_STORAGE_HIDE_ALL)

		visible_message("<span class='notice'>[usr] folds up [src].</span>")
		var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
		usr.put_in_hands(B)
		for(var/atom/movable/A in contents)
			A.forceMove(B)
		qdel(src)
