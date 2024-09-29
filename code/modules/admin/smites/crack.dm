// Crack a bone.
/datum/smite/crack
	name = "Crack"

/datum/smite/crack/effect(client/user, mob/living/target)
	. = ..()
	if(!iscarbon(target))
		to_chat(usr,"<span class='warning'>This must be used on a carbon mob.</span>", confidential = TRUE)
		return
	var/mob/living/carbon/C = target
	for(var/obj/item/bodypart/squish_part in C.bodyparts)
		var/type_wound = pick(list(/datum/wound/brute/bone/critical, /datum/wound/brute/bone/severe, /datum/wound/brute/bone/critical, /datum/wound/brute/bone/severe, /datum/wound/brute/bone/moderate))
		squish_part.force_wound_upwards(type_wound, smited=TRUE)
