/datum/action/changeling/resonant_shriek
	name = "Resonant Shriek"
	desc = "Our lungs and vocal cords shift, allowing us to briefly emit a noise that deafens and confuses the weak-minded. Costs 30 chemicals."
	helptext = "Emits a high-frequency sound that confuses and deafens humans, blows out nearby lights and overloads cyborg sensors."
	button_icon_state = "resonant_shriek"
	chemical_cost = 30
	dna_cost = 2
	req_human = TRUE

//A flashy ability, good for crowd control and sowing chaos.
/datum/action/changeling/resonant_shriek/sting_action(mob/living/user)
	..()
	for(var/mob/living/M in hearers(4, user))
		if(iscarbon(M) && M.get_ear_protection() <= 0)
			var/mob/living/carbon/C = M
			if(!C.mind || !C.mind.has_antag_datum(/datum/antagonist/changeling))
				var/obj/item/organ/ears/ears = C.get_organ_slot(ORGAN_SLOT_EARS)
				if(ears)
					ears.adjustEarDamage(0, 30)
				C.adjust_confusion(15 SECONDS)
				C.set_jitter_if_lower(40 SECONDS)
			else
				SEND_SOUND(C, sound('sound/effects/screech.ogg'))

		if(issilicon(M))
			SEND_SOUND(M, sound('sound/weapons/flash.ogg'))
			M.Paralyze(rand(75,150))

	for(var/obj/machinery/light/L in range(4, user))
		L.on = 1
		L.break_light_tube()
	return TRUE

/datum/action/changeling/dissonant_shriek
	name = "Dissonant Shriek"
	desc = "We shift our vocal cords to release a high-frequency sound that overloads nearby electronics. Costs 25 chemicals."
	button_icon_state = "dissonant_shriek"
	chemical_cost = 25
	dna_cost = 2

/datum/action/changeling/dissonant_shriek/sting_action(mob/living/user)
	..()
	for(var/obj/machinery/light/L in range(5, usr))
		L.on = 1
		L.break_light_tube()
	empulse(get_turf(user), 2, 3, 1)
	return TRUE
