SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = FIRE_PRIORITY_MOBS
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2 SECONDS

	var/list/currentrun = list()
	var/static/list/clients_by_zlevel[][]
	var/static/list/dead_players_by_zlevel[][] = list(list()) // Needs to support zlevel 1 here, MaxZChanged only happens when z2 is created and new_players can login before that.
	var/static/list/cubemonkeys = list()

/datum/controller/subsystem/mobs/stat_entry()
	. = ..("P:[GLOB.mob_living_list.len]")

/datum/controller/subsystem/mobs/proc/MaxZChanged()
	if (!islist(clients_by_zlevel))
		clients_by_zlevel = new /list(world.maxz,0)
		dead_players_by_zlevel = new /list(world.maxz,0)
	while (clients_by_zlevel.len < world.maxz)
		clients_by_zlevel.len++
		clients_by_zlevel[clients_by_zlevel.len] = list()
		dead_players_by_zlevel.len++
		dead_players_by_zlevel[dead_players_by_zlevel.len] = list()

/datum/controller/subsystem/mobs/fire(resumed = FALSE)
	if (!resumed)
		src.currentrun = GLOB.mob_living_list.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	var/times_fired = src.times_fired

	//Every 10 fires we check for invalid locations and update registered zlevels (if necessary)
	if(times_fired % 10 == 0)
		for(var/X in currentrun)
			var/mob/living/M = X
			if (!M.client)
				if (M.registered_z)
					log_game("Z-TRACKING: [M] of type [M.type] has a Z-registration despite not having a client.")
					M.update_z(null)
				continue
			var/turf/T = get_turf(M)
			if(!T)
				for(var/obj/effect/landmark/error/E in GLOB.landmarks_list)
					M.forceMove(E.loc)
					break
				var/msg = "[ADMIN_LOOKUPFLW(M)] was found to have no .loc with an attached client, if the cause is unknown it would be wise to ask how this was accomplished."
				message_admins(msg)
				send2irc_adminless_only("Mob", msg, R_ADMIN)
				log_game("[key_name(M)] was found to have no .loc with an attached client.")

			// This is a temporary error tracker to make sure we've caught everything
			else if (M.registered_z != T.z)
#ifdef TESTING
				message_admins("[ADMIN_LOOKUPFLW(M)] has somehow ended up in Z-level [T.z] despite being registered in Z-level [M.registered_z]. If you could ask them how that happened and notify coderbus, it would be appreciated.")
#endif
				log_game("Z-TRACKING: [M] has somehow ended up in Z-level [T.z] despite being registered in Z-level [M.registered_z].")
				M.update_z(T.z)

	while(currentrun.len)
		var/mob/living/L = currentrun[currentrun.len]
		currentrun.len--
		if(L)
			L.Life(wait * 0.1, times_fired)
		else
			GLOB.mob_living_list.Remove(L)
		if (MC_TICK_CHECK)
			return
