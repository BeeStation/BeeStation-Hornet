/datum/component/swimming/felinid/enter_pool()
	var/mob/living/L = parent
	L.emote("scream")
	to_chat(parent, span_userdanger("You get covered in water and start panicking!"))

/datum/component/swimming/felinid/process()
	..()
	var/mob/living/L = parent
	var/obj/item/pool/helditem = L.get_active_held_item()
	if(istype(helditem) && ISWIELDED(helditem))
		return
	switch(rand(1, 100))
		if(1 to 4)
			to_chat(parent, span_userdanger("You can't touch the bottom!"))
			L.emote("scream")
		if(5 to 7)
			if(L.confused < 5)
				L.confused += 1
		if(8 to 12)
			L.Jitter(10)
		if(13 to 14)
			shake_camera(L, 15, 1)
			L.emote("whimper")
			L.Paralyze(10)
			to_chat(parent, span_userdanger("You feel like you are never going to get out..."))
		if(15 to 17)
			L.emote("cry")
		if(18 to 100)
			pass()
