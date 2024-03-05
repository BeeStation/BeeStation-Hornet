//TODO: handle icons for written and blank states - Racc
/obj/item/sticker/sticky_note
	name = "office note"
	icon_state = "sticky_note"
	sticker_icon_state = "sticky_note_sticker"
	do_outline = FALSE
	///Internal paper we use for display
	var/obj/item/paper/my_paper
	///Custom text to throw into the paper at init
	var/custom_text

/obj/item/sticker/sticky_note/Initialize(mapload)
	my_paper = new(src)
	if(custom_text)
		my_paper.add_raw_text(custom_text)
		sticker_icon_state = "sticky_note_sticker_written"
	RegisterSignal(my_paper, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(handle_paper))
	return ..()

/obj/item/sticker/sticky_note/Destroy()
	. = ..()
	UnregisterSignal(my_paper, COMSIG_ATOM_UPDATE_OVERLAYS)
	QDEL_NULL(my_paper)

/obj/item/sticker/sticky_note/examine(mob/user)
	. = ..()
	return my_paper.examine(user)

/obj/item/sticker/sticky_note/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	my_paper.attackby(I, user, params)

/obj/item/sticker/sticky_note/interact(mob/user)
	. = ..()
	my_paper.interact(user)

/obj/item/sticker/sticky_note/proc/handle_paper()
	SIGNAL_HANDLER

	sticker_icon_state = "sticky_note_sticker_written"
	stuck_appearance = build_stuck_appearance()
	if(sticker_state == STICKER_STATE_STUCK)
		var/old_x = pixel_x
		var/old_y = pixel_y
		update_appearance()
		pixel_x = old_x
		pixel_y = old_y
	UnregisterSignal(my_paper, COMSIG_ATOM_UPDATE_OVERLAYS)
