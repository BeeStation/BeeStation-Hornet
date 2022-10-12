/proc/tgui_select_picture(mob/user, list/datum/picture/choices, title = "Select Photo")
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	if(!choices)
		return
	var/datum/tgui_select_picture/textbox = new(user, choices, title)
	textbox.ui_interact(user)
	textbox.wait()
	if (textbox)
		. = textbox.entry
		qdel(textbox)

/datum/tgui_select_picture
	/// Boolean field describing if the tgui_select_picture was closed by the user.
	var/closed
	/// The entry that the user has selected
	var/datum/picture/entry
	/// The title of the TGUI window
	var/title
	/// The list of picture datums to select from
	var/list/datum/picture/choices = list()

/datum/tgui_select_picture/New(mob/user, choices, title)
	src.title = title
	src.choices = choices

/datum/tgui_select_picture/Destroy(force, ...)
	SStgui.close_uis(src)
	. = ..()

/**
 * Waits for a user's response to the tgui_select_picture's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_select_picture/proc/wait()
	while (!entry && !closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_select_picture/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PictureSelectModal")
		ui.open()

/datum/tgui_select_picture/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_select_picture/ui_state(mob/user)
	return GLOB.always_state

/datum/tgui_select_picture/ui_data(mob/user)
	var/list/pictures = list()
	for(var/datum/picture/picture in choices)
		var/icon/img = picture.picture_image
		var/picture_path = "tgui_select_picture_[picture.id]_[rand(0, 99999)].png"
		usr << browse_rsc(img, picture_path)
		// DM is a great language, am I right?
		// Adding a list to a list un-lists it, so we need a double list to make an "object" list.
		pictures += list(list(
			"ref" = "[REF(picture)]",
			"path" = picture_path,
			"name" = picture.picture_name,
			"desc" = picture.picture_desc,
		))
	return list(
		"title" = title,
		"pictures" = pictures
	)

/datum/tgui_select_picture/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			var/datum/picture/choice = locate(params["entry"]) in choices
			if(!istype(choice))
				return
			entry = choice
			SStgui.close_uis(src)
			return TRUE
