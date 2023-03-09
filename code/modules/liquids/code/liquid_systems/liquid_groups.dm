/***************************************************/
/********************PROPER GROUPING**************/

//Whenever you add a liquid cell add its contents to the group, have the group hold the reference to total reagents for processing sake
//Have the liquid turfs point to a partial liquids reference in the group for any interactions
//Have the liquid group handle the total reagents datum, and reactions too (apply fraction?)

GLOBAL_VAR_INIT(liquid_debug_colors, FALSE)

/datum/liquid_group
	///the generated color given to the group on creation for debugging
	var/color
	///list of all current members of the group saved in true/false format
	var/list/members = list()
	///list of all current burning members of our group
	var/list/burning_members = list()
	///our reagent holder, where the entire liquid groups reagents are stored
	var/datum/reagents/reagents
	///the expected height of all the collective turfs
	var/expected_turf_height = 1
	///A saved variable of the total reagent volumes to avoid calling reagents.total_volume constantly
	var/total_reagent_volume = 0
	///a cached value of our reagents per turf, used to determine liquid height and state
	var/reagents_per_turf = 0
	///the icon state our group currently uses
	var/group_overlay_state = LIQUID_STATE_PUDDLE
	///the calculated alpha cache for our group
	var/group_alpha = 0
	///the calculated temperature cache for our group
	var/group_temperature = 300
	///the generated color used to apply coloring to all the members
	var/group_color
	///a variable to forcibly trigger a recount of our reagents
	var/updated_total = FALSE
	///have we failed a process? if so we are added to a death check so it will gracefully die on its own
	var/failed_death_check = FALSE
	///the burn power of our group, used to determine how strong we burn each process_fire()
	var/group_burn_power = 0
	///the icon state of our fire
	var/group_fire_state = LIQUID_FIRE_STATE_NONE
	///the amount of reagents we attempt to burn each process_fire()
	var/group_burn_rate = 0
	///the viscosity of our group, determines how much we can spread with our total reagent pool, higher means less turfs per reagent
	var/group_viscosity = 1
	///are we currently attempting a merge? if so don't process groups
	var/merging = FALSE
	///list of cached edge turfs with a sublist of directions stored
	var/list/cached_edge_turfs = list()
	///list of cached spreadable turfs for each burning member
	var/list/cached_fire_spreads = list()
	///list of old reagents
	var/list/cached_reagent_list = list()
	///cached temperature between turfs recalculated on group_process
	var/cached_temperature_shift = 0

///NEW/DESTROY
/datum/liquid_group/New(height, obj/effect/abstract/liquid_turf/created_liquid)
	color = "#[random_short_color()]"
	expected_turf_height = height
	reagents = new(100000) // this is a random number used on creation it expands based on the turfs in the group
	if(created_liquid)
		add_to_group(created_liquid.my_turf)
		cached_edge_turfs[created_liquid.my_turf] = list(NORTH, SOUTH, EAST, WEST)
	SSliquids.active_groups |= src

/datum/liquid_group/Destroy()
	SSliquids.active_groups -= src
	for(var/t in members)
		var/turf/T = t
		T.liquids.liquid_group = null
	members = null
	burning_members = null
	return ..()

///GROUP CONTROLLING
/datum/liquid_group/proc/add_to_group(turf/T)
	if(!T)
		return
	if(!T.liquids)
		T.liquids = new(null, src)
		cached_edge_turfs[T] = list(NORTH, SOUTH, EAST, WEST)

	if(!members)
		qdel(T.liquids)
		return

	members[T] = TRUE
	T.liquids.liquid_group = src
	reagents.maximum_volume += 1000 /// each turf will hold 1000 units plus the base amount spread across the group
	updated_total = TRUE
	if(group_color)
		T.liquids.color = group_color
	process_group()

/datum/liquid_group/proc/remove_from_group(turf/T)

	if(burning_members[T])
		burning_members -= T

	if(T in SSliquids.burning_turfs)
		SSliquids.burning_turfs -= T

	members -= T
	if(T.liquids)
		T.liquids.liquid_group = null

	if(!members.len)
		qdel(src)
		return
	updated_total = TRUE
	process_group()

/datum/liquid_group/proc/remove_all()
	for(var/turf/member in members)
		qdel(member.liquids)

