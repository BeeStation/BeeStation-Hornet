/// Orders mobs by type then by name. Accepts optional arg to sort a custom list, otherwise copies GLOB.mob_list.
/proc/sortmobs()
	var/list/moblist = list()
	var/list/sortmob = sort_names(GLOB.mob_list)
	for(var/mob/living/silicon/ai/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/camera/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/silicon/pai/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/silicon/robot/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/carbon/human/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/brain/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/carbon/alien/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/dead/observer/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/dead/new_player/authenticated/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/dead/new_player/pre_auth/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/carbon/monkey/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/simple_animal/slime/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/simple_animal/mob_to_sort in sortmob)
		// We've already added slimes.
		if(isslime(mob_to_sort))
			continue
		moblist += mob_to_sort
	for(var/mob/living/basic/mob_to_sort in sortmob)
		moblist += mob_to_sort
	return moblist
