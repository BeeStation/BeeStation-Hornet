/*
//////////////////////////////////////

Necrotizing Fasciitis (AKA Flesh-Eating Disease)

	Very very noticeable.
	Lowers resistance tremendously.
	No changes to stage speed.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Deals brute damage over time.

//////////////////////////////////////
*/

/datum/symptom/flesh_eating

	name = "Hemorrhaging Fasciitis"
	desc = "The virus aggressively attacks the skin and blood, leading to extreme bleeding."
	stealth = -3
	resistance = -2
	stage_speed = 0
	transmission = -1
	level = 7
	severity = 4
	base_message_chance = 50
	symptom_delay_min = 15
	symptom_delay_max = 60
	prefixes = list("Bloody ", "Hemo")
	bodies = list("Hemophilia")
	var/bleed = FALSE
	var/damage = FALSE
	threshold_desc = "<b>Resistance 10:</b> The host takes brute damage as their flesh is burst open<br>\
						<b>Transmission 8:</b> The host will bleed far more violently, losing even more blood, and spraying infected blood everywhere."

/datum/symptom/flesh_eating/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 10) //extra bleeding
		damage = TRUE
	if(A.transmission >= 8)
		power = 2
		bleed = TRUE

/datum/symptom/flesh_eating/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2,3)
			if(prob(base_message_chance) && M.stat != DEAD)
				to_chat(M, span_warning("[pick("You feel a sudden pain across your body.", "Drops of blood appear suddenly on your skin.")]"))
		if(4,5)
			if(M.stat != DEAD)
				to_chat(M, span_userdanger("[pick("You cringe as a violent pain takes over your body.", "It feels like your body is eating itself inside out.", "IT HURTS.")]"))
			Flesheat(M, A)

/datum/symptom/flesh_eating/proc/Flesheat(mob/living/M, datum/disease/advance/A)
	if(damage)
		M.take_overall_damage(brute = rand(15,25), required_bodytype = BODYTYPE_ORGANIC)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	H.add_bleeding(BLEED_SURFACE)
	H.add_splatter_floor(H.loc)
	if(bleed) // this is really, really messy
		var/geysers = rand(2, 6)
		var/bloodsplatters = transmission
		var/list/geyserdirs = GLOB.alldirs.Copy()
		var/turf/T = H.loc
		playsound(T, 'sound/effects/splat.ogg', 50, 1)
		H.visible_message(span_danger("Blood bursts from [H]'s flesh!"), \
	span_userdanger("Blood spews forth from your flesh! It hurts!"))
		for(var/i in 0 to geysers)
			var/geyserdir = pick_n_take(geyserdirs)
			var/geyserdist = rand(1, max(1,bloodsplatters))
			bloodsplatters -= geyserdist
			new /obj/effect/temp_visual/dir_setting/bloodsplatter(T, geyserdir)
			for(var/a in 0 to geyserdist)
				T = get_step(T, geyserdir)
				H.add_splatter_floor(T)
			T = H.loc
	return TRUE

/*
//////////////////////////////////////

Autophagocytosis (AKA Programmed mass cell death)

	Very noticeable.
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
	transmission = -2
	level = 9
	severity = 5
	base_message_chance = 50
	symptom_delay_min = 3
	symptom_delay_max = 6
	prefixes = list("Necrotic ", "Necro")
	suffixes = list(" Rot")
	var/chems = FALSE
	var/zombie = FALSE
	threshold_desc = "<b>Stage Speed 7:</b> Synthesizes Heparin and Lipolicide inside the host, causing increased bleeding and hunger.<br>\
						<b>Stealth 5:</b> The symptom remains hidden until active."


/datum/symptom/flesh_death/severityset(datum/disease/advance/A)
	. = ..()
	if(((A.stealth >= 2) && (A.stage_rate >= 12) && CONFIG_GET(flag/special_symptom_thresholds)) || A.event)
		bodies = list("Zombie")

/datum/symptom/flesh_death/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 5)
		suppress_warning = TRUE
	if(A.stage_rate >= 7) //bleeding and hunger
		chems = TRUE
	if(((A.stealth >= 2) && (A.stage_rate >= 12) && CONFIG_GET(flag/special_symptom_thresholds)) || A.event)
		zombie = TRUE

/datum/symptom/flesh_death/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2,3)
			if(M.mob_biotypes & MOB_UNDEAD)//i dont wanna do it like this but i gotta
				return
			if(prob(base_message_chance) && !suppress_warning && M.stat != DEAD)
				to_chat(M, span_warning("[pick("You feel your body break apart.", "Your skin rubs off like dust.")]"))
		if(4,5)
			Flesh_death(M, A)
			if(M.mob_biotypes & MOB_UNDEAD) //ditto
				return
			if(prob(base_message_chance / 2) && M.stat != DEAD) //reduce spam
				to_chat(M, span_userdanger("[pick("You feel your muscles weakening.", "Some of your skin detaches itself.", "You feel sandy.")]"))

/datum/symptom/flesh_death/proc/Flesh_death(mob/living/M, datum/disease/advance/A)
	var/get_damage = rand(6,10)
	if(M.mob_biotypes & MOB_UNDEAD)
		return //this symptom wont work on the undead.
	M.take_overall_damage(brute = get_damage, required_bodytype = BODYTYPE_ORGANIC)
	if(chems)
		M.reagents.add_reagent_list(list(/datum/reagent/toxin/heparin = 2, /datum/reagent/toxin/lipolicide = 2))
	if(zombie)
		if(ishuman(A.affected_mob))
			if(!A.affected_mob.get_organ_slot(ORGAN_SLOT_ZOMBIE))
				var/obj/item/organ/zombie_infection/virus/ZI = new()
				ZI.Insert(M)
	return 1
