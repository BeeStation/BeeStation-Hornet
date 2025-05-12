/obj/item/sticker/sticky_note
	name = "office note"
	desc = "An adhesive office note."
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
	. += my_paper.examine(user)

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

/*
	Dispenser for sticky notes
*/
/obj/item/sticky_note_pile
	name = "office note pad"
	desc = "A stack of adhesive office notes."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "sticky_note_pile"
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 8
	resistance_flags = FLAMMABLE
	///How many sticky notes do we contain
	var/current_notes = 30

/obj/item/sticky_note_pile/Initialize(mapload)
	. = ..()
	interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP

/obj/item/sticky_note_pile/MouseDrop(atom/over_object)
	. = ..()
	var/mob/living/L = usr
	if(!istype(L) || L.incapacitated() || !Adjacent(L))
		return

	if(over_object == L)
		L.put_in_hands(src)

	else if(istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over_object
		L.putItemFromInventoryInHandIfPossible(src, H.held_index)

	add_fingerprint(L)

/obj/item/sticky_note_pile/attack_hand(mob/user)
	. = ..()
	//Prechecks
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return
	if(current_notes <= 0)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	//Give the note
	user.changeNext_move(CLICK_CD_MELEE)
	var/obj/item/sticker/sticky_note/N = new()
	N.add_fingerprint(user)
	N.forceMove(user.loc)
	user.put_in_hands(N)
	to_chat(user, "<span class='notice'>You take [N] out of \the [src].</span>")
	//Deitterate notes
	current_notes -= 1

/obj/item/sticky_note_pile/examine(mob/user)
	. = ..()
	if(current_notes)
		. += "It contains [current_notes] [current_notes > 1 ? "notes" : "note"]."
	else
		. += "It doesn't contain anything."
