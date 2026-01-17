/datum/disease/tuberculosis
	form = "Disease"
	name = "Fungal tuberculosis"
	max_stages = 5
	spread_text = "Airborne"
	cure_text = "Spaceacillin & salbutamol"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/salbutamol)
	agent = "Fungal Tubercle bacillus Cosmosis"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 2.5 //like hell are you getting out of hell
	desc = "A rare highly transmissible virulent virus. Few samples exist, rumoured to be carefully grown and cultured by clandestine bio-weapon specialists. Causes fever, blood vomiting, lung damage, weight loss, and fatigue."
	required_organs = list(/obj/item/organ/lungs)
	danger = DISEASE_BIOHAZARD
	bypasses_immunity = TRUE // TB primarily impacts the lungs; it's also bacterial or fungal in nature; viral immunity should do nothing.

/datum/disease/tuberculosis/stage_act(delta_time, times_fired) //it begins
	. = ..()
	if(!.)
		return

	if(DT_PROB(stage * 2, delta_time))
		affected_mob.emote("cough")
		to_chat(affected_mob, span_danger("Your chest hurts."))

	switch(stage)
		if(2)
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, span_danger("Your stomach violently rumbles!"))
			if(DT_PROB(2.5, delta_time))
				to_chat(affected_mob, span_danger("You feel a cold sweat form."))
		if(4)
			var/need_mob_update = FALSE
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, span_userdanger("You see four of everything!"))
				affected_mob.set_dizzy_if_lower(10 SECONDS)
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, span_danger("You feel a sharp pain from your lower chest!"))
				need_mob_update += affected_mob.adjustOxyLoss(5, updating_health = FALSE)
				affected_mob.emote("gasp")
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, span_danger("You feel air escape from your lungs painfully."))
				need_mob_update += affected_mob.adjustOxyLoss(25, updating_health = FALSE)
				affected_mob.emote("gasp")
			if(need_mob_update)
				affected_mob.updatehealth()
		if(5)
			var/need_mob_update = FALSE
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, span_userdanger("[pick("You feel your heart slowing...", "You relax and slow your heartbeat.")]"))
				need_mob_update += affected_mob.adjustStaminaLoss(70, updating_health = FALSE)
			if(DT_PROB(5, delta_time))
				need_mob_update += affected_mob.adjustStaminaLoss(100, updating_health = FALSE)
				affected_mob.visible_message(span_warning("[affected_mob] faints!"), span_userdanger("You surrender yourself and feel at peace..."))
				affected_mob.AdjustSleeping(10 SECONDS)
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, span_userdanger("You feel your mind relax and your thoughts drift!"))
				affected_mob.adjust_confusion_up_to(8 SECONDS, 100 SECONDS)
			if(DT_PROB(5, delta_time))
				affected_mob.vomit(lost_nutrition = 20)
			if(DT_PROB(1.5, delta_time))
				to_chat(affected_mob, span_warning("<i>[pick("Your stomach silently rumbles...", "Your stomach seizes up and falls limp, muscles dead and lifeless.", "You could eat a crayon")]</i>"))
				affected_mob.overeatduration = max(affected_mob.overeatduration - (200 SECONDS), 0)
				affected_mob.adjust_nutrition(-100)
			if(DT_PROB(7.5, delta_time))
				to_chat(affected_mob, span_danger("[pick("You feel uncomfortably hot...", "You feel like unzipping your jumpsuit...", "You feel like taking off some clothes...")]"))
				affected_mob.adjust_bodytemperature(40)
			if(need_mob_update)
				affected_mob.updatehealth()

