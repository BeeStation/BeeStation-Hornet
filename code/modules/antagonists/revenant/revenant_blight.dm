/datum/disease/revblight
	name = "Unnatural Wasting"
	max_stages = 5
	stage_prob = 2
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	cure_text = "Holy water or extensive rest."
	spread_text = "A burst of unholy energy"
	cures = list(/datum/reagent/water/holywater)
	cure_chance = 50 //higher chance to cure, because revenants are assholes
	agent = "Unholy Forces"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CURABLE
	permeability_mod = 1
	danger = DISEASE_HARMFUL
	var/finalstage = 0 //Ensures the final stage effects that should only happen once do not happen repeatedly.
	var/startresting
	var/turf/restingat

/datum/disease/revblight/cure()
	if(affected_mob)
		affected_mob.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, "#1d2953")
		if(affected_mob.dna && affected_mob.dna.species)
			affected_mob.dna.species.handle_mutant_bodyparts(affected_mob)
			affected_mob.dna.species.handle_hair(affected_mob)
		new /obj/effect/temp_visual/revenant/blightcure(affected_mob.loc)
		to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
	..()

/datum/disease/revblight/stage_act()
	..()
	affected_mob.adjustStaminaLoss(1) //Provides gradual exhaustion, but mostly to prevent regeneration and set an upper limit on disease duration to about five minutes
	if(!(affected_mob.mobility_flags & MOBILITY_STAND))
		if(affected_mob.stam_paralyzed && !finalstage)
			stage = 5 
		if(!startresting || restingat != get_turf(affected_mob))
			startresting = world.time
			restingat = get_turf(affected_mob)
		else if(world.time - startresting >= 30 SECONDS) //Ensures nobody is left in permanent stamcrit, and also enables players to rest in a safe location to cure themselves
			cure()
	else
		startresting = null
	if(prob(stage*3) && !finalstage && affected_mob.staminaloss <= stage * 25) //no more lesser flavor messages and sparkles after stage 5
		to_chat(affected_mob, "<span class='revennotice'>You suddenly feel [pick("like you need to rest", "disoriented", "tired and confused", "nauseated", "faint", "dizzy")]...</span>")
		affected_mob.confused += 8
		affected_mob.adjustStaminaLoss(15) //Where the real exhaustion builds up.
		new /obj/effect/temp_visual/revenant(affected_mob.loc)

	switch(stage)
		if(3)
			if(prob(5))
				affected_mob.emote(pick("pale","shiver"))
		if(4)
			if(prob(10))
				affected_mob.emote(pick("pale","shiver","cries"))
		if(5)
			if(affected_mob.staminaloss <= 200) //check required to prevent randomly screaming from limbs being crippled at extreme stamina
				affected_mob.adjustStaminaLoss(15) //No longer realistically possible to counteract with stimulants
			if(!finalstage)
				finalstage = TRUE
				to_chat(affected_mob, "<span class='revenbignotice'>You feel like [pick("you just can't go on", "you should just give up", "there's nothing you can do", "everything is hopeless")].</span>")
				new /obj/effect/temp_visual/revenant(affected_mob.loc)
				if(affected_mob.dna?.species)
					affected_mob.dna.species.handle_mutant_bodyparts(affected_mob,"#1d2953")
					affected_mob.dna.species.handle_hair(affected_mob,"#1d2953")
				affected_mob.visible_message("<span class='warning'>[affected_mob] looks terrifyingly gaunt...</span>", "<span class='revennotice'>You suddenly feel like your skin is <i>wrong</i>...</span>")
				affected_mob.add_atom_colour("#1d2953", TEMPORARY_COLOUR_PRIORITY)
		else
			return
