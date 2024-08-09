/obj/item/computer_hardware/goober
	power_usage = 10 //W
	icon_state = "card_mini"
	w_class = WEIGHT_CLASS_SMALL
	expansion_hw = TRUE

	/// The card in question
	var/obj/item/stored_card
	/// If we are allowing the AI card to be removed
	var/locked = FALSE

/obj/item/computer_hardware/goober/handle_atom_del(atom/A)
	if(A == stored_card)
		try_eject(forced = TRUE)
	. = ..()

/obj/item/computer_hardware/goober/Destroy()
	if(!isnull(stored_card))
		qdel(stored_card)
	..()

/obj/item/computer_hardware/goober/try_insert(obj/item/I, mob/living/user = null)
	if(!holder)
		return FALSE

	if(!isnull(stored_card))
		to_chat(user, "<span class='warning'>You try to insert \the [I] into \the [src], but the slot is occupied.</span>")
		return FALSE
	if(user && !user.transferItemToLoc(I, src))
		return FALSE

	stored_card = I
	post_insert(stored_card, user)

	return TRUE

/obj/item/computer_hardware/goober/proc/post_insert(obj/item/stored_card, mob/living/user)
	to_chat(user, "<span class='notice'>You insert \the [stored_card] into \the [src].</span>")

/obj/item/computer_hardware/goober/try_eject(mob/living/user = null, forced = FALSE)
	if(!stored_card)
		to_chat(user, "<span class='warning'>There is no card in \the [src].</span>")
		return FALSE

	if(locked && !forced)
		to_chat(user, "<span class='warning'>Safeties prevent you from removing the card until reconstruction is complete...</span>")
		return FALSE

	if(stored_card)
		to_chat(user, "<span class='notice'>You eject [stored_card] from [src].</span>")
		locked = FALSE
		if(user && in_range(src, user))
			user.put_in_hands(stored_card)
		else
			stored_card.forceMove(drop_location())
		stored_card = null
		return TRUE
	return FALSE

/obj/item/computer_hardware/goober/attackby(obj/item/I, mob/living/user)
	if(..())
		return
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user, "<span class='notice'>You press down on the manual eject button with \the [I].</span>")
		try_eject(user, TRUE)
		return

/obj/item/computer_hardware/goober/ai
	name = "intelliCard interface slot"
	desc = "A module allowing this computer to interface with most common intelliCard modules. Necessary for some programs to run properly."
	power_usage = 100
	device_type = MC_AI

/obj/item/computer_hardware/goober/ai/examine(mob/user)
	. = ..()
	if(stored_card)
		. += "There appears to be an intelliCard loaded. There appears to be a pinhole protecting a manual eject button. A screwdriver could probably press it."
	else
		. += "It has an open slot for an intelliCard."

/obj/item/computer_hardware/goober/ai/try_insert(obj/item/I, mob/living/user)
	if(!istype(I, /obj/item/aicard))
		return FALSE

	return ..()

/obj/item/computer_hardware/goober/ai/try_eject(mob/living/user, forced)
	if(locked && !forced)
		to_chat(user, "<span class='warning'>Safeties prevent you from removing the card until reconstruction is complete...</span>")
		return FALSE

	return ..()

/obj/item/computer_hardware/goober/pai
	name = "personal AI interface slot"
	desc = "A module allowing this computer to interface with a personal AI device."
	power_usage = 10
	device_type = MC_PAI

/obj/item/computer_hardware/goober/pai/examine(mob/user)
	. = ..()
	if(stored_card)
		. += "There appears to be a personal AI loaded. There appears to be a pinhole protecting a manual eject button. A screwdriver could probably press it."

/obj/item/computer_hardware/goober/pai/try_insert(obj/item/I, mob/living/user)
	if(!istype(I, /obj/item/paicard))
		return FALSE

	return ..()

/obj/item/computer_hardware/goober/pai/post_insert(obj/item/stored_card, mob/living/user)
	// If the pAI moves out of the PDA, remove the reference.
	RegisterSignal(stored_card, COMSIG_MOVABLE_MOVED, PROC_REF(stored_pai_moved))
	RegisterSignal(stored_card, COMSIG_PARENT_QDELETING, PROC_REF(remove_pai))
	to_chat(user, "<span class='notice'>You slot \the [stored_card] into [src].</span>")
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
	holder.update_icon()

/// Handle when the pAI moves to exit the component
/obj/item/computer_hardware/goober/pai/proc/stored_pai_moved()
	if(istype(stored_card) && stored_card.loc != src)
		visible_message("<span class='notice'>[stored_card] ejects itself from [src]!</span>")
		remove_pai()

/// Set the internal pAI card to null - this is NOT "Ejecting" it.
/obj/item/computer_hardware/goober/pai/proc/remove_pai()
	if(!istype(stored_card))
		return
	UnregisterSignal(stored_card, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(stored_card, COMSIG_PARENT_QDELETING)
	stored_card = null
	holder.update_icon()

