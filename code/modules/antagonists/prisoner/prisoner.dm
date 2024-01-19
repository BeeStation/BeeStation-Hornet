/datum/antagonist/prisoner
	name = "Transferred prisoner"
	banning_key = ROLE_PRISONER
	show_in_antagpanel = FALSE
	roundend_category = "Transferred prisoners"
	antagpanel_category = "Transferred prisoner"

/datum/antagonist/prisoner/greet()
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Revenant",
		"You are a spirit that has managed to stay in the mortal realm. Take vengance on those that walk this plane without you.")

/datum/antagonist/prisoner/compromised_agent
	name = "Compromised Syndicate Agent"
	roundend_category = "Compromised Syndicate Agent"
	antagpanel_category = "Compromised Syndicate Agent"
//make a counter to count down till the next prisoner transfer
//ghosts triggered events
