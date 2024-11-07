/datum/objective/polaroid //take a picture of the target with you in it.
	name = "polaroid"

/datum/objective/polaroid/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Take a photo of [target.name] while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/polaroid/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/mind in owners)
		var/mob/living/current = mind.current
		if(!istype(current))
			continue
		for(var/obj/item/photo/photo in current.GetAllContents(/obj/item/photo)) //Check for wanted items
			var/datum/picture/picture = photo.picture
			if(!picture)
				continue
			var/seen_mind_stat = picture.minds_seen[target]
			if(!isnull(seen_mind_stat) && seen_mind_stat != DEAD)
				return TRUE
	return ..()

/datum/objective/polaroid/on_target_cryo()
	qdel(src)