/datum/liquid_group/proc/merge_group(datum/liquid_group/otherg)
	if(otherg == src)
		return

	otherg.merging = TRUE
	var/list/created_reagent_list = list()
	for(var/datum/reagent/reagent in otherg.reagents.reagent_list)
		created_reagent_list |= reagent.type
		created_reagent_list[reagent.type] = reagent.volume

	add_reagents(reagent_list = created_reagent_list, chem_temp = otherg.group_temperature)
	cached_edge_turfs |= otherg.cached_edge_turfs

	for(var/turf/liquid_turf in otherg.members)
		otherg.remove_from_group(liquid_turf)
		add_to_group(liquid_turf)


	total_reagent_volume = reagents.total_volume
	reagents_per_turf = total_reagent_volume / length(members)
	updated_total = TRUE

	qdel(otherg)
	process_group()

/datum/liquid_group/proc/break_group()
	qdel(src)

/datum/liquid_group/proc/check_dead()
	if(!members && !total_reagent_volume)
		if(failed_death_check)
			qdel(src)
			return
		failed_death_check = TRUE

///PROCESSING
/datum/liquid_group/proc/process_group()
	if(merging)
		return
	if(!members || !members.len) // this ideally shouldn't exist, ideally groups would die before they got to this point but alas here we are
		check_dead()
		return

	if(group_temperature != reagents.chem_temp)
		reagents.chem_temp = group_temperature

	handle_visual_changes()


	var/turf/open/open_turf = pick(members)
	var/datum/gas_mixture/math_cache = open_turf.air

	if(math_cache)
		if(group_temperature != math_cache.return_temperature())
			cached_temperature_shift =((math_cache.return_temperature() * math_cache.total_moles()) + ((group_temperature * total_reagent_volume) * 0.025)) / ((total_reagent_volume * 0.025) + math_cache.total_moles())

	if(total_reagent_volume != reagents.total_volume || updated_total)
		updated_total = FALSE
		total_reagent_volume = reagents.total_volume
		reagents.handle_reactions()

		if(!total_reagent_volume || !members)
			return

		reagents_per_turf = total_reagent_volume / length(members)

	expected_turf_height = CEILING(reagents_per_turf, 1) / LIQUID_HEIGHT_DIVISOR
	var/old_overlay = group_overlay_state
	switch(expected_turf_height)
		if(0 to LIQUID_ANKLES_LEVEL_HEIGHT-1)
			group_overlay_state = LIQUID_STATE_PUDDLE
		if(LIQUID_ANKLES_LEVEL_HEIGHT to LIQUID_WAIST_LEVEL_HEIGHT-1)
			group_overlay_state = LIQUID_STATE_ANKLES
		if(LIQUID_WAIST_LEVEL_HEIGHT to LIQUID_SHOULDERS_LEVEL_HEIGHT-1)
			group_overlay_state = LIQUID_STATE_WAIST
		if(LIQUID_SHOULDERS_LEVEL_HEIGHT to LIQUID_FULLTILE_LEVEL_HEIGHT-1)
			group_overlay_state = LIQUID_STATE_SHOULDERS
		if(LIQUID_FULLTILE_LEVEL_HEIGHT to INFINITY)
			group_overlay_state = LIQUID_STATE_FULLTILE
	if(old_overlay != group_overlay_state)
		for(var/turf/member in members)
			member.liquids.set_new_liquid_state(group_overlay_state)
			member.liquid_height = expected_turf_height + member.turf_height

/datum/liquid_group/proc/process_turf_disperse()
	if(!total_reagent_volume)
		for(var/turf/member in members)
			remove_from_group(member)
			qdel(member.liquids)
		return

	var/list/removed_turf = list()
	var/recursion_sanity = 0
	while(reagents_per_turf < 5 && recursion_sanity <= 200)
		recursion_sanity++
		if(members && members.len)
			var/turf/picked_turf = pick(members)
			if(picked_turf.liquids)
				remove_from_group(picked_turf)
				qdel(picked_turf.liquids)
				removed_turf |= picked_turf
				if(!total_reagent_volume)
					reagents_per_turf = 0
				else
					reagents_per_turf = total_reagent_volume / length(members)
			else
				members -= picked_turf

	while(removed_turf.len)
		var/turf/picked_turf = pick(removed_turf)
		var/list/output = try_split(picked_turf, TRUE)
		removed_turf -= picked_turf
		for(var/turf/outputted_turf in output)
			if(outputted_turf in removed_turf)
				removed_turf -= outputted_turf

