/datum/config_entry/string/ooc_tgs_channel_tag
/datum/config_entry/string/adminhelp_tgs_channel_tag

/datum/config_entry/string/ooc_webhook
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/adminhelp_webhook
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/proc/sendooc2tgs(var/msg)
	var/ooc_channel = CONFIG_GET(string/ooc_tgs_channel_tag)
	if(!length(ooc_channel))
		sendooc2tgs_webhook(msg)
		return
	send2chat(msg, ooc_channel)

/proc/sendooc2tgs_webhook(var/msg)
	var/ooc_webhook = CONFIG_GET(string/ooc_webhook)
	if(!length(ooc_webhook))
		return
	send_webhook(ooc_webhook, msg)

/proc/sendadminhelp2tgs(var/msg)
	var/adminhelp_channel = CONFIG_GET(string/adminhelp_tgs_channel_tag)
	if(!length(adminhelp_channel))
		sendadminhelp2tgs_webhook(msg)
		return
	send2chat(msg, adminhelp_channel)

/proc/sendadminhelp2tgs_webhook(var/msg)
	var/adminhelp_webhook = CONFIG_GET(string/adminhelp_webhook)
	if(!length(adminhelp_webhook))
		return
	send_webhook(adminhelp_webhook, msg)

/proc/send_webhook(var/link, var/msg)
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, link, json_encode(list(
		"content" = msg
	)), list(
		"Content-Type" = "application/json"
	))
	request.begin_async()
