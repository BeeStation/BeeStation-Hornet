//does toxin damage, hallucination, targets think they're not hurt at all
/datum/blobstrain/reagent/regenerative_materia
	name = "Regenerative Materia"
	description = "will do toxin damage and cause targets to believe they are fully healed."
	analyzerdescdamage = "Does toxin damage and injects a toxin that causes the target to believe they are fully healed."
	color = "#A88FB7"
	complementary_color = "#AF7B8D"
	message_living = ", and you feel <i>alive</i>"
	reagent = /datum/reagent/blob/regenerative_materia
	point_rate_bonus = 1

/datum/reagent/blob/regenerative_materia
	name = "Regenerative Materia"
	taste_description = "heaven"
	color = "#A88FB7"
	chemical_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN

/datum/reagent/blob/regenerative_materia/expose_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(iscarbon(M))
		M.adjust_drugginess(reac_volume * 2 SECONDS)
	if(M.reagents)
		M.reagents.add_reagent(/datum/reagent/blob/regenerative_materia, 0.2*reac_volume)
		M.reagents.add_reagent(/datum/reagent/toxin/spore, 0.2*reac_volume)
	M.apply_damage(0.7*reac_volume, TOX)

/datum/reagent/blob/regenerative_materia/on_mob_life(mob/living/carbon/metabolizer, delta_time, times_fired)
	. = ..()
	if(metabolizer.adjustToxLoss(1 * REM * delta_time, updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/blob/regenerative_materia/on_mob_metabolize(mob/living/metabolizer)
	. = ..()
	metabolizer.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/reagent/blob/regenerative_materia/on_mob_end_metabolize(mob/living/metabolizer)
	. = ..()
	metabolizer.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
