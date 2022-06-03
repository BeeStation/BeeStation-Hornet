/**
 * Archive console.
 *
 * Used in exploration crew missions to have the exploration crew download data about this station.
 * This will provide them with a data disk that can be used for science research which can then be used
 * to grant the explorers with some upgrades related to research.
 *
 * When a ruin generations, an archive room will be created as well as some archive upload zones.
 */

/obj/machinery/computer/archive
	name = "archive access console"
	desc = "An old computer that interfaces with a station's central archive repository, allowing the data to be downloaded to a data disk."
	var/activated = FALSE
	var/time_left = 3 MINUTES
	var/completion_world_time
	//Maintain a cache of nearby turfs while the machine is active.
	//Turfs are recycled by byond, so are safe to maintain references to.
	var/list/nearby_turf_cache
	var/spawn_range = 30
	//List of enemies we spawn
	var/mob_count = 0
	//Enemy mob spawns
	var/list/enemy_spawns = list(
		/mob/living/simple_animal/hostile/syndicate/melee/space = 7,
		/mob/living/simple_animal/hostile/syndicate/melee/space/stormtrooper = 3,
		/mob/living/simple_animal/hostile/syndicate/ranged/space = 5,
		/mob/living/simple_animal/hostile/syndicate/ranged/space/stormtrooper = 2,
		/mob/living/simple_animal/hostile/syndicate/ranged/shotgun/space = 3,
		/mob/living/simple_animal/hostile/syndicate/ranged/smg/space = 3,
		/mob/living/simple_animal/hostile/syndicate/ranged/shotgun/space/stormtrooper = 1,
		/mob/living/simple_animal/hostile/syndicate/ranged/smg/space/stormtrooper = 1,
	)
	var/pod_dropped = TRUE
	var/completed = FALSE

/obj/machinery/computer/archive/ui_data(mob/user)
	var/list/data = list()
	return data

/obj/machinery/computer/archive/process()
	. = ..()
	//Do nothing if not activated
	if(!activated)
		return
	//Check if we can be activated
	if(!can_process())
		deactivate()
		return
	if(world.time > completion_world_time)
		complete()
		return
	//Play a noise
	playsound(src, 'sound/items/timer.ogg', 40, TRUE, 9)
	//Spawn hostile enemies out of view (More spawn as we get closer to completion)
	var/time_proportion = (completion_world_time - world.time) / (5 MINUTES)
	if(prob(4 + 20 * (1 - time_proportion)) && mob_count < 5 + 15 * (1 - time_proportion))
		spawn_enemies()

/obj/machinery/computer/archive/proc/spawn_enemies()
	var/mob/living/simple_animal/hostile/enemy_mob
	var/turf/T = get_spawn_turf()
	var/spawn_loc = T
	if(pod_dropped)
		var/obj/structure/closet/supplypod/pod = new /obj/structure/closet/supplypod/bluespacepod(null, STYLE_SYNDICATE)
		pod.explosionSize = list(0, 0, 0, 0)
		new /obj/effect/pod_landingzone(T, pod)
		spawn_loc = pod
	var/mob_type = pickweight(enemy_spawns)
	enemy_mob = new mob_type(spawn_loc)
	enemy_mob.environment_smash |= ENVIRONMENT_SMASH_RWALLS | ENVIRONMENT_SMASH_WALLS
	//Make the mob target the computers
	enemy_mob.wanted_objects |= /obj/machinery/computer/archive
	enemy_mob.wanted_objects |= /obj/machinery/archive_server
	//Path to this location
	enemy_mob.toggle_ai(AI_ON)
	enemy_mob.add_persistant_target(src)
	mob_count ++
	RegisterSignal(enemy_mob, COMSIG_MOB_DEATH, .proc/mob_died)

/obj/machinery/computer/archive/proc/mob_died()
	mob_count--

/obj/machinery/computer/archive/proc/get_spawn_turf()
	var/sanity_tries = 10
	while(sanity_tries > 0)
		sanity_tries --
		var/turf/selected = pick(nearby_turf_cache)
		var/good_location = TRUE
		for(var/client/C in SSmobs.clients_by_zlevel[z])
			var/mob/living/L = C?.mob
			if(!istype(L))
				continue
			var/list/view_range = getviewsize(C?.view)
			if(can_see(L, src, max(view_range[1], view_range[2])))
				good_location = FALSE
				break
		if(good_location)
			return selected
	return pick(nearby_turf_cache)

/obj/machinery/computer/archive/proc/complete()
	completed = TRUE

/obj/machinery/computer/archive/proc/can_process()
	//Check if we are disabled
	if(stat)
		return FALSE
	return TRUE

/obj/machinery/computer/archive/proc/activate()
	if(completed)
		return
	//Start up the machine
	completion_world_time = world.time + time_left
	activated = TRUE
	//Calculate the turf cache
	if(!nearby_turf_cache)
		nearby_turf_cache = block(
			locate(max(x - spawn_range, 1), max(y - spawn_range, 1), z),
			locate(min(x + spawn_range, world.maxx), min(y + spawn_range, world.maxy), z)
		)
		//Remove nearby turfs
		nearby_turf_cache -= view(10, get_turf(src))
		//Remove closed turfs
		for(var/turf/closed/T in nearby_turf_cache)
			nearby_turf_cache -= T

/obj/machinery/computer/archive/proc/deactivate()
	//How much time is left
	time_left = completion_world_time - world.time
