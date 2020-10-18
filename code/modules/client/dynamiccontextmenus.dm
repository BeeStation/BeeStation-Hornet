/client/show_popup_menus = 0

/client/verb/use_right_click()
	set name = "Use Right Click"
	set category = "IC"
	if(show_popup_menus)
		to_chat(src, "You already have popup menus enabled.")
		return
	to_chat(src, "Popup menus enabled for 30 seconds.")
	show_popup_menus = TRUE
	addtimer(CALLBACK(src, /client/proc/disable_right_click), 300)

/client/proc/disable_right_click()
	to_chat(src, "Popup menus disabled.")
	show_popup_menus = FALSE