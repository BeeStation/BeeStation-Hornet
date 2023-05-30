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

/datum/language_menu/ui_data(mob/user)
	var/list/data = list()

	var/is_admin = check_rights_for(user.client, R_ADMIN) || check_rights_for(user.client, R_DEBUG)
	var/atom/movable/AM = language_holder.get_atom()
	if(isliving(AM))
		data["is_living"] = TRUE
	else
		data["is_living"] = FALSE

	data["languages"] = list()
	for(var/lang in GLOB.all_languages)
		var/result = language_holder.has_language(lang) || language_holder.has_language(lang, TRUE)
		if(!result)
			continue
		var/datum/language/language = lang
		var/list/L = list()

		L["name"] = initial(language.name)
		L["desc"] = initial(language.desc)
		L["key"] = initial(language.key)
		L["is_default"] = (language == language_holder.selected_language)
		if(AM)
			L["can_speak"] = AM.can_speak_language(language)
			L["can_understand"] = AM.has_language(language)

		if(lang == /datum/language/metalanguage) // metalanguage is only visible to admins
			if(!(is_admin || HAS_TRAIT(user, TRAIT_METALANGUAGE_KEY_ALLOWED)))
				continue

		data["languages"] += list(L)

	if(is_admin || isobserver(AM))
		data["admin_mode"] = TRUE
		data["omnitongue"] = language_holder.omnitongue

		data["unknown_languages"] = list()
		for(var/lang in GLOB.all_languages)
			if(language_holder.has_language(lang) || language_holder.has_language(lang, TRUE))
				continue
			var/datum/language/language = lang
			var/list/L = list()

			L["name"] = initial(language.name)
			L["desc"] = initial(language.desc)
			L["key"] = initial(language.key)

			data["unknown_languages"] += list(L)
	else
		data["admin_mode"] = null
		data["omnitongue"] = null
		data["unknown_languages"] = null
	return data

/datum/language_menu/ui_act(action, params)
	if(..())
		return
	var/mob/user = usr
	var/atom/movable/AM = language_holder.get_atom()

	var/language_name = params["language_name"]
	var/datum/language/language_datum
	for(var/lang in GLOB.all_languages)
		var/datum/language/language = lang
		if(language_name == initial(language.name))
			language_datum = language
	var/is_admin = check_rights_for(user.client, R_ADMIN) || check_rights_for(user.client, R_DEBUG)

	switch(action)
		if("select_default")
			if(language_datum)
				// they're changing their language to something else from metalanguage. It must be mistake.
				if(language_holder.selected_language == /datum/language/metalanguage && \
						language_datum != /datum/language/metalanguage && \
						!HAS_TRAIT(user, TRAIT_METALANGUAGE_KEY_ALLOWED) && \
						!is_admin)
					var/no = alert(user, "You're giving up your power to speak in a powerful language that everyone understands. Do you really wish to do that?", "WARNING!", "Yes", "No")
					if(no != "Yes")
						return

				if(AM.can_speak_language(language_datum))
					language_holder.selected_language = language_datum
					. = TRUE
		if("grant_language")
			if((is_admin || isobserver(AM)) && language_datum)
				var/list/choices = list("Only Spoken", "Only Understood", "Both")
				var/choice = input(user,"How do you want to add this language?","[language_datum]",null) as null|anything in choices
				var/spoken = FALSE
				var/understood = FALSE
				switch(choice)
					if("Only Spoken")
						spoken = TRUE
					if("Only Understood")
						understood = TRUE
					if("Both")
						spoken = TRUE
						understood = TRUE
				language_holder.grant_language(language_datum, understood, spoken)
				if(spoken && language_datum == /datum/language/metalanguage)
					var/yes = alert(user, "You have added speakable Metalanguage. Do you wish to give them a trait that they can use language key(,`) to say that? Otherwise, they'll have no way to say that, or, instead, you should set their default language to metalanguage.", "Give Metalangauge trait?", "Yes", "No")
					if(yes == "Yes")
						ADD_TRAIT(user, TRAIT_METALANGUAGE_KEY_ALLOWED, "lang_added_by_admin")
				if(is_admin)
					message_admins("[key_name_admin(user)] granted the [language_name] language to [key_name_admin(AM)].")
					log_admin("[key_name(user)] granted the language [language_name] to [key_name(AM)].")
				. = TRUE
		if("remove_language")
			if((is_admin || isobserver(AM)) && language_datum)
				var/list/choices = list("Only Spoken", "Only Understood", "Both")
				var/choice = input(user,"Which part do you wish to remove?","[language_datum]",null) as null|anything in choices
				var/spoken = FALSE
				var/understood = FALSE
				switch(choice)
					if("Only Spoken")
						spoken = TRUE
					if("Only Understood")
						understood = TRUE
					if("Both")
						spoken = TRUE
						understood = TRUE
				language_holder.remove_language(language_datum, understood, spoken)
				if(spoken && language_datum == /datum/language/metalanguage)
					REMOVE_TRAIT(user, TRAIT_METALANGUAGE_KEY_ALLOWED, "lang_added_by_admin")
				if(is_admin)
					message_admins("[key_name_admin(user)] removed the [language_name] language to [key_name_admin(AM)].")
					log_admin("[key_name(user)] removed the language [language_name] to [key_name(AM)].")
				. = TRUE
		if("toggle_omnitongue")
			if(is_admin || isobserver(AM))
				language_holder.omnitongue = !language_holder.omnitongue
				if(is_admin)
					message_admins("[key_name_admin(user)] [language_holder.omnitongue ? "enabled" : "disabled"] the ability to speak all languages (that they know) of [key_name_admin(AM)].")
					log_admin("[key_name(user)] [language_holder.omnitongue ? "enabled" : "disabled"] the ability to speak all languages (that_they know) of [key_name(AM)].")
				. = TRUE
