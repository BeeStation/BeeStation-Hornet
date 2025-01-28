//does toxin damage, hallucination, targets think they're not hurt at all
/datum/blobstrain/reagent/regenerative_materia
	name = "Regenerative Materia"
	description = "will do toxin damage and cause targets to believe they are fully healed."
	analyzerdescdamage = "Does toxin damage and injects a toxin that causes the target to believe they are fully healed."
	color = "#A88FB7"
	complementary_color = "#AF7B8D"
	message_living = ", and you feel <i>alive</i>"
	reagent = /datum/reagent/blob/regenerative_materia

/datum/reagent/blob/regenerative_materia
	name = "Regenerative Materia"
	taste_description = "heaven"
	color = "#A88FB7"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN

/datum/reagent/blob/regenerative_materia/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	reac_volume = ..()
	exposed_mob.adjust_drugginess(reac_volume)
	if(exposed_mob.reagents)
		exposed_mob.reagents.add_reagent(/datum/reagent/blob/regenerative_materia, 0.2*reac_volume)
		exposed_mob.reagents.add_reagent(/datum/reagent/toxin/spore, 0.2*reac_volume)
	exposed_mob.apply_damage(0.7*reac_volume, TOX)

/datum/reagent/blob/regenerative_materia/on_mob_life(mob/living/carbon/C)
	C.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER)
	C.hal_screwyhud = SCREWYHUD_HEALTHY //fully healed, honest
	..()

/datum/reagent/blob/regenerative_materia/on_mob_end_metabolize(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/N = M
		N.hal_screwyhud = 0
	..()
