//TODO: Add an indicator when buffs are 'on' - Racc
/datum/plant_need/reagent/buff
	buff = TRUE

/datum/plant_need/reagent/buff/check_need(_delta_time)
	. = ..()
//Reverse buff
	if(buff_applied || debuff)
		remove_buff(_delta_time)
		buff_applied = FALSE
//Flight checks
	if(!. && COOLDOWN_FINISHED(src, nectar_timer))
		return
	if(buff_applied)
		return
//Apply buff
	apply_buff(_delta_time)
	buff_applied = TRUE
