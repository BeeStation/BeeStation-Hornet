/datum/plant_need/reagent
	///What kind of reagents do we need per second - This can be multiple for special cases and punishments, but try to keep it to one
	var/list/reagent_needs = list() // (/datum/reagent = amount, /datum/reagent = amount)
	///Do we consume the reagents we need?
	var/consume_reagents = TRUE
	///What % of reagents met do we need to succeed?
	var/success_threshold = 1 //100%
	var/auto_threshold = FALSE

/datum/plant_need/reagent/New(datum/plant_feature/_parent)
	. = ..()
	success_threshold = auto_threshold ? 1 / length(reagent_needs) : success_threshold
	var/old_desc = need_description
	need_description = "This plant([parent.name]) [buff ? "optionally needs" : "needs"]"
	var/reagent_index = 1
	for(var/datum/reagent/reagent as anything in reagent_needs)
		need_description = "[need_description] [reagent_needs[reagent]]u of [initial(reagent.name)][reagent_index < length(reagent_needs) ? ", " : ""]"
		if(auto_threshold) //Add 'or' to the last option to show you only need 1 of the ingredients
			need_description = "[need_description][reagent_index+1 == length(reagent_needs) ? "or" : ""]"
		reagent_index++
	need_description = "[need_description]\n	'[old_desc]'"

/datum/plant_need/reagent/check_need(_delta_time)
	. = ..()
	if(!parent?.parent)
		return
	var/reagent_hits = 0
	var/list/reagent_holders = list()
	SEND_SIGNAL(parent.parent, COMSIG_PLANT_REQUEST_REAGENTS, reagent_holders, parent)
	if(!length(reagent_holders))
		return FALSE
	for(var/datum/reagents/R as anything in reagent_holders)
		if(!R)
			continue
		for(var/reagent as anything in reagent_needs)
			var/amount_needed = reagent_needs[reagent] * _delta_time
			amount_needed /= COOLDOWN_FINISHED(src, nectar_timer) ? 1 : 2 //Nectar buff halves the amount needed
			if(!R.has_reagent(reagent, amount_needed))
				continue
			if(consume_reagents)
				R.remove_reagent(reagent, amount_needed)
			reagent_hits++
	if(reagent_hits / length(reagent_needs) >= success_threshold)
		return TRUE
	return FALSE

///used to automatically satisfy this need, used for roundstart pot plants
/datum/plant_need/reagent/fufill_need(atom/location)
	. = ..()
	if(!location?.reagents)
		return
	for(var/datum/reagent/reagent as anything in reagent_needs)
		//This essentially gives each reagent an equal % of the volume to occupy. This doesn't handle needs that have different % needs, like (water = 1, blood = 10)
		location.reagents.add_reagent(reagent, location?.reagents.maximum_volume / length(reagent_needs))
