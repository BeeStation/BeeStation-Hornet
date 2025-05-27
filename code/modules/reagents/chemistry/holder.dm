/proc/build_chemical_reagent_list()
	//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id

	if(GLOB.chemical_reagents_list)
		return

	var/paths = subtypesof(/datum/reagent)
	GLOB.chemical_reagents_list = list()

	for(var/path in paths)
		var/datum/reagent/D = new path()
		GLOB.chemical_reagents_list[path] = D

/proc/build_chemical_reactions_list()
	//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
	// It is filtered into multiple lists within a list.
	// For example:
	// chemical_reactions_list_reactant_index[/datum/reagent/toxin/plasma] is a list of all reactions relating to plasma

	if(GLOB.chemical_reactions_list_reactant_index)
		return

	var/paths = subtypesof(/datum/chemical_reaction)
	GLOB.chemical_reactions_list = list() //typepath to reaction list
	GLOB.chemical_reactions_list_reactant_index = list() //reagents to reaction list

	for(var/path in paths)
		var/datum/chemical_reaction/D = new path()
		var/list/reaction_ids = list()
		var/list/reagents = list()

		if(!D.required_reagents || !D.required_reagents.len) //Skip impossible reactions
			continue

		GLOB.chemical_reactions_list[path] = D

		for(var/reaction in D.required_reagents)
			reaction_ids += reaction
			var/datum/reagent/reagent = find_reagent_object_from_type(reaction)
			if(!istype(reagent))
				stack_trace("Invalid reagent found in [D] required_reagents: [reaction]")
				continue
			reagents += list(list("name" = reagent.name, "id" = reagent.type))

		for(var/product in D.results)
			var/datum/reagent/reagent = find_reagent_object_from_type(product)
			if(!istype(reagent))
				stack_trace("Invalid reagent found in [D] results: [product]")
				continue

		// Create filters based on each reagent id in the required reagents list
		for(var/id in reaction_ids)
			if(!GLOB.chemical_reactions_list_reactant_index[id])
				GLOB.chemical_reactions_list_reactant_index[id] = list()
			GLOB.chemical_reactions_list_reactant_index[id] += D
			break // Don't bother adding ourselves to other reagent ids, it is redundant

///////////////////////////////////////////////////////////////////////////////////

/// Holder for a bunch of [/datum/reagent]
/datum/reagents
	/// The reagents being held
	var/list/datum/reagent/reagent_list = new/list()
	/// Current volume of all the reagents
	var/total_volume = 0
	/// Max volume of this holder
	var/maximum_volume = 100
	/// The atom this holder is attached to
	var/atom/my_atom = null
	/// Current temp of the holder volume
	var/chem_temp = 150
	/// unused
	var/last_tick = 1
	/// see [/datum/reagents/proc/metabolize] for usage
	var/addiction_tick = 1
	/// currently addicted reagents
	var/list/datum/reagent/addiction_list = new/list()
	/// various flags, see code\__DEFINES\reagents.dm
	var/flags

/datum/reagents/New(maximum=100, new_flags=0)
	maximum_volume = maximum

	//I dislike having these here but map-objects are initialised before world/New() is called. >_>
	if(!GLOB.chemical_reagents_list)
		build_chemical_reagent_list()
	if(!GLOB.chemical_reactions_list)
		build_chemical_reactions_list()

	flags = new_flags

/datum/reagents/Destroy()
	. = ..()
	//We're about to delete all reagents, so lets cleanup
	addiction_list.Cut()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		qdel(R)
	cached_reagents.Cut()
	cached_reagents = null
	if(my_atom?.reagents == src)
		my_atom.reagents = null
	my_atom = null

/**
 * Adds a reagent to this holder
 *
 * Arguments:
 * * reagent - The reagent id to add
 * * amount - Amount to add
 * * list/data - Any reagent data for this reagent, used for transferring data with reagents
 * * reagtemp - Temperature of this reagent, will be equalized
 * * no_react - prevents reactions being triggered by this addition
 */
/datum/reagents/proc/add_reagent(datum/reagent/reagent, amount, list/data=null, reagtemp = DEFAULT_REAGENT_TEMPERATURE, no_react = 0)

	if(!ispath(reagent))
		stack_trace("invalid reagent passed to add reagent [reagent]")
		return FALSE

	if(!isnum_safe(amount) || !amount)
		return FALSE

	// Prevents small amount problems, as well as zero and below zero amounts.
	if(amount <= CHEMICAL_QUANTISATION_LEVEL)
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_REAGENTS_PRE_ADD_REAGENT, reagent, amount, reagtemp, data, no_react) & COMPONENT_CANCEL_REAGENT_ADD)
		return FALSE

	var/datum/reagent/glob_reagent = GLOB.chemical_reagents_list[reagent]
	if(!glob_reagent)
		stack_trace("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")
		return FALSE

	update_total()
	var/cached_total = total_volume
	if(cached_total + amount > maximum_volume)
		amount = (maximum_volume - cached_total) //Doesnt fit in. Make it disappear. shouldn't happen. Will happen.
		if(amount <= 0)
			return FALSE

	var/cached_temp = chem_temp
	var/list/cached_reagents = reagent_list

	//Equalize temperature - Not using specific_heat() because the new chemical isn't in yet.
	var/old_heat_capacity = 0
	if(reagtemp != cached_temp)
		for(var/datum/reagent/iter_reagent as anything in cached_reagents)
			old_heat_capacity += iter_reagent.specific_heat * iter_reagent.volume

	//add the reagent to the existing if it exists
	for(var/datum/reagent/iter_reagent as anything in cached_reagents)
		if (iter_reagent.type == reagent)
			iter_reagent.volume += amount
			update_total()

			iter_reagent.on_merge(data, amount)
			if(reagtemp != cached_temp)
				set_temperature(((old_heat_capacity * cached_temp) + (iter_reagent.specific_heat * amount * reagtemp)) / heat_capacity())

			SEND_SIGNAL(src, COMSIG_REAGENTS_ADD_REAGENT, iter_reagent, amount, reagtemp, data, no_react)
			if(!no_react)
				handle_reactions()
			return TRUE

	//otherwise make a new one
	var/datum/reagent/new_reagent = new reagent(data)
	cached_reagents += new_reagent
	new_reagent.holder = src
	new_reagent.volume = amount
	new_reagent.on_new(data)

	if(isliving(my_atom))
		new_reagent.on_mob_add(my_atom) //Must occur before it could posibly run on_mob_delete

	update_total()
	if(reagtemp != cached_temp)
		set_temperature(((old_heat_capacity * cached_temp) + (new_reagent.specific_heat * amount * reagtemp)) / heat_capacity())

	SEND_SIGNAL(src, COMSIG_REAGENTS_NEW_REAGENT, new_reagent, amount, reagtemp, data, no_react)
	if(!no_react)
		handle_reactions()
	return TRUE

