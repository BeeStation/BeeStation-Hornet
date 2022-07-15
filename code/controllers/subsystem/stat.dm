SUBSYSTEM_DEF(stat)
	name = "Stat"
	wait = 1 SECONDS
	priority = FIRE_PRIORITY_STAT
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME	//RUNLEVEL_INIT doesn't work, so the stat panel will not auto update during this time (But that is good since we don't want to waste processing time during that phase).
	init_order = INIT_ORDER_STAT
	flags = SS_NO_INIT | SS_BACKGROUND

	//The run of clients updating normally
	var/list/currentrun = list()
	//The run of clients updating alt clicked turfs
	var/list/currentrun_listed = list()
	//List of icon requests
	var/list/icon_requests = list()
	//List of people who need re-updating after icon requests are processed
	var/list/currentrun_aftericon = list()

/datum/controller/subsystem/stat/fire(resumed = 0)
	if (!resumed)
		src.currentrun = GLOB.clients.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	var/list/currentrun_listed = src.currentrun_listed
	var/list/currentrun_aftericon = src.currentrun_aftericon

	while(currentrun.len)
		var/client/C = currentrun[currentrun.len]
		currentrun.len--

		if (C)
			var/mob/M = C.mob
			if(M)
				//Handle listed turfs seperately
				if(sanitize(M.listed_turf?.name) == C.selected_stat_tab)
					currentrun_listed += C
				else
					//Auto-update, not forced
					M.UpdateMobStat(FALSE)

		if (MC_TICK_CHECK)
			src.currentrun_listed = currentrun_listed
			return

	if(MC_TICK_CHECK)
		src.currentrun_listed = currentrun_listed
		return

	//Handle clients on listed turfs as low priority, if they run over then we will give our processing time
	//back to the people not on listed turfs (listed turfs is slightly more laggy)
	while(currentrun_listed.len)
		var/client/C = currentrun_listed[currentrun_listed.len]
		currentrun_listed.len--

		if (C)
			var/mob/M = C.mob
			if(M)
				//Auto-update, not forced
				M.UpdateMobStat(FALSE)

		if (MC_TICK_CHECK)
			return

	if(MC_TICK_CHECK)
		return

	//Process clients that just got an item and need to update now.
	//Client list will empty if the system overruns, since they will get updated anyway.
	if(MC_TICK_CHECK)
		src.currentrun_aftericon = list()
		return

	while(currentrun_aftericon.len)
		var/client/C = currentrun_aftericon[currentrun_aftericon.len]
		currentrun_aftericon.len--

		if (C)
			var/mob/M = C.mob
			if(M)
				//Auto-update, not forced
				M.UpdateMobStat(FALSE)

		if (MC_TICK_CHECK)
			src.currentrun_aftericon = list()
			return

	if(MC_TICK_CHECK)
		src.currentrun_aftericon = list()
		return

/datum/controller/subsystem/stat/proc/send_global_alert(title, message)
	for(var/client/C in GLOB.clients)
		if(C?.tgui_panel)
			C.tgui_panel.give_alert_popup(title, message)

/datum/controller/subsystem/stat/proc/clear_global_alert()
	for(var/client/C in GLOB.clients)
		if(C?.tgui_panel)
			C.tgui_panel.clear_alert_popup()
