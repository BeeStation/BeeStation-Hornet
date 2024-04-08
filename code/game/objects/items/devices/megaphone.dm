/obj/item/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon = 'icons/obj/device.dmi'
	icon_state = "megaphone"
	item_state = "megaphone"
	lefthand_file = 'icons/mob/inhands/misc/megaphone_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/megaphone_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	var/spamcheck = 0
	var/list/voicespan = list(SPAN_MEGAPHONE)
	var/cooldown = 5 SECONDS

/obj/item/megaphone/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is uttering [user.p_their()] last words into \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	spamcheck = 0//so they dont have to worry about recharging
	user.say("AAAAAAAAAAAARGHHHHH", forced="megaphone suicide")//he must have died while coding this
	return OXYLOSS

/obj/item/megaphone/equipped(mob/M, slot)
	. = ..()
	if (slot == ITEM_SLOT_HANDS)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/megaphone/dropped(mob/M)
	..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/megaphone/proc/handle_speech(mob/living/carbon/user, list/speech_args)
	SIGNAL_HANDLER

	if (user.get_active_held_item() == src)
		if(spamcheck > world.time)
			to_chat(user, "<span class='warning'>\The [src] needs to recharge!</span>")
		else
			playsound(loc, 'sound/items/megaphone.ogg', 100, 0, 1)
			spamcheck = world.time + cooldown
			speech_args[SPEECH_SPANS] |= voicespan

/obj/item/megaphone/on_emag(mob/user)
	..()
	to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
	voicespan = list(SPAN_REALLYBIG, "userdanger")

/obj/item/megaphone/sec
	name = "security megaphone"
	icon_state = "megaphone-sec"
	item_state = "megaphone-sec"

/obj/item/megaphone/command
	name = "command megaphone"
	icon_state = "megaphone-command"
	item_state = "megaphone-command"

/obj/item/megaphone/cargo
	name = "supply megaphone"
	icon_state = "megaphone-cargo"
	item_state = "megaphone-cargo"

/obj/item/megaphone/clown
	name = "clown's megaphone"
	desc = "Something that should not exist."
	icon_state = "megaphone-clown"
	item_state = "megaphone-clown"
	voicespan = list(SPAN_CLOWN)

/obj/item/megaphone/nospam
	cooldown = 2 MINUTES // So it can be varedited if needed
	var/list/charges_list = list()
	var/maximum_charge = 5 //So it can be varedited too

/obj/item/megaphone/nospam/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/megaphone/nospam/process(delta_time)
	var/current_index = length(charges_list)
	while(current_index > 0)
		if(charges_list[current_index] < world.time)
			charges_list.Cut(current_index, current_index+1)
		current_index--
	return

/obj/item/megaphone/nospam/handle_speech(mob/living/carbon/user, list/speech_args)
	if (user.get_active_held_item() != src)
		return
	if(length(charges_list) < maximum_charge)
		charges_list.Add(world.time + cooldown)
		playsound(loc, 'sound/items/megaphone.ogg', 100, 0, 1)
		speech_args[SPEECH_SPANS] |= voicespan
	else
		to_chat(user, "<span class='warning'>You neeed to wait a bit before you can use [src] again!</span>")

/obj/item/megaphone/nospam/examine(mob/user)
	. = ..()
	var/charges = maximum_charge - length(charges_list)
	switch(charges)
		if(2 to INFINITY)
			. += "<span class='notice'>It has [charges] charges remaining.</span>"
		if(1)
			. += "<span class='notice'>It has [charges] charge remaining.</span>"
		if(-INFINITY to 0)
			. += "<span class='warning'>It needs to recharge!</span>"

/obj/item/megaphone/nospam/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()
