/datum/config_entry/string/ooc_tgs_channel_tag
/datum/config_entry/string/adminhelp_tgs_channel_tag

/proc/sendooc2tgs(var/msg)
	var/ooc_channel = CONFIG_GET(string/ooc_tgs_channel_tag)
	if(!length(ooc_channel))
		return
	send2chat(msg, ooc_channel)

/proc/sendadminhelp2tgs(var/msg)
	var/adminhelp_channel = CONFIG_GET(string/adminhelp_tgs_channel_tag)
	if(!length(adminhelp_channel))
		return
	send2chat(msg, adminhelp_channel)