/**
 * Like add_reagent but you can enter a list.
 * Arguments
 *
 * * [list_reagents][list] - list to add. Format it like this: list(/datum/reagent/toxin = 10, "beer" = 15)
 * * [data][list] - additional data to add
 */
/datum/reagents/proc/add_reagent_list(list/list_reagents, list/data = null)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
		add_reagent(r_id, amt, data)

/**
 * Removes a specific reagent. can supress reactions if needed
 * Arguments
 *
 * * [reagent][datum/reagent] - the type of reagent
 * * amount - the volume to remove
 * * safety - if FALSE will initiate reactions upon removing. used for trans_id_to
 */
/datum/reagents/proc/remove_reagent(datum/reagent/reagent, amount, safety)
	if(!ispath(reagent))
		stack_trace("invalid reagent passed to remove reagent [reagent]")
		return FALSE

	if(isnull(amount))
		amount = 0
		CRASH("null amount passed to reagent code")

	if(!isnum_safe(amount))
		return FALSE

	if(amount < 0)
		return FALSE

	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/cached_reagent as anything in cached_reagents)
		if (cached_reagent.type == reagent)
			//clamp the removal amount to be between current reagent amount
			//and zero, to prevent removing more than the holder has stored
			amount = clamp(amount, 0, cached_reagent.volume)
			cached_reagent.volume -= amount
			update_total()
			SEND_SIGNAL(src, COMSIG_REAGENTS_REM_REAGENT, QDELING(cached_reagent) ? reagent : cached_reagent, amount)
			if(!safety)//So it does not handle reactions when it need not to
				handle_reactions()

			return TRUE

	return FALSE

/// Remove an amount of reagents without caring about what they are
/datum/reagents/proc/remove_any(amount = 1)
	var/list/cached_reagents = reagent_list
	var/total_removed = 0
	var/current_list_element = 1
	var/initial_list_length = cached_reagents.len //stored here because removing can cause some reagents to be deleted, ergo length change.

	current_list_element = rand(1, cached_reagents.len)

	while(total_removed != amount)
		if(total_removed >= amount)
			break
		if(total_volume <= 0 || !cached_reagents.len)
			break

		if(current_list_element > cached_reagents.len)
			current_list_element = 1

		var/datum/reagent/R = cached_reagents[current_list_element]
		var/remove_amt = min(amount-total_removed,round(amount/rand(2,initial_list_length),round(amount/10,0.01))) //double round to keep it at a somewhat even spread relative to amount without getting funky numbers.
		//min ensures we don't go over amount.
		remove_reagent(R.type, remove_amt)

		current_list_element++
		total_removed += remove_amt
		update_total()

	handle_reactions()
	return total_removed //this should be amount unless the loop is prematurely broken, in which case it'll be lower. It shouldn't ever go OVER amount.

/// Removes all reagents from this holder
/datum/reagents/proc/remove_all(amount = 1)
	var/list/cached_reagents = reagent_list
	if(total_volume > 0)
		var/part = amount / total_volume
		for(var/datum/reagent/reagent as anything in cached_reagents)
			remove_reagent(reagent.type, reagent.volume * part)

		update_total()
		handle_reactions()
		return amount

