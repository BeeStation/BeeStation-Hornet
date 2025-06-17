/obj/item/organ/stomach
	name = "stomach"
	icon_state = "stomach"
	visual = FALSE
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_STOMACH
	attack_verb_continuous = list("gores", "squishes", "slaps", "digests")
	attack_verb_simple = list("gore", "squish", "slap", "digest")
	desc = "Onaka ga suite imasu."

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	low_threshold_passed = span_info("Your stomach flashes with pain before subsiding. Food doesn't seem like a good idea right now.")
	high_threshold_passed = span_warning("Your stomach flares up with constant pain- you can hardly stomach the idea of food right now!")
	high_threshold_cleared = span_info("The pain in your stomach dies down for now, but food still seems unappealing.")
	low_threshold_cleared = span_info("The last bouts of pain in your stomach have died out.")

	var/disgust_metabolism = 1

/obj/item/organ/stomach/on_life(delta_time, times_fired)
	. = ..()
	var/mob/living/carbon/human/H = owner
	var/datum/reagent/nutriment

	if(istype(H))
		if(!(organ_flags & ORGAN_FAILING))
			H.dna.species.handle_digestion(H, delta_time, times_fired)
		handle_disgust(H, delta_time, times_fired)

	if(damage < low_threshold)
		return

	nutriment = locate(/datum/reagent/consumable/nutriment) in H.reagents.reagent_list

	if(nutriment)
		if(prob((damage/40) * nutriment.volume * nutriment.volume))
			H.vomit(damage)
			to_chat(H, span_warning("Your stomach reels in pain as you're incapable of holding down all that food!"))

	else if(nutriment && damage > high_threshold)
		if(prob((damage/10) * nutriment.volume * nutriment.volume))
			H.vomit(damage)
			to_chat(H, span_warning("Your stomach reels in pain as you're incapable of holding down all that food!"))

/obj/item/organ/stomach/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutantstomach

/obj/item/organ/stomach/proc/handle_disgust(mob/living/carbon/human/H, delta_time, times_fired)
	if(H.disgust)
		var/pukeprob = 2.5 + (0.025 * H.disgust)
		if(H.disgust >= DISGUST_LEVEL_GROSS)
			if(DT_PROB(5, delta_time))
				H.stuttering += 1
				H.confused += 2
			if(DT_PROB(5, delta_time) && !H.stat)
				to_chat(H, span_warning("You feel kind of iffy..."))
			H.jitteriness = max(H.jitteriness - 3, 0)
		if(H.disgust >= DISGUST_LEVEL_VERYGROSS)
			if(DT_PROB(pukeprob, delta_time)) //iT hAndLeS mOrE ThaN PukInG
				H.confused += 2.5
				H.stuttering += 1
				H.vomit(10, 0, 1, 0, 1, 0)
			H.Dizzy(5)
		if(H.disgust >= DISGUST_LEVEL_DISGUSTED)
			if(DT_PROB(13, delta_time))
				H.blur_eyes(3) //We need to add more shit down here

		H.adjust_disgust(-0.25 * disgust_metabolism * delta_time)
	switch(H.disgust)
		if(0 to DISGUST_LEVEL_GROSS)
			H.clear_alert("disgust")
			SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "disgust")
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			H.throw_alert("disgust", /atom/movable/screen/alert/gross)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/gross)
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			H.throw_alert("disgust", /atom/movable/screen/alert/verygross)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/verygross)
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			H.throw_alert("disgust", /atom/movable/screen/alert/disgusted)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/disgusted)

/obj/item/organ/stomach/Remove(mob/living/carbon/M, special = 0, pref_load = FALSE)
	var/mob/living/carbon/human/H = owner
	if(istype(H))
		H.clear_alert("disgust")
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "disgust")
	return ..()

/obj/item/organ/stomach/fly
	name = "insectoid stomach"
	icon_state = "stomach-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "A mutant stomach designed to handle the unique diet of a flyperson."

/obj/item/organ/stomach/plasmaman
	name = "digestive crystal"
	icon_state = "stomach-p"
	desc = "A strange crystal that is responsible for metabolizing the unseen energy force that feeds plasmamen."

/obj/item/organ/stomach/battery
	name = "implantable battery"
	icon_state = "implant-power"
	desc = "A battery that stores charge for species that run on electricity."
	var/max_charge = 5000 //same as upgraded+ cell
	var/charge = 5000

