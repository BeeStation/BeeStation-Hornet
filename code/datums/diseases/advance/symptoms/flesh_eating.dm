/*
//////////////////////////////////////

Necrotizing Fasciitis (AKA Flesh-Eating Disease)

	Very very noticable.
	Lowers resistance tremendously.
	No changes to stage speed.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Deals brute damage over time.

//////////////////////////////////////
*/

/datum/symptom/flesh_eating

	name = "Necrotizing Fasciitis"
	desc = "The virus aggressively attacks body cells, necrotizing tissues and organs."
	stealth = -3
	resistance = -4
	stage_speed = 0
	transmittable = -4
	level = 6
	severity = 4
	base_message_chance = 50
	symptom_delay_min = 15
	symptom_delay_max = 60
	var/bleed = FALSE
	var/pain = FALSE
	threshold_desc = "<b>Resistance 7:</b> Host will bleed profusely during necrosis.<br>\
					  <b>Transmission 8:</b> Causes extreme pain to the host, weakening it."

/datum/symptom/flesh_eating/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["resistance"] >= 7) //extra bleeding
		bleed = TRUE
	if(A.properties["transmittable"] >= 8) //extra stamina damage
		pain = TRUE

/datum/symptom/flesh_eating/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2,3)
			if(prob(base_message_chance))
				to_chat(M, "<span class='warning'>[pick("You feel a sudden pain across your body.", "Drops of blood appear suddenly on your skin.")]</span>")
		if(4,5)
			to_chat(M, "<span class='userdanger'>[pick("You cringe as a violent pain takes over your body.", "It feels like your body is eating itself inside out.", "IT HURTS.")]</span>")
			Flesheat(M, A)

/datum/symptom/flesh_eating/proc/Flesheat(mob/living/M, datum/disease/advance/A)
	var/get_damage = rand(15,25) * power
	M.take_overall_damage(brute = get_damage, required_status = BODYPART_ORGANIC)
	if(pain)
		M.adjustStaminaLoss(get_damage * 2)
	if(bleed)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.bleed_rate += 5 * power
	return 1

/*
//////////////////////////////////////

Autophagocytosis (AKA Programmed mass cell death)

	Very noticable.
	Lowers resistance.
	Fast stage speed.
	Decreases transmittablity.
	Fatal Level.

Bonus
	Deals brute damage over time.

//////////////////////////////////////
*/

/datum/symptom/flesh_death

	name = "Autophagocytosis Necrosis"
	desc = "The virus rapidly consumes infected cells, leading to heavy and widespread damage. Contains dormant prions- expert virologists believe it to be the precursor to Romerol, though the mechanism through which they are activated is largely unknown"
	stealth = -2
	resistance = -2
	stage_speed = 1
	transmittable = -2
	level = 9
	severity = 5
	base_message_chance = 50
	symptom_delay_min = 3
	symptom_delay_max = 6
	var/chems = FALSE
	var/zombie = FALSE
	threshold_desc = "<b>Stage Speed 7:</b> Synthesizes Heparin and Lipolicide inside the host, causing increased bleeding and hunger.<br>\
					  <b>Stealth 5:</b> The symptom remains hidden until active."

/datum/symptom/flesh_death/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stealth"] >= 5)
		suppress_warning = TRUE
	if(A.properties["stage_rate"] >= 7) //bleeding and hunger
		chems = TRUE
	if((A.properties["stealth"] >= 2) && (A.properties["stage_rate"] >= 12))
		zombie = TRUE

/datum/symptom/flesh_death/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2,3)
			if(MOB_UNDEAD in M.mob_biotypes)//i dont wanna do it like this but i gotta
				return
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='warning'>[pick("You feel your body break apart.", "Your skin rubs off like dust.")]</span>")
		if(4,5)
			Flesh_death(M, A)
			if(MOB_UNDEAD in M.mob_biotypes) //ditto
				return
			if(prob(base_message_chance / 2)) //reduce spam
				to_chat(M, "<span class='userdanger'>[pick("You feel your muscles weakening.", "Some of your skin detaches itself.", "You feel sandy.")]</span>")
		
/datum/symptom/flesh_death/proc/Flesh_death(mob/living/M, datum/disease/advance/A)
	var/get_damage = rand(6,10)
	if(MOB_UNDEAD in M.mob_biotypes)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/S = H.dna.species
			if(zombie && istype(S, /datum/species/zombie/infectious) && !istype(S, /datum/species/zombie/infectious/fast))
				H.set_species(/datum/species/zombie/infectious/fast)
				to_chat(M, "<span class='warning'>Your extraneous flesh sloughs off, giving you a boost of speed at the cost of a bit of padding!</span>")
			else if(prob(base_message_chance))
				to_chat(M, "<span class='warning'>Your body slowly decays... luckily, you're already dead!</span>")
		return //this symptom wont work on the undead.
	M.take_overall_damage(brute = get_damage, required_status = BODYPART_ORGANIC)
	if(chems)
		M.reagents.add_reagent_list(list(/datum/reagent/toxin/heparin = 2, /datum/reagent/toxin/lipolicide = 2))
	if(zombie)
		if(ishuman(A.affected_mob))
			if(!A.affected_mob.getorganslot(ORGAN_SLOT_ZOMBIE))
				var/obj/item/organ/zombie_infection/ZI = new()
				ZI.Insert(M)
	return 1