/datum/reagents/proc/remove_all_type(reagent_type, amount, strict = 0, safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
	if(!ispath(reagent_type))
		stack_trace("invalid reagent path passed to remove all type [reagent_type]")
		return FALSE

	if(!isnum_safe(amount))
		return 1
	var/list/cached_reagents = reagent_list
	var/has_removed_reagent = 0

	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		var/matches = 0
		// Switch between how we check the reagent type
		if(strict)
			if(R.type == reagent_type)
				matches = 1
		else
			if(istype(R, reagent_type))
				matches = 1
		// We found a match, proceed to remove the reagent.	Keep looping, we might find other reagents of the same type.
		if(matches)
			// Have our other proc handle removement
			has_removed_reagent = remove_reagent(R.type, amount, safety)

	return has_removed_reagent

/**
 * Removes an specific reagent from this holder
 * Arguments
 *
 * * [reagent][datum/reagent] - type typepath of the reagent to remove
 */
/datum/reagents/proc/del_reagent(datum/reagent/reagent)
	if(!ispath(reagent))
		stack_trace("invalid reagent path passed to del reagent [reagent]")
		return FALSE

	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if(R.type == reagent)
			var/mob/living/mob_consumer

			if (isliving(my_atom))
				mob_consumer = my_atom
			else if (istype(my_atom, /obj/item/organ))
				var/obj/item/organ/organ = my_atom
				mob_consumer = organ.owner

			if (mob_consumer)
				if(R.metabolizing)
					R.metabolizing = FALSE
					R.on_mob_end_metabolize(mob_consumer)
				R.on_mob_delete(mob_consumer)

			//Clear from relevant lists
			addiction_list -= R
			reagent_list -= R
			qdel(R)
			update_total()
			SEND_SIGNAL(src, COMSIG_REAGENTS_DEL_REAGENT, reagent)
	return TRUE

/// Remove every reagent except this one
/datum/reagents/proc/isolate_reagent(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if(R.type != reagent)
			del_reagent(R.type)
			update_total()

/// Removes all reagents
/datum/reagents/proc/clear_reagents()
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/reagent as anything in cached_reagents)
		del_reagent(reagent.type)
	SEND_SIGNAL(src, COMSIG_REAGENTS_CLEAR_REAGENTS)

/**
 * Check if this holder contains this reagent.
 * Reagent takes a PATH to a reagent.
 * Amount checks for having a specific amount of that chemical.
 * Needs metabolizing takes into consideration if the chemical is metabolizing when it's checked.
 */
/datum/reagents/proc/has_reagent(datum/reagent/target_reagent, amount = -1, needs_metabolizing = FALSE)
	if(!ispath(target_reagent))
		stack_trace("invalid reagent path passed to has reagent [target_reagent]")
		return FALSE

	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/holder_reagent as anything in cached_reagents)
		if (holder_reagent.type == target_reagent)
			if(!amount)
				if(needs_metabolizing && !holder_reagent.metabolizing)
					return FALSE
				return holder_reagent
			else
				if(FLOOR(holder_reagent.volume, CHEMICAL_QUANTISATION_LEVEL) >= amount)
					if(needs_metabolizing && !holder_reagent.metabolizing)
						return FALSE
					return holder_reagent

	return FALSE

/**
  * Transfer some stuff from this holder to a target object
  *
  * Arguments:
  * * obj/target - Target to attempt transfer to
  * * amount - amount of reagent volume to transfer
  * * multiplier - multiplies amount of each reagent by this number
  * * preserve_data - if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
  * * no_react - passed through to [/datum/reagents/proc/add_reagent]
  * * mob/transfered_by - used for logging
  * * remove_blacklisted - skips transferring of reagents with can_synth = FALSE
  * * methods - passed through to [/datum/reagents/proc/expose_single] and [/datum/reagent/proc/on_transfer]
  * * show_message - passed through to [/datum/reagents/proc/expose_single]
  * * round_robin - if round_robin=TRUE, so transfer 5 from 15 water, 15 sugar and 15 plasma becomes 10, 15, 15 instead of 13.3333, 13.3333 13.3333. Good if you hate floating point errors
  */
/datum/reagents/proc/trans_to(obj/target, amount = 1, multiplier = 1, preserve_data = TRUE, no_react = FALSE, mob/transfered_by, remove_blacklisted = FALSE, methods = NONE, show_message = TRUE, round_robin = FALSE)
	var/list/cached_reagents = reagent_list
	if(!target || !total_volume)
		return
	if(amount < 0)
		return

	var/atom/target_atom
	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
		target_atom = R.my_atom
	else
		if(!target.reagents)
			return
		R = target.reagents
		target_atom = target

	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/trans_data = null
	var/transfer_log = list()
	if(!round_robin)
		var/part = amount / src.total_volume
		for(var/reagent in cached_reagents)
			var/datum/reagent/T = reagent
			if(remove_blacklisted && (T.chem_flags & CHEMICAL_NOT_SYNTH))
				continue
			var/transfer_amount = T.volume * part
			if(preserve_data)
				trans_data = copy_data(T)
			if(!R.add_reagent(T.type, transfer_amount * multiplier, trans_data, chem_temp, no_react = TRUE)) //we only handle reaction after every reagent has been transfered.
				continue
			if(methods)
				R.expose_single(T, target_atom, methods, part, show_message)
				T.on_transfer(target_atom, methods, transfer_amount * multiplier)
			remove_reagent(T.type, transfer_amount)
			transfer_log[T.type] = transfer_amount
	else
		var/to_transfer = amount
		for(var/reagent in cached_reagents)
			if(!to_transfer)
				break
			var/datum/reagent/T = reagent
			if(remove_blacklisted && (T.chem_flags & CHEMICAL_NOT_SYNTH))
				continue
			if(preserve_data)
				trans_data = copy_data(T)
			var/transfer_amount = amount
			if(amount > T.volume)
				transfer_amount = T.volume
			if(!R.add_reagent(T.type, transfer_amount * multiplier, trans_data, chem_temp, no_react = TRUE)) //we only handle reaction after every reagent has been transfered.
				continue
			to_transfer = max(to_transfer - transfer_amount , 0)
			if(methods)
				R.expose_single(T, target_atom, methods, transfer_amount, show_message)
				T.on_transfer(target_atom, methods, transfer_amount * multiplier)
			remove_reagent(T.type, transfer_amount)
			transfer_log[T.type] = transfer_amount

	if(transfered_by && target_atom)
		target_atom.add_hiddenprint(transfered_by) //log prints so admins can figure out who touched it last.
		log_combat(transfered_by, target_atom, "transferred reagents ([log_list(transfer_log)]) from [my_atom] to")

	update_total()
	R.update_total()
	if(!no_react)
		R.handle_reactions()
		src.handle_reactions()
	return amount

