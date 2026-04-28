/obj/item/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices. Allows for syncing when using a secure signaler on another."
	icon_state = "signaller"
	inhand_icon_state = "signaler"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	custom_materials = list(/datum/material/iron=400, /datum/material/glass=120)
	attachable = TRUE
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'

	var/code = DEFAULT_SIGNALER_CODE /// The code sent by this signaler.
	var/frequency = FREQ_SIGNALER	/// The frequency this signaler is set to.
	var/cooldown_length = 1 SECONDS	/// How long of a cooldown exists on this signaller.
	var/datum/radio_frequency/radio_connection /// The radio frequency connection this signaler is using.
	var/datum/mind/suicider /// Holds the mind that commited suicide.
	var/suicide_mob /// Holds a reference string to the mob, decides how much of a gamer you are.
	var/hearing_range = 1 /// How many tiles away can you hear when this signaler is used or gets activated.
	var/last_receive_signal_log /// String containing the last piece of logging data relating to when this signaller has received a signal.

/obj/item/assembly/signaler/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] eats \the [src]! If it is signaled, [user.p_they()] will die!"))
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	moveToNullspace()
	suicider = user.mind
	suicide_mob = REF(user)
	return MANUAL_SUICIDE_NONLETHAL

/obj/item/assembly/signaler/proc/manual_suicide(datum/mind/suicidee)
	var/mob/living/user = suicidee.current
	if(!istype(user))
		return
	if(suicide_mob == REF(user))
		user.visible_message(span_suicide("[user]'s [src] receives a signal, killing [user.p_them()] instantly!"))
	else
		user.visible_message(span_suicide("[user]'s [src] receives a signal and [user.p_they()] die[user.p_s()] like a gamer!"))
	user.adjustOxyLoss(200)//it sends an electrical pulse to their heart, killing them. or something.
	user.death(FALSE)
	playsound(user, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	qdel(src)

/obj/item/assembly/signaler/Initialize(mapload)
	. = ..()
	set_frequency(frequency)

/obj/item/assembly/signaler/Destroy()
	SSradio.remove_object(src,frequency)
	suicider = null
	. = ..()

/obj/item/assembly/signaler/activate()
	if(!..())//cooldown processing
		return FALSE
	signal()
	return TRUE

/obj/item/assembly/signaler/update_icon()
	. = ..()
	holder?.update_icon()

/obj/item/assembly/signaler/ui_status(mob/user, datum/ui_state/state)
	if(is_secured(user))
		return ..()
	return UI_CLOSE

/obj/item/assembly/signaler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Signaler", name)
		ui.open()

/obj/item/assembly/signaler/ui_data(mob/user)
	var/list/data = list()
	data["frequency"] = frequency
	data["cooldown"] = cooldown_length
	data["code"] = code
	data["minFrequency"] = MIN_FREE_FREQ
	data["maxFrequency"] = MAX_FREE_FREQ
	return data

/obj/item/assembly/signaler/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("signal")
			if(cooldown_length > 0)
				if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_SIGNALLER_SEND))
					balloon_alert(ui.user, "recharging!")
					return
				TIMER_COOLDOWN_START(src, COOLDOWN_SIGNALLER_SEND, cooldown_length)
			INVOKE_ASYNC(src, PROC_REF(signal))
			balloon_alert(ui.user, "signaled")
			. = TRUE
		if("freq")
			var/new_frequency = sanitize_frequency(unformat_frequency(params["freq"]), TRUE)
			set_frequency(new_frequency)
			. = TRUE
		if("code")
			code = text2num(params["code"])
			code = round(code)
			. = TRUE
		if("reset")
			if(params["reset"] == "freq")
				frequency = initial(frequency)
			else
				code = initial(code)
			. = TRUE

	update_icon()

/obj/item/assembly/signaler/attackby(obj/item/W, mob/user, params)
	if(issignaler(W))
		var/obj/item/assembly/signaler/signaler2 = W
		if(secured && signaler2.secured)
			code = signaler2.code
			set_frequency(signaler2.frequency)
			to_chat(user, "You transfer the frequency and code of \the [signaler2.name] to \the [name]")
	..()

/obj/item/assembly/signaler/proc/signal()
	if(!radio_connection)
		return

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)

	var/logging_data = "[time] <B>:</B> [key_name(usr)] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]"
	add_to_signaler_investigate_log(logging_data)

	var/datum/signal/signal = new(list("code" = code), logging_data = logging_data)
	radio_connection.post_signal(src, signal)

/obj/item/assembly/signaler/receive_signal(datum/signal/signal)
	. = FALSE
	if(!signal)
		return
	if(signal.data["code"] != code)
		return
	if(suicider)
		manual_suicide(suicider)
		return

	// If the holder is a TTV, we want to store the last received signal to incorporate it into TTV logging, else wipe it.
	last_receive_signal_log = istype(holder, /obj/item/transfer_valve) ? signal.logging_data : null

	pulse()
	audible_message(span_infoplain("[icon2html(src, hearers(src))] *beep* *beep* *beep*"), null, hearing_range)
	for(var/mob/hearing_mob in get_hearers_in_view(hearing_range, src))
		hearing_mob.playsound_local(get_turf(src), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	return TRUE

/obj/item/assembly/signaler/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)
	return

