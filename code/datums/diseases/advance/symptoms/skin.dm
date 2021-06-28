/*
//////////////////////////////////////
Vitiligo

	Hidden.
	No change to resistance.
	Increases stage speed.
	Slightly increases transmittability.
	Critical Level.

BONUS
	Makes the mob lose skin pigmentation.

//////////////////////////////////////
*/

/datum/symptom/vitiligo

	name = "Vitiligo"
	desc = "The virus destroys skin pigment cells, causing rapid loss of pigmentation in the host."
	stealth = 2
	resistance = 0
	stage_speed = 3
	transmission = 1
	level = 5
	severity = 0
	symptom_delay_min = 25
	symptom_delay_max = 75
	var/cachedcolor = null

/datum/symptom/vitiligo/Start(datum/disease/advance/A)
	. = ..()
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna.species.use_skintones)
			cachedcolor = H.skin_tone
		else if(MUTCOLORS in H.dna.species.species_traits)
			cachedcolor	= H.dna.features["mcolor"]

/datum/symptom/vitiligo/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.skin_tone == "albino")
			return
		if(H.dna.features["mcolor"] == "EEE")
			return
		switch(A.stage)
			if(5)
				if(H.dna.species.use_skintones)
					H.skin_tone = "albino"
				else if(MUTCOLORS in H.dna.species.species_traits)
					H.dna.features["mcolor"] = "EEE" //pure white.
				H.regenerate_icons()
			else
				H.visible_message("<span class='notice'>[H] looks a bit pale.</span>", "<span class='notice'>Your skin suddenly appears lighter.</span>")

/datum/symptom/vitiligo/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna.species.use_skintones)
			H.skin_tone = cachedcolor
		else if(MUTCOLORS in H.dna.species.species_traits)
			H.dna.features["mcolor"] = cachedcolor
		H.regenerate_icons()

/*
//////////////////////////////////////
Revitiligo

	Slightly noticable.
	Increases resistance.
	Increases stage speed slightly.
	Increases transmission.
	Critical Level.

BONUS
	Makes the mob gain skin pigmentation.

//////////////////////////////////////
*/

/datum/symptom/revitiligo
	name = "Revitiligo"
	desc = "The virus causes increased production of skin pigment cells, making the host's skin grow darker over time."
	stealth = 1
	resistance = 2
	stage_speed = 1
	transmission = 2
	level = 5
	severity = 0
	symptom_delay_min = 7
	symptom_delay_max = 14
	var/cachedcolor = null

/datum/symptom/revitiligo/Start(datum/disease/advance/A)
	. = ..()
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna.species.use_skintones)
			cachedcolor = H.skin_tone
		else if(MUTCOLORS in H.dna.species.species_traits)
			cachedcolor	= H.dna.features["mcolor"]

/datum/symptom/revitiligo/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.skin_tone == "african2")
			return
		if(H.dna.features["mcolor"] == "000")
			return
		switch(A.stage)
			if(5)
				if(H.dna.species.use_skintones)
					H.skin_tone = "african2"
				else if(MUTCOLORS in H.dna.species.species_traits)
					H.dna.features["mcolor"] = "000" //pure black.
				H.regenerate_icons()
			else
				H.visible_message("<span class='notice'>[H] looks a bit dark.</span>", "<span class='notice'>Your skin suddenly appears darker.</span>")

/datum/symptom/revitiligo/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna.species.use_skintones)
			H.skin_tone = cachedcolor
		else if(MUTCOLORS in H.dna.species.species_traits)
			H.dna.features["mcolor"] = cachedcolor
		H.regenerate_icons()

/*
//////////////////////////////////////
Polyvitiligo

	Not Noticeable.
	Increases resistance slightly.
	Increases stage speed.
	Transmittable.
	Low Level.

BONUS
	Makes the host change color

//////////////////////////////////////
*/

/datum/symptom/polyvitiligo
	name = "Polyvitiligo"
	desc = "The virus replaces the melanin in the skin with reactive pigment."
	stealth = 0
	resistance = 1
	stage_speed = 4
	transmission = 1
	level = 0
	severity = 0
	base_message_chance = 50
	symptom_delay_min = 45
	symptom_delay_max = 90

/datum/symptom/polyvitiligo/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(5)
			var/static/list/banned_reagents = list(/datum/reagent/colorful_reagent/powder/invisible, /datum/reagent/colorful_reagent/powder/white)
			var/color = pick(subtypesof(/datum/reagent/colorful_reagent/powder) - banned_reagents)
			if(M.reagents.total_volume <= (M.reagents.maximum_volume/10)) // no flooding humans with 1000 units of colorful reagent
				M.reagents.add_reagent(color, 5)
		else
			if (prob(50)) // spam
				M.visible_message("<span class='notice'>[M] looks rather vibrant.</span>", "<span class='notice'>The colors, man, the colors.</span>")

