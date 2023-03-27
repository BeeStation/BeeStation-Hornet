/datum/config_entry/string/ooc_webhook
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/adminhelp_webhook
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/str_list/webhook_allowed_mention_types
/datum/config_entry/str_list/webhook_allowed_mention_users
/datum/config_entry/str_list/webhook_allowed_mention_roles

/proc/sendooc2ext(var/msg)
	var/ooc_webhook = CONFIG_GET(string/ooc_webhook)
	if(!length(ooc_webhook))
		return
	send_webhook(ooc_webhook, msg)

/proc/sendadminhelp2ext(var/msg)
	var/adminhelp_webhook = CONFIG_GET(string/adminhelp_webhook)
	if(!length(adminhelp_webhook))
		return
	send_webhook(adminhelp_webhook, msg)

/proc/send_webhook(var/link, var/msg)
	// It's up to the external source to escape this, Discord won't ping due to the allowed_mentions object
	msg = html_decode(msg)
	var/allowed_types = CONFIG_GET(str_list/webhook_allowed_mention_types) || list()
	var/allowed_users = CONFIG_GET(str_list/webhook_allowed_mention_users) || list()
	var/allowed_roles = CONFIG_GET(str_list/webhook_allowed_mention_roles) || list()
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, link, json_encode(list(
		"content" = msg,
		"allowed_mentions": {
			"parse": allowed_types,
			"users": allowed_users,
			"roles": allowed_roles
		}
	)), list(
		"Content-Type" = "application/json"
	))
	request.begin_async()
