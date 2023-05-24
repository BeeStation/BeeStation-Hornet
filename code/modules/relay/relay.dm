/datum/config_entry/string/ooc_webhook
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/adminhelp_webhook
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/str_list/webhook_allowed_mention_types
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/str_list/webhook_allowed_mention_users
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/str_list/webhook_allowed_mention_roles
	protection = CONFIG_ENTRY_LOCKED

/// Send OOC via webhook. allowed_x arguments are lists of strings, bypassing restrictions on mentions, joined to the values in the config.
/proc/sendooc2ext(msg, list/allowed_types = list(), list/allowed_users = list(), list/allowed_roles = list())
	var/ooc_webhook = CONFIG_GET(string/ooc_webhook)
	if(!length(ooc_webhook))
		return
	send_webhook(ooc_webhook, msg, allowed_types = allowed_types, allowed_users = allowed_users, allowed_roles = allowed_roles)

/// Send adminhelp via webhook. allowed_x arguments are lists of strings, bypassing restrictions on mentions, joined to the values in the config.
/proc/sendadminhelp2ext(msg, list/allowed_types = list(), list/allowed_users = list(), list/allowed_roles = list())
	var/adminhelp_webhook = CONFIG_GET(string/adminhelp_webhook)
	if(!length(adminhelp_webhook))
		return
	send_webhook(adminhelp_webhook, msg, allowed_types = allowed_types, allowed_users = allowed_users, allowed_roles = allowed_roles)

/// Send text via webhook, asynchronously. allowed_x arguments are lists of strings, bypassing restrictions on mentions, joined to the values in the config.
/// sent as JSON via POST {"content": "[msg]", "allowed_mentions": {"parse": [...]}}
/proc/send_webhook(link, msg, list/allowed_types = list(), list/allowed_users = list(), list/allowed_roles = list())
	if(IsAdminAdvancedProcCall())
		log_admin_private("send_webhook: Admin proc call blocked from [key_name(usr)]")
		message_admins("send_webhook: Admin proc call blocked from [key_name(usr)]")
		return
	// It's up to the external source to escape this, Discord won't ping due to the allowed_mentions object
	msg = html_decode(msg)
	var/allowed_types_full = allowed_types | CONFIG_GET(str_list/webhook_allowed_mention_types)
	var/allowed_users_full = allowed_users | CONFIG_GET(str_list/webhook_allowed_mention_users)
	var/allowed_roles_full = allowed_roles | CONFIG_GET(str_list/webhook_allowed_mention_roles)
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, link, json_encode(list(
		"content" = msg,
		"allowed_mentions" = list(
			"parse" = allowed_types_full,
			"users" = allowed_users_full,
			"roles" = allowed_roles_full
		)
	)), list(
		"Content-Type" = "application/json"
	))
	request.begin_async()
