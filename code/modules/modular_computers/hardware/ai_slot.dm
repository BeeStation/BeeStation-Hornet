/obj/item/computer_hardware/ai_slot
	name = "intelliCard interface slot"
	desc = "A module allowing this computer to interface with most common intelliCard modules. Necessary for some programs to run properly."
	power_usage = 100 //W
	icon_state = "card_mini"
	w_class = WEIGHT_CLASS_SMALL
	device_type = MC_AI

	var/obj/item/aicard/stored_card
	var/locked = FALSE

///What happens when the intellicard is removed (or deleted) from the module, through try_eject() or not.
/obj/item/computer_hardware/ai_slot/Exited(atom/A, atom/newloc)
	if(A == stored_card)
		stored_card = null
	return ..()

/obj/item/computer_hardware/ai_slot/examine(mob/user)
	. = ..()
	if(stored_card)
		. += "There appears to be an intelliCard loaded. There appears to be a pinhole protecting a manual eject button. A screwdriver could probably press it."

/obj/item/computer_hardware/ai_slot/on_install(obj/item/modular_computer/M, mob/living/user = null)
	M.add_computer_verbs(device_type)

/obj/item/computer_hardware/ai_slot/on_remove(obj/item/modular_computer/M, mob/living/user = null)
	M.remove_computer_verbs(device_type)

/obj/item/computer_hardware/ai_slot/try_insert(obj/item/I, mob/living/user = null)
	if(!holder)
		return FALSE

	if(!istype(I, /obj/item/aicard))
		return FALSE

	if(stored_card)
		to_chat(user, "<span class='warning'>You try to insert \the [I] into \the [src], but the slot is occupied.</span>")
		return FALSE
	if(user && !user.transferItemToLoc(I, src))
		return FALSE

	stored_card = I
	to_chat(user, "<span class='notice'>You insert \the [I] into \the [src].</span>")

	return TRUE


/obj/item/computer_hardware/ai_slot/try_eject(slot=0,mob/living/user = null,forced = 0)
	if(!stored_card)
		to_chat(user, "<span class='warning'>There is no card in \the [src].</span>")
		return FALSE

	if(locked && !forced)
		to_chat(user, "<span class='warning'>Safeties prevent you from removing the card until reconstruction is complete...</span>")
		return FALSE

	if(stored_card)
		to_chat(user, "<span class='notice'>You remove [stored_card] from [src].</span>")
		locked = FALSE
		if(user)
			user.put_in_hands(stored_card)
		else
			stored_card.forceMove(drop_location())

		return TRUE
	return FALSE

/obj/item/computer_hardware/ai_slot/attackby(obj/item/I, mob/living/user)
	if(..())
		return
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user, "<span class='notice'>You press down on the manual eject button with \the [I].</span>")
		try_eject(,user,1)
		return
