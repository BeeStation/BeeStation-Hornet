#define CLEAR_TURF_PROCESSING_TIME (120 SECONDS)	//Time it takes to clear all turfs
#define CHECK_ZLEVEL_TICKS (5 SECONDS)			//Every 5 seconds check if a tracked z-level is free.

GLOBAL_LIST_EMPTY(zclear_atoms)
GLOBAL_LIST_EMPTY(zclear_blockers)

SUBSYSTEM_DEF(zclear)
	name = "Z-Clear"
	wait = 1

	flags = SS_NO_INIT
	runlevels = RUNLEVEL_GAME

	//List of z-levels to be auto-wiped when they are left
	//Assoc list
	var/list/datum/space_level/autowipe

	//List of free, empty z-levels.
	var/list/datum/space_level/free_levels

	//List of processing Z-Levels
	var/list/datum/zclear_data/processing_levels

	//List of atoms to ignore
	var/list/ignored_atoms = null

	//List of nullspaced mobs to replace in ruins
	var/list/nullspaced_mobs = list()

	//List of z-levels being docked with
	var/list/docking_levels = list()

	//Announced zombie levels
	var/list/announced_zombie_levels = list()

/datum/controller/subsystem/zclear/New()
	. = ..()
	ignored_atoms = typecacheof(list(/mob/dead, /mob/camera, /mob/dview, /atom/movable/lighting_object, /obj/effect/abstract/mirage_holder))

/datum/controller/subsystem/zclear/Recover()
	if(!islist(autowipe)) autowipe = list()
	autowipe |= SSzclear.autowipe
	if(!islist(free_levels)) free_levels = list()
	free_levels |= SSzclear.free_levels
	if(!islist(processing_levels)) processing_levels = list()
	processing_levels |= SSzclear.processing_levels
	if(!islist(ignored_atoms)) ignored_atoms = list()
	ignored_atoms |= SSzclear.ignored_atoms
	nullspaced_mobs |= SSzclear.nullspaced_mobs
	docking_levels |= SSzclear.docking_levels
	announced_zombie_levels |= SSzclear.announced_zombie_levels

/datum/controller/subsystem/zclear/fire(resumed)
	if(times_fired % CHECK_ZLEVEL_TICKS == 0)
		check_for_empty_levels()
	for(var/datum/zclear_data/cleardata as() in processing_levels)
		continue_wipe(cleardata)

