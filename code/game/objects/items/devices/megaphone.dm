/obj/item/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon = 'icons/obj/device.dmi'
	icon_state = "megaphone"
	inhand_icon_state = "megaphone"
	lefthand_file = 'icons/mob/inhands/misc/megaphone_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/megaphone_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	var/spamcheck = 0
	var/list/voicespan = list(SPAN_MEGAPHONE)
	var/cooldown = 5 SECONDS

/obj/item/megaphone/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is uttering [user.p_their()] last words into \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
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
			to_chat(user, span_warning("\The [src] needs to recharge!"))
		else
			playsound(loc, 'sound/items/megaphone.ogg', 100, 0, 1)
			spamcheck = world.time + cooldown
			speech_args[SPEECH_SPANS] |= voicespan

/obj/item/megaphone/on_emag(mob/user)
	..()
	to_chat(user, span_warning("You overload \the [src]'s voice synthesizer."))
	voicespan = list(SPAN_REALLYBIG, "userdanger")

/obj/item/megaphone/sec
	name = "security megaphone"
	icon_state = "megaphone-sec"
	inhand_icon_state = "megaphone-sec"

/obj/item/megaphone/command
	name = "command megaphone"
	icon_state = "megaphone-command"
	inhand_icon_state = "megaphone-command"

/obj/item/megaphone/cargo
	name = "supply megaphone"
	icon_state = "megaphone-cargo"
	inhand_icon_state = "megaphone-cargo"

/obj/item/megaphone/clown
	name = "clown's megaphone"
	desc = "Something that should not exist."
	icon_state = "megaphone-clown"
	inhand_icon_state = "megaphone-clown"
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
		to_chat(user, span_warning("You neeed to wait a bit before you can use [src] again!"))

/obj/item/megaphone/nospam/examine(mob/user)
	. = ..()
	var/charges = maximum_charge - length(charges_list)
	switch(charges)
		if(2 to INFINITY)
			. += span_notice("It has [charges] charges remaining.")
		if(1)
			. += span_notice("It has [charges] charge remaining.")
		if(-INFINITY to 0)
			. += span_warning("It needs to recharge!")

/obj/item/megaphone/nospam/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()
