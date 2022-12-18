#define FIRST_INSTANCE 1 // just list[1] is bad to read

SUBSYSTEM_DEF(status)
	name = "Atom Status"
	init_order = INIT_ORDER_STATUS
	flags = SS_BACKGROUND | SS_NO_FIRE

	var/list/atom_list = list()
	var/list/atom_status = list()
/*
	< atom_list structure >
		[1. atom_list]
		key: atom
		value: [2. list - atom_status path]
			   key: atom_status path
			   value: [3. list - individual status datum]
			          key: (none, number counting)
			          value: [4. list - details]
							 "type": contains a type of atom_status
							 "duration": remaining time of the effect
 */

/datum/controller/subsystem/status/PreInit()
	for(var/datum/atom_status/D as() in subtypesof(/datum/atom_status))
		D = new D()
		atom_status[D.type] = D
	START_PROCESSING(SSprocessing, src)

/datum/controller/subsystem/status/proc/_add_status(atom/A, path, duration, force_duration, datum/atom_status/D)
	var/build_list = list(
		"type" = D,
		"current_pulse" = 0,
		"duration" = force_duration ? duration || D.starting_duration : min(D.maximum_duration, duration || D.starting_duration))
	atom_list[A][path] += list(build_list)
	D.on_add(A, grab_status_instance(A, path))

/datum/controller/subsystem/status/proc/add_status(atom/A, path, duration=0, force_duration=FALSE)
	if(!A || !path)
		return FALSE
	if(!length(atom_list[A]))
		atom_list[A] = list()
	if(!atom_list[A][path])
		atom_list[A][path] = list()

	var/datum/atom_status/D = atom_status[path]


	// We can just add a new instance
	if(D.max_stack_size > length(atom_list[A][path]))
		_add_status(A, path, duration, force_duration, D)

	// renewing an existing instnance
	else

		if(length(atom_list[A][path]) == 1) // if length is 1, no need to find
			atom_list[A][path][FIRST_INSTANCE]["duration"] = calculate_duration(D, atom_list[A][path][FIRST_INSTANCE]["duration"], duration, force_duration)

		else // we'll find an instance that has the least duration among itselves
			var/iteration_count = 0
			var/instance_with_least_duration = atom_list[A][path][FIRST_INSTANCE]
			while(iteration_count++ < length(atom_list[A][path]))
				if(atom_list[A][path][iteration_count]["duration"] < instance_with_least_duration["duration"])
					instance_with_least_duration = atom_list[A][path][iteration_count]
			instance_with_least_duration["duration"] = calculate_duration(D, instance_with_least_duration["duration"], duration, force_duration)


/datum/controller/subsystem/status/proc/calculate_duration(datum/atom_status/D, original_duration, duration=0, force_duration=FALSE)
	return min(D.maximum_duration, max(duration, original_duration+duration, D.starting_duration))

/datum/controller/subsystem/status/proc/_remove_status(atom/A, path, target_count, datum/atom_status/D)
	D.on_remove(A, atom_list[A][path][target_count])
	atom_list[A][path] -= list(atom_list[A][path][target_count])

/datum/controller/subsystem/status/proc/remove_status(atom/A, path, target_count = 0)
	if(!length(atom_list[A]))
		return
	if(!length(atom_list[A][path]))
		return
	if(target_count)
		if(!length(atom_list[A][path][target_count]))
			return
		_remove_status(A, path, target_count, atom_list[A][path][target_count]["type"])
		return TRUE

	if(length(atom_list[A][path]) == 1)
		_remove_status(A, path, 1, atom_list[A][path][FIRST_INSTANCE]["type"])
		return TRUE

	var/iteration_count = 0
	var/instance_with_least_duration = atom_list[A][path][FIRST_INSTANCE]
	while(iteration_count++ < length(atom_list[A][path]))
		if(atom_list[A][path][iteration_count]["duration"] < instance_with_least_duration["duration"])
			instance_with_least_duration = atom_list[A][path][iteration_count]

	_remove_status(A, path, iteration_count, instance_with_least_duration["type"])
	return TRUE


/datum/controller/subsystem/status/process(delta_time)
	if(!length(atom_list))
		return

	for(var/atom/each_atom in atom_list)
		for(var/each_status in atom_list[each_atom])
			var/iteration_count = 0
			while(iteration_count++ < length(atom_list[each_atom][each_status]))
				var/data = atom_list[each_atom][each_status][iteration_count]
				var/datum/atom_status/D = data["type"]
				data["duration"] -= delta_time
				data["current_pulse"] += 1
				if(!(data["current_pulse"] % D.pulse_per_tick))
					D.on_progress(each_atom, data)
				if(data["duration"] <= 0)
					remove_status(each_atom, each_status, iteration_count)
					iteration_count--
			if(!length(atom_list[each_atom][each_status]))
				atom_list[each_atom] -= each_status
		if(!length(atom_list[each_atom]))
			atom_list -= each_atom



/// Grabs an instance of a specific status. This DOSE NOT reliablly grab an specific instance if there're multiple(stackable) instances. It will try to grab the last instance if there're multiple instances.
/datum/controller/subsystem/status/proc/grab_status_instance(atom/A, path, num=0)
	if(!A || !path)
		return FALSE
	return atom_list[A][path][num || length(atom_list[A][path])] || FALSE
	/* usage example
		******************
		var/status = SSstatus.grab_status_instance(mob, /datum/atom_status/omni_regeneration)
			status["duration"] = 0
		******************/

/// unlike `grab_status_instance()`, it returns all lists that have the same path
/datum/controller/subsystem/status/proc/grab_all_status_instances(atom/A, path)
	if(!A || !path)
		return FALSE
	return atom_list[A][path] || FALSE
	/* usage example
		******************
		for(var/each_status in SSstatus.grab_all_status_instances(mob, /datum/atom_status/omni_regeneration))
			each_status["duration"] = 0
		******************/

#undef FIRST_INSTANCE
