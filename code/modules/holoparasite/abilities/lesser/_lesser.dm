/datum/holoparasite_ability/lesser/Destroy()
	if(master_stats && (src in master_stats.lesser_abilities))
		master_stats.lesser_abilities -= src
	return ..()
