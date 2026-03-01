SUBSYSTEM_DEF(augury)
	name = "Augury"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/watchers = list()
	var/list/doombringers = list()

	var/list/observers_given_action = list()

/datum/controller/subsystem/augury/stat_entry(msg)
	. = ..("W:[watchers.len]|D:[doombringers.len]")

/datum/controller/subsystem/augury/proc/register_doom(atom/A, severity)
	doombringers[A] = severity

/datum/controller/subsystem/augury/proc/unregister_doom(atom/A)
	doombringers -= A

/datum/controller/subsystem/augury/fire()
	var/biggest_doom
	var/biggest_threat

	for(var/datum/d as() in doombringers)
		if(QDELETED(d))
			doombringers -= d
			continue
		var/threat = doombringers[d]
		if((biggest_threat == null) || (biggest_threat < threat))
			biggest_doom = d
			biggest_threat = threat

	if(length(doombringers))
		for(var/mob/dead/observer/observer in GLOB.player_list - observers_given_action)
			var/datum/action/augury/action = new()
			action.Grant(observer)
			observers_given_action += observer
	else
		for(var/mob/dead/observer/observer in observers_given_action)
			for(var/datum/action/augury/action in observer.actions)
				qdel(action)
			observers_given_action -= observer

	for(var/mob/dead/observer/W as() in watchers)
		if(QDELETED(W))
			watchers -= W
			continue
		if(biggest_doom && (!W.orbiting || W.orbiting.parent != biggest_doom))
			W.check_orbitable(biggest_doom)

/datum/action/augury
	name = "Auto Follow Debris"
	button_icon = 'icons/obj/meteor.dmi'
	button_icon_state = "flaming"
	background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND
	toggleable = TRUE

/datum/action/augury/Destroy()
	if(owner)
		SSaugury.watchers -= owner
	return ..()

/datum/action/augury/on_activate(at)
	SSaugury.watchers += owner
	to_chat(owner, span_notice("You are now auto-following debris."))
	update_buttons()

/datum/action/augury/on_deactivate(mob/user, atom/target)
	SSaugury.watchers -= owner
	to_chat(owner, span_notice("You are no longer auto-following debris."))
	update_buttons()

/datum/action/augury/update_button(atom/movable/screen/movable/action_button/button, status_only = FALSE, force)
	. = ..()
	if(active)
		button.icon_state = "template_active"
	else
		button.icon_state = "template"
