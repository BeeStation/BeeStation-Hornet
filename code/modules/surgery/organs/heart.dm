/obj/item/organ/heart
	name = "heart"
	desc = "I feel bad for the heartless bastard who lost this."
	icon_state = "heart-on"
	base_icon_state = "heart"

	visual = FALSE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_HEART
	item_flags = NO_BLOOD_ON_ITEM

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = 5 * STANDARD_ORGAN_DECAY //designed to fail about 5 minutes after death

	low_threshold_passed = span_info("Prickles of pain appear then die out from within your chest...")
	high_threshold_passed = span_warning("Something inside your chest hurts, and the pain isn't subsiding. You notice yourself breathing far faster than before.")
	now_fixed = span_info("Your heart begins to beat again.")
	high_threshold_cleared = span_info("The pain in your chest has died down, and your breathing becomes more relaxed.")

	attack_verb_continuous = list("beats", "thumps")
	attack_verb_simple = list("beat", "thump")

	// Heart attack code is in code/modules/mob/living/carbon/human/life.dm
	var/beating = TRUE
	//is this mob having a heatbeat sound played? if so, which?
	var/beat = BEAT_NONE
	//to prevent constantly running failing code
	var/failed = FALSE
	//whether the heart's been operated on to fix some of its damages
	var/operated = FALSE

/obj/item/organ/heart/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[beating ? "on" : "off"]"

/obj/item/organ/heart/Remove(mob/living/carbon/M, special = 0, pref_load = FALSE)
	..()
	if(!special)
		addtimer(CALLBACK(src, PROC_REF(stop_if_unowned)), 120)

/obj/item/organ/heart/proc/stop_if_unowned()
	if(QDELETED(src))
		return
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
	return TRUE

/obj/item/organ/heart/proc/Restart()
	beating = TRUE
	update_appearance()
	return TRUE

/obj/item/organ/heart/on_eat_from(eater, feeder)
	. = ..()
	beating = FALSE
	update_appearance()

/obj/item/organ/heart/on_life(delta_time, times_fired)
	..()

	if(!owner.needs_heart())
		return

	if(owner.client && beating)
		failed = FALSE
		var/sound/slowbeat = sound('sound/health/slowbeat.ogg', repeat = TRUE)
		var/sound/fastbeat = sound('sound/health/fastbeat.ogg', repeat = TRUE)
		var/mob/living/carbon/H = owner

		if(H.health <= H.crit_threshold && beat != BEAT_SLOW)
			beat = BEAT_SLOW
			H.playsound_local(get_turf(H), slowbeat,40,0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
			to_chat(owner, span_notice("You feel your heart slow down."))
		if(beat == BEAT_SLOW && H.health > H.crit_threshold)
			H.stop_sound_channel(CHANNEL_HEARTBEAT)
			beat = BEAT_NONE

		if(H.has_status_effect(/datum/status_effect/jitter))
			if(H.health > HEALTH_THRESHOLD_FULLCRIT && (!beat || beat == BEAT_SLOW))
				H.playsound_local(get_turf(H),fastbeat,40,0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
				beat = BEAT_FAST

		else if(beat == BEAT_FAST)
			H.stop_sound_channel(CHANNEL_HEARTBEAT)
			beat = BEAT_NONE

	if(organ_flags & ORGAN_FAILING)	//heart broke, stopped beating, death imminent
		if(owner.stat == CONSCIOUS)
			owner.visible_message(span_userdanger("[owner] clutches at [owner.p_their()] chest as if [owner.p_their()] heart is stopping!"))
		owner.set_heartattack(TRUE)
		failed = TRUE

/obj/item/organ/heart/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutantheart

/obj/item/organ/heart/cursed
	name = "cursed heart"
	desc = "A heart that, when inserted, will force you to pump it manually."
	icon_state = "cursedheart-off"
	base_icon_state = "cursedheart"
	decay_factor = 0

	/// How long between needed pumps
	var/pump_delay = 3 SECONDS
	/// How much blood you lose per missed pump
	var/blood_loss = BLOOD_VOLUME_NORMAL * 0.2
	/// How much of each damage type to heal per pump
	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_oxy = 0

/obj/item/organ/heart/cursed/attack_self(mob/user)
	. = ..()
	playsound(user,'sound/effects/singlebeat.ogg',40,1)
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)

/obj/item/organ/heart/cursed/on_insert(mob/living/carbon/accursed)
	. = ..()
	accursed.AddComponent(/datum/component/manual_heart, pump_delay = pump_delay, blood_loss = blood_loss, heal_brute = heal_brute, heal_burn = heal_burn, heal_oxy = heal_oxy)

/obj/item/organ/heart/cursed/Remove(mob/living/carbon/accursed, special = 0, pref_load = FALSE)
	. = ..()
	qdel(accursed.GetComponent(/datum/component/manual_heart))

/datum/client_colour/cursed_heart_blood
	priority = 100 //it's an indicator you're dying, so it's very high priority
	colour = "red"

/obj/item/organ/heart/cybernetic
	name = "cybernetic heart"
	desc = "An electronic device designed to mimic the functions of an organic human heart. Also holds an emergency dose of epinephrine, used automatically after facing severe trauma."
	icon_state = "heart-c-on"
	base_icon_state = "heart-c"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	var/dose_available = TRUE
	var/rid = /datum/reagent/medicine/epinephrine
	var/ramount = 10

/obj/item/organ/heart/cybernetic/ipc //this sucks
	name = "coolant pump"
	desc = "A small pump powered by the IPC's internal systems for circulating coolant."
	status = ORGAN_ROBOTIC

/obj/item/organ/heart/cybernetic/ipc/emp_act()
	. = ..()
	to_chat(owner, "<span class='warning'>Alert: Cybernetic heart failed one heartbeat</span>")
	addtimer(CALLBACK(src, PROC_REF(Restart)), 10 SECONDS)

/obj/item/organ/heart/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(30/severity))
		Stop()
		addtimer(CALLBACK(src, PROC_REF(Restart)), 10 SECONDS)

