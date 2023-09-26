/obj/item/computer_hardware/printer
	name = "printer"
	desc = "Computer-integrated printer with paper recycling module."
	power_usage = 100
	icon_state = "printer"
	w_class = WEIGHT_CLASS_NORMAL
	device_type = MC_PRINT
	expansion_hw = TRUE
	var/stored_paper = 20
	var/max_paper = 30

/obj/item/computer_hardware/printer/diagnostics(mob/living/user)
	..()
	to_chat(user, "Paper level: [stored_paper]/[max_paper].")

/obj/item/computer_hardware/printer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Paper level: [stored_paper]/[max_paper].</span>"


/obj/item/computer_hardware/printer/proc/can_print()
	if(!stored_paper)
		return FALSE
	if(!check_functionality())
		return FALSE

	return TRUE

/obj/item/computer_hardware/printer/proc/print_text(text_to_print, paper_title = "")
	if(!can_print())
		return FALSE

	var/obj/item/paper/printed_paper = new/obj/item/paper(holder.drop_location())

	// Damaged printer causes the resulting paper to be somewhat harder to read.
	if(damage > damage_malfunction)
		printed_paper.add_raw_text(stars(text_to_print, 100-malfunction_probability))
	else
		printed_paper.add_raw_text(text_to_print)
	if(paper_title)
		printed_paper.name = paper_title
	printed_paper.update_icon()
	stored_paper--

	return TRUE

/obj/item/computer_hardware/printer/proc/print_type(type_to_print, paper_title, do_malfunction = FALSE)
	if(!can_print())
		return FALSE
	if(!ispath(type_to_print, /obj))
		return FALSE

	var/obj/O = new type_to_print(holder.drop_location())

	if(istype(O, /obj/item/paper))
		var/obj/item/paper/P = O
		// Damaged printer causes the resulting paper to be somewhat harder to read.
		if(do_malfunction && damage > damage_malfunction)
			P.default_raw_text = stars(P.default_raw_text, 100-malfunction_probability)
			// From the stars definition:
			//   This proc is dangerously laggy, avoid it or die
			// Because of this, malfunction is disabled by default for this, since we might be printing big things
		if(paper_title)
			P.name = paper_title

	stored_paper--

	return TRUE

/obj/item/computer_hardware/printer/try_insert(obj/item/I, mob/living/user = null)
	if(istype(I, /obj/item/paper))
		if(stored_paper >= max_paper)
			to_chat(user, "<span class='warning'>You try to add \the [I] into [src], but its paper bin is full!</span>")
			return FALSE

		if(user && !user.temporarilyRemoveItemFromInventory(I))
			return FALSE
		to_chat(user, "<span class='notice'>You insert \the [I] into [src]'s paper recycler.</span>")
		qdel(I)
		stored_paper++
		return TRUE
	return FALSE

/obj/item/computer_hardware/printer/mini
	name = "miniprinter"
	desc = "A small printer with paper recycling module."
	power_usage = 50
	icon_state = "printer_mini"
	w_class = WEIGHT_CLASS_TINY
	stored_paper = 5
	max_paper = 15
