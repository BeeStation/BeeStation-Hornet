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
	transmittable = 1
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
	transmittable = 2
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
	transmittable = 1
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
