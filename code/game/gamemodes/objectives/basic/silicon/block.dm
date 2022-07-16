/datum/objective/block
	name = "no organics on shuttle"
	explanation_text = "Do not allow any organic lifeforms to escape on the shuttle alive."
	martyr_compatible = 1

/datum/objective/block/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return TRUE
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind && player.stat != DEAD && !issilicon(player))
			if(get_area(player) in SSshuttle.emergency.shuttle_areas)
				return ..()
	return TRUE
