/client/proc/fax_manager()
	set name = "Fax Manager"
	set desc = "Open the manager panel to view all requests during the round in progress."
	set category = "Admin"
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Fax Manager")
	GLOB.fax_manager.ui_interact(usr)