/// Transfer a specific reagent id to the target object
/datum/reagents/proc/trans_id_to(obj/target, reagent, amount=1, preserve_data=1)//Not sure why this proc didn't exist before. It does now! /N
	var/list/cached_reagents = reagent_list
	if (!target)
		return
	if (!target.reagents || src.total_volume<=0 || !src.get_reagent_amount(reagent))
		return
	if(amount < 0)
		return

	var/datum/reagents/R = target.reagents
	if(src.get_reagent_amount(reagent)<amount)
		amount = src.get_reagent_amount(reagent)
	amount = min(amount, R.maximum_volume-R.total_volume)
	var/trans_data = null
	for (var/CR in cached_reagents)
		var/datum/reagent/current_reagent = CR
		if(current_reagent.type == reagent)
			if(preserve_data)
				trans_data = current_reagent.data
			R.add_reagent(current_reagent.type, amount, trans_data, src.chem_temp)
			remove_reagent(current_reagent.type, amount, 1)
			break

	src.update_total()
	R.update_total()
	R.handle_reactions()
	return amount

/// Copies the reagents to the target object
/datum/reagents/proc/copy_to(obj/target, amount=1, multiplier=1, preserve_data=1)
	var/list/cached_reagents = reagent_list
	if(!target || !total_volume)
		return

	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
	else
		if(!target.reagents)
			return
		R = target.reagents

	if(amount < 0)
		return
	amount = min(min(amount, total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / total_volume
	var/trans_data = null
	for(var/reagent in cached_reagents)
		var/datum/reagent/T = reagent
		var/copy_amount = T.volume * part
		if(preserve_data)
			trans_data = T.data
		R.add_reagent(T.type, copy_amount * multiplier, trans_data, chem_temp)

	src.update_total()
	R.update_total()
	R.handle_reactions()
	src.handle_reactions()
	return amount

/// Multiplies the reagents inside this holder by a specific amount
/datum/reagents/proc/multiply_reagents(multiplier=1)
	var/list/cached_reagents = reagent_list
	if(!total_volume)
		return
	var/change = (multiplier - 1) //Get the % change
	for(var/reagent in cached_reagents)
		var/datum/reagent/T = reagent
		if(change > 0)
			add_reagent(T.type, T.volume * change)
		else
			remove_reagent(T.type, abs(T.volume * change)) //absolute value to prevent a double negative situation (removing -50% would be adding 50%)

	update_total()
	handle_reactions()

/// Get the name of the reagent there is the most of in this holder
/datum/reagents/proc/get_master_reagent_name()
	var/list/cached_reagents = reagent_list
	var/name
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			name = R.name

	return name

/// Get the id of the reagent there is the most of in this holder
/datum/reagents/proc/get_master_reagent_id()
	var/list/cached_reagents = reagent_list
	var/max_type
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			max_type = R.type

	return max_type

/// Get a reference to the reagent there is the most of in this holder
/datum/reagents/proc/get_master_reagent()
	var/list/cached_reagents = reagent_list
	var/datum/reagent/master
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			master = R

	return master

/**
  * Triggers metabolizing the reagents in this holder
  *
  * Arguments:
  * * mob/living/carbon/C - The mob to metabolize in, if null it uses [/datum/reagents/var/my_atom]
  * * can_overdose - Allows overdosing
  * * liverless - Stops reagents that aren't set as [/datum/reagent/var/self_consuming] from metabolizing
  */
/datum/reagents/proc/metabolize(mob/living/carbon/owner, delta_time, times_fired, can_overdose = FALSE, liverless = FALSE)
	if(owner?.dna?.species && (NOREAGENTS in owner.dna.species.species_traits))
		return 0
	var/list/cached_reagents = reagent_list
	var/list/cached_addictions = addiction_list
	if(owner)
		expose_temperature(owner.bodytemperature, 0.25)
	var/need_mob_update = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(QDELETED(R.holder))
			continue

		if(!owner)
			owner = R.holder.my_atom

		if(owner && R)
			if(owner.reagent_check(R, delta_time, times_fired) != TRUE) //Most relevant to Humans, this handles species-specific chem interactions.
				if(liverless && !R.self_consuming) //need to be metabolized
					continue
				if(!R.metabolizing)
					R.metabolizing = TRUE
					R.on_mob_metabolize(owner)
				if(can_overdose)
					if(R.overdose_threshold)
						if(R.volume >= R.overdose_threshold && !R.overdosed)
							R.overdosed = TRUE
							need_mob_update += R.overdose_start(owner)
							log_game("[key_name(owner)] has started overdosing on [R.name] at [R.volume] units.")
					if(R.addiction_threshold)
						if(R.volume >= R.addiction_threshold && !is_type_in_list(R, cached_addictions))
							var/datum/reagent/new_reagent = new R.type()
							cached_addictions.Add(new_reagent)
							log_game("[key_name(owner)] has become addicted to [R.name] at [R.volume] units.")
					if(R.overdosed)
						need_mob_update += R.overdose_process(owner, delta_time, times_fired)
					if(is_type_in_list(R,cached_addictions))
						for(var/addiction in cached_addictions)
							var/datum/reagent/A = addiction
							if(istype(R, A))
								A.addiction_stage = -15 // you're satisfied for a good while.
				need_mob_update += R.on_mob_life(owner, delta_time, times_fired)

	if(can_overdose)
		if(addiction_tick == 6)
			addiction_tick = 1
			for(var/addiction in cached_addictions)
				var/datum/reagent/R = addiction
				if(owner && R)
					R.addiction_stage++
					switch(R.addiction_stage)
						if(1 to 10)
							need_mob_update += R.addiction_act_stage1(owner)
						if(10 to 20)
							need_mob_update += R.addiction_act_stage2(owner)
						if(20 to 30)
							need_mob_update += R.addiction_act_stage3(owner)
						if(30 to 40)
							need_mob_update += R.addiction_act_stage4(owner)
						if(40 to INFINITY)
							remove_addiction(R)
						else
							SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "[R.type]_overdose")
		addiction_tick++
	if(owner && need_mob_update) //some of the metabolized reagents had effects on the mob that requires some updates.
		owner.updatehealth()
		owner.update_stamina()
	update_total()

/// Signals that metabolization has stopped, triggering the end of trait-based effects
/datum/reagents/proc/end_metabolization(mob/living/carbon/C, keep_liverless = TRUE)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(QDELETED(R.holder))
			continue
		if(keep_liverless && R.self_consuming) //Will keep working without a liver
			continue
		if(!C)
			C = R.holder.my_atom
		if(R.metabolizing)
			R.metabolizing = FALSE
			R.on_mob_end_metabolize(C)

/// Removes addiction to a specific reagent on [/datum/reagents/var/my_atom]
/datum/reagents/proc/remove_addiction(datum/reagent/R)
	to_chat(my_atom, "<span class='notice'>You feel like you've gotten over your need for [R.name].</span>")
	SEND_SIGNAL(my_atom, COMSIG_CLEAR_MOOD_EVENT, "[R.type]_overdose")
	LAZYREMOVE(addiction_list, R)
	qdel(R)

/**
  * Calls [/datum/reagent/proc/on_move] on every reagent in this holder
  *
  * Arguments:
  * * atom/A - passed to on_move
  * * Running - passed to on_move
  */
/datum/reagents/proc/conditional_update_move(atom/A, Running = 0)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		R.on_move (A, Running)
	update_total()

/**
  * Calls [/datum/reagent/proc/on_update] on every reagent in this holder
  *
  * Arguments:
  * * atom/A - passed to on_update
  */
/datum/reagents/proc/conditional_update(atom/A)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		R.on_update (A)
	update_total()

/// Handle any reactions possible in this holder
/datum/reagents/proc/handle_reactions()
	if(QDELING(src))
		CRASH("[my_atom] is trying to handle reactions while being flagged for deletion. It presently has [length(reagent_list)] number of reactants in it. If that is over 0 then something terrible happened.")

	if(!length(reagent_list))
		return FALSE

	if(flags & NO_REACT)
		return FALSE //Yup, no reactions here. No siree.

	var/list/cached_reagents = reagent_list
	var/list/cached_reactions = GLOB.chemical_reactions_list_reactant_index
	var/datum/cached_my_atom = my_atom

	. = 0
	var/reaction_occurred
	do
		var/list/possible_reactions = list()
		reaction_occurred = FALSE
		for(var/reagent in cached_reagents)
			var/datum/reagent/R = reagent
			for(var/reaction in cached_reactions[R.type]) // Was a big list but now it should be smaller since we filtered it with our reagent id
				if(!reaction)
					continue

				var/datum/chemical_reaction/C = reaction
				var/list/cached_required_reagents = C.required_reagents
				var/total_required_reagents = cached_required_reagents.len
				var/total_matching_reagents = 0
				var/list/cached_required_catalysts = C.required_catalysts
				var/total_required_catalysts = cached_required_catalysts.len
				var/total_matching_catalysts= 0
				var/matching_container = 0
				var/matching_other = 0
				var/required_temp = C.required_temp
				var/is_cold_recipe = C.is_cold_recipe
				var/meets_temp_requirement = 0

				for(var/B in cached_required_reagents)
					if(!has_reagent(B, cached_required_reagents[B]))
						break
					total_matching_reagents++
				for(var/B in cached_required_catalysts)
					if(!has_reagent(B, cached_required_catalysts[B]))
						break
					total_matching_catalysts++
				if(cached_my_atom)
					if(C.required_container_accepts_subtypes)
						matching_container = !C.required_container || istype(cached_my_atom, C.required_container)
					else
						matching_container = !C.required_container || cached_my_atom.type == C.required_container

					if(isliving(cached_my_atom) && !C.mob_react) //Makes it so certain chemical reactions don't occur in mobs
						matching_container = FALSE

					matching_other = C.required_other ? C.pre_reaction_other_checks(src) : TRUE

					if(C.check_other()) //if a recipe has required_other, call this proc to see if it meets requirements
						matching_other = TRUE
				else
					if(!C.required_container)
						matching_container = TRUE
					if(!C.required_other)
						matching_other = TRUE

				if(required_temp == 0 || (is_cold_recipe && chem_temp <= required_temp) || (!is_cold_recipe && chem_temp >= required_temp))
					meets_temp_requirement = 1

				if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other && meets_temp_requirement && C.can_react(src))
					possible_reactions  += C

		if(possible_reactions.len)
			var/datum/chemical_reaction/selected_reaction = possible_reactions[1]
			//select the reaction with the most extreme temperature requirements
			for(var/V in possible_reactions)
				var/datum/chemical_reaction/competitor = V
				if(selected_reaction.is_cold_recipe) //if there are no recipe conflicts, everything in possible_reactions will have this same value for is_cold_reaction. warranty void if assumption not met.
					if(competitor.required_temp <= selected_reaction.required_temp)
						selected_reaction = competitor
				else
					if(competitor.required_temp >= selected_reaction.required_temp)
						selected_reaction = competitor
			var/list/cached_required_reagents = selected_reaction.required_reagents
			var/list/cached_results = selected_reaction.results
			var/list/multiplier = INFINITY
			for(var/B in cached_required_reagents)
				multiplier = min(multiplier, round(get_reagent_amount(B) / cached_required_reagents[B]))

			for(var/B in cached_required_reagents)
				remove_reagent(B, (multiplier * cached_required_reagents[B]), safety = 1)

			for(var/P in selected_reaction.results)
				multiplier = max(multiplier, 1) //this shouldn't happen ...
				SSblackbox.record_feedback("tally", "chemical_reaction", cached_results[P]*multiplier, P)
				add_reagent(P, cached_results[P]*multiplier, null, chem_temp)

			var/list/seen = viewers(4, get_turf(my_atom))
			var/iconhtml = icon2html(cached_my_atom, seen)
			if(cached_my_atom)
				if(!ismob(cached_my_atom)) // No bubbling mobs
					if(selected_reaction.mix_sound)
						playsound(get_turf(cached_my_atom), selected_reaction.mix_sound, 80, 1)

					for(var/mob/M as() in seen)
						to_chat(M, span_notice("[iconhtml] [selected_reaction.mix_message]"))

				if(istype(cached_my_atom, /obj/item/slime_extract))
					var/obj/item/slime_extract/ME2 = my_atom
					ME2.Uses--
					if(ME2.Uses <= 0) // give the notification that the slime core is dead
						for(var/mob/M as() in seen)
							to_chat(M, span_notice("[iconhtml] \The [my_atom]'s power is consumed in the reaction."))
							ME2.name = "used slime extract"
							ME2.desc = "This extract has been used up."

			selected_reaction.on_reaction(src, multiplier)
			reaction_occurred = TRUE
			.++

	while(reaction_occurred)
	update_total()
	if(.)
		SEND_SIGNAL(src, COMSIG_REAGENTS_REACTED, .)

