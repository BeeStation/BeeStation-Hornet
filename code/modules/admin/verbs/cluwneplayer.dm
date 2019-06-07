/mob/living/proc/cluwne()
	for(var/obj/item/W in src)  // they drop everything they have
		if(!dropItemToGround(W))
			qdel(W)
			regenerate_icons()

	var/datum/mind/M = mind

	var/mob/living/simple_animal/cluwne/newmob =  new(get_turf(src))

	if (client)
		SSmedals.UnlockMedal(MEDAL_GET_CLUWNED,client)

	M.transfer_to(newmob)
	if(key)  // afk (no mind)
		newmob.key = key

	var/msg = "\n\n\n\n\nYour mind is ripped apart like threads in fabric, everything you've ever known is gone.\n"
	msg += "There is only the <b><i>Honkmother</i></b> now.\n"
	msg += "Honk!\n"
	to_chat(M, msg)

	qdel(src)
