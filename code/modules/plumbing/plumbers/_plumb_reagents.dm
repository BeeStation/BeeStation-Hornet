/**
 * Specialized reagent container for plumbing. Uses the round robin approach of transferring reagents
 * so transfer 5 from 15 water, 15 sugar and 15 plasma becomes 10, 15, 15 instead of 13.3333, 13.3333 13.3333. Good if you hate floating point errors
 */
/datum/reagents/plumbing

/**
 * Same as the parent trans_to except only a few arguments have impact here & the rest of the arguments are discarded.
 * Arguments
 *
 * * atom/target - the target we are transfering to
 * * amount - amount to transfer
 * * datum/reagent/target_id - the reagent id we want to transfer. if null everything gets transfered
 * * methods - this is key for deciding between round-robin or proportional transfer. It does not mean the same as the
 * parent proc. LINEAR for round robin(in this technique reagents are missing/lost/not preserved when there isn't enough space to hold them)
 * NONE means everything is transfered regardless of how much space is available in the receiver in proportions
 */
/datum/reagents/plumbing/trans_to(
	atom/target,
	amount = 1,
	multiplier = 1, //unused for plumbing
	datum/reagent/target_id,
	preserve_data = TRUE, //unused for plumbing
	no_react = FALSE, //unused for plumbing we always want reactions
	mob/transferred_by, //unused for plumbing logging is not important inside plumbing machines
	remove_blacklisted = FALSE, //unused for plumbing, we don't care what reagents are inside us
	methods = LINEAR, //default round robin technique for transferring reagents
	show_message = TRUE, //unused for plumbing, used for logging only
	ignore_stomach = FALSE, //unused for plumbing, reagents flow only between machines & is not injected to mobs at any point in time
	copy_only = FALSE //unused
)
	if(QDELETED(target) || !total_volume)
		return FALSE

	if(!IS_FINITE(amount))
		stack_trace("non finite amount passed to trans_to [amount] amount of reagents")
		return FALSE

	if(!isnull(target_id) && !ispath(target_id))
		stack_trace("invalid target reagent id [target_id] passed to trans_to")
		return FALSE

	var/datum/reagents/target_holder
	if(istype(target, /datum/reagents))
		target_holder = target
	else
		target_holder = target.reagents

	// Prevents small amount problems, as well as zero and below zero amounts.
	amount = round(min(amount, total_volume, target_holder.maximum_volume - target_holder.total_volume), CHEMICAL_QUANTISATION_LEVEL)
	if(amount <= 0)
		return FALSE

	var/list/cached_reagents = reagent_list
	var/transfer_amount
	var/transfered_amount
	var/total_transfered_amount = 0

	var/round_robin = methods & LINEAR
	var/part
	var/to_transfer
	if(round_robin)
		to_transfer = amount
	else
		part = amount / total_volume

	//first add reagents to target
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(round_robin && !to_transfer)
			break

		if(!isnull(target_id))
			if(reagent.type == target_id)
				transfer_amount = min(amount, reagent.volume)
			else
				continue
		else
			if(round_robin)
				transfer_amount = min(to_transfer, reagent.volume)
			else
				transfer_amount = reagent.volume * part

		if(reagent.intercept_reagents_transfer(target_holder, transfer_amount))
			continue

		transfered_amount = target_holder.add_reagent(reagent.type, transfer_amount, copy_data(reagent), chem_temp, no_react = TRUE) //we only handle reaction after every reagent has been transferred.
		if(!transfered_amount)
			continue
		total_transfered_amount += transfered_amount
		if(round_robin)
			to_transfer -= transfered_amount
		reagent.volume -= transfered_amount

		if(!isnull(target_id))
			break
	update_total()
	target_holder.handle_reactions()

	return total_transfered_amount
