/datum/objective/survival_of_the_fittest
	name = "survival of the fittest"
	explanation_text = "Exfiltrate the station while culling the population of humanoids; ensuring that at most %GOAL% non-changeling humanoids escape on board the escape shuttle."
	martyr_compatible = FALSE
	murderbone_flag = TRUE
	var/amount = 0

/datum/objective/survival_of_the_fittest/proc/generate_amount()
	amount = ceil(max(SSjob.initial_players_to_assign * 0.7, 4))
	update_explanation_text()

/datum/objective/survival_of_the_fittest/update_explanation_text()
	. = ..()
	explanation_text = replacetext(initial(explanation_text), "%GOAL%", amount)

/datum/objective/survival_of_the_fittest/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return ..()
	var/total_survivors = 0
	for(var/mob/living/player in GLOB.player_list)
		if(!player.mind)
			continue
		if(player.stat == DEAD)
			continue
		if (!ishuman(player))
			continue
		if(!SSshuttle.emergency.shuttle_areas[get_area(player)])
			continue
		if (IS_CHANGELING(player))
			continue
		if (player.mind in get_owners())
			continue
		total_survivors++
	return (total_survivors <= amount) || ..()