/obj/item/organ/stomach/battery/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE, pref_load = FALSE)
	. = ..()
	RegisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(charge))
	update_nutrition()

/obj/item/organ/stomach/battery/Remove(mob/living/carbon/M, special = 0, pref_load = FALSE)
	UnregisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	if(!HAS_TRAIT(owner, TRAIT_NOHUNGER) && HAS_TRAIT(owner, TRAIT_POWERHUNGRY))
		owner.nutrition = 0
		owner.throw_alert("nutrition", /atom/movable/screen/alert/nocell)
	return ..()

/obj/item/organ/stomach/battery/proc/charge(datum/source, amount, repairs)
	SIGNAL_HANDLER
	adjust_charge(amount)

/obj/item/organ/stomach/battery/proc/adjust_charge(amount)
	if(amount > 0)
		charge = clamp((charge + amount)*(1-(damage/maxHealth)), 0, max_charge)
	else
		charge = clamp(charge + amount, 0, max_charge)
	update_nutrition()

/obj/item/organ/stomach/battery/proc/adjust_charge_scaled(amount)
	adjust_charge(amount*max_charge/NUTRITION_LEVEL_FULL)

/obj/item/organ/stomach/battery/proc/set_charge(amount)
	charge = clamp(amount*(1-(damage/maxHealth)), 0, max_charge)
	update_nutrition()

/obj/item/organ/stomach/battery/proc/set_charge_scaled(amount)
	set_charge(amount*max_charge/NUTRITION_LEVEL_FULL)

/obj/item/organ/stomach/battery/proc/update_nutrition()
	if(!owner)
		return
	if(!HAS_TRAIT(owner, TRAIT_NOHUNGER) && HAS_TRAIT(owner, TRAIT_POWERHUNGRY))
		owner.nutrition = (charge/max_charge)*NUTRITION_LEVEL_FULL

/obj/item/organ/stomach/battery/emp_act(severity)
	. = ..()
	adjust_charge((-0.3 * max_charge) / severity)

/obj/item/organ/stomach/battery/ipc
	name = "micro-cell"
	icon_state = "microcell"
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("assault and batteries")
	attack_verb_simple = list("assault and battery")
	desc = "A micro-cell, for IPC use. Do not swallow."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	max_charge = 2750 //50 nutrition from 250 charge
	charge = 2750

/obj/item/organ/stomach/battery/ipc/emp_act(severity)
	. = ..()
	switch(severity)
		if(1)
			to_chat(owner, span_warning("Alert: Heavy EMP Detected. Rebooting power cell to prevent damage."))
		if(2)
			to_chat(owner, span_warning("Alert: EMP Detected. Cycling battery."))

/obj/item/organ/stomach/battery/ethereal
	name = "biological battery"
	icon_state = "stomach-p" //Welp. At least it's more unique in functionaliy.
	desc = "A crystal-like organ that stores the electric charge of ethereals."
	max_charge = 2500 //same as upgraded cell
	charge = 2500

/obj/item/organ/stomach/battery/ethereal/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE, pref_load = FALSE)
	RegisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))
	return ..()

/obj/item/organ/stomach/battery/ethereal/Remove(mob/living/carbon/M, special = 0, pref_load = FALSE)
	UnregisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT)
	return ..()

/obj/item/organ/stomach/battery/ethereal/proc/on_electrocute(datum/source, shock_damage, siemens_coeff = 1, flags = NONE)
	SIGNAL_HANDLER

	if(flags & SHOCK_ILLUSION)
		return
	adjust_charge(shock_damage * siemens_coeff * 20)
	to_chat(owner, span_notice("You absorb some of the shock into your body!"))

/obj/item/organ/stomach/cybernetic
	name = "basic cybernetic stomach"
	icon_state = "stomach-c"
	desc = "A basic device designed to mimic the functions of a human stomach"
	organ_flags = ORGAN_SYNTHETIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.5

/obj/item/organ/stomach/cybernetic/upgraded
	name = "cybernetic stomach"
	icon_state = "stomach-c-u"
	desc = "An electronic device designed to mimic the functions of a human stomach. Handles disgusting food a bit better."
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	disgust_metabolism = 2

/obj/item/organ/stomach/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(30/severity))
		owner.vomit(stun = FALSE)

/obj/item/organ/stomach/diona
	name = "nutrient vessel"
	desc = "A group of plant matter and vines, useful for digestion of light and radiation."
	icon_state = "diona_stomach"
