GLOBAL_LIST(admin_objective_list) //Prefilled admin assignable objective list

/datum/objective
	var/datum/mind/owner				//The primary owner of the objective. !!SOMEWHAT DEPRECATED!! Prefer using 'team' for new code.
	var/datum/team/team					//An alternative to 'owner': a team. Use this when writing new code.
	var/name = "generic objective" 		//Name for admin prompts
	var/explanation_text = "Nothing"	//What that person is supposed to do.
	var/team_explanation_text			//For when there are multiple owners.
	var/datum/mind/target = null		//If they are focused on a particular person.
	var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = 0					//currently only used for custom objectives.
	var/martyr_compatible = 0			//If the objective is compatible with martyr objective, i.e. if you can still do it while dead.
	var/murderbone_flag = FALSE

/datum/objective/New(var/text)
	if(text)
		explanation_text = text

//Apparently objectives can be qdel'd. Learn a new thing every day
/datum/objective/Destroy()
	set_target(null)
	if(team)
		team.objectives -= src
	for(var/datum/mind/own as() in get_owners())
		for(var/datum/antagonist/A as() in own.antag_datums)
			A.objectives -= src
		own.crew_objectives -= src
	return ..()

/datum/objective/proc/get_owners() // Combine owner and team into a single list.
	. = (team && team.members) ? team.members.Copy() : list()
	if(owner)
		. += owner

/datum/objective/proc/admin_edit(mob/admin)
	return

//Shared by few objective types
/datum/objective/proc/admin_simple_target_pick(mob/admin)
	var/list/possible_targets = list()
	var/def_value
	for(var/datum/mind/possible_target as() in SSticker.minds)
		if ((possible_target != src) && ishuman(possible_target.current))
			possible_targets += possible_target.current


	if(target?.current)
		def_value = target.current

	var/mob/new_target = input(admin,"Select target:", "Objective target", def_value) as null|anything in (sort_names(possible_targets) | list("Free objective","Random"))
	if (!new_target)
		return

	if (new_target == "Free objective")
		set_target(null)
	else if (new_target == "Random")
		find_target()
	else
		set_target(new_target.mind)

	update_explanation_text()

/datum/objective/proc/considered_escaped(datum/mind/M)
	if(!considered_alive(M))
		return FALSE
	if(M.force_escaped)
		return TRUE
	if(SSticker.force_ending || SSticker.mode.station_was_nuked) // Just let them win.
		return TRUE
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return FALSE
	var/turf/location = get_turf(M.current)
	if(!location || istype(location, /turf/open/floor/plasteel/shuttle/red) || istype(location, /turf/open/floor/mineral/plastitanium/red/brig)) // Fails if they are in the shuttle brig
		return FALSE
	return location.onCentCom() || location.onSyndieBase()

/datum/objective/proc/check_completion()
	return completed

/datum/objective/proc/get_completion_message()
	return check_completion() ? "[explanation_text] <span class='greentext'>Success!</span>" : "[explanation_text] <span class='redtext'>Fail.</span>"

/datum/objective/proc/is_unique_objective(possible_target, list/dupe_search_range)
	if(!islist(dupe_search_range))
		stack_trace("Non-list passed as duplicate objective search range")
		dupe_search_range = list(dupe_search_range)

	for(var/A in dupe_search_range)
		var/list/objectives_to_compare
		if(istype(A,/datum/mind))
			var/datum/mind/M = A
			objectives_to_compare = M.get_all_objectives()
		else if(istype(A,/datum/antagonist))
			var/datum/antagonist/G = A
			objectives_to_compare = G.objectives
		else if(istype(A,/datum/team))
			var/datum/team/T = A
			objectives_to_compare = T.objectives
		for(var/datum/objective/O as() in objectives_to_compare)
			if(istype(O, type) && O.get_target() == possible_target)
				return FALSE
	return TRUE

/datum/objective/proc/get_target()
	return target

/datum/objective/proc/set_target(datum/mind/new_target)
	if(target)
		UnregisterSignal(target, COMSIG_MIND_CRYOED)
	target = new_target
	if(istype(target, /datum/mind))
		RegisterSignal(target, COMSIG_MIND_CRYOED, PROC_REF(on_target_cryo))
		target.isAntagTarget = TRUE

/datum/objective/proc/get_crewmember_minds()
	. = list()
	for(var/datum/data/record/R as() in GLOB.data_core.locked)
		var/datum/mind/M = R.fields["mindref"]
		if(M)
			. += M

//dupe_search_range is a list of antag datums / minds / teams
/datum/objective/proc/find_target(list/dupe_search_range, list/blacklist)
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/list/prefered_targets = list()
	var/list/possible_targets = list()
	var/try_target_late_joiners = FALSE
	var/owner_is_exploration_crew = FALSE
	var/owner_is_shaft_miner = FALSE
	for(var/datum/mind/O as() in get_owners())
		if(O.late_joiner)
			try_target_late_joiners = TRUE
		if(O.assigned_role == "Exploration Crew")
			owner_is_exploration_crew = TRUE
		if(O.assigned_role == "Shaft Miner")
			owner_is_shaft_miner = TRUE
	for(var/datum/mind/possible_target as() in get_crewmember_minds())
		if(!is_valid_target(possible_target))
			continue
		if(!is_unique_objective(possible_target,dupe_search_range))
			continue
		if(possible_target in blacklist)
			continue

		if(possible_target.assigned_role == "Exploration Crew")
			if(owner_is_exploration_crew)
				prefered_targets += possible_target
			else
				//Reduced chance to get people off station
				if(prob(70) && !owner_is_shaft_miner)
					continue
		else if(possible_target.assigned_role == "Shaft Miner")
			if(owner_is_shaft_miner)
				prefered_targets += possible_target
			else
				//Reduced chance to get people off station
				if(prob(70) && !owner_is_exploration_crew)
					continue

		possible_targets += possible_target
	if(try_target_late_joiners)
		var/list/all_possible_targets = possible_targets.Copy()
		for(var/datum/mind/PT as() in all_possible_targets)
			if(!PT.late_joiner)
				possible_targets -= PT
		if(!possible_targets.len)
			possible_targets = all_possible_targets
	//30% chance to go for a prefered target
	if(prefered_targets.len > 0 && prob(30))
		set_target(pick(prefered_targets))
	else if(possible_targets.len > 0)
		set_target(pick(possible_targets))
	else
		set_target(null)
	update_explanation_text()
	return target