///currently shelved while this gets reworked
/datum/liquid_group/proc/handle_group_temperature_shift()
	var/turf/open/picked_turf = pick(members)
	var/datum/gas_mixture/math_cache = picked_turf.air
	if(!math_cache)
		return //we may or may not lose some air processing
	var/increaser =((math_cache.return_temperature() * math_cache.total_moles()) + (group_temperature * total_reagent_volume)) / (2 + total_reagent_volume + math_cache.total_moles())

	for(var/turf/member in members)
		var/turf/open/member_open = member
		var/datum/gas_mixture/gas = member_open.air
		if(gas)
			if(gas.return_temperature() > group_temperature)
				if(increaser > group_temperature + 3)
					gas.set_temperature(increaser)
					group_temperature = increaser
					gas.react()
			else if(group_temperature > gas.return_temperature())
				if(increaser > gas.return_temperature() + 3)
					group_temperature = increaser
					gas.set_temperature(increaser)
					gas.react()

///REAGENT ADD/REMOVAL HANDLING
/datum/liquid_group/proc/check_liquid_removal(obj/effect/abstract/liquid_turf/remover, amount)
	if(amount >= reagents_per_turf)
		remove_from_group(remover.my_turf)
		var/turf/remover_turf = remover.my_turf
		qdel(remover)
		try_split(remover_turf)

		for(var/dir in GLOB.cardinals)
			var/turf/open/open_turf = get_step(remover_turf, dir)
			if(!isopenturf(open_turf) || !open_turf.liquids)
				continue
			check_edges(open_turf)
	process_group()

/datum/liquid_group/proc/remove_any(obj/effect/abstract/liquid_turf/remover, amount)
	reagents.remove_any(amount, TRUE)
	if(remover)
		check_liquid_removal(remover, amount)
	updated_total = TRUE
	total_reagent_volume = reagents.total_volume
	reagents_per_turf = total_reagent_volume / members.len
	expected_turf_height = CEILING(reagents_per_turf, 1) / LIQUID_HEIGHT_DIVISOR
	if(!total_reagent_volume && !reagents.total_volume)
		remove_all()
		qdel(src)

/datum/liquid_group/proc/remove_specific(obj/effect/abstract/liquid_turf/remover, amount, datum/reagent/reagent_type)
	reagents.remove_reagent(reagent_type.type, amount, no_react = TRUE)
	if(remover)
		check_liquid_removal(remover, amount)
	updated_total = TRUE
	total_reagent_volume = reagents.total_volume

/datum/liquid_group/proc/transfer_to_atom(obj/effect/abstract/liquid_turf/remover, amount, atom/transfer_target, transfer_method = INGEST)
	reagents.trans_to(transfer_target, amount, method = transfer_method)
	if(remover)
		check_liquid_removal(remover, amount)
	updated_total = TRUE
	total_reagent_volume = reagents.total_volume

/datum/liquid_group/proc/move_liquid_group(obj/effect/abstract/liquid_turf/member)
	remove_from_group(member.my_turf)
	member.liquid_group = new(1, member)
	var/remove_amount = reagents_per_turf / length(reagents.reagent_list)
	for(var/datum/reagent/reagent_type in reagents.reagent_list)
		member.liquid_group.reagents.add_reagent(reagent_type, remove_amount, no_react = TRUE)
		remove_specific(amount = remove_amount, reagent_type = reagent_type)

/datum/liquid_group/proc/add_reagents(obj/effect/abstract/liquid_turf/member, reagent_list, chem_temp)
	reagents.add_reagent_list(reagent_list, no_react = TRUE)

	var/amount = 0
	for(var/list_item in reagent_list)
		amount += reagent_list[list_item]
	handle_temperature(amount, chem_temp)
	handle_visual_changes()
	process_group()

/datum/liquid_group/proc/add_reagent(obj/effect/abstract/liquid_turf/member, datum/reagent/reagent, amount, temperature)
	reagents.add_reagent(reagent, amount, temperature, no_react = TRUE)

	handle_temperature(amount, temperature)
	handle_visual_changes()
	process_group()

