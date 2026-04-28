/**
 * Records subtype for the shared functionality between medical/security/warrant consoles.
 */
/obj/machinery/computer/records
	/// The character preview view for the UI.
	var/atom/movable/screen/map_view/character_preview_view/character_preview_view

/obj/machinery/computer/records/Initialize(mapload)
	. = ..()
	character_preview_view = new(null, src)

/obj/machinery/computer/records/ui_data(mob/user)
	var/list/data = list()

	data["authenticated"] = authenticated && (isliving(user) || IsAdminGhost(user))
	data["is_silicon"] = issilicon(user)

	return data

/obj/machinery/computer/records/ui_close(mob/user)
	. = ..()
	character_preview_view.unregister_from_client(user.client)

/obj/machinery/computer/records/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	// If you leave and come back, re-register the character preview. This also runs the first time it's opened
	if (!isnull(character_preview_view) && istype(user.client) && !(character_preview_view in user.client.screen))
		character_preview_view.register_to_client(user.client)

/obj/machinery/computer/records/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user

	if (issilicon(user)) // Silicons are forbidden from editing records.
		return FALSE

	var/datum/record/crew/target_record
	if(params["record_ref"])
		target_record = locate(params["record_ref"]) in GLOB.manifest.general

	switch(action)
		if("edit_field")
			if (!target_record)
				return FALSE
			if (!authenticated)
				return FALSE
			var/field = params["field"]
			if(!field || !can_edit_field(field))
				return FALSE
			var/text = "[params["value"]]" //Converts the value to a string, due to fuckery in TGUI.
			var/value = sanitize_ic(trim(text, MAX_BROADCAST_LEN))
			target_record.vars[field] = value || null
			update_all_security_huds()
			return TRUE

		if("anonymize_record")
			if(!target_record)
				return FALSE
			if (!authenticated)
				return FALSE

			target_record.anonymize_record_info()
			balloon_alert(user, "record anonymized")
			playsound(src, 'sound/machines/terminal_eject.ogg', 70, TRUE)

			return TRUE

		if("login")
			authenticated = secure_login(user)
			return TRUE

		if("logout")
			balloon_alert(user, "logged out")
			playsound(src, 'sound/machines/terminal_off.ogg', 70, TRUE)
			authenticated = FALSE

			return TRUE

		if("purge_records")
			if (!authenticated)
				return FALSE
			ui.close()
			balloon_alert(user, "purging records")
			playsound(src, 'sound/machines/terminal_alert.ogg', 70, TRUE)

			if(do_after(user, 5 SECONDS))
				for(var/datum/record/crew/entry in GLOB.manifest.general)
					entry.delete_security_record()

				update_all_security_huds()
				balloon_alert(user, "records purged")
				playsound(src, 'sound/machines/terminal_off.ogg', 70, TRUE)

			return TRUE

		if("view_record")
			if(!target_record)
				return FALSE
			if (!authenticated)
				return FALSE

			playsound(src, "sound/machines/terminal_button0[rand(1, 8)].ogg", 50, TRUE)
			update_preview(user, sanitize(params["character_preview_view"]), target_record)
			return TRUE

	return FALSE

/obj/machinery/computer/records/proc/can_edit_field(field)
	return FALSE

/// Creates a character preview view for the UI.
/obj/machinery/computer/records/proc/create_character_preview_view(mob/user)
	if(istype(character_preview_view))
		return
	character_preview_view = new()
	if(user.client)
		character_preview_view.register_to_client(user.client)
	if(isnull(character_preview_view.body)) //only want to run this once
		if (isnull(character_preview_view.body))
			character_preview_view.create_body()
		else
			character_preview_view.body.wipe_state()
	// Force map view to update as well
	character_preview_view.name = character_preview_view.name == "character_preview" ? "character_preview_1" : "character_preview"
	return character_preview_view

/// Takes a record and updates the character preview view to match it.
/obj/machinery/computer/records/proc/update_preview(mob/user, character_preview_view, datum/record/crew/target)
	var/mutable_appearance/preview = new(target.character_appearance)
	preview.underlays += mutable_appearance('icons/effects/effects.dmi', "static_base", alpha = 20)
	preview.add_overlay(mutable_appearance(generate_icon_alpha_mask('icons/effects/effects.dmi', "scanline"), alpha = 20))

	var/atom/movable/screen/map_view/character_preview_view/old_view = user.client?.screen_maps[character_preview_view]?[1]
	if(!old_view)
		return

	old_view.appearance = preview.appearance

/// Detects whether a user can use buttons on the machine
/obj/machinery/computer/records/proc/has_auth(mob/user)
	if(IsAdminGhost(user)) // Admins don't need to authenticate
		return TRUE

	if(!isliving(user))
		return FALSE
	var/mob/living/player = user

	var/obj/item/card/auth = player.get_idcard(TRUE)
	if(!auth)
		return FALSE
	var/list/access = auth.GetAccess()
	if(!check_access_list(access))
		return FALSE

	return TRUE

/// Inserts a new record into GLOB.manifest.general. Requires a photo to be taken.
/obj/machinery/computer/records/proc/insert_new_record(mob/user, obj/item/photo/mugshot)
	if(!mugshot || !is_operational || !user.canUseTopic(src))
		return FALSE

	if(!authenticated && !has_auth(user))
		balloon_alert(user, "access denied")
		playsound(src, 'sound/machines/terminal_error.ogg', 70, TRUE)
		return FALSE

	if(mugshot.picture.psize_x > world.icon_size || mugshot.picture.psize_y > world.icon_size)
		balloon_alert(user, "photo too large!")
		playsound(src, 'sound/machines/terminal_error.ogg', 70, TRUE)
		return FALSE

	var/trimmed = copytext(mugshot.name, 9, MAX_NAME_LEN) // Remove "photo - "
	var/name = tgui_input_text(user, "Enter the name of the new record.", "New Record", trimmed, MAX_NAME_LEN)
	if(!name || !is_operational || !user.canUseTopic(src) || !mugshot || QDELETED(mugshot) || QDELETED(src))
		return FALSE

	new /datum/record/crew(name = name, character_appearance = mugshot.picture.picture_image)

	balloon_alert(user, "record created")
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 70, TRUE)

	qdel(mugshot)

	return TRUE

/// Secure login
/obj/machinery/computer/records/proc/secure_login(mob/user)
	if(!user.canUseTopic(src) || !is_operational)
		return FALSE

	if(!has_auth(user))
		balloon_alert(user, "access denied")
		playsound(src, 'sound/machines/terminal_error.ogg', 70, TRUE)
		return FALSE

	balloon_alert(user, "logged in")
	playsound(src, 'sound/machines/terminal_on.ogg', 70, TRUE)

	return TRUE