/// Updates [/datum/reagents/var/total_volume]
/datum/reagents/proc/update_total()
	var/list/cached_reagents = reagent_list
	total_volume = 0
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(reagent.volume < 0.1)
			del_reagent(reagent.type)
		else
			total_volume += reagent.volume

/**
 * Turn one reagent into another, preserving volume, temp
 * Arguments
 *
 * * [source_reagent_typepath][/datum/reagent] - the typepath of the reagent you are trying to convert
 * * [target_reagent_typepath][/datum/reagent] - the final typepath the source_reagent_typepath will be converted into
 * * multiplier - the multiplier applied on the source_reagent_typepath volume before converting
 * * include_source_subtypes- if TRUE will convert all subtypes of source_reagent_typepath into target_reagent_typepath as well
 */
/datum/reagents/proc/convert_reagent(datum/reagent/source_reagent_typepath, datum/reagent/target_reagent_typepath, multiplier = 1, include_source_subtypes = FALSE)
	if(!ispath(source_reagent_typepath))
		stack_trace("invalid reagent path passed to convert reagent [source_reagent_typepath]")
		return FALSE

	var/reagent_amount
	if(include_source_subtypes)
		for(var/datum/reagent/reagent as anything in reagent_list)
			if(reagent.type in typecacheof(source_reagent_typepath))
				reagent_amount += reagent.volume
				remove_reagent(reagent.type, reagent.volume)
	else
		var/datum/reagent/source_reagent = get_reagent(source_reagent_typepath)
		reagent_amount = source_reagent.volume
		remove_reagent(source_reagent_typepath, reagent_amount)
	add_reagent(target_reagent_typepath, reagent_amount * multiplier, reagtemp = chem_temp)

