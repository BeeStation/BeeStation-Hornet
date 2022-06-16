/obj/structure/closet/crate/bin
	desc = "A trash bin, place your trash here for the janitor to collect."
	name = "trash bin"
	icon_state = "largebins"
	base_icon_state = "largebins"
	open_sound = 'sound/effects/bin_open.ogg'
	close_sound = 'sound/effects/bin_close.ogg'
	anchored = TRUE
	horizontal = FALSE
	delivery_icon = null
	door_anim_time = 0

/obj/structure/closet/crate/bin/Initialize(mapload)
	. = ..()
	if(icon_state == "[base_icon_state]open")
		opened = TRUE
	update_appearance()

/obj/structure/closet/crate/bin/update_icon_state()
	icon_state = "[base_icon_state][opened ? "open" : null]"
	return ..()

/obj/structure/closet/crate/bin/update_overlays()
	. = ..()

	if(contents.len == 0)
		. += "largebing"
		return
	if(contents.len >= storage_capacity)
		. += "largebinr"
		return
	. += "largebino"

/obj/structure/closet/crate/bin/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/storage/bag/trash))
		var/obj/item/storage/bag/trash/T = W
		to_chat(user, "<span class='notice'>You fill the bag.</span>")
		for(var/obj/item/O in src)
			SEND_SIGNAL(T, COMSIG_TRY_STORAGE_INSERT, O, user, TRUE)
		T.update_appearance()
		do_animate()
		return TRUE
	else
		return ..()

/obj/structure/closet/crate/bin/proc/do_animate()
	playsound(loc, open_sound, 15, 1, -3)
	flick("animate_largebins", src)
	addtimer(CALLBACK(src, .proc/close), 13)
