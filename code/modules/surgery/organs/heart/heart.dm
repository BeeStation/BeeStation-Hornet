/obj/item/organ/heart
	name = "heart"
	desc = "I feel bad for the heartless bastard who lost this."
	icon_state = "heart-on"
	base_icon_state = "heart"
	visual = FALSE
	slot = ORGAN_SLOT_HEART

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = 2 * STANDARD_ORGAN_DECAY

	low_threshold_passed = span_info("Prickles of pain appear then die out from within your chest...")
	high_threshold_passed = span_warning("Something inside your chest hurts, and the pain isn't subsiding. You notice yourself breathing far faster than before.")
	now_fixed = span_info("Your heart begins to beat again.")
	high_threshold_cleared = span_info("The pain in your chest has died down, and your breathing becomes more relaxed.")

	// Heart attack code is in code/modules/mob/living/carbon/human/life.dm
	var/beating = TRUE
	attack_verb_continuous = list("beats", "thumps")
	attack_verb_simple = list("beat", "thump")
	//is this mob having a heatbeat sound played? if so, which?
	var/beat = BEAT_NONE
	//to prevent constantly running failing code
	var/failed = FALSE
	//whether the heart's been operated on to fix some of its damages
	var/operated = FALSE
	///Color of the heart, is set by the species on gain
	//var/ethereal_color = "#9c3030"
	/// How effective is this heart at circulating blood around the body
	var/circulation_effectiveness = 1

/obj/item/organ/heart/update_icon_state()
	icon_state = "[base_icon_state]-[beating ? "on" : "off"]"
	return ..()

/obj/item/organ/heart/Insert(mob/living/carbon/receiver, special, drop_if_replaced, pref_load)
	. = ..()
	receiver.blood.set_circulation_rating(circulation_effectiveness, FROM_HEART)

/obj/item/organ/heart/Remove(mob/living/carbon/M, special = 0, pref_load = FALSE)
	..()
	// No longer recieves circulation from heart
	M.blood.set_circulation_rating(0, FROM_HEART)
	if(!special)
		addtimer(CALLBACK(src, PROC_REF(stop_if_unowned)), 120)

/obj/item/organ/heart/proc/stop_if_unowned()
	if(!owner)
		Stop()

/obj/item/organ/heart/attack_self(mob/user)
	..()
	if(!beating)
		user.visible_message(span_notice("[user] squeezes [src] to make it beat again!"), span_notice("You squeeze [src] to make it beat again!"))
		Restart()
		addtimer(CALLBACK(src, PROC_REF(stop_if_unowned)), 80)

/obj/item/organ/heart/proc/Stop()
	beating = FALSE
	update_appearance()
	owner?.blood.set_circulation_rating(0, FROM_HEART)
	return TRUE

/obj/item/organ/heart/proc/Restart()
	beating = TRUE
	update_appearance()
	owner?.blood.set_circulation_rating(circulation_effectiveness, FROM_HEART)
	return TRUE

/obj/item/organ/heart/on_eat_from(eater, feeder)
	. = ..()
	Stop()

/obj/item/organ/heart/on_life(delta_time, times_fired)
	..()

	if(!owner.needs_heart())
		return

	if(owner.client && beating)
		failed = FALSE
		var/sound/slowbeat = sound('sound/health/slowbeat.ogg', repeat = TRUE)
		var/sound/fastbeat = sound('sound/health/fastbeat.ogg', repeat = TRUE)
		var/mob/living/carbon/H = owner


		if(H.stat >= SOFT_CRIT && beat != BEAT_SLOW)
			beat = BEAT_SLOW
			H.playsound_local(get_turf(H), slowbeat,40,0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
			to_chat(owner, span_notice("You feel your heart slow down."))

		if(beat == BEAT_SLOW && H.stat >= SOFT_CRIT)
			H.stop_sound_channel(CHANNEL_HEARTBEAT)
			beat = BEAT_NONE

		if(H.jitteriness)
			if(H.stat >= HARD_CRIT && (!beat || beat == BEAT_SLOW))
				H.playsound_local(get_turf(H),fastbeat,40,0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
				beat = BEAT_FAST
		else if(beat == BEAT_FAST)
			H.stop_sound_channel(CHANNEL_HEARTBEAT)
			beat = BEAT_NONE

	if ((organ_flags & ORGAN_FAILING) && !failed)	//heart broke, stopped beating, death imminent
		if(owner.stat == CONSCIOUS)
			owner.visible_message(span_userdanger("[owner] clutches at [owner.p_their()] chest as if [owner.p_their()] heart is stopping!"))
		owner.set_heartattack(TRUE)
		failed = TRUE

/obj/item/organ/heart/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutantheart && ..()
