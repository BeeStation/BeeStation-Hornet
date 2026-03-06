/datum/symptom/mind_restoration //heals damage to the brain
	name = "Mind Restoration"
	desc = "The virus strengthens the bonds between neurons, reducing the duration of any ailments of the mind."
	stealth = -1
	resistance = -2
	stage_speed = 1
	transmission = -3
	level = 6
	severity = -1
	symptom_delay_min = 5
	symptom_delay_max = 10
	bodies = list("Neuron")
	var/purge_alcohol = FALSE
	var/trauma_heal_mild = FALSE
	var/trauma_heal_severe = FALSE
	threshold_desc = "<b>Resistance 6:</b> Heals minor brain traumas.<br>\
						<b>Resistance 9:</b> Heals severe brain traumas.<br>\
						<b>Transmission 8:</b> Purges alcohol in the bloodstream."

/datum/symptom/mind_restoration/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.resistance >= 6) //heal brain damage
		trauma_heal_mild = TRUE
		if(A.resistance >= 9) //heal severe traumas
			trauma_heal_severe = TRUE
	if(A.transmission >= 8) //purge alcohol
		purge_alcohol = TRUE

/datum/symptom/mind_restoration/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob


	if(A.stage >= 3)
		M.adjust_dizzy(-4 SECONDS)
		M.adjust_drowsiness(-4 SECONDS)
		// All slurring effects get reduced down a bit
		for(var/datum/status_effect/speech/slurring/slur in M.status_effects)
			slur.remove_duration(1 SECONDS)

		M.adjust_confusion(-2 SECONDS)
		if(purge_alcohol)
			M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3)
			M.adjust_drunk_effect(-5)

	if(A.stage >= 4)
		M.adjust_drowsiness(-4 SECONDS)
		if(M.reagents.has_reagent(/datum/reagent/toxin/mindbreaker))
			M.reagents.remove_reagent(/datum/reagent/toxin/mindbreaker, 5)
		if(M.reagents.has_reagent(/datum/reagent/toxin/histamine))
			M.reagents.remove_reagent(/datum/reagent/toxin/histamine, 5)
		M.adjust_hallucinations(-20 SECONDS)

	if(A.stage >= 5)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3)
		if(trauma_heal_mild && iscarbon(M))
			var/mob/living/carbon/C = M
			if(prob(10))
				if(trauma_heal_severe)
					C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_LOBOTOMY, special_method = TRUE)
				else
					C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC, special_method = TRUE)



/datum/symptom/sensory_restoration //heals damage to the eyes and ears
	name = "Sensory Restoration"
	desc = "The virus stimulates the production and replacement of sensory tissues, causing the host to regenerate eyes and ears when damaged."
	stealth = 0
	resistance = 1
	stage_speed = -2
	transmission = 2
	level = 6
	severity = -1
	base_message_chance = 7
	symptom_delay_min = 1
	symptom_delay_max = 1

/datum/symptom/sensory_restoration/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	var/obj/item/organ/eyes/eyes = M.get_organ_slot(ORGAN_SLOT_EYES)
	if (!eyes)
		return
	switch(A.stage)
		if(4, 5)
			var/obj/item/organ/ears/ears = M.get_organ_slot(ORGAN_SLOT_EARS)
			if(ears)
				ears.adjustEarDamage(-4, -4)

			if(HAS_TRAIT_FROM(M, TRAIT_BLIND, EYE_DAMAGE))
				if(prob(20))
					if(M.stat != DEAD)
						to_chat(M, span_notice("Your vision slowly returns..."))
					M.cure_blind(EYE_DAMAGE)
					M.cure_nearsighted(EYE_DAMAGE)
					M.set_eye_blur_if_lower(70 SECONDS)
			else if(HAS_TRAIT_FROM(M, TRAIT_NEARSIGHT, EYE_DAMAGE))
				if(M.stat != DEAD)
					to_chat(M, span_notice("You can finally focus your eyes on distant objects."))
				M.cure_nearsighted(EYE_DAMAGE)
				M.set_eye_blur_if_lower(20 SECONDS)
			else if(M.is_blind() || M.has_status_effect(/datum/status_effect/eye_blur))
				M.set_blindness(0)
				M.remove_status_effect(/datum/status_effect/eye_blur)
			else if(eyes.damage > 0)
				eyes.apply_organ_damage(-1)
		else
			if(prob(base_message_chance) && M.stat != DEAD)
				to_chat(M, span_notice("[pick("Your eyes feel great.","You feel like your eyes can focus more clearly.", "You don't feel the need to blink.","Your ears feel great.","Your healing feels more acute.")]"))


/datum/symptom/organ_restoration //heals damage to other internal organs that get damaged far less often
	name = "Organ Restoration"
	desc = "The virus stimulates rapid cell growth in organ tissues, slowly repairing the host's organs over time."
	stealth = 2
	resistance = 3
	stage_speed = -2
	transmission = -1
	level = 6
	severity = -1
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Organ ")
	var/curing = FALSE
	var/regenorgans = FALSE
	threshold_desc = "<b>Stealth 4:</b> The host will regenerate missing organs over a long period of time.<br>\
						<b>Stage Speed 10:</b> The virus causes the host's internal organs to gain some self-correcting behaviour, preventing heart attacks and appendicitis.<br>"

/datum/symptom/organ_restoration/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 4)
		severity -= 1

/datum/symptom/organ_restoration/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 10)
		curing = TRUE
	if(A.stealth >= 4)
		regenorgans = TRUE

