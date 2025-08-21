/datum/language_menu
	var/datum/language_holder/language_holder

/datum/language_menu/New(_language_holder)
	language_holder = _language_holder

/datum/language_menu/Destroy()
	language_holder = null
	. = ..()

/datum/language_menu/ui_state(mob/user)
	return GLOB.language_menu_state

/datum/language_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LanguageMenu")
		ui.open()

/datum/language_menu/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/chat)
	)

/datum/language_menu/ui_static_data(mob/user)
	var/list/data = list()

	data["language_static_data"] = list()
	for(var/lang in GLOB.all_languages)
		var/datum/language/language = lang
		var/list/L = list()

		L["name"] = initial(language.name)
		L["desc"] = initial(language.desc)
		L["key"] = initial(language.key)
		L["icon_state"] = initial(language.icon_state)

		data["language_static_data"][initial(language.name)] = L
	return data

/datum/language_menu/ui_data(mob/user)
	var/list/data = list()

	var/is_admin = check_rights_for(user.client, R_ADMIN) || check_rights_for(user.client, R_DEBUG)
	var/atom/movable/speaker = language_holder.owner
	data["is_living"] = isliving(speaker)

	data["known_languages"] = list()
	for(var/datum/language/language as anything in GLOB.all_languages)
		var/result = language_holder.has_language(language) || language_holder.has_language(language, SPOKEN_LANGUAGE)
		if(!result)
			continue
		var/list/lang_data = list()

		lang_data["name"] = initial(language.name)
		lang_data["is_default"] = (language == language_holder.selected_language)
		if(speaker)
			lang_data["can_speak"] = speaker.can_speak_language(language)
			lang_data["can_understand"] = speaker.has_language(language)

		if(language == /datum/language/metalanguage) // metalanguage is only visible to admins
			if(!(is_admin || HAS_TRAIT(user, TRAIT_METALANGUAGE_KEY_ALLOWED)))
				continue

		UNTYPED_LIST_ADD(data["known_languages"], lang_data)

	if(is_admin || isobserver(speaker))
		data["admin_mode"] = TRUE
		data["omnitongue"] = language_holder.omnitongue
		data["unknown_languages"] = list()
		for(var/datum/language/language as anything in GLOB.all_languages)
			if(language_holder.has_language(language) || language_holder.has_language(language, TRUE))
				continue
			var/list/lang_data = list()

			lang_data["name"] = initial(language.name)

			UNTYPED_LIST_ADD(data["unknown_languages"], lang_data)
	else
		data["admin_mode"] = null
		data["omnitongue"] = null
		data["unknown_languages"] = null
	return data

/datum/language_menu/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	var/atom/movable/speaker = language_holder.owner
	var/is_admin = check_rights_for(user.client, R_ADMIN) || check_rights_for(user.client, R_DEBUG)
	var/language_name = params["language_name"]
	var/datum/language/language_datum
	for(var/datum/language/language as anything in GLOB.all_languages)
		if(language_name == initial(language.name))
			language_datum = language

	switch(action)
		if("select_default")
			if(language_datum)
				// they're changing their language to something else from metalanguage. It must be mistake.
				if(language_holder.selected_language == /datum/language/metalanguage && \
						language_datum != /datum/language/metalanguage && \
						!HAS_TRAIT(user, TRAIT_METALANGUAGE_KEY_ALLOWED) && \
						!is_admin)
					var/metachoice = tgui_alert(user, "You're giving up your power to speak in a powerful language that everyone understands. Do you really wish to do that?", "WARNING!", list("Yes", "No"))
					if(metachoice != "Yes")
						return

				if(speaker.can_speak_language(language_datum))
					language_holder.selected_language = language_datum
					. = TRUE
		if("grant_language")
			if((is_admin || isobserver(speaker)) && language_datum)
				var/list/choices = list("Only Spoken", "Only Understood", "Both")
				var/choice = tgui_input_list(user, "How do you want to add this language?", "[language_datum]", choices)
				if(isnull(choice))
					return
				var/adding_flags = NONE
				switch(choice)
					if("Only Spoken")
						adding_flags |= SPOKEN_LANGUAGE
					if("Only Understood")
						adding_flags |= UNDERSTOOD_LANGUAGE
					if("Both")
						adding_flags |= ALL
				if(LAZYACCESS(language_holder.blocked_languages, language_datum))
					choice = tgui_alert(user, "Do you want to lift the blockage that's also preventing the language to be spoken or understood?", "[language_datum]", list("Yes", "No"))
					if(choice == "Yes")
						language_holder.remove_blocked_language(language_datum, LANGUAGE_ALL)
						message_admins("[key_name_admin(user)] removed the [language_name] language from [key_name_admin(speaker)]'s blocked languages list.")
						log_admin("[key_name(user)] removed the language [language_name] from [key_name(speaker)]'s blocked languages list.")
				language_holder.grant_language(language_datum, adding_flags)
				if((adding_flags & SPOKEN_LANGUAGE) && (language_datum == /datum/language/metalanguage))
					var/yes = tgui_alert(user, "You have added speakable Metalanguage. Do you wish to give them a trait that they can use language key(,`) to say that? Otherwise, they'll have no way to say that, or, instead, you should set their default language to metalanguage.", "Give Metalangauge trait?", list("Yes", "No"))
					if(yes == "Yes")
						ADD_TRAIT(user, TRAIT_METALANGUAGE_KEY_ALLOWED, "lang_added_by_admin")
				if(is_admin)
					message_admins("[key_name_admin(user)] granted the [language_name] language to [key_name_admin(speaker)].")
					log_admin("[key_name(user)] granted the language [language_name] to [key_name(speaker)].")
				. = TRUE
		if("remove_language")
			if((is_admin || isobserver(speaker)) && language_datum)
				var/list/choices = list("Only Spoken", "Only Understood", "Both")
				var/choice = tgui_input_list(user, "Which part do you wish to remove?", "[language_datum]", choices)
				if(isnull(choice))
					return
				var/removing_flags = NONE
				switch(choice)
					if("Only Spoken")
						removing_flags |= SPOKEN_LANGUAGE
					if("Only Understood")
						removing_flags |= UNDERSTOOD_LANGUAGE
					if("Both")
						removing_flags |= ALL

				language_holder.remove_language(language_datum, removing_flags)
				if((removing_flags & SPOKEN_LANGUAGE) && (language_datum == /datum/language/metalanguage))
					REMOVE_TRAIT(user, TRAIT_METALANGUAGE_KEY_ALLOWED, "lang_added_by_admin")
				if(is_admin)
					message_admins("[key_name_admin(user)] removed the [language_name] language to [key_name_admin(speaker)].")
					log_admin("[key_name(user)] removed the language [language_name] to [key_name(speaker)].")
				. = TRUE
		if("toggle_omnitongue")
			if(is_admin || isobserver(speaker))
				language_holder.omnitongue = !language_holder.omnitongue
				if(is_admin)
					message_admins("[key_name_admin(user)] [language_holder.omnitongue ? "enabled" : "disabled"] the ability to speak all languages (that they know) of [key_name_admin(speaker)].")
					log_admin("[key_name(user)] [language_holder.omnitongue ? "enabled" : "disabled"] the ability to speak all languages (that_they know) of [key_name(speaker)].")
				. = TRUE
