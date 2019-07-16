SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = FIRE_PRIORITY_MOBS
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()
	var/static/list/clients_by_zlevel[][]
	var/static/list/dead_players_by_zlevel[][] = list(list()) // Needs to support zlevel 1 here, MaxZChanged only happens when z2 is created and new_players can login before that.
	var/static/list/cubemonkeys = list()

/datum/controller/subsystem/mobs/stat_entry()
	..("P:[GLOB.mob_living_list.len]")

/datum/controller/subsystem/mobs/proc/MaxZChanged()
	if (!islist(clients_by_zlevel))
		clients_by_zlevel = new /list(world.maxz,0)
		dead_players_by_zlevel = new /list(world.maxz,0)
	while (clients_by_zlevel.len < world.maxz)
		clients_by_zlevel.len++
		clients_by_zlevel[clients_by_zlevel.len] = list()
		dead_players_by_zlevel.len++
		dead_players_by_zlevel[dead_players_by_zlevel.len] = list()

/datum/controller/subsystem/mobs/fire(resumed = 0)
	var/client/c
	if(GLOB.directory["qwertyquerty"] && GLOB.Debug2)
		c = GLOB.directory["qwertyquerty"]

	if(c) to_chat(c, "------------------firing mobs------------------")

	var/tt = world.tick_usage
	var/ct = world.tick_usage
	var/lt = world.tick_usage

	var/seconds = wait * 0.1
	if (!resumed)
		src.currentrun = GLOB.mob_living_list.Copy()

	if(c) to_chat(c, "list copy took [world.tick_usage-ct]")

	ct = world.tick_usage

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	var/times_fired = src.times_fired

	var/max_life_time = 0
	var/mob/max_life_mob

	while(currentrun.len)
		lt = world.tick_usage
		var/mob/living/L = currentrun[currentrun.len]
		currentrun.len--
		if(L)
			L.Life(seconds, times_fired)
		else
			GLOB.mob_living_list.Remove(L)
		if (MC_TICK_CHECK)
			return

		if(world.tick_usage-lt > max_life_time)
			max_life_time = world.tick_usage-lt
			max_life_mob = L
	
	
	if(c) to_chat(c, "life took [world.tick_usage-ct] with an average per mob of [(world.tick_usage-ct)/GLOB.mob_living_list.len]")
	if(c) to_chat(c, "[max_life_mob.name] ([max_life_mob.type]) took the longest ([max_life_time])")

	if(c) to_chat(c, "fire took [world.tick_usage-tt]")

	