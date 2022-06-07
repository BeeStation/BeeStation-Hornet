SUBSYSTEM_DEF(parallax)
	name = "Parallax"
	wait = 2
	flags = SS_POST_FIRE_TIMING | SS_BACKGROUND
	priority = FIRE_PRIORITY_PARALLAX
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	var/current_run_pointer = 1
	var/list/currentrun
	var/list/queued = list()
	var/planet_x_offset = 128
	var/planet_y_offset = 128
	var/random_layer
	var/random_parallax_color

//These are cached per client so needs to be done asap so people joining at roundstart do not miss these.
/datum/controller/subsystem/parallax/PreInit()
	. = ..()
	if(prob(70))	//70% chance to pick a special extra layer
		random_layer = pick(/atom/movable/screen/parallax_layer/random/space_gas, /atom/movable/screen/parallax_layer/random/asteroids)
		random_parallax_color = pick(COLOR_TEAL, COLOR_GREEN, COLOR_SILVER, COLOR_YELLOW, COLOR_CYAN, COLOR_ORANGE, COLOR_PURPLE)//Special color for random_layer1. Has to be done here so everyone sees the same color.
	planet_y_offset = rand(100, 160)
	planet_x_offset = rand(100, 160)

/datum/controller/subsystem/parallax/Initialize(start_timeofday)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, .proc/on_mob_login)

/datum/controller/subsystem/parallax/fire(resumed = 0)
	//Swap the 2 lists
	if(!length(currentrun))
		//Nothing to process here
		if(!length(queued))
			return
		var/temp = currentrun
		currentrun = queued
		queued = temp
		current_run_pointer = 1
	//Begin processing the processing queue
	while(current_run_pointer <= length(currentrun))
		//Use a pointer, less wasted processing than removing from the list
		var/client/C = currentrun[current_run_pointer]
		//Increment the current list pointer, so we process the next element
		current_run_pointer ++
		//No client (Disconnected)
		if(!C)
			continue
		//Do the parallax update (Move it to the correct location)
		C?.mob?.hud_used?.update_parallax()
	//Processing is completed, clear the list
	currentrun.Cut()

/datum/controller/subsystem/parallax/proc/on_mob_login(datum/source, mob/new_login)
	//Register the required signals
	RegisterSignal(new_login, COMSIG_PARENT_MOVED_RELAY, .proc/on_mob_moved)
	RegisterSignal(new_login, COMSIG_MOB_LOGOUT, .proc/on_mob_logout)

/datum/controller/subsystem/parallax/proc/on_mob_logout(mob/source)
	UnregisterSignal(source, COMSIG_PARENT_MOVED_RELAY)
	UnregisterSignal(source, COMSIG_MOB_LOGOUT)

/datum/controller/subsystem/parallax/proc/on_mob_moved(mob/moving_mob, atom/parent, force)

//We need a client var for optimisation purposes
/client
	var/parallax_update_queued = FALSE

/datum/controller/subsystem/parallax/proc/update_client_parallax(client/updater)
	//Already queued for update
	if(!updater || updater?.parallax_update_queued)
		return
	//Mark it as being queued
	updater?.parallax_update_queued = TRUE
	queued += updater
