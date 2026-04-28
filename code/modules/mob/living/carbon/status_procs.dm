//Here are the procs used to modify status effects of a mob.
//The effects include: stun, knockdown, unconscious, sleeping, resting, jitteriness, dizziness, ear damage,
//eye_blind, eye_blurry, druggy, TRAIT_BLIND trait, TRAIT_NEARSIGHT trait, and TRAIT_HUSK trait.


/mob/living/carbon/IsParalyzed(include_stamcrit = TRUE)
	return ..() || (include_stamcrit && HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA))

/mob/living/carbon/proc/enter_stamcrit()
	if(!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE))
		return
	if(absorb_stun(0)) //continuous effect, so we don't want it to increment the stuns absorbed.
		return
	to_chat(src, span_notice("You're too exhausted to keep going..."))
	stam_regen_start_time = world.time + STAMINA_CRIT_TIME
	ADD_TRAIT(src, TRAIT_INCAPACITATED, STAMINA)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, STAMINA)
	ADD_TRAIT(src, TRAIT_FLOORED, STAMINA)

/mob/living/carbon/adjust_disgust(amount)
	disgust = clamp(disgust+amount, 0, DISGUST_LEVEL_MAXEDOUT)

/mob/living/carbon/set_disgust(amount)
	disgust = clamp(amount, 0, DISGUST_LEVEL_MAXEDOUT)


////////////////////////////////////////TRAUMAS/////////////////////////////////////////

/mob/living/carbon/proc/get_traumas(special_method = FALSE)
	. = list()
	var/obj/item/organ/brain/B = get_organ_slot(ORGAN_SLOT_BRAIN)
	if(B)
		if(special_method)
			for(var/T in B.traumas)
				var/datum/brain_trauma/trauma = T
				if(CHECK_BITFIELD(trauma.trauma_flags, TRAUMA_SPECIAL_CURE_PROOF))
					continue
				. += trauma
		else
			. = B.traumas

/mob/living/carbon/proc/has_trauma_type(brain_trauma_type, resilience, special_method = FALSE)
	var/obj/item/organ/brain/B = get_organ_slot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.has_trauma_type(brain_trauma_type, resilience, special_method)

/mob/living/carbon/proc/gain_trauma(datum/brain_trauma/trauma, resilience, ...)
	var/obj/item/organ/brain/B = get_organ_slot(ORGAN_SLOT_BRAIN)
	if(B)
		var/list/arguments = list()
		if(args.len > 2)
			arguments = args.Copy(3)
		. = B.brain_gain_trauma(trauma, resilience, arguments)

/mob/living/carbon/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience)
	var/obj/item/organ/brain/B = get_organ_slot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.gain_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/cure_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience, special_method = FALSE)
	var/obj/item/organ/brain/B = get_organ_slot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.cure_trauma_type(brain_trauma_type, resilience, special_method)

/mob/living/carbon/proc/cure_all_traumas(resilience, special_method = FALSE)
	var/obj/item/organ/brain/B = get_organ_slot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.cure_all_traumas(resilience, special_method)

/mob/living/carbon/update_blindness(overlay = /atom/movable/screen/fullscreen/blind, add_color, can_see = TRUE)
	var/obj/item/organ/eyes/E = get_organ_slot(ORGAN_SLOT_EYES)
	can_see = E?.can_see
	return ..()
