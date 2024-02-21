//Hivemind monitoring and powers shop

/datum/gang_tracker
	var/name = "gang tracker"

/datum/gang_tracker/ui_state(mob/user)
	return GLOB.always_state

/datum/gang_tracker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GangTracker", "Gang Tracker")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/gang_tracker/ui_data(mob/user)
	var/list/data = list()

	data["gangs"] = list()
	for(var/datum/team/gang/gangs in GLOB.gangs)
		var/list/gang_data = list(
			name = gangs.name,
			size = gangs.members.len,
			territories = LAZYLEN(gang.territories),
			influence = gangs.influence,
			reputation = gangs.reputation,
			credits = gangs.credits,
		)
		data["gangs"] += list(gang_data)



	return data

/datum/action/innate/gang_tracker
	name = "Gang Tracker"
	icon_icon = 'icons/mob/actions/actions_hive.dmi'
	button_icon_state = "scan"
	background_icon_state = "bg_gang"
	var/datum/gang_tracker/gang_tracker

/datum/action/innate/gang_tracker/New(our_target)
	. = ..()
	button.name = name
	if(istype(our_target, /datum/gang_tracker))
		gang_tracker = our_target
	else
		CRASH("gang_tracker action created with non tracker")

/datum/action/innate/gang_tracker/Activate()
	gang_tracker.ui_interact(owner)
