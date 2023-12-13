/obj/structure/closet/crate/bin
	desc = "A trash bin, place your trash here for the janitor to collect."
	name = "trash bin"
	icon_state = "trashbin"
	base_icon_state = "trashbin"
	open_sound = 'sound/effects/bin_open.ogg'
	close_sound = 'sound/effects/bin_close.ogg'
	anchored = TRUE
	horizontal = FALSE
	delivery_icon = null
	//door_anim_time = 0

/obj/structure/closet/crate/bin/LateInitialize()
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/structure/closet/crate/bin/update_overlays()
	. = ..()
	. += emissive_appearance(icon, base_icon_state + "_empty", src.layer)
	if(contents.len == 0)
		. += base_icon_state + "_empty"
		return
	if(contents.len >= storage_capacity)
		. += base_icon_state + "_full"
		return
	. += base_icon_state + "_some"

/obj/structure/closet/crate/bin/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/storage/bag/trash)&& !opened)
		var/obj/item/storage/bag/trash/T = W
		to_chat(user, "<span class='notice'>You fill the bag.</span>")
		for(var/obj/item/O in src)
			SEND_SIGNAL(T, COMSIG_TRY_STORAGE_INSERT, O, user, TRUE)
		T.update_appearance()
		do_open()
		return TRUE
	else
		return ..()

/obj/structure/closet/crate/bin/proc/do_open()
	playsound(loc, open_sound, 15, 1, -3)
	addtimer(CALLBACK(src, PROC_REF(do_close)), 13)

/obj/structure/closet/crate/bin/proc/do_close()
	playsound(loc, close_sound, 15, TRUE, -3)
	update_appearance()