/datum/liquid_group/proc/transfer_reagents_to_secondary_group(obj/effect/abstract/liquid_turf/member, obj/effect/abstract/liquid_turf/transfer)
	var/total_removed = length(members) + 1 / total_reagent_volume
	var/remove_amount = total_removed / length(reagents.reagent_list)
	if(!transfer)
		transfer = new()
	if(!transfer.liquid_group)
		transfer.liquid_group = new(1, transfer)
	for(var/datum/reagent/reagent_type in reagents.reagent_list)
		transfer.liquid_group.reagents.add_reagent(reagent_type.type, remove_amount, no_react = TRUE)
		remove_specific(amount = remove_amount, reagent_type = reagent_type)
		total_removed += remove_amount
	check_liquid_removal(member, total_removed)
	handle_visual_changes()
	process_group()

/datum/liquid_group/proc/trans_to_seperate_group(datum/reagents/secondary_reagent, amount, obj/effect/abstract/liquid_turf/remover, merge = FALSE)
	reagents.trans_to(secondary_reagent, amount)
	if(remover)
		check_liquid_removal(remover, amount)
	else if(!merge)
		process_removal(amount)

	handle_visual_changes()

/datum/liquid_group/proc/process_removal(amount)

	total_reagent_volume = reagents.total_volume
	if(total_reagent_volume)
		reagents_per_turf = total_reagent_volume / length(members)
	else
		reagents_per_turf = 0
	process_turf_disperse()
	process_group()

/datum/liquid_group/proc/handle_temperature(previous_reagents, temp)
	var/baseline_temperature = ((total_reagent_volume * group_temperature) + (previous_reagents * temp)) / (total_reagent_volume + previous_reagents)
	group_temperature = baseline_temperature
	reagents.chem_temp = group_temperature

/datum/liquid_group/proc/handle_visual_changes()
	var/new_color
	var/old_color = group_color

	if(GLOB.liquid_debug_colors)
		new_color = color
	else if(cached_reagent_list.len != reagents.reagent_list.len)
		new_color = mix_color_from_reagent_list(reagents.reagent_list)
		cached_reagent_list = list()
		cached_reagent_list |= reagents.reagent_list

	var/alpha_setting = 1
	var/alpha_divisor = 1

	for(var/r in reagents.reagent_list)
		var/datum/reagent/R = r
		alpha_setting += max((R.opacity * R.volume), 1)
		alpha_divisor += max((1 * R.volume), 1)

	var/old_alpha = group_alpha
	if(new_color == old_color && group_alpha == old_alpha || !new_color)
		return
	group_alpha = clamp(round(alpha_setting / alpha_divisor, 1), 120, 255)
	group_color = new_color
	for(var/turf/member in members)
		member.liquids.alpha = group_alpha
		member.liquids.color = group_color

///Fire Related Procs / Handling

/datum/liquid_group/proc/get_group_burn()
	var/total_burn_power = 0
	var/total_burn_rate = 0
	for(var/datum/reagent/reagent_type in reagents.reagent_list)
		var/burn_power = initial(reagent_type.liquid_fire_power)
		if(burn_power)
			total_burn_power += burn_power * reagent_type.volume
			total_burn_rate += burn_power
	group_burn_rate = total_burn_rate * 0.5 //half power because reasons
	if(!total_burn_power)
		if(burning_members.len)
			extinguish_all()
		group_burn_power = 0
		return

	total_burn_power /= reagents.total_volume //We get burn power per unit.
	if(total_burn_power <= REQUIRED_FIRE_POWER_PER_UNIT)
		return FALSE
	//Finally, we burn
	var/old_burn = group_burn_power

	group_burn_power = total_burn_power

	if(old_burn == group_burn_power)
		return
	switch(group_burn_power)
		if(0 to 7)
			group_fire_state = LIQUID_FIRE_STATE_SMALL
		if(7 to 8)
			group_fire_state = LIQUID_FIRE_STATE_MILD
		if(8 to 9)
			group_fire_state = LIQUID_FIRE_STATE_MEDIUM
		if(9 to 10)
			group_fire_state = LIQUID_FIRE_STATE_HUGE
		if(10 to INFINITY)
			group_fire_state = LIQUID_FIRE_STATE_INFERNO

