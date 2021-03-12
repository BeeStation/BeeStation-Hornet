/datum/disease/corona
	name = "Severe acute respiratory syndrome coronavirus 2"
	max_stages = 5
	spread_text = "Airborne"
	cure_text = "Perfluorodecalin"
	cures = list(/datum/reagent/medicine/perfluorodecalin)
	cure_chance = 10
	agent = "SARS-CoV-2"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	permeability_mod = 0.75
	desc = "Attacks the respiratory system. Early stage symptoms are similar to the common flu, however if left untreated it will damage the lungs."
	severity = DISEASE_SEVERITY_HARMFUL

/datum/disease/corona/stage_act()
	..()
	switch(stage)
		if(2)
			if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(20))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your muscles ache.</span>")
				if(prob(20))
					affected_mob.take_bodypart_damage(1)
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()

		if(3)
			if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(15))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your muscles ache.</span>")
				if(prob(20))
					affected_mob.take_bodypart_damage(1)
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()
		if(4)
			if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(20))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You have trouble breathing.</span>")
				if(prob(15))
					affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, 1, 170)
					affected_mob.updatehealth()
					affected_mob.adjustOxyLoss(2)
					affected_mob.emote("gasp")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()
		if(5)
			if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(20))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You have trouble breathing.</span>")
				if(prob(15))
					affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, 3, 190)
					affected_mob.updatehealth()
					affected_mob.adjustOxyLoss(2)
					affected_mob.emote("gasp")
			if(prob(3))
				to_chat(affected_mob, "<span class ='danger'>Your lung feels like it is filled with razors! There is no air!</span")
					affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, 20, 200)
					affected_mob.updatehealth()
					affected_mob.adjustOxyLoss(10)
					affected_mob.emote("gag")
	return