//Checks if the reaction is valid for IPC
/datum/reagents/proc/reaction_check(mob/living/M, datum/reagent/R)
	var/can_process = FALSE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//Check if this mob's species is set and can process this type of reagent
		if(H.dna && H.dna.species.reagent_tag)
			if((R.process_flags & SYNTHETIC) && (H.dna.species.reagent_tag & PROCESS_SYNTHETIC))		//SYNTHETIC-oriented reagents require PROCESS_SYNTHETIC
				can_process = TRUE
			if((R.process_flags & ORGANIC) && (H.dna.species.reagent_tag & PROCESS_ORGANIC))		//ORGANIC-oriented reagents require PROCESS_ORGANIC
				can_process = TRUE
	//We'll assume that non-human mobs lack the ability to process synthetic-oriented reagents (adjust this if we need to change that assumption)
	else
		if(R.process_flags != SYNTHETIC)
			can_process = TRUE
	return can_process

//================================Exposure(to apply reagent effects)======================
/**
 * Applies the relevant expose_ proc for every reagent in this holder
 * * [/datum/reagent/proc/expose_mob]
 * * [/datum/reagent/proc/expose_turf]
 * * [/datum/reagent/proc/expose_obj]
 *
 * Arguments
 * - Atom/target: What mob/turf/object is being exposed to reagents? This is your reaction target.
 * - Method: What reaction type is the reagent itself going to call on the reaction target? Types are TOUCH, INGEST, VAPOR, PATCH, and INJECT.
 * - Volume_modifier: What is the reagent volume multiplied by when exposed? Note that this is called on the volume of EVERY reagent in the base body, so factor in your Maximum_Volume if necessary!
 * - Show_message: Whether to display anything to mobs when they are exposed.
 * -
 */
/datum/reagents/proc/expose(atom/A, methods = TOUCH, volume_modifier = 1, show_message = 1, obj/item/bodypart/affecting)
	if(isnull(A))
		return null

	var/list/cached_reagents = reagent_list
	if(!cached_reagents.len)
		return null

	var/list/reagents = list()
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		reagents[R] = R.volume * volume_modifier

	return A.expose_reagents(reagents, src, methods, volume_modifier, show_message, affecting)

/// Same as [/datum/reagents/proc/expose] but only for one reagent
/datum/reagents/proc/expose_single(datum/reagent/R, atom/A, methods = TOUCH, volume_modifier = 1, show_message = TRUE)
	if(isnull(A))
		return null

	if(ispath(R))
		R = get_reagent(R)
	if(isnull(R))
		return null

	// Yes, we need the parentheses.
	return A.expose_reagents(list((R) = R.volume * volume_modifier), src, methods, volume_modifier, show_message)

/// Is this holder full or not
/datum/reagents/proc/holder_full()
	return total_volume >= maximum_volume

/// Returns the average specific heat for all reagents currently in this holder.
/datum/reagents/proc/specific_heat()
	. = 0
	var/cached_amount = total_volume		//cache amount
	var/list/cached_reagents = reagent_list		//cache reagents
	for(var/I in cached_reagents)
		var/datum/reagent/R = I
		. += R.specific_heat * (R.volume / cached_amount)

