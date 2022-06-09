/datum/status_effect/water_affected
	id = "wateraffected"
	alert_type = null
	duration = -1

/datum/status_effect/water_affected/on_apply()
	//We should be inside a liquid turf if this is applied
	calculate_water_slow()
	return TRUE

/datum/status_effect/water_affected/proc/calculate_water_slow()
	//Factor in swimming skill here?
	var/turf/T = get_turf(owner)
	var/slowdown_amount = T.liquids.liquid_state * 0.5
	owner.add_or_update_variable_actionspeed_modifier(/datum/movespeed_modifier/status_effect/water_slowdown, TRUE, 100, multiplicative_slowdown = slowdown_amount)
/datum/status_effect/water_affected/tick()
	var/turf/T = get_turf(owner)
	if(!T || !T.liquids || T.liquids.liquid_state == LIQUID_STATE_PUDDLE)
		qdel(src)
		return
	calculate_water_slow()
	//Make the reagents touch the person
	var/fraction = SUBMERGEMENT_PERCENT(owner, T.liquids)
	var/datum/reagents/tempr = T.liquids.simulate_reagents_flat(SUBMERGEMENT_REAGENTS_TOUCH_AMOUNT*fraction)
	tempr.reaction(owner, TOUCH)

	tempr.trans_to(owner, ((SUBMERGEMENT_REAGENTS_TOUCH_AMOUNT*fraction/20)), transfered_by = owner)
	for(var/liquids in T.liquids.reagent_list)
		T.liquids.reagent_list[liquids] -= (SUBMERGEMENT_REAGENTS_TOUCH_AMOUNT*fraction)/20
		T.liquids.total_reagents -= (SUBMERGEMENT_REAGENTS_TOUCH_AMOUNT*fraction)/20
		if(T.liquids.reagent_list[liquids] <= 0)
			T.liquids.reagent_list.Remove(liquids)
	var/new_height = CEILING(T.liquids.total_reagents, 1)/LIQUID_HEIGHT_DIVISOR
	T.liquids.set_height(new_height)

	qdel(tempr)
	return ..()

/datum/status_effect/water_affected/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/water_slowdown)

/datum/movespeed_modifier/status_effect/water_slowdown
