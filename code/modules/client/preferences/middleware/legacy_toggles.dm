/// In the before times, toggles were all stored in one bitfield.
/// In order to preserve this existing data (and code) without massive
/// migrations, this middleware attempts to handle this in a way
/// transparent to the preferences UI itself.
/// In the future, the existing toggles data should just be migrated to
/// individual `/datum/preference/toggle`s.
/datum/preference_middleware/legacy_toggles
	// DO NOT ADD ANY NEW TOGGLES HERE!
	// Use `/datum/preference/toggle` instead.
	var/static/list/legacy_toggles = list(
		"admin_ignore_cult_ghost" = ADMIN_IGNORE_CULT_GHOST,
		"announce_login" = ANNOUNCE_LOGIN,
		"combohud_lighting" = COMBOHUD_LIGHTING,
		"deadmin_always" = DEADMIN_ALWAYS,
		"deadmin_antagonist" = DEADMIN_ANTAGONIST,
		"deadmin_position_head" = DEADMIN_POSITION_HEAD,
		"deadmin_position_security" = DEADMIN_POSITION_SECURITY,
		"deadmin_position_silicon" = DEADMIN_POSITION_SILICON,
		"member_public" = MEMBER_PUBLIC,
	)

	var/list/legacy_chat_toggles = list(
		"chat_bankcard" = CHAT_BANKCARD,
		"chat_dead" = CHAT_DEAD,
		"chat_ghostears" = CHAT_GHOSTEARS,
		"chat_ghostlaws" = CHAT_GHOSTLAWS,
		"chat_ghostpda" = CHAT_GHOSTPDA,
		"chat_ghostradio" = CHAT_GHOSTRADIO,
		"chat_ghostsight" = CHAT_GHOSTSIGHT,
		"chat_ghostwhisper" = CHAT_GHOSTWHISPER,
		"chat_login_logout" = CHAT_LOGIN_LOGOUT,
		"chat_ooc" = CHAT_OOC,
		"chat_prayer" = CHAT_PRAYER,
		"chat_pullr" = CHAT_PULLR,
	)

/datum/preference_middleware/legacy_toggles/get_character_preferences(mob/user)
	if (preferences.current_window != PREFERENCE_TAB_GAME_PREFERENCES)
		return list()

	var/static/list/admin_only_legacy_toggles = list(
		"admin_ignore_cult_ghost",
		"announce_login",
		"combohud_lighting",
		"deadmin_always",
		"deadmin_antagonist",
		"deadmin_position_head",
		"deadmin_position_security",
		"deadmin_position_silicon",
		"sound_adminhelp",
		"sound_prayers",
	)

	var/static/list/admin_only_chat_toggles = list(
		"chat_dead",
		"chat_prayer",
	)

	var/static/list/deadmin_flags = list(
		"deadmin_antagonist",
		"deadmin_position_head",
		"deadmin_position_security",
		"deadmin_position_silicon",
	)

	var/list/new_game_preferences = list()
	var/is_admin = is_admin(user.client)

	for (var/toggle_name in legacy_toggles)
		if (!is_admin && (toggle_name in admin_only_legacy_toggles))
			continue

		if (is_admin && (toggle_name in deadmin_flags) && (preferences.toggles & DEADMIN_ALWAYS))
			continue

		if (toggle_name == "member_public" && !preferences.unlock_content)
			continue

		new_game_preferences[toggle_name] = (preferences.toggles & legacy_toggles[toggle_name]) != 0

	for (var/toggle_name in legacy_chat_toggles)
		if (!is_admin && (toggle_name in admin_only_chat_toggles))
			continue

		new_game_preferences[toggle_name] = (preferences.chat_toggles & legacy_chat_toggles[toggle_name]) != 0

	return list(
		PREFERENCE_CATEGORY_GAME_PREFERENCES = new_game_preferences,
	)

/datum/preference_middleware/legacy_toggles/pre_set_preference(mob/user, preference, value)
	var/legacy_flag = legacy_toggles[preference]
	if (!isnull(legacy_flag))
		if (value)
			preferences.toggles |= legacy_flag
		else
			preferences.toggles &= ~legacy_flag
		return TRUE

	var/legacy_chat_flag = legacy_chat_toggles[preference]
	if (!isnull(legacy_chat_flag))
		if (value)
			preferences.chat_toggles |= legacy_chat_flag
		else
			preferences.chat_toggles &= ~legacy_chat_flag

		return TRUE

	return FALSE
