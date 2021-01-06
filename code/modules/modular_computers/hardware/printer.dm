/obj/item/computer_hardware/printer
	name = "printer"
	desc = "Computer-integrated printer with paper recycling module."
	power_usage = 100
	icon_state = "printer"
	w_class = WEIGHT_CLASS_NORMAL
	device_type = MC_PRINT
	var/stored_paper = 20
	var/max_paper = 30

/obj/item/computer_hardware/printer/diagnostics(mob/living/user)
	..()
	to_chat(user, "Paper level: [stored_paper]/[max_paper].")

/obj/item/computer_hardware/printer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Paper level: [stored_paper]/[max_paper].</span>"


/obj/item/computer_hardware/printer/proc/print_text(var/text_to_print, var/paper_title = "")
	if(!stored_paper)
		return EF_FALSE
	if(!check_functionality())
		return EF_FALSE

	var/obj/item/paper/P = new/obj/item/paper(holder.drop_location())

	// Damaged printer causes the resulting paper to be somewhat harder to read.
	if(damage > damage_malfunction)
		P.info = stars(text_to_print, 100-malfunction_probability)
	else
		P.info = text_to_print
	if(paper_title)
		P.name = paper_title
	P.update_icon()
	stored_paper--
	P = null
	return EF_TRUE

/obj/item/computer_hardware/printer/try_insert(obj/item/I, mob/living/user = null)
	if(istype(I, /obj/item/paper))
		if(stored_paper >= max_paper)
			to_chat(user, "<span class='warning'>You try to add \the [I] into [src], but its paper bin is full!</span>")
			return EF_FALSE

		if(user && !user.temporarilyRemoveItemFromInventory(I))
			return EF_FALSE
		to_chat(user, "<span class='notice'>You insert \the [I] into [src]'s paper recycler.</span>")
		qdel(I)
		stored_paper++
		return EF_TRUE
	return EF_FALSE

/obj/item/computer_hardware/printer/mini
	name = "miniprinter"
	desc = "A small printer with paper recycling module."
	power_usage = 50
	icon_state = "printer_mini"
	w_class = WEIGHT_CLASS_TINY
	stored_paper = 5
	max_paper = 15
