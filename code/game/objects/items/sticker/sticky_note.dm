//TODO: handle icons for written and blank states - Racc
/obj/item/sticker/sticky_note
	name = "office note"
	icon_state = "sticky_note"
	sticker_icon_state = "sticky_note_sticker"
	do_outline = FALSE
	///Internal paper we use for display
	var/obj/item/paper/my_paper
	///Custom text to throw into the paper at init
	var/custom_text = ""

/obj/item/sticker/sticky_note/Initialize(mapload)
	. = ..()
	my_paper = new(src)
	my_paper.range_check_anchor = src
	my_paper.add_raw_text(custom_text)

/obj/item/sticker/sticky_note/Destroy()
	. = ..()
	my_paper.range_check_anchor = null
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
