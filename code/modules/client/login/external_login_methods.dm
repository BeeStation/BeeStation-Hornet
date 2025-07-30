/datum/external_login_method
	/// Unique identifier for this login method
	VAR_PROTECTED/id
	/// Column name in SS13_player
	VAR_PROTECTED/db_id_column_name
	/// Display name for this login method
	VAR_PROTECTED/name

/datum/external_login_method/vv_edit_var(var_name, var_value)
	return FALSE

/datum/external_login_method/proc/get_url(ip, seeker_port, session_creation_nonce)
	var/list/methods = CONFIG_GET(keyed_list/external_auth_method)
	var/link = methods[src::id]
	if(!istext(link))
		return null
	var/port_data = ""
	if(isnum_safe(seeker_port))
		port_data = "&seeker_port=[seeker_port]"
	return "[link]?ip=[url_encode(ip)]&nonce=[session_creation_nonce][port_data]"

/// use client.key_is_external where possible
/datum/external_login_method/proc/is_fake_key(key)
	CRASH("Unimplemented!")


/proc/is_external_auth_key(key)
	for(var/method_id in GLOB.login_methods)
		var/datum/external_login_method/method = GLOB.login_methods[method_id]
		if(istype(method) && method.is_fake_key(key))
			return TRUE
	return FALSE

/datum/external_login_method/proc/to_fake_key(external_uid)
	CRASH("Unimplemented!")

/datum/external_login_method/proc/to_fake_ckey(external_uid)
	return ckey(to_fake_key(external_uid))

/datum/external_login_method/proc/get_badge_id()
	CRASH("Unimplemented!")

/datum/external_login_method/proc/format_display_name(external_display_name)
	CRASH("Unimplemented!")

/datum/external_login_method/discord
	id = "discord"
	db_id_column_name = "discord_uid"
	name = "Discord"

GLOBAL_DATUM_INIT(discord_ckey_regex, /regex, regex(@"^[dD]\d{10}\d+$"))

/// use client.key_is_external where possible
/datum/external_login_method/discord/is_fake_key(key)
	return istext(key) && GLOB.discord_ckey_regex.Find(ckey(key))

/datum/external_login_method/discord/to_fake_key(external_uid)
	return "D[external_uid]"

/datum/external_login_method/discord/get_badge_id()
	return src::id

/datum/external_login_method/discord/format_display_name(external_display_name)
	return "@[external_display_name]"