/**
 * Get the amount of this reagent or the sum of all its subtypes if specified
 * Arguments
 * * [reagent][datum/reagent] - the typepath of the reagent to look for
 * * include_subtypes - if TRUE returns the sum of volumes of all subtypes of the above param reagent
 */
/datum/reagents/proc/get_reagent_amount(datum/reagent/reagent, include_subtypes = FALSE)
	if(!ispath(reagent))
		stack_trace("invalid path passed to get_reagent_amount [reagent]")
		return 0

	var/list/cached_reagents = reagent_list
	var/total_amount = 0
	for(var/datum/reagent/cached_reagent as anything in cached_reagents)
		if((!include_subtypes && cached_reagent.type == reagent) || (include_subtypes && ispath(cached_reagent.type, reagent)))
			total_amount += FLOOR(cached_reagent.volume, CHEMICAL_QUANTISATION_LEVEL)
	return total_amount

/// Get a comma separated string of every reagent name in this holder. UNUSED
/datum/reagents/proc/get_reagent_names()
	var/list/names = list()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		names += R.name

	return jointext(names, ",")

/// helper function to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/get_data(reagent_id)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.type == reagent_id)
			return R.data

/// helper function to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/set_data(reagent_id, new_data)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.type == reagent_id)
			R.data = new_data

/// Shallow copies (deep copy of viruses) data from the provided reagent into our copy of that reagent
/datum/reagents/proc/copy_data(datum/reagent/current_reagent)
	if(!current_reagent || !current_reagent.data)
		return null
	if(!istype(current_reagent.data, /list))
		return current_reagent.data

	var/list/trans_data = current_reagent.data.Copy()

	// We do this so that introducing a virus to a blood sample
	// doesn't automagically infect all other blood samples from
	// the same donor.
	//
	// Technically we should probably copy all data lists, but
	// that could possibly eat up a lot of memory needlessly
	// if most data lists are read-only.
	if(trans_data["viruses"])
		var/list/v = trans_data["viruses"]
		trans_data["viruses"] = v.Copy()

	return trans_data

/// Get a reference to the reagent if it exists
/datum/reagents/proc/get_reagent(type)
	var/list/cached_reagents = reagent_list
	. = locate(type) in cached_reagents


/**
  * Returns what this holder's reagents taste like
  *
  * Arguments:
  * * minimum_percent - the lower the minimum percent, the more sensitive the message is.
  */
/datum/reagents/proc/generate_taste_message(minimum_percent=15)
	var/list/out = list()
	var/list/tastes = list() //descriptor = strength
	if(minimum_percent <= 100)
		for(var/datum/reagent/R in reagent_list)
			if(!R.taste_mult)
				continue

			if(istype(R, /datum/reagent/consumable/nutriment))
				var/list/taste_data = R.data
				for(var/taste in taste_data)
					var/ratio = taste_data[taste]
					var/amount = ratio * R.taste_mult * R.volume
					if(taste in tastes)
						tastes[taste] += amount
					else
						tastes[taste] = amount
			else
				var/taste_desc = R.taste_description
				var/taste_amount = R.volume * R.taste_mult
				if(taste_desc in tastes)
					tastes[taste_desc] += taste_amount
				else
					tastes[taste_desc] = taste_amount
		//deal with percentages
		// TODO it would be great if we could sort these from strong to weak
		var/total_taste = counterlist_sum(tastes)
		if(total_taste > 0)
			for(var/taste_desc in tastes)
				var/percent = tastes[taste_desc]/total_taste * 100
				if(percent < minimum_percent)
					continue
				var/intensity_desc = "a hint of"
				if(percent > minimum_percent * 2 || percent == 100)
					intensity_desc = ""
				else if(percent > minimum_percent * 3)
					intensity_desc = "the strong flavor of"
				if(intensity_desc != "")
					out += "[intensity_desc] [taste_desc]"
				else
					out += "[taste_desc]"

	return english_list(out, "something indescribable")

/// Returns the total heat capacity for all of the reagents currently in this holder.
/datum/reagents/proc/heat_capacity()
	. = 0
	var/list/cached_reagents = reagent_list //cache reagents
	for(var/I in cached_reagents)
		var/datum/reagent/R = I
		. += R.specific_heat * R.volume

/datum/reagents/proc/adjust_thermal_energy(J, min_temp = 2.7, max_temp = 1000)
	var/S = specific_heat()
	chem_temp = clamp(chem_temp + (J / (S * total_volume)), 2.7, 1000)

/// Applies heat to this holder
/datum/reagents/proc/expose_temperature(var/temperature, var/coeff=0.02)
	var/temp_delta = (temperature - chem_temp) * coeff
	if(temp_delta > 0)
		chem_temp = min(chem_temp + max(temp_delta, 1), temperature)
	else
		chem_temp = max(chem_temp + min(temp_delta, -1), temperature)
	set_temperature(round(chem_temp))
	handle_reactions()

/** Sets the temperature of this reagent container to a new value.
 *
 * Handles setter signals.
 *
 * Arguments:
 * - _temperature: The new temperature value.
 */
/datum/reagents/proc/set_temperature(_temperature)
	if(_temperature == chem_temp)
		return

	. = chem_temp
	chem_temp = _temperature
	SEND_SIGNAL(src, COMSIG_REAGENTS_TEMP_CHANGE, _temperature, .)

/**
  * Used in attack logs for reagents in pills and such
  *
  * Arguments:
  * * external_list - list of reagent types = amounts
  */
/datum/reagents/proc/log_list(external_list)
	if((external_list && !length(external_list)) || !length(reagent_list))
		return "no reagents"

	var/list/data = list()
	if(external_list)
		for(var/r in external_list)
			data += "[r] ([round(external_list[r], 0.1)]u)"
	else
		for(var/r in reagent_list) //no reagents will be left behind
			var/datum/reagent/R = r
			data += "[R.type] ([round(R.volume, 0.1)]u)"
			//Using types because SOME chemicals (I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
	return english_list(data)