/datum/liquid_group/proc/process_fire()
	get_group_burn()

	var/reagents_to_remove = group_burn_rate * (burning_members.len)

	if(!group_burn_power)
		extinguish_all()
		return

	remove_any(amount = reagents_to_remove)

	if(group_burn_rate >= reagents_per_turf * 0.2)
		var/list/removed_turf = list()
		for(var/num = 1, num < (burning_members.len * 0.2), num++)
			var/turf/picked_turf = burning_members[1]
			extinguish(picked_turf)
			remove_from_group(picked_turf)
			qdel(picked_turf.liquids)
			removed_turf |= picked_turf


		for(var/turf/remover in removed_turf)
			for(var/dir in GLOB.cardinals)
				var/turf/open/open_turf = get_step(remover, dir)
				if(!isopenturf(open_turf) || !open_turf.liquids)
					continue
				check_edges(open_turf)

		while(removed_turf.len)
			var/turf/picked_turf = pick(removed_turf)
			var/list/output = try_split(picked_turf, TRUE)
			removed_turf -= picked_turf
			for(var/turf/outputted_turf in output)
				if(outputted_turf in removed_turf)
					removed_turf -= outputted_turf


/datum/liquid_group/proc/ignite_turf(turf/member)
	get_group_burn()
	if(!group_burn_power)
		return

	member.liquids.fire_state = group_fire_state
	member.liquids.set_fire_effect()
	burning_members |= member
	SSliquids.burning_turfs |= member

/datum/liquid_group/proc/build_fire_cache(turf/burning_member)
	cached_fire_spreads |= burning_member
	var/list/directions = list(NORTH, SOUTH, EAST, WEST)
	var/list/spreading_turfs = list()
	for(var/dir in directions)
		var/turf/open/open_adjacent = get_step(burning_member, dir)
		if(!open_adjacent || !open_adjacent.liquids)
			continue
		spreading_turfs |= open_adjacent

	cached_fire_spreads[burning_member] = spreading_turfs

/datum/liquid_group/proc/process_spread(turf/member)
	if(member.liquids.fire_state <= LIQUID_FIRE_STATE_MEDIUM) // fires to small to worth spreading
		return

	if(!cached_fire_spreads[member])
		build_fire_cache(member)

	for(var/turf/open/adjacent_turf in cached_fire_spreads[member])
		if(adjacent_turf.liquids && adjacent_turf.liquids.liquid_group == src && adjacent_turf.liquids.fire_state < member.liquids.fire_state)
			adjacent_turf.liquids.fire_state = group_fire_state
			member.liquids.set_fire_effect()
			burning_members |= adjacent_turf
			SSliquids.burning_turfs |= adjacent_turf
			for(var/atom/movable/movable in adjacent_turf)
				movable.fire_act((T20C+50) + (50*adjacent_turf.liquids.fire_state), 125)

/datum/liquid_group/proc/extinguish_all()
	group_burn_power = 0
	group_fire_state = LIQUID_FIRE_STATE_NONE
	for(var/turf/member in burning_members)
		member.liquids.fire_state = LIQUID_FIRE_STATE_NONE
		member.liquids.set_fire_effect()
		if(burning_members[member])
			burning_members -= member
		if(SSliquids.burning_turfs[member])
			SSliquids.burning_turfs -= member

/datum/liquid_group/proc/extinguish(turf/member)
	if(SSliquids.burning_turfs[member])
		SSliquids.burning_turfs -= member
	burning_members -= member
	if(!member.liquids)
		return
	member.liquids.fire_state = LIQUID_FIRE_STATE_NONE
	member.liquids.set_fire_effect()

///EDGE COLLECTION AND PROCESSING

/datum/liquid_group/proc/check_adjacency(turf/member)
	var/adjacent_liquid = 0
	for(var/tur in member.GetAtmosAdjacentTurfs())
		var/turf/adjacent_turf = tur
		if(adjacent_turf.liquids)
			if(adjacent_turf.liquids.liquid_group == member.liquids.liquid_group)
				adjacent_liquid++
	if(adjacent_liquid < 2)
		return FALSE
	return TRUE

/datum/liquid_group/proc/process_cached_edges()
	for(var/turf/cached_turf in cached_edge_turfs)
		for(var/direction in cached_edge_turfs[cached_turf])
			var/turf/directional_turf = get_step(cached_turf, direction)
			if(isclosedturf(directional_turf))
				continue
			if(spread_liquid(directional_turf, cached_turf))
				cached_edge_turfs[cached_turf] -= direction
				if(!length(cached_edge_turfs[cached_turf]))
					cached_edge_turfs -= cached_turf

