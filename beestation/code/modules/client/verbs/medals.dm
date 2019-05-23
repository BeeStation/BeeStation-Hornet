
/client/verb/medals()
	set name = "Medals"
	set desc = "View all the medals you have earned!"
	set category = "OOC"

	if (!CONFIG_GET(string/medal_hub_address) ||  !CONFIG_GET(string/medal_hub_password))
		to_chat(src, "<span class='danger'>Sorry, this server does not have medals enabled.</span>")
		return

	spawn(1)
		var/medals = world.GetMedal("", src.key, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))

		if (isnull(medals))
			to_chat(src, "<span class='danger'>Sorry, could not contact the BYOND hub for your medal information.</span>")
			return

		if (!medals)
			to_chat(src, "<b>You don't have any medals.</b>")
			return

		medals = params2list(medals)
		medals = sortList(medals)


		var/msg = "<b>Medals:</b>\n"
		for (var/medal in medals)
			msg+= "&emsp;[medal]\n"
		msg += "<b>You have [length(medals)] medal\s.</b>"
		to_chat(src, msg)
