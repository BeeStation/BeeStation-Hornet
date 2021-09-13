/datum/brain_trauma/special/imaginary_friend/mrat
	name = "Epistemania"
	desc = "Patient suffers from a manic pursuit of knowlewdge."
	scan_desc = "epistemania"
	gain_text = "<span class='notice'>Requesting mentor...</span>"
	lose_text = ""
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/special/imaginary_friend/mrat/make_friend()
	friend = new /mob/camera/imaginary_friend/mrat(get_turf(owner), src)

/datum/brain_trauma/special/imaginary_friend/mrat/get_ghost()
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = pollMentorCandidatesForMob("Do you want to play as [owner]'s mentor rat?", ROLE_PAI, null, null, 75, friend, POLL_IGNORE_IMAGINARYFRIEND)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		friend.key = C.key
		friend.real_name = friend.key
		friend.name = friend.real_name
		
		var/mob/camera/imaginary_friend/mrat/I = friend
		I.Costume()
					
		friend_initialized = TRUE
		to_chat(owner, "<span class='notice'>You have acquired the mentor rat [friend.key], ask them any question you like. They will leave your presence when they are done.</span>")
	else
		to_chat(owner, "<span class='warning'>No mentor responded to your request. Try again later.</span>")
		qdel(src)

/mob/camera/imaginary_friend/mrat
	name = "Mentor Rat"
	real_name = "Mentor Rat"
	desc = "Your personal mentor assistant."

	var/datum/action/innate/mrat_costume/costume
	var/datum/action/innate/mrat_leave/leave
	var/list/icons_available = list()
	var/current_costume = FALSE

/mob/camera/imaginary_friend/mrat/proc/update_available_icons()
	icons_available = list()

	icons_available += list("Mouse" = image(icon = 'icons/mob/animal.dmi', icon_state = "mouse_white"))
	icons_available += list("Moonrat" = image(icon = 'icons/mob/pets.dmi', icon_state = "moonrat"))
	icons_available += list("Hologram" = image(icon = 'icons/mob/ai.dmi', icon_state = "default"))
	icons_available += list("Spaceman" = image(icon = 'icons/mob/animal.dmi', icon_state = "old"))
	icons_available += list("Bee" = image(icon = 'icons/mob/animal.dmi', icon_state = "bee_1"))

/mob/camera/imaginary_friend/mrat/proc/Costume()
	update_available_icons()
	if(icons_available)
		var/selection = show_radial_menu(src, src, icons_available, radius = 38)
		if(!selection)
			return
		
		current_costume = selection

		switch(selection)
			if("Mouse")
				human_image = icon('icons/mob/animal.dmi', icon_state = "mouse_white")
				color = "#1ABC9C"
				Show()
			if("Corgi")
				human_image = icon('icons/mob/pets.dmi', icon_state = "corgi")
				color = "#1ABC9C"
				Show()
			if("Hologram")
				human_image = icon('icons/mob/ai.dmi', icon_state = "default")
				color = "#1ABC9C"
				Show()
			if("Spaceman")
				human_image = icon('icons/mob/animal.dmi', icon_state = "old")
				color = null
				Show()
			if("Bee")
				human_image = icon('icons/mob/animal.dmi', icon_state = "bee_1")
				color = "#1ABC9C"
				Show()

/mob/camera/imaginary_friend/mrat/friend_talk()
	. = ..()
	if(!current_costume)
		return
	switch(current_costume)
		if("Mouse")
			SEND_SOUND(owner, sound('sound/effects/mousesqueek.ogg'))
			SEND_SOUND(src, sound('sound/effects/mousesqueek.ogg'))
		if("Corgi")
			SEND_SOUND(owner, sound('sound/machines/uplinkpurchase.ogg'))
			SEND_SOUND(src, sound('sound/machines/uplinkpurchase.ogg'))
		if("Hologram")
			SEND_SOUND(owner, sound('sound/machines/ping.ogg'))
			SEND_SOUND(src, sound('sound/machines/ping.ogg'))
		if("Spaceman")
			SEND_SOUND(owner, sound('sound/machines/buzz-sigh.ogg'))
			SEND_SOUND(src, sound('sound/machines/buzz-sigh.ogg'))
		if("Bee")
			SEND_SOUND(owner, sound('sound/creatures/bee.ogg'))
			SEND_SOUND(src, sound('sound/creatures/bee.ogg'))

/mob/camera/imaginary_friend/mrat/greet()
	to_chat(src, "<span class='notice'><b>You are the mentor rat of [owner]!</b></span>")
	to_chat(src, "<span class='notice'>Do not give [owner] any OOC information from your time as a ghost.</span>")
	to_chat(src, "<span class='notice'>Your job is to answer [owner]'s question(s) and you are given this form to assist in that.</span>")
	to_chat(src, "<span class='notice'>Don't be stupid with this or you will face the consequences.</span>")

/mob/camera/imaginary_friend/mrat/Initialize(mapload, _trauma)
	. = ..()
	costume = new
	costume.Grant(src)
	leave = new
	leave.Grant(src)

/mob/camera/imaginary_friend/mrat/setup_friend()
	human_image = null

/datum/action/innate/mrat_costume
	name = "Change Appearance"
	desc = "Shape your appearance to whatever you desire."
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "ninja_phase"

/datum/action/innate/mrat_costume/Activate()
	var/mob/camera/imaginary_friend/mrat/I = owner
	I.Costume()

/datum/action/innate/mrat_leave
	name = "Leave"
	desc = "Leave and return to your ghost form."
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "beam_up"

/datum/action/innate/mrat_leave/Activate()
	var/mob/camera/imaginary_friend/I = owner
	to_chat(I, "<span class='warning'>You have ejected yourself from [I.owner].</span>")
	to_chat(I.owner, "<span class='warning'>Your mentor has left.</span>")
	qdel(I.trauma)

/mob/camera/imaginary_friend/mrat/pointed(atom/A as mob|obj|turf in view())
	if(!..())
		return FALSE
	to_chat(owner, "<b>[src]</b> points at [A].")
	to_chat(src, "<span class='notice'>You point at [A].</span>")
	return TRUE