/datum/liquid_group/proc/check_edges(turf/checker)
	var/list/passed_directions = list()
	for(var/direction in GLOB.cardinals)
		var/turf/directional_turf = get_step(checker, direction)
		if(directional_turf.liquids)
			continue
		passed_directions.Add(direction)

	if(length(passed_directions))
		cached_edge_turfs |= checker
		cached_edge_turfs[checker] = passed_directions



///SPLITING PROCS AND RETURNING CONNECTED PROCS

/*okay for large groups we need some way to iterate over it without grinding the server to a halt to split them
* A breadth-first search or depth first search, are the most efficent but still cause issues with larger groups
* the easist way around this would be using an index of visted turfs and comparing it for changes to save cycles
* this has the draw back of being multiple times slower on small groups, but massively faster on large groups
* For a unique key the easist way to do so would be either to retrive its member number, or better its position
* key as that will be totally unique. this can be used for things aside from splitting by sucking up large groups
*/

/datum/liquid_group/proc/return_connected_liquids(obj/effect/abstract/liquid_turf/source, adjacent_checks = 0)
	var/temporary_split_key = source.temporary_split_key
	var/turf/first_turf = source.my_turf
	var/list/connected_liquids = list()
	///the current queue
	var/list/queued_liquids = list(source)
	///the turfs that we have previously visited with unique ids
	var/list/previously_visited = list()
	///the turf object the liquid resides on
	var/turf/queued_turf

	var/obj/effect/abstract/liquid_turf/current_head
	///compares after each iteration to see if we even need to continue
	var/visited_length = 0
	while(queued_liquids.len)
		current_head = queued_liquids[1]
		queued_turf = current_head.my_turf
		queued_liquids -= current_head

		for(var/turf/adjacent_turf in get_adjacent_open_turfs(queued_turf))
			if(!adjacent_turf.liquids || !members[adjacent_turf])
				continue
			if(!(adjacent_turf in queued_turf.atmos_adjacent_turfs)) //i hate that this is needed
				continue
			visited_length = length(previously_visited)
			previously_visited["[adjacent_turf.liquids.x]_[adjacent_turf.liquids.y]"] = adjacent_turf.liquids
			if(length(previously_visited) != visited_length)
				queued_liquids |= adjacent_turf.liquids
				connected_liquids |= adjacent_turf
				if(adjacent_checks)
					if(temporary_split_key == adjacent_turf.liquids.temporary_split_key && adjacent_turf != first_turf)
						adjacent_checks--
						if(adjacent_checks <= 0)
							return FALSE

	return connected_liquids

/datum/liquid_group/proc/return_connected_liquids_in_range(obj/effect/abstract/liquid_turf/source, total_turfs = 0)
	var/list/connected_liquids = list()
	///the current queue
	var/list/queued_liquids = list(source)
	///the turfs that we have previously visited with unique ids
	var/list/previously_visited = list()
	///the turf object the liquid resides on
	var/turf/queued_turf

	var/obj/effect/abstract/liquid_turf/current_head
	///compares after each iteration to see if we even need to continue
	var/visited_length = 0
	while(queued_liquids.len)
		current_head = queued_liquids[1]
		queued_turf = current_head.my_turf
		queued_liquids -= current_head

		for(var/turf/adjacent_turf in get_adjacent_open_turfs(queued_turf))
			if(!adjacent_turf.liquids || !members[adjacent_turf])
				continue

			visited_length = length(previously_visited)
			previously_visited["[adjacent_turf.liquids.x]_[adjacent_turf.liquids.y]"] = adjacent_turf.liquids
			if(length(previously_visited) != visited_length)
				queued_liquids |= adjacent_turf.liquids
				connected_liquids |= adjacent_turf
				if(total_turfs > 0 && length(connected_liquids) >= total_turfs)
					return connected_liquids


