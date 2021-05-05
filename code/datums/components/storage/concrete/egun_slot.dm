/datum/component/storage/concrete/egun_slot/handle_item_insertion(obj/item/W, prevent_warning = FALSE, mob/living/user)
	var/atom/P = src.parent
	var/list/things = contents()
	var/total_guns = 0
	var/max_guns = 1 //max guns allowed

	if(istype(W, /obj/item/gun/energy))
		for(var/i in things)
			var/obj/item/E = i
			if(istype(E, /obj/item/gun/energy))
				total_guns++
	else
		. = ..()

	if(total_guns >= max_guns) //No more guns allowed
		to_chat(user, "<span class='warning'>You cant fit any more guns into [P]!</span>")
		return
	else
		. = ..()