/datum/symptom/organ_restoration/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	var/organtype = ORGAN_ORGANIC
	if(A.infectable_biotypes & MOB_ROBOTIC)
		organtype = null //if the disease is capable of interfacing with robotics, it is allowed to heal mechanical organs
	if(A.stage >= 4)
		M.adjustOrganLoss(ORGAN_SLOT_APPENDIX, -1, required_organ_flag = organtype)
		M.adjustOrganLoss(ORGAN_SLOT_STOMACH, -1, required_organ_flag = organtype)
		M.adjustOrganLoss(ORGAN_SLOT_LUNGS, -1, required_organ_flag = organtype)
		M.adjustOrganLoss(ORGAN_SLOT_HEART, -1, required_organ_flag = organtype)
		M.adjustOrganLoss(ORGAN_SLOT_LIVER, -1, required_organ_flag = organtype)
		M.adjustOrganLoss(ORGAN_SLOT_TAIL, -1, required_organ_flag = organtype)
		M.adjustOrganLoss(ORGAN_SLOT_WINGS, -1, required_organ_flag = organtype)
		if(curing)
			for(var/datum/disease/D in M.diseases)
				if(istype(D, /datum/disease/appendicitis) || istype(D, /datum/disease/heart_failure))
					D.cure()
			if(M.undergoing_cardiac_arrest())
				M.set_heartattack(FALSE)
		if(regenorgans) //regenerate missing organs that this disease cures, other than the brain
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/species/S = H.dna.species
				if(!M.get_organ_by_type(/obj/item/organ/appendix) && !((TRAIT_NOHUNGER in S.inherent_traits) || (TRAIT_POWERHUNGRY in S.inherent_traits)))
					var/obj/item/organ/appendix/O = new()
					O.Insert(M)
					M.adjustOrganLoss(ORGAN_SLOT_APPENDIX, 99, 99) //don't make it fail, or the host will start taking massive damage
					return
				if(!M.get_organ_by_type(/obj/item/organ/stomach))
					var/obj/item/organ/stomach/O
					if(S.mutantstomach)
						O = new S.mutantstomach()
					else
						O = new()
					O.Insert(M, drop_if_replaced = FALSE)
					M.adjustOrganLoss(ORGAN_SLOT_STOMACH, 200)
					return
				if(!M.get_organ_by_type(/obj/item/organ/lungs) && !(TRAIT_NOBREATH in S.inherent_traits))
					var/obj/item/organ/lungs/O
					if(S.mutantlungs)
						O = new S.mutantlungs()
					else
						O = new()
					O.Insert(M, drop_if_replaced = FALSE)
					M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 200)
					return
				if(!M.get_organ_by_type(/obj/item/organ/heart) && !HAS_TRAIT(S, TRAIT_NOBLOOD))
					var/obj/item/organ/heart/O = new()
					O.Insert(M, drop_if_replaced = FALSE)
					M.adjustOrganLoss(ORGAN_SLOT_HEART, 200)
					return
				if(!M.get_organ_by_type(/obj/item/organ/liver) && !(TRAIT_NOMETABOLISM in S.inherent_traits))
					var/obj/item/organ/liver/O
					if(S.mutantliver)
						O = new S.mutantliver()
					else
						O = new()
					O.Insert(M, drop_if_replaced = FALSE)
					M.adjustOrganLoss(ORGAN_SLOT_LIVER, 200)
					return
				if(!M.get_organ_by_type(/obj/item/organ/wings))
					if(S.mutantwings)
						var/obj/item/organ/wings/O = new S.mutantwings()
						O.Insert(M, drop_if_replaced = FALSE)
						M.adjustOrganLoss(ORGAN_SLOT_WINGS, 200)
						M.visible_message(span_notice("[M] sprouts a new pair of wings!"), span_userdanger("You sprout a new pair of wings!."))
						playsound(M, 'sound/magic/demon_consume.ogg', 50, 1)
						M.add_splatter_floor(get_turf(M))
						return
	if(prob(2) && M.stat != DEAD)
		to_chat(M, span_notice("[pick("You feel healthy!.","You feel energetic!", "You feel rejuvenated!")]"))