/obj/item/assembly/signaler/cyborg

/obj/item/assembly/signaler/cyborg/attackby(obj/item/W, mob/user, params)
	return
/obj/item/assembly/signaler/cyborg/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/item/assembly/signaler/internal
	name = "internal remote signaling device"

/obj/item/assembly/signaler/internal/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/assembly/signaler/internal/attackby(obj/item/W, mob/user, params)
	return

/obj/item/assembly/signaler/internal/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/item/assembly/signaler/internal/can_interact(mob/user)
	if(ispAI(user))
		return TRUE
	. = ..()

// Embedded signaller used in anomalies.
/obj/item/assembly/signaler/anomaly
	name = "anomaly core"
	desc = "The neutralized core of an anomaly. It'd probably be valuable for research."
	icon_state = "anomaly_core"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	resistance_flags = FIRE_PROOF
	var/anomaly_type = /obj/effect/anomaly

/obj/item/assembly/signaler/anomaly/receive_signal(datum/signal/signal)
	if(!signal)
		return FALSE
	if(signal.data["code"] != code)
		return FALSE
	if(suicider)
		manual_suicide(suicider)
	for(var/obj/effect/anomaly/A in get_turf(src))
		A.anomalyNeutralize()
	return TRUE

/obj/item/assembly/signaler/anomaly/manual_suicide(mob/living/carbon/user)
	user.visible_message(span_suicide("[user]'s [src] is reacting to the radio signal, warping [user.p_their()] body!"))
	user.set_suicide(TRUE)
	user.gib()

/obj/item/assembly/signaler/anomaly/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_ANALYZER)
		to_chat(user, span_notice("Analyzing... [src]'s stabilized field is fluctuating along frequency [format_frequency(frequency)], code [code]."))
	..()

//Anomaly cores
/obj/item/assembly/signaler/anomaly/pyro
	name = "\improper pyroclastic anomaly core"
	desc = "The neutralized core of a pyroclastic anomaly. It feels warm to the touch. It'd probably be valuable for research."
	icon_state = "pyro_core"
	anomaly_type = /obj/effect/anomaly/pyro
	custom_price = 750

/obj/item/assembly/signaler/anomaly/grav
	name = "\improper gravitational anomaly core"
	desc = "The neutralized core of a gravitational anomaly. It feels much heavier than it looks. It'd probably be valuable for research."
	icon_state = "grav_core"
	anomaly_type = /obj/effect/anomaly/grav
	custom_price = 500

/obj/item/assembly/signaler/anomaly/flux
	name = "\improper flux anomaly core"
	desc = "The neutralized core of a flux anomaly. Touching it makes your skin tingle. It'd probably be valuable for research."
	icon_state = "flux_core"
	anomaly_type = /obj/effect/anomaly/flux
	custom_price = 500

/obj/item/assembly/signaler/anomaly/bluespace
	name = "\improper bluespace anomaly core"
	desc = "The neutralized core of a bluespace anomaly. It keeps phasing in and out of view. It'd probably be valuable for research."
	icon_state = "anomaly_core"
	anomaly_type = /obj/effect/anomaly/bluespace
	custom_price = 10000
	max_demand = 10

/obj/item/assembly/signaler/anomaly/vortex
	name = "\improper vortex anomaly core"
	desc = "The neutralized core of a vortex anomaly. It won't sit still, as if some invisible force is acting on it. It'd probably be valuable for research."
	icon_state = "vortex_core"
	anomaly_type = /obj/effect/anomaly/bhole
	custom_price = 15000

/obj/item/assembly/signaler/anomaly/bioscrambler
	name = "\improper bioscrambler anomaly core"
	desc = "The neutralized core of a bioscrambler anomaly. It's squirming, as if moving. It'd probably be valuable for research."
	icon_state = "bioscrambler_core"
	anomaly_type = /obj/effect/anomaly/bioscrambler
	custom_price = 1000

/obj/item/assembly/signaler/anomaly/hallucination
	name = "\improper hallucination anomaly core"
	desc = "The neutralized core of a hallucination anomaly. It seems to be moving, but it's probably your imagination. It'd probably be valuable for research."
	icon_state = "hallucination_core"
	anomaly_type = /obj/effect/anomaly/hallucination
	custom_price = 250

/obj/item/assembly/signaler/anomaly/blood
	name = "\improper blood anomaly core"
	desc = "The neutralized core of a blood anomaly. You feel your blood running through your veins when you are around it. It'd probably be valuable for research."
	icon_state = "hallucination_core"
	anomaly_type = /obj/effect/anomaly/blood
	custom_price = 5000

/obj/item/assembly/signaler/anomaly/insanity
	name = "\improper insanity pulse anomaly core"
	desc = "The neutralized core of a insanity pulse anomaly. Ah."
	icon_state = "hallucination_core"
	anomaly_type = /obj/effect/anomaly/insanity_pulse
	custom_price = 1000

/obj/item/assembly/signaler/anomaly/attack_self()
	return
