/*
//////////////////////////////////////

Vomiting

	Very very noticeable.
	Decreases resistance.
	Doesn't increase stage speed.
	Little transmissibility.
	Medium Level.

Bonus
	Forces the affected mob to vomit!
	Meaning your disease can spread via
	people walking on vomit.
	Makes the affected mob lose nutrition and
	heal toxin damage.

//////////////////////////////////////
*/

/datum/symptom/vomit

	name = "Vomiting"
	desc = "The virus causes nausea and irritates the stomach, causing occasional vomit."
	stealth = -2
	resistance = 0
	stage_speed = 1
	transmission = 2
	level = 3
	severity = 1
	base_message_chance = 100
	symptom_delay_min = 25
	symptom_delay_max = 80
	prefixes = list("Digestive ")
	bodies = list("Vomit")
	suffixes = list(" Emission")
	threshold_desc = "<b>Stage Speed 5:</b> Host will vomit blood, causing internal damage.<br>\
						<b>Transmission 6:</b> Host will projectile vomit, increasing vomiting range.<br>\
						<b>Stealth 4:</b> The symptom remains hidden until active."

	var/vomit_nebula = FALSE
	var/vomit_blood = FALSE
	var/proj_vomit = 0

/datum/symptom/vomit/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 4)
		suppress_warning = TRUE
	if(A.stage_rate >= 5) //blood vomit
		vomit_blood = TRUE
	if(A.transmission >= 6) //projectile vomit
		proj_vomit = 5

/datum/symptom/vomit/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(M.stat == DEAD)
		return
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, span_warning("[pick("You feel nauseated.", "You feel like you're going to throw up!")]"))
		else
			vomit(M)

/datum/symptom/vomit/proc/vomit(mob/living/carbon/vomiter)
	var/deductable_nutrition = 0
	var/constructed_flags = (MOB_VOMIT_MESSAGE | MOB_VOMIT_HARM)
	var/type_of_vomit = /obj/effect/decal/cleanable/vomit/toxic
	if(vomit_nebula)
		type_of_vomit = /obj/effect/decal/cleanable/vomit/nebula
		deductable_nutrition = 10
	else
		constructed_flags |= MOB_VOMIT_STUN
		deductable_nutrition = 20

	if(vomit_blood)
		constructed_flags |= MOB_VOMIT_BLOOD

	vomiter.vomit(vomit_flags = constructed_flags, vomit_type = type_of_vomit, lost_nutrition = deductable_nutrition, distance = proj_vomit)

/datum/symptom/vomit/nebula
	name = "Nebula Vomiting"
	desc = "The condition irritates the stomach, causing occasional vomit with stars that does not stun."
	vomit_nebula = TRUE
	naturally_occuring = FALSE