/*
 * Checks for empty z-levels and wipes them.
*/
/datum/controller/subsystem/zclear/proc/check_for_empty_levels()
	var/list/active_levels = list()
	//Levels that have living mobs
	var/list/living_levels = list()
	//Levels with mobs dead/alive
	var/list/mob_levels = list()
	//Check active mobs
	for(var/mob/living/L as () in GLOB.mob_list)
		if(!L)
			continue
		//Dead mobs get sent to new ruins
		if(L.ckey || L.mind || L.client)
			var/turf/T = get_turf(L)
			mob_levels["[T.z]"] = TRUE
			if(L.stat != DEAD)
				active_levels["[T.z]"] = TRUE
				living_levels["[T.z]"] = TRUE
	//Check active nukes
	for(var/obj/machinery/nuclearbomb/decomission/bomb in GLOB.decomission_bombs)
		if(bomb.timing)
			active_levels["[bomb.z]"] = TRUE
			living_levels["[bomb.z]"] = TRUE	//Dont perform mob saving actions on mobs about to be blown to smitherines.
	//Block z-clear from these levels.
	for(var/atom/A as() in GLOB.zclear_blockers)
		active_levels["[A.z]"] = TRUE
	//Check for shuttles
	for(var/obj/docking_port/mobile/M in SSshuttle.mobile)
		active_levels["[M.z]"] = TRUE
		//Check shuttle destination
		if(M.destination)
			active_levels["[M.destination.z]"] = TRUE
			living_levels["[M.destination.z]"] = TRUE
	//Check for shuttles docking
	for(var/port_id in SSorbits.assoc_shuttles)
		var/datum/orbital_object/shuttle/shuttle = SSorbits.assoc_shuttles[port_id]
		if(shuttle.docking_target)
			for(var/datum/space_level/level in shuttle.docking_target.linked_z_level)
				active_levels["[level.z_value]"] = TRUE
				living_levels["[level.z_value]"] = TRUE
	//Check for shuttles coming in
	for(var/docking_level in docking_levels)
		active_levels["[docking_level]"] = TRUE
		living_levels["[docking_level]"] = TRUE

	for(var/datum/space_level/level as() in autowipe)
		if(!level)
			autowipe -= level

		//Check if free
		if(active_levels["[level.z_value]"])
			if(!living_levels["[level.z_value]"] && mob_levels["[level.z_value]"] && !announced_zombie_levels["[level.z_value]"])
				//Zombie level detected.
				announced_zombie_levels["[level.z_value]"] = TRUE
				var/datum/orbital_object/linked_object = SSorbits.assoc_z_levels["[level.z_value]"]
				if(linked_object)
					priority_announce("Nanotrasen long ranged sensors have indicated that all sentient life forms at priority waypoint [linked_object.name] have ceased life functions. Command is recommended to establish a rescue operation to recover the bodies. Due to the nature of the threat at this location, security personnel armed with lethal weaponry is recommended to accompany the rescue team.", "Nanotrasen Long Range Sensors")
			continue
		//Level is free, do the wiping thing.
		LAZYREMOVE(autowipe, level)
		//Reset orbital body.
		QDEL_NULL(SSorbits.assoc_z_levels["[level.z_value]"])
		//Continue tracking after
		wipe_z_level(level.z_value, TRUE)

//Temporarily stops a z from being wiped for 30 seconds.
/datum/controller/subsystem/zclear/proc/temp_keep_z(z_level)
	docking_levels |= z_level
	addtimer(CALLBACK(src, PROC_REF(unkeep_z), z_level), 2 MINUTES)

/datum/controller/subsystem/zclear/proc/unkeep_z(z_level)
	docking_levels -= z_level

/*
 * Returns a free space level.
 * After a 60 second grace period of allocation, the z-level will be put back into the pool of z-levels to clear.
 * Will create a new z-level if none are available.
*/
/datum/controller/subsystem/zclear/proc/get_free_z_level()
	while(LAZYLEN(free_levels))
		var/datum/space_level/picked_level = pick(free_levels)
		LAZYREMOVE(free_levels, picked_level)
		//In 1 minute we will begine tracking when all mobs have left the z-level.
		//Begin tracking. In the rare case that someone got into a free z-level then just allow them to float there with no ruins. Space is pretty empty you know.
		addtimer(CALLBACK(src, PROC_REF(begin_tracking), picked_level), 60 SECONDS)
		//Check if the z-level is actually free. (Someone might have drifted into the z-level.)
		var/free = TRUE
		for(var/mob/living/L in GLOB.player_list)
			var/turf/T = get_turf(L)
			if(T.z == picked_level.z_value)
				free = FALSE
				break
		if(free)
			return picked_level
	var/datum/space_level/picked_level = SSmapping.add_new_zlevel("Dynamic free level [LAZYLEN(free_levels)]", ZTRAITS_SPACE, orbital_body_type = null)
	addtimer(CALLBACK(src, PROC_REF(begin_tracking), picked_level), 60 SECONDS)
	message_admins("SSORBITS: Created a new dynamic free level ([LAZYLEN(free_levels)] now created) as none were available at the time.")
	return picked_level

/datum/controller/subsystem/zclear/proc/begin_tracking(datum/space_level/sl)
	LAZYOR(autowipe, sl)


