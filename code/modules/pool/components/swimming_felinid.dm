/datum/component/swimming/felinid //felinids don't like swimming
	positive_moodlet = FALSE

/datum/component/swimming/felinid/enter_pool()
	var/mob/living/L = parent
	L.emote("scream")
	to_chat(parent, "<span class='userdanger'>You get covered in water and start panicking!</span>")
	SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "was_stuck_in_pool")
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "stuck_in_pool", /datum/mood_event/stuck_in_pool)

/datum/component/swimming/felinid/exit_pool()
	var/mob/living/L = parent
	SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "stuck_in_pool")
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "was_stuck_in_pool", /datum/mood_event/was_stuck_in_pool)

/datum/component/swimming/felinid/process()
	..()
	var/mob/living/L = parent
	var/obj/item/pool/helditem = L.get_active_held_item()
	if(istype(helditem) && ISWIELDED(helditem))
		return
	switch(rand(1, 100))
		if(1 to 4)
			to_chat(parent, "<span class='userdanger'>You can't touch the bottom!</span>")
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
			to_chat(parent, "<span class='userdanger'>You feel like you are never going to get out...</span>")
		if(15 to 17)
			L.emote("cry")
		else
			SWITCH_EMPTY_STATEMENT