/datum/liquid_group/proc/try_split(turf/source, return_list = FALSE)
	var/list/connected_liquids = list()

	var/turf/head_turf = source
	var/obj/effect/abstract/liquid_turf/current_head

	var/generated_key = "[world.time]_activemembers[members.len]"
	var/adjacent_liquid_count = 0
	for(var/turf/adjacent_turf in get_adjacent_open_turfs(head_turf))
		if(!adjacent_turf.liquids || !members[adjacent_turf]) //empty turf or not our group just skip this
			continue
		///the section is a little funky, as if say a cross shaped liquid removal occurs this will leave 3 of them in the same group, not a big deal as this only affects turfs that are like 5 tiles total
		current_head = adjacent_turf.liquids
		current_head.temporary_split_key = generated_key
		adjacent_liquid_count++

	if(adjacent_liquid_count <= 1) ///if there is only 1 adjacent liquid it physically can't split
		return FALSE

	if(current_head)
		connected_liquids = return_connected_liquids(current_head, adjacent_liquid_count)

	if(!length(connected_liquids) || connected_liquids.len == members.len) //yes yes i know if two groups are identical in size this will break but fixing this would add to much processing
		if(return_list)
			return connected_liquids
		return FALSE

	var/amount_to_transfer = length(connected_liquids) * reagents_per_turf

	members -= connected_liquids
	var/datum/liquid_group/new_group = new(1)
	new_group.members += connected_liquids

	for(var/turf/connected_liquid in connected_liquids)
		new_group.check_edges(connected_liquid)

		if(connected_liquid in burning_members)
			new_group.burning_members |= connected_liquid
		remove_from_group(connected_liquid, TRUE)
		new_group.add_to_group(connected_liquid)

	trans_to_seperate_group(new_group.reagents, amount_to_transfer)
	new_group.total_reagent_volume = new_group.reagents.total_volume
	new_group.reagents_per_turf = new_group.total_reagent_volume / length(new_group.members)

	///asses the group to see if it should exist
	var/new_group_length = length(new_group.members)
	if(new_group.total_reagent_volume == 0 || new_group.reagents_per_turf == 0 || !new_group_length)
		qdel(new_group)
		return FALSE
	for(var/turf/new_turf in new_group.members)
		if(new_turf in members)
			new_group.members -= new_turf

	if(!new_group.members.len)
		qdel(new_group)
		return FALSE

	if(return_list)
		return connected_liquids

	return TRUE

///EXPOSURE AND SPREADING
/datum/liquid_group/proc/expose_members_turf(obj/effect/abstract/liquid_turf/member)
	var/turf/members_turf = member.my_turf
	var/datum/reagents/exposed_reagents = new(1000)
	var/list/passed_list = list()
	for(var/reagent_type in reagents.reagent_list)
		var/amount = reagents.reagent_list[reagent_type] / members
		if(!amount)
			continue
		remove_specific(src, amount * 0.2, reagent_type)
		passed_list[reagent_type] = amount

	exposed_reagents.add_reagent_list(passed_list, no_react = TRUE)
	exposed_reagents.chem_temp = group_temperature

	for(var/atom/movable/target_atom in members_turf)
		exposed_reagents.reaction(target_atom, TOUCH, liquid = TRUE)
	qdel(exposed_reagents)

/datum/liquid_group/proc/expose_atom(atom/target, modifier = 0, method)
	var/datum/reagents/exposed_reagents = new(1000)
	var/list/passed_list = list()
	for(var/reagent_type in reagents.reagent_list)
		var/amount = reagents.reagent_list[reagent_type] / members
		if(!amount)
			continue
		passed_list[reagent_type] = amount

	exposed_reagents.add_reagent_list(passed_list, no_react = TRUE)
	exposed_reagents.chem_temp = group_temperature

	if(modifier)
		exposed_reagents.remove_any((exposed_reagents.total_volume * modifier))

	exposed_reagents.reaction(target, method, liquid = TRUE)