/************************************
Dermagraphic Ovulogenesis

	Extremely Noticeable
	Increases resistance slightly.
	Not Fast, Not Slow
	Transmittable.
	High Level

BONUS
	Provides Brute Healing when Egg Sacs/Eggs are eaten, simultaneously infecting anyone who eats them

***********************************/
/datum/symptom/skineggs //Thought Exolocomotive Xenomitosis was a weird symptom? Well, this is about 10x weirder.
	name = "Dermagraphic Ovulogenesis"
	desc = "The virus causes the host to grow egg-like nodules on their skin, which periodically fall off and contain the disease and some healing chemicals."
	stealth = -3 //You are basically growing these weird Egg shits on your skin, this is not stealthy in the slightest
	resistance = 1
	stage_speed = 0
	transmission = 2 //The symptom is in it of itself meant to spread
	level = 9
	severity = -1
	base_message_chance = 50
	symptom_delay_min = 60
	symptom_delay_max = 105
	var/big_heal
	var/all_disease
	var/eggsplosion
	var/sneaky
	threshold_desc = "<b>Transmission 12:</b> Eggs and Egg Sacs contain all diseases on the host, instead of just the disease containing the symptom.<br>\
					  <b>Transmission 16:</b> Egg Sacs will 'explode' into eggs after a period of time, covering a larger area with infectious matter.<br>\
					  <b>Resistance 10:</b> Eggs and Egg Sacs contain more healing chems.<br>\
					  <b>Stealth 6:</b> Eggs and Egg Sacs become nearly transparent, making them more difficult to see.<br>\
					  <b>Stage Speed 10:</b> Egg Sacs fall off the host more frequently."

/datum/symptom/skineggs/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 10)
		severity -= 1
	if(A.transmission >= 12)
		severity += 1
		if(A.transmission >= 16)
			severity += 1
	if(A.stealth >= 6)
		severity += 1

/datum/symptom/skineggs/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 10)
		big_heal = TRUE
	if(A.transmission >= 12)
		all_disease = TRUE
		if(A.transmission >= 16)
			eggsplosion = TRUE //Haha get it?
	if(A.stealth >= 6)
		sneaky = TRUE
	if(A.stage_rate >= 10)
		symptom_delay_min -= 10
		symptom_delay_max -= 20


/datum/symptom/skineggs/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	var/list/diseases = list(A)
	switch(A.stage)
		if(5)
			if(all_disease)
				for(var/datum/disease/D in M.diseases)
					if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS) || (D.spread_flags & DISEASE_SPREAD_FALTERED))
						continue
					if(D == A)
						continue
					diseases += D
			new /obj/item/reagent_containers/food/snacks/eggsac(M.loc, diseases, eggsplosion, sneaky, big_heal)

#define EGGSPLODE_DELAY 100 SECONDS
/obj/item/reagent_containers/food/snacks/eggsac
	name = "Fleshy Egg Sac"
	desc = "A small Egg Sac which appears to be made out of someone's flesh!"
	customfoodfilling = FALSE //Not Used For Filling
	icon = 'icons/obj/food/food.dmi'
	icon_state = "eggsac"
	bitesize = 4
	var/list/diseases = list()
	var/sneaky_egg
	var/big_heal

//Constructor
/obj/item/reagent_containers/food/snacks/eggsac/New(loc, var/list/disease, var/eggsplodes, var/sneaky, var/large_heal)
	..()
	for(var/datum/disease/D in disease)
		diseases += D
	if(large_heal)
		reagents.add_reagent_list(list(/datum/reagent/medicine/bicaridine = 20, /datum/reagent/medicine/tricordrazine = 10))
		reagents.add_reagent(/datum/reagent/blood, 10, diseases)
		big_heal = TRUE
	else
		reagents.add_reagent_list(list(/datum/reagent/medicine/bicaridine = 10, /datum/reagent/medicine/tricordrazine = 10))
		reagents.add_reagent(/datum/reagent/blood, 15, diseases)
	if(sneaky)
		icon_state = "eggsac-sneaky"
		sneaky_egg = sneaky
	if(eggsplodes)
		addtimer(CALLBACK(src, .proc/eggsplode), EGGSPLODE_DELAY)
	if(LAZYLEN(diseases))
		AddComponent(/datum/component/infective, diseases)

#undef EGGSPLODE_DELAY

/obj/item/reagent_containers/food/snacks/eggsac/proc/eggsplode()
	for(var/i = 1, i <= rand(4,8), i++)
		var/list/directions = GLOB.alldirs
		var/obj/item/I = new /obj/item/reagent_containers/food/snacks/fleshegg(src.loc, diseases, sneaky_egg, big_heal)
		var/turf/thrown_at = get_ranged_target_turf(I, pick(directions), rand(2, 4))
		I.throw_at(thrown_at, rand(2,4), 4)

/obj/item/reagent_containers/food/snacks/fleshegg
	name = "Fleshy Egg"
	desc = "An Egg which appears to be made out of someone's flesh!"
	customfoodfilling = FALSE //Not Used For Filling
	icon = 'icons/obj/food/food.dmi'
	icon_state = "fleshegg"
	bitesize = 1
	var/list/diseases = list()

/obj/item/reagent_containers/food/snacks/fleshegg/New(loc, var/list/disease, var/sneaky, var/large_heal)
	..()
	for(var/datum/disease/D in disease)
		diseases += D
	if(large_heal)
		reagents.add_reagent_list(list(/datum/reagent/medicine/bicaridine = 20, /datum/reagent/medicine/tricordrazine = 10))
		reagents.add_reagent(/datum/reagent/blood, 10, diseases)
	else
		reagents.add_reagent_list(list(/datum/reagent/medicine/bicaridine = 10, /datum/reagent/medicine/tricordrazine = 10))
		reagents.add_reagent(/datum/reagent/blood, 15, diseases)
	if(sneaky)
		icon_state = "fleshegg-sneaky"
	if(LAZYLEN(diseases))
		AddComponent(/datum/component/infective, diseases)
