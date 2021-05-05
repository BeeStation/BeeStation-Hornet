/datum/component/storage/concrete/egun_slot
	var/max_guns = 1 //max guns allowed
	var/total_guns
	var/atom/P
	var/list/things

/datum/component/storage/concrete/egun_slot/handle_item_insertion(obj/item/W, prevent_warning = FALSE, mob/living/user)
	total_guns = 0
	P = src.parent
	things = contents()

	if(istype(W, /obj/item/gun/energy)) //do we try to insert energy gun?
		for(var/i in things) //look at every item in the storage
			var/obj/item/E = i

			if(istype(E, /obj/item/gun/energy)) //is there any energy guns in the storage already?
				total_guns++

		if(total_guns >= max_guns) //no space for guns so no more guns allowed
			to_chat(user, "<span class='warning'>You cant fit any more guns into [P]!</span>")
			return

	. = ..()
