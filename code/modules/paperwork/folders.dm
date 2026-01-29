/obj/item/folder
	name = "folder"
	desc = "A folder."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = WEIGHT_CLASS_SMALL
	pressure_resistance = 2
	resistance_flags = FLAMMABLE
	/// The background color for tgui in hex (with a `#`)
	var/bg_color = "#7f7f7f"

/obj/item/folder/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins filing an imaginary death warrant! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/folder/Initialize(mapload)
	update_icon()
	. = ..()

/obj/item/folder/Destroy()
	for(var/obj/important_thing in contents)
		if(!(important_thing.resistance_flags & INDESTRUCTIBLE))
			continue
		important_thing.forceMove(drop_location()) //don't destroy round critical content such as objective documents.
	return ..()

/obj/item/folder/examine()
	. = ..()
	if(length(contents))
		. += span_notice("Alt-click to remove [contents[1]].")

/obj/item/folder/proc/rename(mob/user)
	if(!user.is_literate())
		to_chat(user, span_notice("You scribble illegibly on the cover of [src]!"))
		return

	var/inputvalue = stripped_input(user, "What would you like to label the folder?", "Folder Labelling", null, MAX_NAME_LEN)

	if(!inputvalue)
		return

	if(user.canUseTopic(src, BE_CLOSE))
		name = "folder[(inputvalue ? " - '[inputvalue]'" : null)]"

/obj/item/folder/proc/remove_item(obj/item/I, mob/user)
	if(istype(I))
		I.forceMove(user.loc)
		user.put_in_hands(I)
		to_chat(user, span_notice("You remove [I] from [src]."))
		update_icon()
		ui_update()

/obj/item/folder/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(length(contents))
		remove_item(contents[1], user)

/obj/item/folder/update_overlays()
	. = ..()
	if(LAZYLEN(contents))
		. += "folder_paper"

/obj/item/folder/attackby(obj/item/W, mob/user, params)
	if(burn_paper_product_attackby_check(W, user))
		return
	if(istype(W, /obj/item/paper) || istype(W, /obj/item/photo) || istype(W, /obj/item/documents))
		//Add paper, photo or documents into the folder
		if(!user.transferItemToLoc(W, src))
			return
		to_chat(user, span_notice("You put [W] into [src]."))
		update_icon()
		ui_update()
	else if(istype(W, /obj/item/pen))
		rename(user)
		ui_update()

/obj/item/folder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Folder")
		ui.open()

/obj/item/folder/ui_data(mob/user)
	var/list/data = list()
	if(istype(src, /obj/item/folder/syndicate))
		data["theme"] = "syndicate"
	data["bg_color"] = "[bg_color]"
	data["folder_name"] = "[name]"

	data["contents"] = list()
	data["contents_ref"] = list()
	for(var/content in src)
		data["contents"] += "[content]"
		data["contents_ref"] += "[REF(content)]"

	return data

/obj/item/folder/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(usr.incapacitated)
		return

	switch(action)
		// Take item out
		if("remove")
			var/obj/item/I= locate(params["ref"]) in src
			remove_item(I, usr)
			. = TRUE
		// Inspect the item
		if("examine")
			var/obj/item/I = locate(params["ref"]) in src
			if(istype(I))
				usr.examinate(I)
				. = TRUE