/*
 * Adds a z-level to the queue to be deleted.
 * If tracking is TRUE, then we will re-wipe the z-level when mobs leave it again.
*/
/datum/controller/subsystem/zclear/proc/wipe_z_level(z_level, tracking = FALSE, datum/callback/completion_callback)
	if(!z_level)
		return

	SSair.pause_z(z_level)

	var/list/turfs = block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level))
	var/list/divided_turfs = list()
	var/section_process_time = CLEAR_TURF_PROCESSING_TIME * 0.5 //There are 3 processes, cleaing atoms, cleaing turfs and then reseting atmos

	//Divide the turfs into groups
	var/group_size = CEILING(turfs.len / section_process_time, 1)
	var/list/current_group = list()
	for(var/i in 1 to turfs.len)
		var/turf/T = turfs[i]
		current_group += T
		if(i % group_size == 0)
			divided_turfs += list(current_group)
			current_group = list()
	divided_turfs += list(current_group)

	//Create the wipe data datum
	var/datum/zclear_data/data = new()
	data.zvalue = z_level
	data.divided_turfs = divided_turfs
	data.process_num = 0
	data.completion_callback = completion_callback
	data.tracking = tracking

	//Add the thing to the wiping levels list.
	LAZYADD(processing_levels, data)

	//Pre-clear anything that needs to be cleared first (Air alarms.)
	for(var/atom/A in GLOB.zclear_atoms)
		if(A.z == z_level)
			qdel(A, TRUE)

	//Unannounce zombie level
	announced_zombie_levels["[z_level]"] = FALSE

/*
 * Continues the process of wiping a z-level.
*/
/datum/controller/subsystem/zclear/proc/continue_wipe(datum/zclear_data/cleardata)
	var/list_element = (cleardata.process_num % (CLEAR_TURF_PROCESSING_TIME * 0.5)) + 1
	switch(cleardata.process_num)
		if(0 to (CLEAR_TURF_PROCESSING_TIME*0.5)-1)
			if(list_element <= length(cleardata.divided_turfs))
				reset_turfs(cleardata.divided_turfs[list_element])
		if((CLEAR_TURF_PROCESSING_TIME*0.5) to (CLEAR_TURF_PROCESSING_TIME-1))
			if(list_element <= length(cleardata.divided_turfs))
				clear_turf_atoms(cleardata.divided_turfs[list_element])
		else
			//Done
			LAZYREMOVE(processing_levels, cleardata)
			//Finalize area
			SSair.unpause_z(cleardata.zvalue)
			var/area/spaceA = GLOB.areas_by_type[/area/space]
			spaceA.reg_in_areas_in_z()	//<< Potentially slow proc
			if(cleardata.completion_callback)
				cleardata.completion_callback.Invoke(cleardata.zvalue)
			if(cleardata.tracking)
				LAZYADD(free_levels, SSmapping.z_list[cleardata.zvalue])
			if(length(nullspaced_mobs))
				var/nullspaced_mob_names = ""
				var/valid = FALSE
				for(var/mob/M as() in nullspaced_mobs)
					if(M.key || M.get_ghost(FALSE, TRUE))
						nullspaced_mob_names += " - [M.name]\n"
						valid = TRUE
				if(valid)
					priority_announce("Sensors indicate that multiple crewmembers have been lost at an abandoned station. They can potentially be recovered by flying to the nearest derelict station and locating their bodies.\n[nullspaced_mob_names]")
	cleardata.process_num ++