///////////////////////////////////////////////////////////////////////////////////


/**
  * Convenience proc to create a reagents holder for an atom
  *
  * Arguments:
  * * max_vol - maximum volume of holder
  * * flags - flags to pass to the holder
  */
/atom/proc/create_reagents(max_vol, flags)
	if(reagents)
		qdel(reagents)
	reagents = new /datum/reagents(max_vol, flags)
	reagents.my_atom = src

/* This proc returns a random reagent ID based on given 'flag_check' which is used to check bitflag for each reagent.
	 *--- arguments ---*
		* flag_check
			the methods will return a random reagent id which has this flag.
			if you want a single category - get_random_reagent_id(CHEMICAL_BASIC_ELEMENT)
			if you want a multiple category - get_random_reagent_id(CHEMICAL_BASIC_ELEMENT|CHEMICAL_BASIC_DRINK|CHEMICAL_RNG_GENERAL)
			(check defines at `code\__DEFINES\reagents.dm`)
		* blacklist_flag
			the methods will remove random reagents from the possible list when they have this flag. default NONE(0)
			same rule above
			(uses chemical defines)
		* union
			default TRUE. if FALSE, the same item will be added to the possible list, making some reagent higher chance to spawn when a reagent is called more than once.
			you will hardly use this though.
			(Bicaridine, Bicardine, Bicaridine means 3x chance than normal.)
		* return_as_list
			default FALSE. if TRUE, the proc will return its list rather than pick a certain ID from the list. Useful when you're going to set blacklist yourself (or add)

	 *--- How to add a new random reagent category ---*
		1. add a new flag at 'code\__DEFINES\reagents.dm' and `var/list/chem_defines` below
			i.e.) `define CHEMICAL_SOMETHING_NEW (1<10)`
		2. add a new static variable which is corresponding to the new flag.
			i.e.) `var/static/list/random_reagents_xx = list() // CHEMICAL_SOMETHING_NEW`
		3. add the new static variable to the 'random_reagent' list
			then done! (of course, don't forget to turn on the new flag at each desired reagent)
*/
/proc/get_random_reagent_id(var/flag_check, var/blacklist_flag = NONE, var/union = TRUE, var/return_as_list = FALSE)


	// ----below is a section you might want to edit for more chem RNGs----
	var/static/list/chem_defines = list( // check `code/__DEFINES/reagents.dm`
		CHEMICAL_NOT_SYNTH,     // (1<<0)
		CHEMICAL_BASIC_ELEMENT, // (1<<1)
		CHEMICAL_BASIC_DRINK,   // (1<<2)
		CHEMICAL_RNG_GENERAL,   // (1<<3)
		CHEMICAL_RNG_FUN,       // (1<<4)
		CHEMICAL_RNG_BOTANY,    // (1<<5)
		CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE,         // (1<<23) - goal_define starts at 23 and goes reversed.
		CHEMICAL_GOAL_BOTANIST_HARVEST,     // (1<<22)
		CHEMICAL_GOAL_BARTENDER_SERVING)    // (1<<21)
	var/static/list/random_reagents_a = list()  // CHEMICAL_NOT_SYNTH
	var/static/list/random_reagents_b = list()  // CHEMICAL_BASIC_ELEMENT
	var/static/list/random_reagents_c = list()  // CHEMICAL_BASIC_DRINK
	var/static/list/random_reagents_d = list()  // CHEMICAL_RNG_GENERAL
	var/static/list/random_reagents_e = list()  // CHEMICAL_RNG_FUN
	var/static/list/random_reagents_f = list()  // CHEMICAL_RNG_BOTANY
	var/static/list/random_reagents_goal_a = list()  // CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	var/static/list/random_reagents_goal_b = list()  // CHEMICAL_GOAL_BOTANIST_HARVEST
	var/static/list/random_reagents_goal_c = list()  // CHEMICAL_GOAL_BARTENDER_SERVING
	var/static/list/random_reagent = list(
		random_reagents_a,
		random_reagents_b,
		random_reagents_c,
		random_reagents_d,
		random_reagents_e,
		random_reagents_f,
		random_reagents_goal_a,
		random_reagents_goal_b,
		random_reagents_goal_c)
	// ----above is a section you might want to edit for more chem RNGs----

	// initialize random reagent static lists
	if(!random_reagents_a.len)
		for(var/thing in subtypesof(/datum/reagent))
			var/i = 0
			for(var/each_define in chem_defines)
				i += 1
				var/datum/reagent/R = thing
				if(initial(R.chem_flags) & each_define)
					random_reagent[i] += R

	// returns a pick from a static before making a list - saving memory
	var/j = 0
	if(!blacklist_flag)
		for(var/each_define in chem_defines)
			j += 1
			if(each_define == flag_check)
				return (return_as_list ? random_reagent[j] : pick(random_reagent[j]))

	// if flag_check has multiple bitflags, then we're going to make a possible list.
	var/list/possible = list()
	j = 0
	for(var/each_define in chem_defines)
		j += 1
		if(each_define & flag_check)
			if(union)
				possible |= random_reagent[j]
			else //concatenation
				possible += random_reagent[j]

	if(blacklist_flag)
		j = 0
		for(var/each_define in chem_defines)
			j += 1
			if(each_define & flag_check)
				possible -= random_reagent[j]

	return (return_as_list ? possible : pick(possible))

/proc/get_chem_id(chem_name)
	for(var/X in GLOB.chemical_reagents_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[X]
		if(ckey(chem_name) == ckey(LOWER_TEXT(R.name)))
			return X
