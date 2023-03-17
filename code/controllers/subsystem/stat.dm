#define FLAT_ICON_CACHE_MAX_SIZE 250

SUBSYSTEM_DEF(stat)
	name = "Stat"
	wait = 1 SECONDS
	priority = FIRE_PRIORITY_STAT
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME	//RUNLEVEL_INIT doesn't work, so the stat panel will not auto update during this time (But that is good since we don't want to waste processing time during that phase).
	init_order = INIT_ORDER_STAT
	flags = SS_NO_INIT | SS_BACKGROUND

	var/list/flat_icon_cache = list()	//Assoc list, datum = flat icon

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
	var/list/icon_requests = src.icon_requests
	var/list/currentrun_aftericon = src.currentrun_aftericon

	while(currentrun.len)
		var/client/C = currentrun[currentrun.len]
		currentrun.len--

		if (C)
			var/mob/M = C.mob
			if(M)
				//Handle listed turfs separately
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

	//Process icon requests
	while(icon_requests.len)
		var/A_name = icon_requests[icon_requests.len]
		var/datum/weakref/A_ref = icon_requests[A_name]
		var/atom/A = A_ref.resolve()
		var/directionless = TRUE
		if(ispipewire(A))
			directionless = FALSE
		icon_requests.len--

		//Adding a new icon
		//If the list gets too big just remove the first thing
		if(flat_icon_cache.len > FLAT_ICON_CACHE_MAX_SIZE)
			flat_icon_cache.Cut(1, 2)
		//We are only going to apply overlays to mobs.
		//Massively faster, getFlatIcon is a bit of a sucky proc.
		flat_icon_cache[A_name] = icon2base64(getStillIcon(A, directionless))

		if (MC_TICK_CHECK)
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

//Note: Doesn't account for decals on items.
//Whoever examins an item with a decal first, everyone else will see that items decals.
//Significantly reduces server lag though, like MASSIVELY!
/datum/controller/subsystem/stat/proc/get_flat_icon(client/requester, atom/A)
	var/directionless = TRUE
	if(ispipewire(A))
		directionless = FALSE
	var/what_to_search = "[A.type][directionless ? 0 : A.dir][(istext(A.icon_state) && length(A.icon_state)) ? A.icon_state[1] : "*"]"
	//Mobs are more important than items.
	//Mob icons will change if their name changes, their type changes or their overlays change.
	if(istype(A, /mob))
		var/mob/M = A
		var/overlay_hash = ""
		for(var/image/I as() in M.overlays)
			if(istext(I.icon_state) && length(I.icon_state) >= 1)
				overlay_hash = "[overlay_hash][I.icon_state[1]]"
			else
				overlay_hash = "[overlay_hash]*"	//Just to make changes known when lengths change. Doesn't have to be accurate per-say.
		what_to_search = "[M.type][M.name][overlay_hash]"
	//Makes it shorter
	var/thing = flat_icon_cache[what_to_search]
	if(thing)
		return thing
	//Start queuing with the subsystem.
	icon_requests["[what_to_search]"] = WEAKREF(A)
	src.currentrun_aftericon |= requester
	return null

/datum/controller/subsystem/stat/proc/send_global_alert(title, message)
	for(var/client/C in GLOB.clients)
		if(C?.tgui_panel)
			C.tgui_panel.give_alert_popup(title, message)

/datum/controller/subsystem/stat/proc/clear_global_alert()
	for(var/client/C in GLOB.clients)
		if(C?.tgui_panel)
			C.tgui_panel.clear_alert_popup()

#undef FLAT_ICON_CACHE_MAX_SIZE