/*
 * Deletes all the atoms within a given turf.
*/
/datum/controller/subsystem/zclear/proc/clear_turf_atoms(list/turfs)
	//Clear atoms
	for(var/turf/T as() in turfs)
		var/max_iterations = 3
		var/list/allowed_contents = typecache_filter_list_reverse(T.contents, ignored_atoms)
		while (max_iterations -- > 0 && length(allowed_contents))
			// Remove all atoms except abstract mobs
			for(var/i in 1 to allowed_contents.len)
				var/thing = allowed_contents[i]
				//Remove powernet to prevent massive amounts of propagate networks, everythings getting deleted so who cares.
				if(istype(thing, /obj/structure/cable))
					var/obj/structure/cable/cable = thing
					cable.powernet = null
				if(ismob(thing))
					if(!isliving(thing))
						continue
					var/mob/living/M = thing
					if(M.mind || M.key)
						if(M.stat == DEAD)
							//Store them for later
							M.ghostize(TRUE)
							M.forceMove(null)
							nullspaced_mobs += M
						else
							//If the mob has a key (but is DC) then teleport them to a safe z-level where they can potentially be retrieved.
							//Since the wiping takes 90 seconds they could potentially still be on the z-level as it is wiping if they reconnect in time
							random_teleport_atom(M)
							M.Knockdown(5)
							to_chat(M, "<span class='warning'>You feel sick as your body lurches through space and time, the ripples of the starship that brought you here eminate no more and you get the horrible feeling that you have been left behind.</span>")
					else
						delete_atom(thing)
				else
					delete_atom(thing)
			allowed_contents = typecache_filter_list_reverse(T.contents, ignored_atoms)

/*
 * DELETES AN ATOM OR TELEPORTS IT TO A RANDOM LOCATION IF IT IS INDESTRUCTIBLE
*/
/datum/controller/subsystem/zclear/proc/delete_atom(atom/A)
	//Dont delete indestructible items, but indestructible structures can go
	if(isitem(A))
		var/obj/O = A
		//Handled by the mob
		if(ismob(O.loc))
			return
		if(O.resistance_flags & INDESTRUCTIBLE)
			random_teleport_atom(A)
			return
	//Force delete effects and docking ports, normal delete everything else.
	//Probably gunna cause problems in testing.
	qdel(A, force = (iseffect(A) || istype(A, /obj/docking_port)))

/*
 * Randomly teleports an atom to a random z-level
 * Copy and paste of turf/open/space/transit, could probably be a global proc
*/
/datum/controller/subsystem/zclear/proc/random_teleport_atom(atom/movable/AM)
	set waitfor = FALSE
	if(!AM || istype(AM, /obj/docking_port))
		return
	if(AM.loc != get_turf(AM)) 	// Multi-tile objects are "in" multiple locs but its loc is it's true placement.
		return					// Don't move multi tile objects if their origin isnt in transit
	var/max = world.maxx-TRANSITIONEDGE
	var/min = 1+TRANSITIONEDGE

	var/list/possible_transtitons = list()
	for(var/datum/space_level/D as() in SSmapping.z_list)
		if (D.linkage == CROSSLINKED)
			possible_transtitons += D.z_value

	if(!length(possible_transtitons))
		possible_transtitons = list(SSmapping.empty_space)

	var/_z = pick(possible_transtitons)

	//now select coordinates for a border turf
	var/_x = rand(min,max)
	var/_y = rand(min,max)

	var/turf/T = locate(_x, _y, _z)
	AM.forceMove(T)

/datum/controller/subsystem/zclear/proc/reset_turfs(list/turfs)
	var/list/new_turfs = list()
	for(var/turf/T as() in turfs)
		var/turf/newT
		if(istype(T, /turf/open/space))
			newT = T
		else
			newT = T.ChangeTurf(/turf/open/space, flags = CHANGETURF_IGNORE_AIR | CHANGETURF_DEFER_CHANGE)
		if(!istype(newT.loc, /area/space))
			var/area/newA = GLOB.areas_by_type[/area/space]
			newA.contents += newT
			newT.change_area(newT.loc, newA)
		newT.flags_1 &= ~NO_RUINS_1
		new_turfs += newT
	return new_turfs

/datum/zclear_data
	var/zvalue
	var/list/divided_turfs
	var/process_num
	var/tracking
	//Callback when completed, z value passed as parameters
	var/datum/callback/completion_callback
