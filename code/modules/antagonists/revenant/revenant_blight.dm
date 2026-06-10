/datum/disease/revblight
	name = "Unnatural Wasting"
	max_stages = 5
	stage_prob = 2
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	cure_text = "Holy water or extensive sleep."   // updated to clarify sleep requirement
	spread_text = "A burst of unholy energy"
	cures = list(/datum/reagent/water/holywater)
	cure_chance = 50
	agent = "Unholy Forces"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CURABLE
	spreading_modifier = 1
	danger = DISEASE_HARMFUL
	var/finalstage = 0
	var/start_sleeping          // world.time when continuous sleep began
	var/turf/sleeping_at        // turf where sleep started

/datum/disease/revblight/cure()
	if(affected_mob)
		affected_mob.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, "#1d2953")
		if(affected_mob.dna && affected_mob.dna.species)
			affected_mob.dna.species.handle_mutant_bodyparts(affected_mob)
			affected_mob.dna.species.handle_hair(affected_mob)
		new /obj/effect/temp_visual/revenant/blightcure(affected_mob.loc)
		to_chat(affected_mob, span_notice("You feel better."))
	..()

/datum/disease/revblight/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	// Gradual stamina drain (stages 1-4)
	affected_mob.adjustStaminaLoss(1)

	// CURE BY SLEEPING (not just lying down)
	if(affected_mob.IsSleeping())   // checks the sleeping var; true if >0
		if(!start_sleeping || sleeping_at != get_turf(affected_mob))
			start_sleeping = world.time
			sleeping_at = get_turf(affected_mob)
		else if(world.time - start_sleeping >= 30 SECONDS)
			cure()                    // sleep for 30 seconds cures the disease
	else
		start_sleeping = null         // not sleeping: reset timer

	// Early-stage flavour effects and extra drain (unchanged)
	if(DT_PROB(1.5 * stage, delta_time) && !finalstage && affected_mob.staminaloss <= stage * 25)
		to_chat(affected_mob, span_revennotice("You suddenly feel [pick("like you need to rest", "disoriented", "tired and confused", "nauseated", "faint", "dizzy")]..."))
		affected_mob.adjust_confusion(8 SECONDS)
		affected_mob.adjustStaminaLoss(7.5 * delta_time, FALSE)
		new /obj/effect/temp_visual/revenant(affected_mob.loc)

	switch(stage)
		if(3)
			if(DT_PROB(2.5, delta_time))
				affected_mob.emote(pick("pale","shiver"))
		if(4)
			if(DT_PROB(5, delta_time))
				affected_mob.emote(pick("pale","shiver","cries"))
		if(5)
			// PERMANENT STAMCRIT
			if(affected_mob.staminaloss < 200)
				affected_mob.adjustStaminaLoss(200 - affected_mob.staminaloss, FALSE)
			// Additional drain to overcome any regen effects
			affected_mob.adjustStaminaLoss(7.5 * delta_time, FALSE)

			if(!finalstage)
				finalstage = TRUE
				to_chat(affected_mob, span_revenbignotice("You feel like [pick("you just can't go on", "you should just give up", "there's nothing you can do", "everything is hopeless")]."))
				new /obj/effect/temp_visual/revenant(affected_mob.loc)
				if(affected_mob.dna?.species)
					affected_mob.dna.species.handle_mutant_bodyparts(affected_mob,"#1d2953")
					affected_mob.dna.species.handle_hair(affected_mob,"#1d2953")
				affected_mob.visible_message(span_warning("[affected_mob] looks terrifyingly gaunt..."), span_revennotice("You suddenly feel like your skin is <i>wrong</i>..."))
				affected_mob.add_atom_colour("#1d2953", TEMPORARY_COLOUR_PRIORITY)
		else
			return
