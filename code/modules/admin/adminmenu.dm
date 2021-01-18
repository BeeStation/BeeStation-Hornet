/client/proc/playerpanel()
	set name = "Player Panel"
	set desc = "Player Panel"
	set category = "Admin"
	if(holder)
		holder.player_panel_new()
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Player Panel New") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