/datum/liquid_group/proc/spread_liquid(turf/new_turf, turf/source_turf)
	if(isclosedturf(new_turf) || !source_turf.atmos_adjacent_turfs)
		return
	if(!(new_turf in source_turf.atmos_adjacent_turfs)) //i hate that this is needed
		return
	if(!source_turf.atmos_adjacent_turfs[new_turf])
		return

	if(new_turf.allow_z_travel)
		var/turf/Z_turf_below = SSmapping.get_turf_below(new_turf)
		if(!Z_turf_below)
			return
		if(isspaceturf(Z_turf_below))
			return FALSE
		if(!Z_turf_below.liquids)
			Z_turf_below.liquids = new(Z_turf_below)
		if(!source_turf.liquids)
			remove_from_group(source_turf)
			if(source_turf in cached_edge_turfs)
				cached_edge_turfs -= source_turf
			return FALSE
		source_turf.liquids.liquid_group.transfer_reagents_to_secondary_group(source_turf.liquids, Z_turf_below.liquids)

		var/obj/splashy = new /obj/effect/temp_visual/liquid_splash(Z_turf_below)
		if(Z_turf_below.liquids.liquid_group)
			splashy.color = Z_turf_below.liquids.liquid_group.group_color
		return FALSE

	if(!new_turf.liquids && !istype(new_turf, /turf/open/openspace) && !isspaceturf(new_turf) && !istype(new_turf, /turf/open/floor/plating/ocean) && source_turf.turf_height == new_turf.turf_height) // no space turfs, or oceans turfs, also don't attempt to spread onto a turf that already has liquids wastes processing time
		if(reagents_per_turf < LIQUID_HEIGHT_DIVISOR)
			return FALSE
		if(!length(members))
			return FALSE
		reagents_per_turf = total_reagent_volume / members.len
		expected_turf_height = CEILING(reagents_per_turf, 1) / LIQUID_HEIGHT_DIVISOR
		new_turf.liquids = new(new_turf, src)
		new_turf.liquids.alpha = group_alpha
		check_edges(new_turf)

		var/obj/splashy = new /obj/effect/temp_visual/liquid_splash(new_turf)
		if(new_turf.liquids.liquid_group)
			splashy.color = new_turf.liquids.liquid_group.group_color

		water_rush(new_turf, source_turf)

	else if(new_turf.liquids && new_turf.liquids.liquid_group && new_turf.liquids.liquid_group != source_turf.liquids.liquid_group && source_turf.turf_height == new_turf.turf_height)
		merge_group(new_turf.liquids.liquid_group)
		return FALSE
	else if(source_turf.turf_height != new_turf.turf_height)
		if(new_turf.turf_height < source_turf.turf_height) // your going down
			if(!new_turf.liquids)
				new_turf.liquids = new(new_turf)
			if(new_turf.turf_height + new_turf.liquids.liquid_group.expected_turf_height < source_turf.turf_height)
				var/obj/effect/abstract/liquid_turf/turf_liquids = new_turf.liquids
				trans_to_seperate_group(turf_liquids.liquid_group.reagents, reagents_per_turf, source_turf)
				turf_liquids.liquid_group.process_group()
		else if(source_turf.turf_height < new_turf.turf_height)
			if(source_turf.turf_height + expected_turf_height < new_turf.turf_height)
				return
			if(!new_turf.liquids)
				new_turf.liquids = new(new_turf)
			var/obj/effect/abstract/liquid_turf/turf_liquids = new_turf.liquids
			trans_to_seperate_group(turf_liquids.liquid_group.reagents, 10, source_turf) //overflows out
			turf_liquids.liquid_group.process_group()

	return TRUE

/datum/liquid_group/proc/water_rush(turf/new_turf, turf/source_turf)
	var/direction = get_dir(source_turf, new_turf)
	for(var/atom/movable/target_atom in new_turf)
		if(!target_atom.anchored && !target_atom.pulledby && !isobserver(target_atom) && (target_atom.move_resist < INFINITY))
			reagents.reaction(target_atom, TOUCH, (reagents_per_turf * 0.5))
			if(expected_turf_height < LIQUID_ANKLES_LEVEL_HEIGHT)
				return
			step(target_atom, direction)
			if(isliving(target_atom) && prob(60))
				var/mob/living/target_living = target_atom
				target_living.Paralyze(6 SECONDS)
				to_chat(target_living, span_danger("You are knocked down by the currents!"))

/datum/liquid_group/proc/fetch_temperature_queue()
	if(!cached_temperature_shift)
		return list()

	var/list/returned =  list()
	for(var/tur in members)
		var/turf/open/member = tur
		returned |= member

	return returned

/datum/liquid_group/proc/act_on_queue(turf/member)
	var/turf/open/member_open = member
	var/datum/gas_mixture/gas = member_open.air
	if(!gas)
		return

	if((cached_temperature_shift > group_temperature + 5) || cached_temperature_shift > gas.return_temperature() + 5 || gas.return_temperature() + 5  > cached_temperature_shift || group_temperature + 5 > cached_temperature_shift)
		gas.set_temperature(cached_temperature_shift)
		if(group_temperature != cached_temperature_shift)
			group_temperature = cached_temperature_shift