/obj/item/organ/heart/cybernetic/on_life(delta_time, times_fired)
	. = ..()
	if(dose_available && owner.stat == UNCONSCIOUS && !owner.reagents.has_reagent(rid))
		owner.reagents.add_reagent(rid, ramount)
		used_dose()

/obj/item/organ/heart/cybernetic/proc/used_dose()
	owner.reagents.add_reagent(rid, ramount)
	dose_available = FALSE

/obj/item/organ/heart/cybernetic/upgraded
	name = "upgraded cybernetic heart"
	desc = "An electronic device designed to mimic the functions of an organic human heart. Also holds an emergency dose of epinephrine, used automatically after facing severe trauma. This upgraded model can regenerate its dose after use."
	icon_state = "heart-c-u-on"
	base_icon_state = "heart-c-u"

/obj/item/organ/heart/cybernetic/upgraded/used_dose()
	. = ..()
	addtimer(VARSET_CALLBACK(src, dose_available, TRUE), 5 MINUTES)

/obj/item/organ/heart/freedom
	name = "heart of freedom"
	desc = "This heart pumps with the passion to give... something freedom."
	organ_flags = ORGAN_SYNTHETIC //the power of freedom prevents heart attacks
	/// The cooldown until the next time this heart can give the host an adrenaline boost.
	COOLDOWN_DECLARE(adrenaline_cooldown)

/obj/item/organ/heart/freedom/on_life(delta_time, times_fired)
	. = ..()
	if(owner.health < 5 && COOLDOWN_FINISHED(src, adrenaline_cooldown))
		COOLDOWN_START(src, adrenaline_cooldown, rand(25 SECONDS, 1 MINUTES))
		to_chat(owner, span_userdanger("You feel yourself dying, but you refuse to give up!"))
		owner.heal_overall_damage(15, 15, 0, BODYTYPE_ORGANIC)
		if(owner.reagents.get_reagent_amount(/datum/reagent/medicine/ephedrine) < 20)
			owner.reagents.add_reagent(/datum/reagent/medicine/ephedrine, 10)

/obj/item/organ/heart/ethereal
	name = "crystal core"
	icon_state = "ethereal_heart-on"
	base_icon_state = "ethereal_heart"
	visual = TRUE //This is used by the ethereal species for color
	desc = "A crystal-like organ that functions similarly to a heart for Ethereals."

	///Color of the heart, is set by the species on gain
	var/ethereal_color = "#9c3030"

/obj/item/organ/heart/ethereal/Initialize(mapload)
	. = ..()
	add_atom_colour(ethereal_color, FIXED_COLOUR_PRIORITY)
	update_appearance()

/obj/item/organ/heart/ethereal/update_overlays()
	. = ..()
	var/mutable_appearance/shine = mutable_appearance(icon, icon_state = "[base_icon_state]_overlay-[beating ? "on" : "off"]")
	shine.appearance_flags = RESET_COLOR //No color on this, just pure white
	. += shine

/obj/item/organ/heart/diona
	name = "polypment segment"
	desc = "A segment of plant matter that is resposible for pumping nutrients around the body."
	icon_state = "diona_heart"