/datum/objective/proc/is_valid_target(datum/mind/possible_target)
	if(possible_target in get_owners())
		return FALSE
	if(!ishuman(possible_target.current))
		return FALSE
	if(possible_target.current.stat == DEAD)
		return FALSE
	var/target_area = get_area(possible_target.current)
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_LATE_ARRIVALS) && istype(target_area, /area/shuttle/arrival))
		return FALSE
	return TRUE

/datum/objective/proc/find_target_by_role(role, role_type=FALSE,invert=FALSE)//Option sets either to check assigned role or special role. Default to assigned., invert inverts the check, eg: "Don't choose a Ling"
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target as() in get_crewmember_minds())
		if(is_valid_target(possible_target))
			var/is_role = FALSE
			if(role_type)
				if(possible_target.special_role == role)
					is_role = TRUE
			else
				if(possible_target.assigned_role == role)
					is_role = TRUE
			if(is_role && !invert || !is_role && invert)
				possible_targets += possible_target
	if(length(possible_targets))
		set_target(pick(possible_targets))
	else
		set_target(null)
	update_explanation_text()
	return target

/datum/objective/proc/update_explanation_text()
	if(team_explanation_text && LAZYLEN(get_owners()) > 1)
		explanation_text = team_explanation_text

/datum/objective/proc/generate_stash(list/special_equipment)
	var/datum/mind/receiver = pick(get_owners())
	var/obj/item/storage/backpack/satchel/flat/empty/secret_bag = receiver.antag_stash
	//Find and generate the stash
	if(!secret_bag)
		secret_bag = new()
		// Hard-del handling is done by the component
		receiver.antag_stash = secret_bag
		var/atom_text = ""
		switch (pick_weight(list("airlock" = 3)))
			if("airlock")
				atom_text = "An airlock"
				//Valid areas
				var/static/list/valid_areas = list(
					/area/medical,
					/area/commons,
					/area/crew_quarters,
					/area/service,
					/area/library,
					/area/maintenance,
					/area/hallway,
					/area/chapel,
					/area/hydroponics,
					/area/holodeck,
					/area/lawoffice,
				)
				// If our airlock isn't accessible to these accesses, then we won't allow the item to spawn here
				var/list/safe_access_list = list(ACCESS_CARGO, ACCESS_MAINT_TUNNELS, ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_JANITOR, ACCESS_CHAPEL_OFFICE, ACCESS_THEATRE, ACCESS_LAWYER, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING)
				//Pick a valid airlock
				for(var/obj/machinery/door/airlock/A in shuffle(GLOB.machines))
					if (!is_station_level(A.z))
						continue
					if (!A.check_access_list(safe_access_list))
						continue
					//Make sure its publicly accessible
					var/area/area = get_area(A)
					var/valid = FALSE
					for(var/area_type in valid_areas)
						if(istype(area, area_type))
							valid = TRUE
							break
					if(!valid)
						continue
					//This airlock is good for us
					A.AddComponent(/datum/component/stash, receiver, secret_bag)
					break
		//Failsafe
		if(!secret_bag.loc)
			atom_text = "You"
			message_admins("Could not find a location to put [ADMIN_FLW(receiver.current)]'s stash.")
			secret_bag.forceMove(get_turf(receiver.current))
			receiver.current.equip_to_appropriate_slot(secret_bag)
			// Remove this from memory since the component deals with hard-dels
			receiver.antag_stash = null
		//Update the mind
		receiver.store_memory("You have a secret stash of items hidden on the station required for your objectives. It is hidden inside of [atom_text] ([secret_bag.loc]) located at [get_area(secret_bag.loc)] [COORD(secret_bag.loc)], you may have to search around for it. (Use alt click on the object the stash is inside to access it).")
		to_chat(receiver?.current, "<span class='notice bold'>You have a secret stash at [get_area(secret_bag)], more details are stored in your notes. (IC > Notes)</span>")
	//Create the objects in the bag
	for(var/eq_path in special_equipment)
		new eq_path(secret_bag)

/datum/objective/proc/on_target_cryo()
	SIGNAL_HANDLER

	find_target(null, list(target))
	if(!target)
		if(team)
			team.objectives -= src
		for(var/datum/mind/own as() in get_owners())
			for(var/datum/antagonist/A as() in own.antag_datums)
				A.objectives -= src
			own.crew_objectives -= src

			to_chat(own.current, "<BR><span class='userdanger'>Your target is no longer within reach. Objective removed!</span>")
			own.announce_objectives()
		qdel(src)
	else
		update_explanation_text()
		for(var/datum/mind/own as() in get_owners())
			to_chat(own.current, "<BR><span class='userdanger'>You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!</span>")
			own.announce_objectives()
