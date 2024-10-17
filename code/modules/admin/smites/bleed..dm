// Blood for the blood god.
/datum/smite/bleed
	name = "Bleed"

/datum/smite/bleed/effect(client/user, mob/living/target)
	. = ..()
	if(!iscarbon(target))
		to_chat(usr,"<span class='warning'>This must be used on a carbon mob.</span>", confidential = TRUE)
		return
	var/mob/living/carbon/C = target
	for(var/obj/item/bodypart/slice_part in C.bodyparts)
		var/type_wound = pick(list(/datum/wound/brute/cut/severe, /datum/wound/brute/cut/moderate))
		slice_part.force_wound_upwards(type_wound, smited=TRUE)
		type_wound = pick(list(/datum/wound/brute/cut/critical, /datum/wound/brute/cut/severe, /datum/wound/brute/cut/moderate))
		slice_part.force_wound_upwards(type_wound, smited=TRUE)
		type_wound = pick(list(/datum/wound/brute/cut/critical, /datum/wound/brute/cut/severe))
		slice_part.force_wound_upwards(type_wound, smited=TRUE)
