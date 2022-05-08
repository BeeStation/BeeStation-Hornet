/**
 * Clipboard
 */
/obj/item/clipboard
	name = "clipboard"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	var/obj/item/pen/pen		//The stored pen.
	var/integrated_pen = FALSE 	//Is the pen integrated?
	/**
	 * Weakref of the topmost piece of paper
	 *
	 * This is used for the paper displayed on the clipboard's icon
	 * and it is the one attacked, when attacking the clipboard.
	 * (As you can't organise contents directly in BYOND)
	 */
	var/datum/weakref/toppaper_ref
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE

/obj/item/clipboard/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins putting [user.p_their()] head into the clip of \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS//the clipboard's clip is very strong. industrial duty. can kill a man easily.

/obj/item/clipboard/Initialize(mapload)
	update_icon()
	. = ..()

/obj/item/clipboard/Destroy()
	QDEL_NULL(pen)
	return ..()

/obj/item/clipboard/examine()
	. = ..()
	if(!integrated_pen && pen)
		. += "<span class='notice'>Alt-click to remove [pen].</span>"
	var/obj/item/paper/toppaper = toppaper_ref?.resolve()
	if(toppaper)
		. += "<span class='notice'>Right-click to remove [toppaper].</span>"

/// Take out the topmost paper
/obj/item/clipboard/proc/remove_paper(obj/item/paper/paper, mob/user)
	if(!istype(paper))
		return
	paper.forceMove(user.loc)
	user.put_in_hands(paper)
	to_chat(user, "<span class='notice'>You remove [paper] from [src].</span>")
	var/obj/item/paper/toppaper = toppaper_ref?.resolve()
	if(paper == toppaper)
		toppaper_ref = null
		var/obj/item/paper/newtop = locate(/obj/item/paper) in src
		if(newtop && (newtop != paper))
			toppaper_ref = WEAKREF(newtop)
		else
			toppaper_ref = null
	update_icon()

/obj/item/clipboard/proc/remove_pen(mob/user)
	pen.forceMove(user.loc)
	user.put_in_hands(pen)
	to_chat(user, "<span class='notice'>You remove [pen] from [src].</span>")
	pen = null
	update_icon()

/obj/item/clipboard/AltClick(mob/user)
	..()
	if(pen)
		remove_pen(user)

/obj/item/clipboard/update_icon()
	cut_overlays()
	var/list/dat = list()
	var/obj/item/paper/toppaper = toppaper_ref?.resolve()
	if(toppaper)
		dat += toppaper.icon_state
		dat += toppaper.overlays.Copy()
	if(pen)
		dat += "clipboard_pen"
	dat += "clipboard_over"
	add_overlay(dat)

/obj/item/clipboard/attackby(obj/item/weapon, mob/user, params)
	var/obj/item/paper/toppaper = toppaper_ref?.resolve()
	if(istype(weapon, /obj/item/paper))
		//Add paper into the clipboard
		if(!user.transferItemToLoc(weapon, src))
			return
		toppaper_ref = WEAKREF(weapon)
		to_chat(user, "<span class='notice'>You clip [weapon] onto [src].</span>")
	else if(istype(weapon, /obj/item/pen) && !pen)
		//Add a pen into the clipboard, attack (write) if there is already one
		if(!usr.transferItemToLoc(weapon, src))
			return
		pen = weapon
		to_chat(usr, "<span class='notice'>You slot [weapon] into [src].</span>")
	else if(toppaper)
		toppaper.attackby(user.get_active_held_item(), user)
	update_icon()

/obj/item/clipboard/attack_self(mob/user)
	ui_interact(user)
	add_fingerprint(usr)

/obj/item/clipboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Clipboard")
		ui.open()

/obj/item/clipboard/ui_data(mob/user)
	// prepare data for TGUI
	var/list/data = list()
	data["pen"] = "[pen]"

	var/obj/item/paper/toppaper = toppaper_ref?.resolve()
	data["top_paper"] = "[toppaper]"
	data["top_paper_ref"] = "[REF(toppaper)]"

	data["paper"] = list()
	data["paper_ref"] = list()
	for(var/obj/item/paper/paper in src)
		if(paper == toppaper)
			continue
		data["paper"] += "[paper]"
		data["paper_ref"] += "[REF(paper)]"

	return data

/obj/item/clipboard/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(usr.stat != CONSCIOUS || usr.restrained())
		return

	switch(action)
		// Take the pen out
		if("remove_pen")
			if(pen)
				remove_pen(usr)
				. = TRUE
		// Take paper out
		if("remove_paper")
			var/obj/item/paper/paper = locate(params["ref"]) in src
			if(istype(paper))
				remove_paper(paper, usr)
				. = TRUE
		// Look at (or edit) the paper
		if("edit_paper")
			var/obj/item/paper/paper = locate(params["ref"]) in src
			if(istype(paper))
				paper.ui_interact(usr)
				update_icon()
				. = TRUE
		// Move paper to the top
		if("move_top_paper")
			var/obj/item/paper/paper = locate(params["ref"]) in src
			if(istype(paper))
				toppaper_ref = WEAKREF(paper)
				to_chat(usr, "<span class='notice'>You move [paper] to the top.</span>")
				update_icon()
				. = TRUE
		// Rename the paper (it's a verb)
		if("rename_paper")
			var/obj/item/paper/paper = locate(params["ref"]) in src
			if(istype(paper))
				paper.rename()
				update_icon()
				. = TRUE
