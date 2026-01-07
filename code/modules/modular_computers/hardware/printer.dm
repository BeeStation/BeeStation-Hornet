/obj/item/computer_hardware/printer
	name = "printer"
	desc = "Computer-integrated printer with paper recycling module."
	power_usage = 50 // Watts per second
	icon_state = "printer"
	w_class = WEIGHT_CLASS_NORMAL
	device_type = MC_PRINT
	expansion_hw = TRUE
	var/stored_paper = 20
	var/max_paper = 30
	can_hack = FALSE
	custom_price = PAYCHECK_MEDIUM * 2

/obj/item/computer_hardware/printer/diagnostics()
	. = ..()
	. += "Paper level: [stored_paper]/[max_paper]."

/obj/item/computer_hardware/printer/examine(mob/user)
	. = ..()
	. += span_notice("Paper level: [stored_paper]/[max_paper].")


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
			to_chat(user, span_warning("You try to add \the [I] into [src], but its paper bin is full!"))
			balloon_alert(user, "printer bin is full!")
			return FALSE

		if(user && !user.temporarilyRemoveItemFromInventory(I))
			balloon_alert(user, "can't insert!")
			return FALSE

		playsound(src, 'sound/machines/paper_insert.ogg', 40, vary = TRUE)
		to_chat(user, span_notice("You insert \the [I] into [src]'s paper recycler."))
		balloon_alert(user, "inserted paper!")
		qdel(I)
		stored_paper++
		return TRUE

	if(istype(I, /obj/item/paper_bin))
		var/obj/item/paper_bin/bin = I
		if(bin.total_paper <= 0)
			balloon_alert(user, "empty bin!")
			return FALSE

		if(stored_paper >= max_paper)
			to_chat(user, span_warning("You try to add \the [I] into [src], but its paper bin is full!"))
			balloon_alert(user, "printer bin is full!")
			return FALSE

		var/papers_added
		while((bin.total_paper > 0) && (stored_paper < max_paper))
			papers_added++
			stored_paper++
			bin.total_paper--

		playsound(src, 'sound/machines/paper_insert.ogg', 40, vary = TRUE)
		to_chat(user, span_notice("Added in [papers_added] new sheets. You now have [stored_paper] / [max_paper] printing paper stored."))
		balloon_alert(user, "added in [papers_added] new sheets!")
		bin.update_appearance()
		return TRUE

	return FALSE

/obj/item/computer_hardware/printer/mini
	name = "miniprinter"
	desc = "A small printer with paper recycling module."
	power_usage = 2
	icon_state = "printer_mini"
	w_class = WEIGHT_CLASS_TINY
	stored_paper = 5
	max_paper = 15
	custom_price = PAYCHECK_MEDIUM
